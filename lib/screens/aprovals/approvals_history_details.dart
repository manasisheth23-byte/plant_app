import 'dart:io';
import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/helpers/api_request.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/aprovals/approval_history_list_screen.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/utils/loading_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/api_helpers.dart';
import '../../models/LoginResponseModel.dart';
import '../../models/get_approval_history_request_model.dart';
import '../../models/get_approval_history_response_model.dart';
import '../../models/get_approval_list_response_model.dart';
import '../../provider/themecontroller.dart';
import '../../utils/CommonUtils.dart';
import '../../utils/SizeConfig.dart';
import '../../utils/global_variables.dart';
import 'approvals_controller.dart';
import 'package:http/http.dart' as http;
class ApprovalsHistoryDetailsScreen extends StatefulWidget {
  LISTAPPROVAL data;
  LoginResponseModel? loginResponseModel;
  ApprovalsHistoryDetailsScreen(this.data,this.loginResponseModel);
  @override
  _ApprovalsHistoryDetailsScreen createState() => _ApprovalsHistoryDetailsScreen(data,loginResponseModel);
}

class _ApprovalsHistoryDetailsScreen extends State<ApprovalsHistoryDetailsScreen> {
  LISTAPPROVAL data;
  LoginResponseModel? loginResponseModel;
  _ApprovalsHistoryDetailsScreen(this.data,this.loginResponseModel);
  late ThemeController themeController;

  TextEditingController rMARKController = TextEditingController();
  GetApproveHistoryResponseModel   approvehistoryresponse=new GetApproveHistoryResponseModel();
  SizeConfig sizeConfig = SizeConfig();
  MediaQueryData? _mediaQueryData;
  String? strUserName;
  String? strUserDesignation;
  SharedPreferences? prefs;

  Future<String> downloadAndSaveFile(String url, String fileName) async {
    showLoadingDialog(context, message: 'Downloading file...');

    final response = await ApiRequest
        .get(url : url);

    // Save the file locally
    // final Directory directory1 = Directory('/storage/emulated/0/Android/data/com.cloud9.crmflutter/files/');

    final directory = await getExternalStorageDirectory();
    final attachmentsDir = Directory('${directory!.path}/AttachmentsFile');
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }
    final file = File("${attachmentsDir.path}/$fileName");
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsBytes(response.bodyBytes);
    Navigator.pop(context);

