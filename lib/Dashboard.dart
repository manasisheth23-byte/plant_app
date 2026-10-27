import 'dart:convert';
import 'dart:io' show File, Platform, WebSocket;

import 'package:erpflutter/Constants.dart';
import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/barcodescanner/view_models/barcoderegistration_viewmodel.dart';
import 'package:erpflutter/barcodescanner/views/assetbarcode.dart';
import 'package:erpflutter/barcodescanner/views/barcode_audit.dart';
import 'package:erpflutter/barcodescanner/views/barcode_physicalstock.dart';
import 'package:erpflutter/barcodescanner/views/barcode_register_view.dart';
import 'package:erpflutter/barcodescanner/views/barcoderegistration_view.dart';
import 'package:erpflutter/database/database_service.dart';
import 'package:erpflutter/models/getnotificationmodel.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/provider/financialyear_provider.dart';
import 'package:erpflutter/provider/get_notification_provider.dart';
import 'package:erpflutter/repository/LoginApiRepository.dart';
import 'package:erpflutter/screens/BarcodeQrcodeScanner/scanqr.dart';
import 'package:erpflutter/screens/FGQuality/FGQualityPage.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/activity/activity_list_screen.dart';
import 'package:erpflutter/screens/alerts/alerts_list.dart';
import 'package:erpflutter/screens/aprovals/approvals_list_screen.dart';
import 'package:erpflutter/screens/bireports/BoldReportList.dart';
import 'package:erpflutter/screens/bireports/BoldReportViewerScreenwithparam.dart';
import 'package:erpflutter/screens/businesspartner/business_partner_screen.dart';
import 'package:erpflutter/screens/ico_image.dart';
import 'package:erpflutter/screens/ico_writer.dart';
import 'package:erpflutter/screens/itemmaster/item_master_details.dart';
import 'package:erpflutter/screens/itemmaster/item_master_list.dart';
import 'package:erpflutter/screens/konowledgebase/knowyourproductscreen.dart';
import 'package:erpflutter/screens/login/login_controller.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/screens/plantlist/plantlist.dart';
import 'package:erpflutter/screens/report/report.dart';
import 'package:erpflutter/screens/salesorder/sales_order_screen.dart';
import 'package:erpflutter/screens/skupricelist/sku_pricelist.dart';
import 'package:erpflutter/screens/so_reports/so_reports_screen.dart';
import 'package:erpflutter/screens/supplier/supplier_screen.dart';
import 'package:erpflutter/utils/CommonUtils.dart';
import 'package:erpflutter/utils/loading_dialog.dart';
import 'package:erpflutter/widgets/drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:windows_taskbar/windows_taskbar.dart';
import '../../utils/SizeConfig.dart';
import 'app_config.dart';
import 'barcodescanner/views/asn_scanning.dart';
import 'barcodescanner/views/grn_broughtout_list.dart';
import 'barcodescanner/views/production_barcode.dart';
import 'helpers/api_helpers.dart';
import 'helpers/api_request.dart';
import 'models/FillStatusListRequestModel.dart';
import 'models/FillStatusListResponseModel.dart';
import 'models/GetDefaultValRequestModel.dart';
import 'models/GetDefaultValResponseModel.dart';
import 'models/add_so_request_model.dart';
import 'models/add_so_response_model.dart';
import 'models/sync_i_ledger_model.dart';
import 'models/sync_price_master_model.dart';
import 'screens/activity/activity_controller.dart';

import 'models/LoginResponseModel.dart';
import 'dart:ui' as ui;

class Dashboard extends StatefulWidget {

  Dashboard();

  @override
  _Dashboard createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> {
  GetDefaultValResponseModel? getdefaultvalresponsemodel;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  LoginResponseModel? loginResponseModel;
  SizeConfig sizeConfig = SizeConfig();
  MediaQueryData? _mediaQueryData;
  String? strUserName;
  String? strUserDesignation;
  SharedPreferences? prefs;
  String? strPriceMaster="01-Jan-1900 00:00:00";
  String? strSyncILedger="01-Jan-1900 00:00:00";
  _Dashboard();

  void check() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool value = prefs.getBool('open_notification_screen') ?? false;

    if(value){
      prefs.setBool('open_notification_screen', false);
      Get.to(AlertsList(showAppBar: true,loginResponseModel: loginResponseModel,));
    }




  }
  Future<String> createBadgeIcon(int count) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 64.0;