    return await file.exists() ? file.path : '';
  }

  void openFile(String fileName,String fileExtension,String fileurl,String folderName) async {
    final directory = await getExternalStorageDirectory();

    bool exists = await File('${directory!.path}/AttachmentsFile/$fileName' ?? '').exists();

    if (exists) {
      try {

          await OpenFile.open('${directory!.path}/AttachmentsFile/$fileName');
           } catch (e) {
        print('$e');
      }
    } else {
      String path = await downloadAndSaveFile(AppConfig.BASE_URL+DownloadAttachmentFile+'?MID=${data.mID}&RPTID=${data.rPTID}&DOCID=${data.dOCID}&USERID=$userId&Token=$token', fileName);
      print(path);
      if (path.isNotEmpty) {
        try {

            await OpenFile.open(path);

        } catch (e) {
          print('$e');
        }
      }
    }
  }
  void openFileDoc(String fileName,String fileExtension,String fileurl) async {
    final directory = await getExternalStorageDirectory();

    bool exists = await File('${directory!.path}/AttachmentsFile/$fileName' ?? '').exists();

    if (exists) {
      try {

        await OpenFile.open('${directory!.path}/AttachmentsFile/$fileName');
      } catch (e) {
        print('$e');
      }
    } else {
      String path = await downloadAndSaveFile(AppConfig.BASE_URL+DownloadAttachmentDOC+'?MID=${data.mID}&RPTID=${data.rPTID}&DOCID=${data.dOCID}&USERID=$userId&Token=$token', fileName);
      print(path);
      if (path.isNotEmpty) {
        try {

          await OpenFile.open(path);

        } catch (e) {
          print('$e');
        }
      }
    }
  }
  @override
  initState(){
    print('data------------------------> ${data.toJson()}');

    getData();

    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);



  }
  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              color: Colors.grey,
              fontSize: Platform.isIOS ? 15 : 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              fontSize:Platform.isIOS ? 18 : 15,
            ),
          ),
        ],
      ),
    );
  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);



    SizeConfig().init(context);
    _mediaQueryData = MediaQuery.of(context);

    // LoginResponseModel user = userProvider.loginResponseModel!;

    return PopScope(
      canPop: true,
      child: Center(
        child: SizedBox(
          width: isDesktop ? 700 : double.infinity,
          child: Scaffold(
            backgroundColor: isDesktop
                ?  Colors.white // dark app background for Windows/Desktop
                : const Color(0xffF5F7FA), // light app background for mobile
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Center(
                    child: SizedBox(
                        width: isDesktop ? 700 : double.infinity,
                        child:AppBar(
              backgroundColor: themeController.primaryColor,
              foregroundColor: Colors.white,
              centerTitle: Platform.isWindows ? false : false,
              title:  Text("Approval History Details" ,style: GoogleFonts.lato(

                color: Colors.white,
                fontSize:Platform.isIOS ? 17 :  14,
                fontWeight: FontWeight.normal,
              )),
              actions: [
                // Navigate to the Search Screen

              ],

            )))),
            bottomNavigationBar: NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                      (states) {
                    if (states.contains(MaterialState.selected)) {
                      return  TextStyle(
                        fontSize:Platform.isIOS ? 13 :  10,
                        fontWeight: FontWeight.w600,
                      );
                    }
                    return  TextStyle(
                      fontSize:Platform.isIOS ? 12 :  9,
                    );
                  },
                ),
              ),
              child: NavigationBar(
                selectedIndex: _idx,
                onDestinationSelected: (index) async {
                  if (index == 3) {
                    showDialog( context: context, builder: (context) =>
                        AlertDialog( title: const Text("Coming Soon 🚀"),
                          content: const Text( "This feature is under development and will be available soon.", ), actions: [ TextButton( onPressed: () => Navigator.pop(context), child: const Text("OK"), ), ], ), ); return; }
                  final plantName = context.read<PlantProvider>().plantName;
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 10),
                      reverseTransitionDuration: const Duration(milliseconds: 10),
                      pageBuilder: (_, animation, secondaryAnimation) =>
                          AppShell(
                            role: "Admin",
                            plant: plantName,
                            selectedIndex: index,

                          ),
                      transitionsBuilder: (_, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            )),
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
           /*       Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppShell(
                        role: "Admin",
                        plant: plantName,
                        selectedIndex: index,

                      ),
                    ),
                  );*/
                },
                height: 60,

                backgroundColor: Colors.white,
                indicatorColor: C.bluep,
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.home_outlined, size: 30),
                    selectedIcon: Icon(Icons.home, color: C.blue, size: 30),
                    label: 'Home',
                  ),

                 /* const NavigationDestination(icon: Icon(Icons.grid_view_outlined,size: 30), selectedIcon: Icon(Icons.grid_view,size: 30, color: C.blue), label: 'Shop Floor'),*/
                  NavigationDestination(
                    icon: Badge( label: Text(unreadProvider.unreadCount.toString()), child: const Icon(Icons.notifications_outlined,size: 30)),
                    selectedIcon: const Icon(Icons.notifications,size: 30, color: C.blue),
                    label: 'Alerts',
                  ),
                  const NavigationDestination(icon: Icon(Icons.bar_chart_outlined,size: 30), selectedIcon: Icon(Icons.bar_chart,size: 30, color: C.blue), label: 'Reports'),
                  const NavigationDestination(icon: Icon(Icons.chat_bubble_outline,size: 30), selectedIcon: Icon(Icons.chat_bubble,size: 30, color: C.blue), label: 'Assistant'),
                  const NavigationDestination(
                    icon: Icon(Icons.person,size: 30),
                    selectedIcon: Icon(Icons.person,size: 30, color: C.blue),
                    label: 'Profile',
                  ),

                  /*const NavigationDestination(
                    icon: Icon(Icons.menu,size: 30),
                    selectedIcon: Icon(Icons.menu,size: 30, color: C.blue),
                    label: 'More',
                  ),
          */
                ],
              ),
            ),
            body: Center(
              child: Container(
                height: MediaQuery.of(context).size.height,
                color:const Color(0xFFF5F7FB),
                width: isDesktop ? 700 : double.infinity,
                padding: const EdgeInsets.all(10),
                child:SingleChildScrollView(
                child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            children: [

                              Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Card(
                                        elevation: 0,
                                        color: Colors.white,
                                        margin: const EdgeInsets.fromLTRB(2,2,2,5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          side: BorderSide(
                                            color: Colors.white,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [

                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 3,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFBEAEA),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      data.iNVCTYPE ?? "",
                                                      style: GoogleFonts.lato(
                                                        color: const Color(0xFFC0504D),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: Platform.isIOS ? 14.5 : 11.5,
                                                      ),
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Text(
                                                    data.iNVCNUMB ?? "",
                                                    style: GoogleFonts.lato(
                                                      fontSize:Platform.isIOS ? 16 :  13,
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(0xFF12426E),
                                                    ),
                                                  ),

                                                ],
                                              ),

                                              const SizedBox(height: 3),


                                              const SizedBox(height: 1),

                                              Text(
                                                (data.sLDESC?.trim().isNotEmpty ?? false)
                                                    ? data.sLDESC!
                                                    : (data.dOCDESC?.trim() ?? ""),
                                                style: GoogleFonts.lato(
                                                  fontSize:Platform.isIOS ? 14 :  11,
                                                  color: Colors.black87,
                                                ),
                                              ),

                                              const SizedBox(height: 3),

                                              Text(
                                                "₹ ${data.dOCAMT}",
                                                style: GoogleFonts.lato(
                                                  fontSize:Platform.isIOS ? 14 :  11,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF1C6FB5),
                                                ),
                                              ),

                                              const SizedBox(height: 3),

                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFEAF1F8),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text(
                                                    "Due ${data.dUEDATE}",
                                                    style: GoogleFonts.lato(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize:Platform.isIOS ? 13 :  10,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Card(
                                        elevation: 0,
                                        color: Colors.white,
                                        margin: const EdgeInsets.fromLTRB(2, 3, 2, 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Container(
                                          color:  Colors.white.withOpacity(.18),
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(3))),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "APPROVAL DETAILS",
                                                    style: GoogleFonts.lato(
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(0xFF12426E),
                                                      fontSize:Platform.isIOS ? 21 :  18,
                                                    ),
                                                  ),
                                                ],
                                              ),


                                              const SizedBox(height: 15),

                                              detailRow(
                                                "Account",
                                                data.sLDESC ?? "",
                                              ),

                                              detailRow(
                                                "GL Account",
                                                data.gLDESC ?? "",
                                              ),

                                              detailRow(
                                                "Release By",
                                                data.cREATEDBYNAME ?? "",
                                              ),

                                              detailRow(
                                                "Invoice Date",
                                                data.iNVCDATE ?? "",
                                              ),

                                              /* detailRow(
                                            "Due Date",
                                            data.dUEDATE ?? "",
                                          ),*/
                                            ],
                                          ),
                                        ),
                                      ),
                                      /*   Container(
                                          width: SizeConfig.safeBlockHorizontal! *100,
                                          color: Colors.blue,
                                          padding: EdgeInsets.all(8),// Background color
                                           // Optional: add padding around the Row
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Align(
                                                      alignment: Alignment.centerLeft, // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                      child:  Text(data.iNVCNUMB!,
                                                        style: GoogleFonts.lato(fontSize: 14, color: Colors.white,
                                                            fontWeight: FontWeight.bold),))),


                                              Expanded(
                                                  child: Align(
                                                      alignment: Alignment.centerRight, // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                      child:Text(data.iNVCDATE!, style: GoogleFonts.lato(fontSize: 14,
                                                          color: Colors.white,fontWeight: FontWeight.bold),))),
                                            ],
                                          )),
                                      Container(
                                          width: SizeConfig.safeBlockHorizontal! *100,
                                           // Background color
                                          padding: EdgeInsets.all(2.0),  // Optional: add padding around the Row
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Align(
                                                      alignment: Alignment.centerLeft, // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                      child:  Text(data.iNVCTYPE!,
                                                        style: GoogleFonts.lato(fontSize: 14, color: Colors.blue,
                                                           fontWeight: FontWeight.normal),))),


                                              Expanded(
                                                  child: Align(
                                                      alignment: Alignment.centerRight, // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                      child:Text(data.dOCAMT!,
                                                        style: GoogleFonts.lato(fontSize: 14,
                                                            color: Colors.blue,
                                                            fontWeight: FontWeight.normal),))),
                                            ],
                                          )),*/
                                      /*    Container(
                                          width: SizeConfig.safeBlockHorizontal! *100,
                                          color: Colors.white,  // Background color
                                          padding: EdgeInsets.all(2.0),  // Optional: add padding around the Row
                                          child: Row(
                                            children: [
                                              Align(
                                                  alignment: Alignment.centerLeft, // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                  child:  Text("Account",
                                                    style: GoogleFonts.lato(fontSize: 14, color: Colors.blue,
                                                        ),)),


                                              SizedBox(
                                                width: 20,
                                              ),
                                              Align(
                                                  alignment: Alignment.centerLeft, // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                  child:Text( data.sLDESC.toString() ?? "",
                                                    style: GoogleFonts.lato(fontSize: 14, color: Colors.black,
                                                        ),)),
                                            ],
                                          )),*/
                                      /*     Container(
                                          width: SizeConfig.safeBlockHorizontal! *100,
                                          color: Colors.white,  // Background color
                                          padding: EdgeInsets.all(2.0),  // Optional: add padding around the Row
                                          child: Row(
                                            children: [
                                              Align(
                                                  alignment: Alignment.centerLeft, // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                  child:  Text(
                                                    "GL Account",
                                                    style: GoogleFonts.lato(fontSize: 14, color: Colors.blue,
                                                        ),)),
                                              SizedBox(
                                                width: 20,
                                              ),

                                              Align(
                                                  alignment: Alignment.centerLeft, // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                  child:Text( data.gLDESC.toString() ?? "",
                                                    style: GoogleFonts.lato(fontSize: 14, color: Colors.black,
                                                       ),)),
                                            ],
                                          )),*/
                                      /*  Container(
                                          width: SizeConfig.safeBlockHorizontal! *100,
                                          color: Colors.white,  // Background color
                                          padding: EdgeInsets.all(2.0),  // Optional: add padding around the Row
                                          child: Row(
                                            children: [
                                              Align(
                                                  alignment: Alignment.centerLeft, // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                  child:  Text(
                                                    "Release By",
                                                    style: GoogleFonts.lato(fontSize: 14, color: Colors.blue,
                                                       ),)),

                                              SizedBox(
                                                width: 20,
                                              ),
                                              Align(
                                                  alignment: Alignment.centerLeft, // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                  child:Text(data.cREATEDBYNAME.toString() ??""  ,
                                                    style: GoogleFonts.lato(fontSize: 14, color: Colors.black,
                                                       ),)),
                                            ],
                                          )),
                                      Container(
                                        width: SizeConfig.safeBlockHorizontal! *100,
                                        color: Colors.white,  // Background color
                                        padding: EdgeInsets.all(2.0),  // Optional: add padding around the Row
                                        child: Row(
                                          children: [
                                            Align(
                                                alignment: Alignment.centerLeft, // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                child:  Text(
                                                  "Due Date",
                                                  style: GoogleFonts.lato(fontSize: 14, color: Colors.blue,
                                                     ),)),

                                            SizedBox(
                                              width: 20,
                                            ),
                                            Align(
                                                alignment: Alignment.centerLeft, // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                child:Text(data.dUEDATE.toString() ?? "",
                                                  style: GoogleFonts.lato(fontSize: 14, color: Colors.black,
                                                      ),)),
                                          ],
                                        ),



                                      ),*/
                                    ],
                                  )),

                              SizedBox(height:10),
                              GestureDetector(
                                onTap: () {
                                  var fileName = data.mID! +
                                      (data.rPTID == null
                                          ? "0"
                                          : data.rPTID!);
                                  openDoc(
                                    context: context,
                                    fileName: fileName,
                                    fileExtension: "",
                                    fileUrl: "",
                                  );
                                },
                                child: Container(
                                    width: SizeConfig.safeBlockHorizontal! *100,
                                    color: Colors.white,  // Background color
                                    padding: EdgeInsets.all(0.0),  // Optional: add padding around the Row
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Container(
                                            color: Colors.white,  // Background color
                                            padding: EdgeInsets.all(2.0),  // Optional: add padding around the Row
                                            child: Align(
                                                alignment: Alignment.center, // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                child:
                                                Text("View Documents",
                                                  style: GoogleFonts.lato(fontSize: 14,
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.normal),))),
                                        Container(

                                          // Background color
                                            padding: EdgeInsets.all(2.0),  // Optional: add padding around the Row
                                            child: Align(
                                                alignment: Alignment.center, // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                child:
                                                Icon(Icons.view_list,size: 30.0,))),],
                                    )),
                              ),
                              SizedBox(height:10),
                              if (data.aTTCHMNTINFO!.aTTACHMENTS!.iNFO != null)
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                      height: (100.0 *
                                          (data.aTTCHMNTINFO!.aTTACHMENTS!.iNFO!
                                              .length))+100, // Or a specific height
                                      child: Column(
                                        children: [
                                          Container(
                                              width: SizeConfig
                                                  .safeBlockHorizontal! *
                                                  100,
                                              color: Colors.grey[400],
                                              // Background color
                                              padding: EdgeInsets.all(2.0),
                                              // Optional: add padding around the Row
                                              child: Align(
                                                  alignment: Alignment.center,
                                                  // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                  child: Text(
                                                    "Attachment File",
                                                    style: GoogleFonts.lato(
                                                        fontSize:Platform.isIOS ? 17 : 14,


                                                        fontWeight:
                                                        FontWeight.normal),
                                                  ))),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: data.aTTCHMNTINFO!
                                                  .aTTACHMENTS!.iNFO!.length,
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  height: 100,
                                                  child: ListTile(
                                                    onTap: () {
                                                      openFile(
                                                          data
                                                              .aTTCHMNTINFO!
                                                              .aTTACHMENTS!
                                                              .iNFO![index]
                                                              .nEWFILENAME
                                                              .toString(),
                                                          data
                                                              .aTTCHMNTINFO!
                                                              .aTTACHMENTS!
                                                              .iNFO![index]
                                                              .eXTENSION
                                                              .toString(),
                                                          "${AppConfig.BASE_URL}" +
                                                              data
                                                                  .aTTCHMNTINFO!
                                                                  .aTTACHMENTS!
                                                                  .iNFO![index]
                                                                  .dOWNLOADURL
                                                                  .toString(), data
                                                          .aTTCHMNTINFO!
                                                          .aTTACHMENTS!
                                                          .iNFO![index]
                                                          .fOLDERNAME
                                                          .toString());
                                                    },
                                                    title: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 1.5),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.white),
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .only(
                                                              right: 10,
                                                              bottom: 10,
                                                              top: 10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Align(
                                                                  alignment: Alignment
                                                                      .centerLeft,
                                                                  // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                                  child: Text(
                                                                    "File Type-" +
                                                                        data
                                                                            .aTTCHMNTINFO!
                                                                            .aTTACHMENTS!
                                                                            .iNFO![
                                                                        index]
                                                                            .eXTENSION
                                                                            .toString(),
                                                                    style: GoogleFonts.lato(
                                                                        fontSize:
                                                                        Platform.isIOS ? 17 : 14,
                                                                        color: Colors
                                                                            .red,

                                                                        fontWeight:
                                                                        FontWeight
                                                                            .normal),
                                                                  )),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Align(
                                                                  alignment:
                                                                  Alignment
                                                                      .center,
                                                                  // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                                                  child: Text(
                                                                    data
                                                                        .aTTCHMNTINFO!
                                                                        .aTTACHMENTS!
                                                                        .iNFO![
                                                                    index]
                                                                        .nEWFILENAME
                                                                        .toString(),
                                                                    style: GoogleFonts.lato(
                                                                        fontSize:
                                                                        Platform.isIOS ? 17 : 14,
                                                                        color: Colors
                                                                            .black,

                                                                        fontWeight:
                                                                        FontWeight
                                                                            .normal),
                                                                  )),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Divider(
                                            color: Colors.grey,
                                            // Color of the divider
                                            height: 20,
                                            // Space around the divider (top + bottom)
                                            thickness: 1,
                                            // Thickness of the line
                                            indent: 20,
                                            // Empty space to the leading edge
                                            endIndent:
                                            20, // Empty space to the trailing edge
                                          ),
                                        ],
                                      )),
                                ),
                              Container(
                                  width: SizeConfig.safeBlockHorizontal! * 100,
                                  color: Colors.white,
                                  // Background color
                                  padding: EdgeInsets.all(12.0),
                                  // Optional: add padding around the Row
                                  child: Align(
                                      alignment: Alignment.center,
                                      // Can be Alignment.topLeft, Alignment.bottomCenter, etc.
                                      child: Text(
                                        "Approval History",
                                        style: GoogleFonts.lato(
                                            fontSize:Platform.isIOS ? 21 : 18,
                                            color: Colors.blue,


                                            fontWeight: FontWeight.normal),
                                      ))),
                            ],
                          ),



                          Container(

                              child: FutureBuilder<GetApproveHistoryResponseModel>(
                                  future:/* ApproveHistoryapicall(context,"1812","99","4823","2",
                                            "1284","903AF0F9-EFC8-4441-BFFD-68937823E59E","1732"),*/
                                  ApproveHistoryapicall(context,data.dOCID!,data.mENUID!,data.mID!, orgStructId!,
                                      posId!, token!, userId!),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      GetApproveHistoryResponseModel?
                                      approveResponseModel = snapshot.data;
                                      if (approveResponseModel != null) {
                                        if (approveResponseModel.data != null) {
                                          return SingleChildScrollView(
                                            child: Column(
                                              children: <Widget>[
                                                for (int k = 0;
                                                k <
                                                    approveResponseModel
                                                        .data!.list.length;
                                                k++) ...[
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to start
                                                    children: [
                                                      Text(
                                                        approveResponseModel!.data!.list![k].releasecount!  + " Release",
                                                        textAlign: TextAlign.start,
                                                        style:
                                                        GoogleFonts.lato(
                                                          color: Colors
                                                              .red,
                                                          fontWeight:
                                                          FontWeight
                                                              .normal,
                                                          fontSize:
                                                          Platform.isIOS ? 17 :14,
                                                        ),
                                                      )],),
                                                  Divider(color: Colors.grey),
                                                  for (int j = 0;
                                                  j <
                                                      approveResponseModel.data!
                                                          .list[k].sublist.length;
                                                  j++) ...[
                                                    Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.center,
                                                          children: <Widget>[
                                                            const Icon(
                                                              Icons
                                                                  .supervised_user_circle,
                                                              size: 50.0,
                                                            ),
                                                            const SizedBox(width: 5),
                                                            Expanded(
                                                              child: historyTile(
                                                                name: approveResponseModel
                                                                    .data!
                                                                    .list[k]
                                                                    .sublist[j]
                                                                    .name!,

                                                                status: approveResponseModel
                                                                    .data!
                                                                    .list[k]
                                                                    .sublist[j]
                                                                    .approverstatus!,

                                                                date: approveResponseModel
                                                                    .data!
                                                                    .list[k]
                                                                    .sublist[j]
                                                                    .date!,

                                                                statusId: approveResponseModel
                                                                    .data!
                                                                    .list[k]
                                                                    .sublist[j]
                                                                    .statusid!,
                                                              ),
                                                              /*
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Container(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                children: <Widget>[
                                                                  const SizedBox(
                                                                      height: 5),
                                                                  Text(
                                                                    approveResponseModel
                                                                        .data!
                                                                        .list[k]
                                                                        .sublist[j]
                                                                        .name!,
                                                                    style:
                                                                   GoogleFonts.lato(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                      fontSize:
                                                                      14,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height: 2),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                                children: <Widget>[
                                                                  const SizedBox(
                                                                      height: 5),
                                                                  if (approveResponseModel
                                                                      .data!
                                                                      .list[k]
                                                                      .sublist[
                                                                  j]
                                                                      .statusid ==
                                                                      "3") ...[
                                                                    Container(
                                                                      padding:
                                                                      const EdgeInsets.all(
                                                                          8.0),
                                                                      child:
                                                                      Align(
                                                                        alignment:
                                                                        Alignment
                                                                            .centerRight,
                                                                        child:
                                                                        Container(
                                                                          color: Colors
                                                                              .red,
                                                                          padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
                                                                          child:
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                            children: [
                                                                              Text(
                                                                                approveResponseModel.data!.list[k].sublist[j].approverstatus!,
                                                                                style: GoogleFonts.lato(
                                                                                  fontSize: 12,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                approveResponseModel.data!.list[k].sublist[j].date!,
                                                                                style: GoogleFonts.lato(
                                                                                  fontSize: 12,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ] else if (approveResponseModel
                                                                      .data!
                                                                      .list[k]
                                                                      .sublist[
                                                                  j]
                                                                      .date !=
                                                                      "01-Jan-1900 12:00 AM") ...[
                                                                    Container(
                                                                      padding:
                                                                      const EdgeInsets.all(
                                                                          8.0),
                                                                      child:
                                                                      Align(
                                                                        alignment:
                                                                        Alignment
                                                                            .centerRight,
                                                                        child:
                                                                        Container(
                                                                          color: Colors
                                                                              .orangeAccent,
                                                                          padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
                                                                          child:
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                            children: [
                                                                              Text(
                                                                                approveResponseModel.data!.list[k].sublist[j].approverstatus!,
                                                                                style: GoogleFonts.lato(
                                                                                  fontSize: 12,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                approveResponseModel.data!.list[k].sublist[j].date!,
                                                                                style: GoogleFonts.lato(
                                                                                  fontSize: 12,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.normal,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ] else ...[
                                                                    Container(
                                                                      padding:
                                                                      const EdgeInsets.all(
                                                                          8.0),
                                                                      child:
                                                                      Align(
                                                                        alignment:
                                                                        Alignment
                                                                            .centerRight,
                                                                        child:
                                                                        Container(
                                                                          color: Colors
                                                                              .blue,
                                                                          padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
                                                                          child:
                                                                          Text(
                                                                            approveResponseModel
                                                                                .data!
                                                                                .list[k]
                                                                                .sublist[j]
                                                                                .approverstatus!,
                                                                            style:
                                                                            GoogleFonts.lato(
                                                                              fontSize:
                                                                              12,
                                                                              color:
                                                                              Colors.black,
                                                                              fontWeight:
                                                                              FontWeight.normal,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                  const SizedBox(
                                                                      height: 2),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),*/
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    /*Column(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: <Widget>[

                                                        Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.center,
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons
                                                                  .supervised_user_circle,
                                                              size: 50.0,
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Expanded(
                                                              child: Row(
                                                                children: <Widget>[
                                                                  Expanded(
                                                                    child: Container(
                                                                      child: Column(
                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                        crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                        children: <Widget>[
                                                                          const SizedBox(
                                                                            height: 5,
                                                                          ),
                                                                          Text(
                                                                            approveResponseModel
                                                                                .data!
                                                                                .list![
                                                                            k]
                                                                                .sublist![
                                                                            j]
                                                                                .name!,
                                                                            style:
                                                                             GoogleFonts.lato(
                                                                              color: Colors
                                                                                  .black,
                                                                              fontWeight:
                                                                              FontWeight
                                                                                  .normal,
                                                                              fontSize:
                                                                              14,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height: 2,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Container(
                                                                      child: Column(
                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                        crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                        children: <Widget>[
                                                                          const SizedBox(
                                                                            height: 5,
                                                                          ),
                                                                          if (approveResponseModel
                                                                              .data!
                                                                              .list[
                                                                          k]
                                                                              .sublist[
                                                                          j]
                                                                              .date !=
                                                                              "01-Jan-1900 12:00 AM") ...[
                                                                            Container(
                                                                              padding:
                                                                              EdgeInsets.all(
                                                                                  8.0),
                                                                              child: Align(
                                                                                alignment: Alignment
                                                                                    .centerRight,
                                                                                child: Container(
                                                                                  color: Colors
                                                                                      .orangeAccent,
                                                                                  padding:
                                                                                  EdgeInsets
                                                                                      .all(
                                                                                      4.0),
                                                                                  child: Column(
                                                                                    crossAxisAlignment:
                                                                                    CrossAxisAlignment
                                                                                        .end,
                                                                                    children: [
                                                                                      Text(
                                                                                        approveResponseModel
                                                                                            .data!
                                                                                            .list[
                                                                                        k]
                                                                                            .sublist[
                                                                                        j]
                                                                                            .approverstatus!,
                                                                                        style:
                                                                                        GoogleFonts.lato(
                                                                                          fontSize:
                                                                                          12,
                                                                                          color: Colors
                                                                                              .black,
                                                                                          fontWeight:
                                                                                          FontWeight.bold,
                                                                                        ),
                                                                                      ),
                                                                                      Text(
                                                                                        approveResponseModel
                                                                                            .data!
                                                                                            .list[
                                                                                        k]
                                                                                            .sublist[
                                                                                        j]
                                                                                            .date!,
                                                                                        style:
                                                                                        GoogleFonts.lato(
                                                                                          fontSize:
                                                                                          12,
                                                                                          color: Colors
                                                                                              .black,
                                                                                          fontWeight:
                                                                                          FontWeight.bold,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ] else ...[
                                                                            Container(
                                                                              padding:
                                                                              EdgeInsets.all(
                                                                                  8.0),
                                                                              child:
                                                                              Align(
                                                                                alignment:
                                                                                Alignment.centerRight,
                                                                                child:
                                                                                Container(
                                                                                  color:
                                                                                  Colors.blue,
                                                                                  padding:
                                                                                  EdgeInsets.all(4.0),
                                                                                  child:
                                                                                  Flexible(
                                                                                    child:
                                                                                    Text(
                                                                                      approveResponseModel.data!.list[k].sublist[j].approverstatus!,
                                                                                      style: GoogleFonts.lato(
                                                                                        fontSize: 12,
                                                                                        color: Colors.black,
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                          const SizedBox(
                                                                            height: 2,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),*/
                                                  ],
                                                  SizedBox(
                                                      width: 100, // Width of the box
                                                      height: 20),

                                                ],
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Center(
                                            child: Text("No Records to display"),
                                          );
                                        }
                                      }
                                    }
                                    return CircularProgressIndicator();
                                  })) ],
                      ),
                    ),
                  ),
                ),
          ),
        ),
      ),
    );



  }
  Future<Directory> _getPlatformDirectory() async {
    if (Platform.isAndroid) {
      return (await getExternalStorageDirectory())!;
    } else if (Platform.isWindows) {
      return await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
  Future<String> downloadAndSaveDoc({
    required BuildContext context,
    required String url,
    required String fileName,
    required String fileExtension,
  })
  async {
    try {
      // Optional: Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final response = await http
          .get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0', // pretend to be a browser
        },
      )
          .timeout(const Duration(minutes: 2));

      if (response.statusCode != 200) {
        Navigator.pop(context);
        throw Exception(
            "Failed to download. Status code: ${response.statusCode}");
      }

      final directory = await _getPlatformDirectory();
      final attachmentsDir = Directory('${directory.path}/AttachmentsFile');
      if (!await attachmentsDir.exists()) {
        await attachmentsDir.create(recursive: true);
      }

      final filePath = '${attachmentsDir.path}/$fileName.$fileExtension';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes, flush: true);

      Navigator.pop(context); // Dismiss loading

      return await file.exists() ? file.path : '';
    } catch (e) {
      Navigator.pop(context);
      print('Download error: $e');
      return '';
    }
  }

  Future<void> openDoc({
    required BuildContext context,
    required String fileName,
    required String fileExtension,
    required String fileUrl,
  })
  async {
    final directory = await _getPlatformDirectory();
    final attachmentsDir = Directory('${directory.path}/AttachmentsFile');
    final fullFilePath = '${attachmentsDir.path}/$fileName.$fileExtension';
    final file = File(fullFilePath);

    // Request storage permission on Android
    if (Platform.isAndroid && !(await Permission.storage.isGranted)) {
      await Permission.storage.request();
    }

    if (await file.exists()) {
      print('Opening existing file: $fullFilePath');
      await OpenFile.open(fullFilePath);
    } else {
      fileUrl = AppConfig.BASE_URL +
          DownloadAttachmentDOC +
          '?MID=${data.mID}&RPTID=${data.rPTID}&DOCID=${data.dOCID}&USERID=$userId&Token=$token';
      print(fileUrl);
      final savedPath = await downloadAndSaveDoc(
        context: context,
        url: fileUrl,
        fileName: fileName,
        fileExtension: fileExtension,
      );
      if (savedPath.isNotEmpty) {
        await OpenFile.open(savedPath);
      }
    }
  }
  Widget historyTile({
    required String name,
    required String status,
    required String date,
    required String statusId,
  })
  {
    Color statusColor;

    if (statusId == "3") {
      statusColor = Colors.red;
    } else if (date != "01-Jan-1900 12:00 AM") {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Timeline Dot
          Column(
            children: [
              SizedBox(height: 20,),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 60,
                color: Colors.grey.shade300,
              ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      name,
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize:Platform.isIOS ? 17 : 14,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.lato(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize:Platform.isIOS ? 14 : 11,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      date,
                      style: GoogleFonts.lato(
                        color: Colors.grey,
                        fontSize:Platform.isIOS ? 15 : 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<GetApproveHistoryResponseModel> ApproveHistoryapicall(BuildContext context,
      String strDocid,String strMenuId,
      String strMid,String strOrgstuctid,String strPostId,
      String strToken,String strUserId) async {
    try {


      CommonUtils commonUtils = new CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {

        GetApproveHistoryRequestModel approvehistoryrequestmodel =
        GetApproveHistoryRequestModel();
        approvehistoryrequestmodel.xMLFILE = XMLFILEAPPROVEHISTORY();
        approvehistoryrequestmodel.xMLFILE!.dOCID =strDocid ;
        approvehistoryrequestmodel.xMLFILE!.fLAG = "1";
        approvehistoryrequestmodel.xMLFILE!.fROMDATE = "";
        approvehistoryrequestmodel.xMLFILE!.mENUID =strMenuId ;
        approvehistoryrequestmodel.xMLFILE!.mID= strMid;
        approvehistoryrequestmodel.xMLFILE!.oRGSTRUCTID = orgStructId;
        approvehistoryrequestmodel.xMLFILE!.controlno = controlno;
        approvehistoryrequestmodel.xMLFILE!.pAGENO = 1;
        approvehistoryrequestmodel.xMLFILE!.pOSID = strPostId;
        approvehistoryrequestmodel.xMLFILE!.tODATE = "";
        approvehistoryrequestmodel.xMLFILE!.tOKEN = strToken;
        approvehistoryrequestmodel.xMLFILE!.uSERID = strUserId;
        approvehistoryresponse = await Provider.of<ApprovalsController>(context, listen: false)
            .GetApprovalHistory(approvehistoryrequestmodel,context);

        print('apporval details-------------> ${approvehistoryresponse.data..toString()}');


        if (approvehistoryresponse != null) {

        } else {

        }
      } else {
        return approvehistoryresponse;
      }
    } catch (error, stacktrace) {

      // print("Exception occured: $error stackTrace: $stacktrace");
    }
    return approvehistoryresponse;
  }
}