    // Background
    final paint = Paint()..color = Colors.red;
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2,
      paint,
    );

    // Text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData =
    await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final dir = await getTemporaryDirectory();

    // ✅ UNIQUE filename every time
    final icoPath =
        '${dir.path}/badge_icon_${DateTime.now().millisecondsSinceEpoch}.ico';

    final icoBytes = encodeIco([
      IcoImage(
        pngBytes,
        width: size.toInt(),
        height: size.toInt(),
      ),
    ]);

    final icoFile = File(icoPath);
    await icoFile.writeAsBytes(icoBytes, flush: true);

    return icoPath;
  }



  Uint8List encodeIco(List<IcoImage> images) {
    final writer = IcoWriter();
    return writer.encode(images);
  }
  void updateWindowsBadge(int badgeCount) async {
    if (badgeCount > 0) {
      final badgePath = await createBadgeIcon(badgeCount);

      WindowsTaskbar.setOverlayIcon(
        ThumbnailToolbarAssetIcon(badgePath),
        tooltip: '$badgeCount new notifications',
      );
    } else {
      WindowsTaskbar.resetOverlayIcon();
    }
  }
  int coloumncount =0;
  String? strUserID;
  Future<void> getNotificationCount() async {
    try {
      final notificationProvider = Provider.of<GetNotificationProvider>(context, listen: false);

      // Wait for data to be fetched
      await notificationProvider.GetNotification("0");

      // Safely access the list
      List<NitificationLIST> notifications =
          notificationProvider.getNotificationModel?.dATA?.lIST ?? [];

      // Sort unread first
      notifications.sort((a, b) {
        return (a.ISREAD == "0" ? 0 : 1).compareTo(b.ISREAD == "0" ? 0 : 1);
      });

      // Count unread
      Constant.unreadCount = notifications.where((item) => item.ISREAD == "0").length;
      final unreadProvider = Provider.of<UnreadNotificationProvider>(context, listen: false);
      unreadProvider.setUnreadCount(
        notifications.where((item) => item.ISREAD == "0").length,
      );
      /*if(Platform.isWindows){
        if(Constant.unreadCount! > 0){
          updateWindowsBadge(Constant.unreadCount!);
        }*/

      }catch (e) {
      print("Error fetching notification count: $e");
    }


      print("Unread count: $Constant.unreadCount");


    }
  Future<void> connectWebSocket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    strUserID = prefs.getString('USERID');
    // Check if already connected
    if (Constant.rawSocket != null &&
        Constant.rawSocket!.readyState == WebSocket.open) {
      print('WebSocket is already connected.');
      return;
    }

    // Close invalid or old connection
    if (Constant.rawSocket != null &&
        Constant.rawSocket!.readyState != WebSocket.closed) {
      print('Closing stale WebSocket connection...');
      await Constant.rawSocket!.close();
    }

    try {
      String wsUrl = AppConfig.RAW_BASE_URL.replaceFirst('http', 'ws');
      Constant.rawSocket = await WebSocket.connect(
          '$wsUrl/ERPAPI/WebSocketHandlerUserWise_API.ashx?USERID=$strUserID');

      print('WebSocket connected.'+'$wsUrl/ERPAPI/WebSocketHandlerUserWise_API.ashx?USERID=$strUserID');
      // Only assign _channel; do NOT call `.listen()` again here
      Constant.channel = IOWebSocketChannel(Constant.rawSocket!);
      Constant.channel!.stream.listen(
            (data) {
          print('Received: $data');
          getNotificationCount();
         /* Get.dialog(
            AlertDialog(
              title: Text('Notification' ),
              content: Text(data ?? 'No Body'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Get.back();

                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );*/
          // setState(() {

          //_updateBadge();
          //Constant.unreadCount!

          int readcount =Constant.unreadCount ?? 0;

          Constant.unreadCount=   Constant.unreadCount!+1;
          if(Constant.unreadCount! > 0){
            updateWindowsBadge(Constant.unreadCount!);
          }
          // updateWindowsBadge(Constant.unreadCount!);
          // });
        },
        onDone: () {
          print('WebSocket closed');
        },
        onError: (error) {
          print('WebSocket error: $error');
        },
      );
    } catch (e) {
      print('WebSocket connection error: $e');
    }
  }
  @override
  initState() {
    check();
    super.initState();
    /*SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);*/
    if (Platform.isWindows){
      coloumncount =8;
    }else{
      coloumncount =4;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserResponse();
      getNotificationCount();
      if(Platform.isWindows){
        connectWebSocket();
      }

      // Fetch barcode details when widget is initialized
    // _loadBarcodeData();
    });



  }
  // 👇 Function to call the same API with different flags
  Future<void> _loadBarcodeData() async {
    final provider = Provider.of<BarcodeProvider>(context, listen: false);

    try {

       await Future.wait([
         provider.fetchBarcodeDetails("1"),
         provider.fetchBarcodeDetails("2"),
       ]);
    } catch (e) {
      print("Error while loading barcode data: $e");
    }
  }
  void syncPriceMasterapicall() async
  {
    AlertDialog alert = AlertDialog(
      content: Row(children: [
        CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
        Container(
            margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
      ]),
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs = await SharedPreferences.getInstance();

    strPriceMaster = prefs.getString('PriceMastLastSyncDate');
    print('calling syncPriceMasterModel API');

    SyncPriceMasterModel syncPriceMasterModel =
    await Provider.of<LoginController>(context, listen: false)
        .syncPriceMasterData({
      "XMLFILE": {
        "FLAG": "1",
        "LASTSYNCDATE": strPriceMaster ?? "01-Jan-1900 00:00:00",
        "MID": "0",
        "ORGSTRUCTID": loginResponseModel!.data!.orgstrucid,
        "POSID": loginResponseModel!.data!.posid,
        "TOKEN": loginResponseModel!.data!.token.toString(),
        "USERID": loginResponseModel!.data!.userid
      }
    },context);

    if(syncPriceMasterModel != null)
    {
      if(syncPriceMasterModel.dATA != null)
      {
        if (prefs != null) {
          Navigator.pop(context);

          prefs.setString("PriceMastLastSyncDate", syncPriceMasterModel.dATA!.sYNCDATETIME ?? "01-Jan-1900 00:00:00" );
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SKUPriceList(),
          ));

        }
      }
    }
    print('Got syncPriceMasterModel data--->');
    await DatabaseService().insertOrUpdatePriseMaster(syncPriceMasterModel);


  }

  void SyncILedgerapicall() async
  {
    AlertDialog alert = AlertDialog(
      content: Row(children: [
        CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
        Container(
            margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
      ]),
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs = await SharedPreferences.getInstance();

    strSyncILedger = prefs.getString('SyncILedgerLastSyncDate');

    String? orStID = prefs.getString('ORGSTRUCTID');

    String? controlno = prefs.getString('CONTROLNO');
    SyncILedgerModel syncILedgerModel =
    await Provider.of<LoginController>(context, listen: false)
        .syncILedgerData({
      "XMLFILE": {
        "FLAG": "1",
        "LASTSYNCDATE": strSyncILedger ?? "01-Jan-1900 00:00:00",
        "MID": "0",
        "ORGSTRUCTID": orStID,
        "POSID": loginResponseModel!.data!.posid,
        "TOKEN": loginResponseModel!.data!.token.toString(),
        "USERID": loginResponseModel!.data!.userid,
        "CONTROLNO" : controlno,
      }
    },context);
    if(syncILedgerModel != null)
    {
      if(syncILedgerModel.dATA != null)
      {
        Navigator.pop(context);
        if (prefs != null) {


          prefs.setString("SyncILedgerLastSyncDate", syncILedgerModel.dATA!.sYNCDATETIME ?? "01-Jan-1900 00:00:00" );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InventoryListFragment()),
          );

        }
      }
    }
    print('Got syncILedgerModel data--->');
    await DatabaseService().insertOrUpdateILedger(syncILedgerModel);
  }
  FillStatusapicall(
      String strStatusId,
      String strTypeId,
      String strToken,
      String strUserId,
      String strOrgstuctid,
      String strPostId,
      String strMenuId,
      String strControlNo,
      String strPageno,
      String strTypeid) async {
    try {
      final LoginApiRepository _repository = LoginApiRepository();
      CommonUtils commonUtils = new CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {
        FillStatusListRequestModel fillstatusrequestmodel =
        FillStatusListRequestModel();
        fillstatusrequestmodel.xMLFILE = XMLFILEFILLSTATUS();
        fillstatusrequestmodel.xMLFILE!.dESC = "";
        fillstatusrequestmodel.xMLFILE!.fLAG = "0";
        fillstatusrequestmodel.xMLFILE!.sTATUSID = strStatusId;
        fillstatusrequestmodel.xMLFILE!.tOKEN = strToken;
        fillstatusrequestmodel.xMLFILE!.tYPEID = strTypeId;

        fillstatusrequestmodel.xMLFILE!.uSERID = int.tryParse(strUserId);

        FillStatusListResponseModel fillstatusresponsemodel =
        await _repository.FillStatusListData(fillstatusrequestmodel);

        if (fillstatusresponsemodel != null) {
          // setState(() {
          //   if(strTypeId == "117") {
          //     _asyncStatusDialog(
          //         context, fillstatusresponsemodel!.data!.list!, strTypeId, strToken, strUserId, strOrgstuctid, strPostId, strMenuId,strControlNo,
          //         strPageno, strStatusId, strTypeid);
          //   }else  if(strTypeId == "139")
          //   {
          //     _asyncTYpeDialog(
          //         context, fillstatusresponsemodel!.data!.list!, strTypeId, strToken, strUserId, strOrgstuctid, strPostId, strMenuId,strControlNo,
          //         strPageno, strStatusId, strTypeid);
          //   }
          // });
        } else {
          //for dissmiss progres dialog
        }
      } else {}
    } catch (error, stacktrace) {
      // print("Exception occured: $error stackTrace: $stacktrace");
    }
  }

  void getUserResponse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs = await SharedPreferences.getInstance();
    setState(() {
      loginResponseModel = LoginResponseModel.fromJson(
          jsonDecode(prefs.getString('LOGINRESPONSE') ?? ''))!;

    });

  }



  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      child: const Text("Yes"),
      onPressed: () async {
        prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLOGGEDIN", false);
          prefs!.setString("TOKEN", '');
        }
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Sign Out"),
      content: const Text("Are you sure you want to sign out!"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void printLargeString(String text) {
    const int chunkSize = 800; // Adjust chunk size based on your needs
    int startIndex = 0;
    while (startIndex < text.length) {
      int endIndex = startIndex + chunkSize;
      if (endIndex > text.length) {
        endIndex = text.length;
      }
      print(text.substring(startIndex, endIndex));
      startIndex = endIndex;
    }
  }

  Future<AddSoResponseModel> AddSODetails(AddSORequestModel data) async {
    showLoadingDialog(context);

    // AddSORequestModel addSORequestModel = await DatabaseService().postSO();

    try {
      String url = AppConfig.BASE_URL + AddSO!;
      var response =
      await ApiRequest.post(url: url, body: json.encode(data.toJson()));
      if (response.statusCode == 401) {}

      return AddSoResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // LoginResponseModel user = userProvider.loginResponseModel!;
    // print(user!.data!.username);
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    final selectedYear =
        context.read<FinancialYearProvider>().selectedYear;
    SizeConfig().init(context);
    _mediaQueryData = MediaQuery.of(context);
    final plantName = context.watch<PlantProvider>().plantName;

    return Consumer2<LoginController, UnreadNotificationProvider>(
        builder: (context, loginController, unreadProvider, _) {
      // LoginResponseModel user = userProvider.loginResponseModel!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if(Platform.isWindows){
              updateWindowsBadge(unreadProvider.unreadCount);
            }

          });
      return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[300],

      /*  appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: AppColors.APPCOLOR,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async{
              SharedPreferences prefs = await SharedPreferences.getInstance();

              String? orgId = prefs.getString("PLANTORGSTRUCTID");
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppShell(role: "Admin", plant: plantName)));
             // Navigator.push(context, MaterialPageRoute(builder: (context) => PlantListScreen(orgStrucId: orgId!,companyName:plantName)));
            },
          ),
          title: Text(plantName,style: GoogleFonts.lato(

            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(
                  selectedYear?.description ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
          *//* backgroundColor: Colors.black,*//*
        ),*/
        body: PopScope(
          canPop: true,
          child: Center(
            child: Container(
                width: isDesktop ? 700 : double.infinity,
              child: loginResponseModel == null
                  ? Center(child: CircularProgressIndicator())
                  : (loginResponseModel!.data!.menulist!.data.isEmpty)
                  ? Center(child: Text("No menu data found."))
                  :/* GridView.count(
                primary: false,
               padding: const EdgeInsets.all(14),

                  crossAxisCount: isDesktop ? 5 : 3,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  childAspectRatio: isDesktop ? 1.4 : 0.95,
                children:loginResponseModel!
                    .data!
                    .menulist!
                    .data[0]
                    .list
                    .map((menu) {
                  final menuColor = getMenuColor(menu.id);
                  return _tool(
                    menu.name ?? '',
                    getMenuAssetImage(menu.id,menuColor),
                    menuColor,
                        () => navigateFromMenu(menu.id),
                    badgeCount: menu.id == "644"
                        ? unreadProvider.unreadCount
                        : 0,
                  );
                }).toList(),
              )*/
             /* Center(
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      color:const Color(0xFFF5F7FB),
                      width: isDesktop ? 700 : double.infinity,
                      padding: const EdgeInsets.all(10),
                      child:  ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: loginResponseModel!
                    .data!
                    .menulist!
                    .data[0]
                    .list
                    .length,
                itemBuilder: (context, index) {
                  final menu = loginResponseModel!
                      .data!
                      .menulist!
                      .data[0]
                      .list[index];

                  final menuColor = getMenuColor(menu.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: _tool(
                      menu.name ?? '',
                      getMenuAssetImage(menu.id, menuColor),
                      menuColor,
                          () => navigateFromMenu(menu.id),
                      badgeCount: menu.id == "644"
                          ? unreadProvider.unreadCount
                          : 0,
                    ),
                  );
                },
              ))),*/
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 6 : 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio:isDesktop? 0.95 : 0.95,
                  ),
                  itemCount: loginResponseModel!.data!.menulist!.data[0].list.length,
                  itemBuilder: (context, index) {
                    final menu = loginResponseModel!
                        .data!
                        .menulist!
                        .data[0]
                        .list[index];

                    final menuColor = getMenuColor(menu.id);

                    return _tool(
                      menu.name ?? '',
                      getMenuAssetImage(menu.id, menuColor),
                      menuColor,
                          () => navigateFromMenu(menu.id),
                      badgeCount:
                      menu.id == "644" ? unreadProvider.unreadCount : 0,
                    );
                  },
                ),
              )
            ),
          ),
        ),
      );
    });
  }
  Color getMenuColor(String? id) {
    switch (id) {
      case "644":
        return C.red;
      case "645":
        return Colors.green;
      case "16":
        return Colors.orange;
      case "647":
        return Colors.purple;
      default:
        return C.blue;
    }
  }
  Widget _tool(
      String label,
      Widget icon,
      Color color,
      VoidCallback onTap, {
        int badgeCount = 0,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: C.line),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF12426E).withOpacity(.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withOpacity(.12),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: icon,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: body(
                        12,
                        w: FontWeight.w600,
                        c: C.deep,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (badgeCount > 0)
            Positioned(
              top: 22,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$badgeCount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
/*  Widget _tool(
      String label,
      Widget icon,
      Color color,
      VoidCallback onTap, {
        int badgeCount = 0,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.line),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF12426E).withOpacity(.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withOpacity(.13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: icon,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                label,
                style: body(
                  14,
                  w: FontWeight.w600,
                  c: C.deep,
                ),
              ),
            ),

            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(width: 10),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }*/
 /* Widget _tool(
      String label,
      Widget icon,
      Color color,
      VoidCallback onTap, {
        int badgeCount = 0,
      }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: C.line),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF12426E).withOpacity(.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withOpacity(.13),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: icon,
              ),
              const SizedBox(height: 7),

              Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: body(
                        11,
                        w: FontWeight.w600,
                        c: C.deep,
                      ),
                    ),
                  ),

                  if (badgeCount > 0)
                    Positioned(
                      top: -8,
                      right: -12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );*/
  Widget menuCard({
    required String title,
    required Widget icon,
    required VoidCallback onTap,
    int badgeCount = 0,
    Color color = C.blue,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.line),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF12426E).withOpacity(.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: icon,
            ),

            const SizedBox(height: 8),

            Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lato(
                      fontSize: Platform.isIOS ? 14 :11,
                      fontWeight: FontWeight.w600,
                      color: C.deep,
                    ),
                  ),
                ),

                if (badgeCount > 0)
                  Positioned(
                    top: -8,
                    right: -12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(minWidth: 18),
                      child: Text(
                        '$badgeCount',
                        textAlign: TextAlign.center,
                        style:  TextStyle(
                          color: Colors.white,
                          fontSize: Platform.isIOS ? 13 :10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 👇 This is like onResume in Android
      print("App Resumed");
      // Call your API or refresh data here
      getNotificationCount();
    } else if (state == AppLifecycleState.paused) {
      print("App Paused");
    }
  }
  GetDefaultValapicall(
      BuildContext context,
      String strMenuId,
      String strOrgStructId,
      String strPostId,
      String strToken,
      String strUserId) async {
    try {
      final LoginApiRepository _repository = LoginApiRepository();
      CommonUtils commonUtils = new CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {
        GetDefaultValRequestModel getvalrequestmodel =
        GetDefaultValRequestModel();
        getvalrequestmodel.xMLFILE = XMLFILEDEFAULTVAL();
        getvalrequestmodel.xMLFILE!.mENUID = strMenuId;
        getvalrequestmodel.xMLFILE!.oRGSTRUCID = strOrgStructId;
        getvalrequestmodel.xMLFILE!.pOSID = strPostId;
        getvalrequestmodel.xMLFILE!.tOKEN = strToken;
        getvalrequestmodel.xMLFILE!.uSERID = strUserId;
        getdefaultvalresponsemodel =
        await _repository.GetDefaultValData(getvalrequestmodel);
        if (getdefaultvalresponsemodel != null) {
          print(getdefaultvalresponsemodel!.data!.list![0].defdocid);
          //  Provider.of<FGQualityController>(context, listen: false).getdefuatVal("username",getdefaultvalresponsemodel);
          Provider.of<LoginController>(context, listen: false).getDefaultVal(
              strMenuId,
              getdefaultvalresponsemodel!.data!.list![0].defdocdesc!,
              getdefaultvalresponsemodel!.data!.list![0].defstatusdesc!,
              getdefaultvalresponsemodel!.data!.list![0].deftypedesc!,
              getdefaultvalresponsemodel,
              loginResponseModel);

          String _strSelectedTypeId =
          getdefaultvalresponsemodel!.data!.list![0].deftypeid!;
          String _strSelectedDocid =
          getdefaultvalresponsemodel!.data!.list![0].defdocid!;
          String _strSelectedStatusId =
          getdefaultvalresponsemodel!.data!.list![0].defstatusid!;

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FGQualityPage(
                  strDefaltDocType: getdefaultvalresponsemodel!
                      .data!.list![0].defdocdesc!,
                  strDefaultStatus: getdefaultvalresponsemodel!
                      .data!.list![0].defstatusdesc!,
                  strDefaultType: getdefaultvalresponsemodel!
                      .data!.list![0].deftypedesc!,
                  strSelectedDocid: _strSelectedDocid,
                  strSelectedStatusId: _strSelectedStatusId,
                  strSelectedTypeId: _strSelectedTypeId,
                )),
          );
        } else {}
      } else {}
    } catch (error, stacktrace) {}
  }

  // {ID: 647, NAME: Sync, MENUCODE: SYNC, SEQ: 27}

  void navigateFromMenu(String? id) {
    // if (loginResponseModel!.data!.menulist!.data[i].list[j].id != null &&
    //     loginResponseModel!.data!.menulist!.data[i].list[j].id == "250"){
    //
    //
    //   GetDefaultValapicall(context,loginResponseModel!.data!.menulist!.data![i].list![j].id!, loginResponseModel!.data!.orgstrucid,  loginResponseModel!.data!.posid,  loginResponseModel!.data!.token, loginResponseModel!.data!.userid);
    //
    // }else  if (loginResponseModel!.data!.menulist!.data[i].list[j].id != null &&
    //     loginResponseModel!.data!.menulist!.data[i].list[j].id == "29"){
    //
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => InventoryListFragment()),
    //   );
    //
    // }

    switch (id) {
      case "367":
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (context, animation, secondaryAnimation) =>
                ActivityListFragment(
                  loginResponseModel: loginResponseModel,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.0), // Slide from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
       /* Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ActivityListFragment(
                loginResponseModel: loginResponseModel,
              )),
        );*/
        break;
      case "200":
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (context, animation, secondaryAnimation) =>
                ApprovalsListFragment(
                  loginResponseModel: loginResponseModel,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
      /*  Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ApprovalsListFragment(
                loginResponseModel: loginResponseModel,
              )),
        );*/
        break;
      case "1111":
      //Barcode - Physical Stock
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (context, animation, secondaryAnimation) =>
            const PhysicalStock(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.0), // Slide from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
       /* Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PhysicalStock(
              )),
        );*/
        break;
      case "985":
      //Material Balance
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (context, animation, secondaryAnimation) =>
             BarcodeAuditScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.0), // Slide from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
       /* Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BarcodeAuditScreen(
              )),
        );*/
        break;
      case "984":
        //material issue
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (context, animation, secondaryAnimation) =>
            const BarcodeRegistrationView(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.0), // Slide from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
      /*  Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BarcodeRegistrationView(
              )),
        );*/
        break;
      case "983":
        //registration
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (context, animation, secondaryAnimation) =>
             BarcodeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.0), // Slide from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
      /*  Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BarcodeScreen(
              )),
        );*/
        break;
      case "1035":
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (context, animation, secondaryAnimation) =>
            const AssetbarcodeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.0), // Slide from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
      //registration
      /*  Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AssetbarcodeScreen(
              )),
        );*/
        break;

      case "645":
       /* Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BusinessPartnerScreen()),
        );*/
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (context, animation, secondaryAnimation) =>
            const BusinessPartnerScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.0), // Slide from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
        break;
        case "420":
       /* Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BusinessPartnerScreen()),
        );*/
     /*  Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ASNScanningScreen()),
        );*/
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 10),
              reverseTransitionDuration: const Duration(milliseconds: 10),
              pageBuilder: (context, animation, secondaryAnimation) =>
               ASNScanningScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.0), // Slide from right
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
            ),
          );
        break;
      case "92":
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (context, animation, secondaryAnimation) =>
             SoListScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.0), // Slide from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
       /* Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SoListScreen()),
        );*/
        break;
        case "95":
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 10),
              reverseTransitionDuration: const Duration(milliseconds: 10),
              pageBuilder: (context, animation, secondaryAnimation) =>
               GRNBroughtOutScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.0), // Slide from right
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
            ),
          );
       /* Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GRNBroughtOutScreen()),
        );*/
        break;
      case "29":

        SyncILedgerapicall();

        break;
      case "646":
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (context, animation, secondaryAnimation) =>
             Report(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.0), // Slide from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
       /* Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Report()),
        );*/
        break;
      case "313":
       /* Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SoReports()),
        );*/
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (context, animation, secondaryAnimation) =>
            const SoReports(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.0), // Slide from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
        break;
      case "293":
       /* Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BoldReportListScreen()),
        );*/
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (context, animation, secondaryAnimation) =>
             BoldReportListScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.0), // Slide from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
        break;
     /* case "377":

        syncPriceMasterapicall();

        break;*/

      case "16":
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (context, animation, secondaryAnimation) =>
            const SupplierScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.0), // Slide from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
      /*  Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SupplierScreen(),
        ));*/
        break;

      case "644":
        Provider.of<ActivityController>(
            context, listen: false).fetchData();
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (context, animation, secondaryAnimation) =>
                AlertsList(
                  loginResponseModel: loginResponseModel,
                  showAppBar: true,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.0), // Slide from right
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
          ),
        );
       /* Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AlertsList(loginResponseModel: loginResponseModel, showAppBar: true,),
        ));*/
        break;
 case "1564":
   Navigator.push(
     context,
     PageRouteBuilder(
       transitionDuration: const Duration(milliseconds: 10),
       reverseTransitionDuration: const Duration(milliseconds: 10),
       pageBuilder: (context, animation, secondaryAnimation) =>
           KnowYourProductScreen(
             text: "",
           ),
       transitionsBuilder:
           (context, animation, secondaryAnimation, child) {
         return SlideTransition(
           position: Tween<Offset>(
             begin: const Offset(0, 0.0), // Slide from right
             end: Offset.zero,
           ).animate(
             CurvedAnimation(
               parent: animation,
               curve: Curves.easeInOutCubic,
             ),
           ),
           child: FadeTransition(
             opacity: animation,
             child: child,
           ),
         );
       },
     ),
   );
   /*Navigator.push(
       context,
       MaterialPageRoute(
           builder: (context) =>
               KnowYourProductScreen(text: "",)));*/


   break;

     /* case "647":

        break;*/
    case "1034":
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 10),
          reverseTransitionDuration: const Duration(milliseconds: 10),
          pageBuilder: (context, animation, secondaryAnimation) =>
          const QRViewExample(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.0), // Slide from right
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                ),
              ),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        ),
      );
     /* Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  QRViewExample()));*/
        break;
   case "1583":
     Navigator.push(
       context,
       PageRouteBuilder(
         transitionDuration: const Duration(milliseconds: 10),
         reverseTransitionDuration: const Duration(milliseconds: 10),
         pageBuilder: (context, animation, secondaryAnimation) =>
         const ProductionBarcodePage(),
         transitionsBuilder:
             (context, animation, secondaryAnimation, child) {
           return SlideTransition(
             position: Tween<Offset>(
               begin: const Offset(0, 0.0), // Slide from right
               end: Offset.zero,
             ).animate(
               CurvedAnimation(
                 parent: animation,
                 curve: Curves.easeInOutCubic,
               ),
             ),
             child: FadeTransition(
               opacity: animation,
               child: child,
             ),
           );
         },
       ),
     );
    /* Navigator.push(
       context,
       MaterialPageRoute(
           builder: (context) =>
               ProductionBarcodePage()),
     );*/
     break;

      default:
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Coming Soon 🚀"),
            content: const Text(
              "This feature is under development and will be available soon.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        break;
    }
  }

  Widget getMenuAssetImage(String? id, Color color) {
    Widget image;
    double? iconSize;

    if (kIsWeb) {
      SizeConfig.safeBlockHorizontal! * 6 ; // Larger for desktop
    } else if (Platform.isWindows) {
      iconSize = SizeConfig.safeBlockHorizontal! * 2 ; // Larger for desktop
    } else if (Platform.isAndroid) {
      SizeConfig.safeBlockHorizontal! * 6 ;
    } else {
      SizeConfig.safeBlockHorizontal! * 6 ; // Larger for desktop
    }
    switch (id) {
      case "16":
        image = Icon(
          Icons.account_balance,
         /* size: SizeConfig.safeBlockHorizontal! * 6,*/  // Adjust the size as needed
          color:color,
        );
        break;
      case "377":
        image = Icon(
          Icons.account_balance,
          size: iconSize,
        /*  size: SizeConfig.safeBlockHorizontal! * 6, */ // Adjust the size as needed
          color: color,
        );
        break;
      case "367":
        image = Icon(
          Icons.calendar_month,
          size: iconSize,
         /* size: SizeConfig.safeBlockHorizontal! * 6,*/  // Adjust the size as needed
          color: color,
        );
        break;
      case "647":
        image = Icon(
          Icons.sync,
          size: iconSize,
          /*size: SizeConfig.safeBlockHorizontal! * 6,  */// Adjust the size as needed
          color: color,
        );
        break;

      case "644":

        image = Icon(
          Icons.notification_add,
          size: iconSize,
         /* size: SizeConfig.safeBlockHorizontal! * 6,*/  // Adjust the size as needed
          color:color,
        );
        break;
      case "646":

        image = Icon(
          Icons.speaker_notes,
          size: iconSize,  // Adjust the size as needed
          color: color,
        );
        break;
      case "313":

        image = Icon(
          Icons.speaker_notes,
          size: iconSize,
          color:color,
        );
        break;
      case "92":

        image = Icon(
          Icons.satellite,
         size: iconSize,
          color:color,
        );
        break;
        case "1564":

        image = Icon(
          Icons.public_rounded,
         size: iconSize,
          color: color,
        );
        break;
        case "1034":

        image = Icon(
          Icons.document_scanner_outlined,
         size: iconSize,
          color: color,
        );
        break;
        case "985":

        image = Icon(
          Icons.account_balance,
         size: iconSize,
          color:color,
        );
        break;

      case "983":

        image = Icon(
          Icons.app_registration,
          size: iconSize,
          color: color,
        );
        break;
      case "984":

        image = Icon(
          Icons.document_scanner_outlined,
          size: iconSize,
          color: color,
        );
        break;
        case "1583":

        image = Icon(
          Icons.document_scanner_outlined,
          size: iconSize,
          color: color,
        );
        break;
        case "1035":

        image = Icon(
          Icons.web_asset,
          size: iconSize,
          color: color,
        );
        break;
      case "200":

        image = Icon(
          Icons.pending_actions_outlined,
          size: iconSize,
          color: color,
        );
        break;
      default:

        image = Icon(
          Icons.account_balance_wallet,
         size: iconSize,
          color: color,
        );
    }
    return image;
  }
}

enum ConfirmAction { Cancel, Accept }
