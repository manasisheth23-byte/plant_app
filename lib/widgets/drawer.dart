
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:erpflutter/Constants.dart';
import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/models/getnotificationmodel.dart';
import 'package:erpflutter/provider/financialyear_provider.dart';
import 'package:erpflutter/provider/get_notification_provider.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/bireports/BoldReportList.dart';
import 'package:erpflutter/screens/bireports/BoldReportViewerScreenwithparam.dart';
import 'package:erpflutter/screens/bireports/ReportList.dart';
import 'package:erpflutter/screens/bireports/WorkmanDashboardReportViewerScreen.dart';
import 'package:erpflutter/screens/bireports/WorkmenDashboardWindows.dart';
import 'package:erpflutter/utils/SizeConfig.dart';
import 'package:erpflutter/versionupdate/UpdateService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../barcodescanner/view_models/physical_barcode_viewmodel.dart';
import '../barcodescanner/views/production_barcode.dart';

import '../database/app_preferences.dart';
import '../database/secure_storage_service.dart';
import '../helpers/api_helpers.dart';
import '../helpers/api_request.dart';
import '../models/CheckDeviceRequestModel.dart';
import '../models/CheckDeviceResponseModel.dart';
import '../models/LoginResponseModel.dart';
import '../models/auth_user_otp_response_model.dart';
import '../models/login_response_model.dart';
import '../provider/themecontroller.dart';
import '../repository/ConfigService.dart';
import '../repository/LoginApiRepository.dart';

import '../screens/ChangePasswordScreen.dart';
import '../screens/bireports/WorkmaemSheduleWindows.dart';
import '../screens/fingerprintregister/fingerprint_register_screen.dart';
import '../screens/konowledgebase/knowyourproductscreen.dart';

import '../app_theme.dart';
import '../screens/login/login.dart';
import '../services/ApiProvider.dart';
import '../utils/loading_dialog.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String _deviceName = 'Unknown ';
  Uint8List? _image;
  File? selectedImage;
  String profile = '';
  ApiProvider _apiProvider = ApiProvider();
  bool isLoading = false;
  var userName;
  var posID;
  var enablebiometry;
  List<LoginModel> users = [];
  LoginResponseModel? loginResponseModel;
  var wifiIP,LocalIP="-";
  Color _colorapk = Colors.white;
  bool _isRequestingInstallPermission = false;
  LoginResponseModel? user;
  String? imageUrl,positiondesc;
  get platform => null;
  static const platformdevice = MethodChannel('com.cloud9.erpflutter/deviceName');
  late ThemeController themeController;


  void getData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName=prefs.getString("USERNAME");
      posID=prefs.getString("POSID");
    });


    print("************************* $userName");
    print("************************* $posID");




    prefs = await SharedPreferences.getInstance();
    setState(() {
      loginResponseModel = LoginResponseModel.fromJson(
          jsonDecode(prefs.getString('LOGINRESPONSE') ?? ''))!;
    });

  }
  void showLogoutDialog(BuildContext context, VoidCallback onLogout) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 0 : 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 420 : double.infinity,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 36,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Logout?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Are you sure you want to logout from your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          var prefs = await SharedPreferences.getInstance();
                          if (prefs != null) {
                            prefs!.setBool("ISLOGGEDIN", false);
                            prefs!.setString("TOKEN", '');

                            // Count unread
                            Constant.unreadCount = 0;
                            final unreadProvider = Provider.of<
                                UnreadNotificationProvider>(
                                context, listen: false);
                            unreadProvider.setUnreadCount(
                              0,
                            );
                          }
                          context.read<FinancialYearProvider>().clear();
                          Navigator.pop(context);
                          onLogout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Logout"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLOGGEDIN", false);
          prefs!.setString("TOKEN", '');

          // Count unread
          Constant.unreadCount = 0;
          final unreadProvider = Provider.of<UnreadNotificationProvider>(context, listen: false);
          unreadProvider.setUnreadCount(
           0,
          );
          Navigator.pop(context);
       /*   Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
          );*/

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 10),
              reverseTransitionDuration: const Duration(milliseconds: 10),
              pageBuilder: (_, animation, secondaryAnimation) =>
                  LoginScreen(),
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



  Future<void> _uploadImage(File image) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");

    final uri =
    Uri.parse('http://10.0.0.245:8401/API/Authentication/EditProfileImage');
    final request = http.MultipartRequest('POST', uri);

    request.headers['X-Auth-Token'] = token!;

    request.fields['FILENAME'] = 'dummy_image';
    request.fields['FILEEXT'] = 'jpg';
    request.fields['IMG'] = image.path;

    setState(() {
      isLoading = true;
    });

    final response = await request.send();

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      print('Uploaded successfully!');
    } else {
      print('Upload failed with status code: ${response.statusCode}');
    }
  }

  Future<void> clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    await prefs.remove("token");
    await prefs.remove('userid');
    await prefs.remove('username');
    await prefs.remove('mobileno');
  }

  Future<String> getprofiledata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? profile = prefs.getString("username");
    print('---username : : : $profile');
    return profile ?? '';
  }
  void getuserdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs = await SharedPreferences.getInstance();
    setState(() {

      enablebiometry = prefs.getString("ENABLEBIOMETRIC") ?? "false";

    });
  }
  Future<String> getmobileno() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobile = prefs.getString("mobileno");
    print('---mobileno : : : $mobile');
    return mobile ?? '';
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance!.addPostFrameCallback((_) =>getData());
    super.initState();
    getuserdata();
    _loadUser();
    getData();
      getprofiledata();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getNotificationCount();

    });

  }
  Future<void> _loadUser() async {
  //  userName = await AppPreferences.getUserName();
    positiondesc = await AppPreferences.getpositionDesce();

    user = await SecureStorageService.getUser();

    final imgDesc = user?.data?.imgdesc;

    if (imgDesc != null && imgDesc.isNotEmpty) {
      imageUrl = "${ConfigService.getBaseOnlyUrl()}/$imgDesc";
    } else {
      imageUrl = "";
    }

    if (mounted) setState(() {});
  }
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
      print("Unread count: $Constant.unreadCount");
    } catch (e) {
      print("Error fetching notification count: $e");
    }
  }

  double _getDrawerWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (kIsWeb) {
      // For Web platform
      return screenWidth * 0.25; // 25% of screen width
    } else if (Platform.isWindows) {
      // For Windows desktop
      return screenWidth * 0.25; // Desktop typically has larger screens
    } else if (Platform.isAndroid) {
      // For Android mobile
      return screenWidth * 0.75; // Typical mobile drawer width
    } else {
      // Default fallback for other platforms (e.g., iOS, macOS)
      return screenWidth * 0.6;
    }
  }
/*  Future<int> getVersionCode() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int versionCode = int.parse(packageInfo.buildNumber);
    print("Version Code: $versionCode");
    return versionCode % 1000;
  }*/
  Future<int> getVersionCode() async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (Platform.isAndroid) {
      // Android: buildNumber is available
      return int.parse(packageInfo.buildNumber);
    } else if (Platform.isWindows) {
      // Windows: extract from version (e.g. 1.0.3)
      final parts = packageInfo.version.split('.');
      final major = int.tryParse(parts[0]) ?? 0;
      final minor = int.tryParse(parts[1]) ?? 0;
      final patch = int.tryParse(parts[2]) ?? 0;

      // Custom version code logic
      return major * 10000 + minor * 100 + patch;
    }

    return 0;
  }
  Future<bool> apiCheckUpdateAvailable() async {
    bool isUpdated = false;

    int currentVersion = await getVersionCode();

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    /* AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    String deviceName = androidInfo.manufacturer + " " + androidInfo.model;*/
    String? deviceName;
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceName= "${androidInfo.manufacturer} ${androidInfo.model}";
    }
    else if (Platform.isWindows) {
      final WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;

      deviceName = "${windowsInfo.computerName}";
    }

    CheckDeviceRequestModel checkDeviceRequestModel =
    new CheckDeviceRequestModel();
    checkDeviceRequestModel.xMLFILE = new XMLFILEc();
    checkDeviceRequestModel.xMLFILE!.uSERID = 0;
    checkDeviceRequestModel.xMLFILE!.dEVICEID = deviceName!;
    checkDeviceRequestModel.xMLFILE!.fLAG = "0";
    checkDeviceRequestModel.xMLFILE!.iPADDRESS = "$LocalIP";
    checkDeviceRequestModel.xMLFILE!.mAC = "";
    checkDeviceRequestModel.xMLFILE!.pORT = "";
    checkDeviceRequestModel.xMLFILE!.vERSION = currentVersion;
    final LoginApiRepository _repository = LoginApiRepository();

    try {
      {
        CheckDeviceResponseModel response =
        await _repository.getCheckDevice(checkDeviceRequestModel);
        if (response != null) if (response.dATA != null &&
            response.dATA!.lATESTVERSION != null) {
          if (int.parse(response.dATA!.lATESTVERSION!) >
              int.parse(response.dATA!.cURRENTVERSION ?? '0')) {
            isUpdated = true;
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Your app is updated!')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response.error!),
          ));
        }
      }
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unable to check latest version!'),
      ));
    }

    return isUpdated;
  }
  Future<String> downloadFile(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to download file');
      }

      final dir = await getApplicationDocumentsDirectory();
      //final filePath = '${dir.path}\\$fileName';
      final filePath = '${dir.path}\\$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath;
    } catch (e) {
      throw Exception('Download error: $e');
    }
  }
  Future<void> downloadBothFiles() async {
    final exePath = await downloadFile(
      'https://yourdomain.com/files/C9Erp.exe',
      'C9Erp.exe',
    );

    final issPath = await downloadFile(
      'https://yourdomain.com/files/C9Erp.iss',
      'C9Erp.iss',
    );

    print('Downloaded EXE: $exePath');
    print('Downloaded ISS: $issPath');
    //runExe(exePath);
  }
  Future<void> ensureDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }
  Future<void> extractAndInstall() async {
    final zipPath =
        r'D:\komal\erpflutter_final\installer_02_02_2026_v2\installer.zip';

    final extractPath =
        r'D:\komal\erpflutter_final\installer_02_02_2026_v2\extracted';

    final exePath = '$extractPath\\installer\\C9Erp.exe';
    await ensureDirectory(extractPath);
    await extractZip(
      zipPath: zipPath,
      destinationPath: extractPath,
    );

    await runExe(exePath);
  }
  Future<void> extractZip({
    required String zipPath,
    required String destinationPath,
  }) async {
    final bytes = File(zipPath).readAsBytesSync();

    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = '$destinationPath\\${file.name}';

      if (file.isFile) {
        final outFile = File(filename);
        outFile.createSync(recursive: true);
        outFile.writeAsBytesSync(file.content as List<int>);
      } else {
        Directory(filename).createSync(recursive: true);
      }
    }
  }

  Future<void> runExe(String exePath) async {
   /* final exePath =
        r'D:\komal\erpflutter_final\installer_02_02_2026_v2\C9Erp.exe';*/

    try {
      await Process.start(
        exePath,
        [],
        mode: ProcessStartMode.detached,
      );
    } catch (e) {
      print('Failed to run exe: $e');
    }
  }
  /*Future<void> runExe(String exePath) async {

    try {
      await Process.start(
        exePath,
        [],
        mode: ProcessStartMode.detached,
      );
    } catch (e) {
      print('Failed to run exe: $e');
    }
  }*/
  @override
  Widget build(BuildContext context) {
    final setHeight = MediaQuery.of(context).size.height * 1;
    final setWidth = MediaQuery.of(context).size.width * 1;
    bool isDesktop = MediaQuery.of(context).size.width > 900;
    themeController = Provider.of(context, listen: false);

   // String imageUrl = AppConfig.RAW_BASE_URL+"/"+loginResponseModel!.data!.imgdesc;
    return Drawer(
      width:  _getDrawerWidth(context),
      child: Column(

        children: <Widget>[

          SizedBox(
              height: 220, // Your desired height
              child:   DrawerHeader(
      padding: EdgeInsets.only(top: 10,bottom: 4),
      decoration: BoxDecoration(color: themeController.primaryColor),
      child: Container(

        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: (imageUrl != null && imageUrl!.isNotEmpty)
                    ? Image.network(
                  imageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Image.asset(
                      'assets/user.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Image.asset(
                  'assets/user.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            /*Image.asset('assets/user.png'),*/
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 3),
                child: SingleChildScrollView(
                    child:Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        userName.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(

                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        )
                    ),
                    Text(
                      loginResponseModel?.data?.usertype ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),

                    Text(
                      loginResponseModel?.data?.email ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    // Text("PosID ${posID.toString()}", style: TextStyle(fontSize: 14,),)
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    )),

          Expanded(

            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 10),
                                reverseTransitionDuration: const Duration(milliseconds: 10),
                                pageBuilder: (_, animation, secondaryAnimation) =>
                                    ChangePasswordScreen(activityName: 'COMPANY', userId: '0',),
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
                           /* Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChangePasswordScreen(activityName: 'COMPANY', userId: '0',)),
                            );*/
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                 Icon(
                                  Icons.lock,
                                  color: themeController.primaryColor,
                                ),
                                SizedBox(
                                  width: setWidth * 0.01,
                                ),
                                Text(
                                  "Change Password",
                                  style: GoogleFonts.lato(fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if( enablebiometry != null && enablebiometry != "true" && enablebiometry != "True" && ! kIsWeb && Platform.isAndroid)...[

                          /*  SizedBox(
      height: setHeight * 0.02,
    ),
    InkWell(
                          onTap: () {

                           final BuildContext safeContext = context;

                            Navigator.pop(safeContext);

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                _showCustomDialog(safeContext);
                              }
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.lock,
                                  color: AppColors.APPCOLOR,
                                ),
                                SizedBox(
                                  width: setWidth * 0.02,
                                ),
                                const Text(
                                  "Register Fingerprint",
                                  style: TextStyle(fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),*/
                        ],
                        SizedBox(
                          height: setHeight * 0.02,
                        ),

/*
                        InkWell(
                          onTap: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Reportlist()),
                            );

                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                 Icon(
    Icons.speaker_notes,
      // Adjust the size as needed
    color: AppColors.APPCOLOR,
    ),
                                SizedBox(
                                  width: setWidth * 0.02,
                                ),
                                const Text(
                                  "Reports",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: setHeight * 0.02,
                        ),*/
                        /*  InkWell(
                          onTap: () {
                            final String reportServiceUrl ="http://125.99.42.182:8441/api/ReportViewer";
                            final String reportPath ="~/BiReports/Product_Wise_Skill.rdl";
                            final String xmlPayload = '''
<XMLFILE>
  <SPXML>
    <SPDETAILS FLAG="1" ORGSTRUCID="0" RULEID="583" USERID="3242" />
  </SPXML>
</XMLFILE>
''';
                            final String htmlpath ='assets/js/bold_reportwithparameters.html';
                            final String label="Project Wise Skill";
    if (Platform.isWindows) {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WorkmenSheduleWindowsScreen( reportServiceUrl: reportServiceUrl,
          reportPath: reportPath,
          xmlPayload: xmlPayload,
        htmlPath: htmlpath,
        label: label,)),
      );
    }
    else{

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BoldReportViewerScreenwithparam(reportServiceUrl: reportServiceUrl,
          reportPath: reportPath,
          xmlPayload: xmlPayload,
          htmlPath: htmlpath,
          label: label,)),

      );
    }

                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.logout,
                                  color:AppColors.APPCOLOR,
                                ),
                                SizedBox(
                                  width: setWidth * 0.02,
                                ),
                                const Text(
                                  "Project Wise Skill",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: setHeight * 0.02,
                        ),*/
                        /*  InkWell(
                          onTap: () {
                            if(Platform.isWindows){


                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => WorkmenDashboardWindowsScreen()),
                              );
                            }else{
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Workmandashboardreportviewerscreen()),
                              );
                            }

                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.logout,
                                  color: AppColors.APPCOLOR,
                                ),
                                SizedBox(
                                  width: setWidth * 0.02,
                                ),
                                const Text(
                                  "Workmen Dashboard",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: setHeight * 0.02,
                        ),*/
                        /* InkWell(
                          onTap: () {
                            final String reportServiceUrl ="http://10.0.0.223:8441/api/ReportViewer";
                            final String reportPath ="~/BiReports/Employee_Wise_Skill.rdl";
                            final String xmlPayload = '''
                             <XMLFILE>
                              <SPXML>
                                <SPDETAILS FLAG="1" ORGSTRUCID="0" RULEID="583" USERID="3242" />
                              </SPXML>
                             </XMLFILE>
                                ''';
                            final String htmlpath ='assets/js/bold_reportwithparameters.html';
                            final String label= "Employee Wise Skill";
                            if(Platform.isWindows){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => WorkmenSheduleWindowsScreen( reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                label: label,)),
                              );
                            }else{
                             *//* Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BoldReportViewerScreenEmpwise()),
                              );*//*
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BoldReportViewerScreenwithparam(reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                  label: label,)),

                              );
                            }

                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.logout,
                                  color:AppColors.APPCOLOR,
                                ),
                                SizedBox(
                                  width: setWidth * 0.02,
                                ),
                                const Text(
                                  "Employee Wise Skill",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: setHeight * 0.02,
                        ),*/
                        /* InkWell(
                          onTap: () {

                            final String reportServiceUrl ="http://10.0.0.223:8441/api/ReportViewer";
                            final String reportPath ="~/BiReports/Workman_Schedule.rdl";
                            final String xmlPayload = '''
                           <XMLFILE>
  <SPXML>
    <SPDETAILS FLAG="2" PRODNLINEID="0" ITEMID="0" SHIFTID="0" PAGENO="1" MACHINEID="0" ORGSTRUCID="0" Ruleid="590" ALLOCATIONDATE="2025-06-03T00:00:00" TODATE="2025-06-03T00:00:00" USERID="3242" />
  </SPXML>
</XMLFILE>
                          ''';
                            final String label= "Workmen Schedule";
                            final String htmlpath ='assets/js/bold_reportwithparameters.html';
                            if(Platform.isWindows){

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => WorkmenSheduleWindowsScreen( reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                label: label,)),
                              );
                            }
                            else{

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BoldReportViewerScreenwithparam(reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                  label: label,)),

                              );
                            }

                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.logout,
                                  color: AppColors.APPCOLOR,
                                ),
                                SizedBox(
                                  width: setWidth * 0.02,
                                ),
                                const Text(
                                  "Workmen Schedule",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: setHeight * 0.02,
                        ),*/
                        /* InkWell(
                          onTap: () {

                            final String reportServiceUrl ="http://10.0.0.223:8441/api/ReportViewer";
                            final String reportPath ="~/BiReports/Employee_Allotment.rdl";
                            final String xmlPayload = '''
                           <XMLFILE>
  <SPXML>
    <SPDETAILS FLAG="1" ORGSTRUCID="0" Ruleid="590" StartDate="2025-06-03T00:00:00" EndDate="2025-06-03T00:00:00" RULEBASEDAVL="0" ISXML="0" IsDefaultRule="1" USERID="3242" SHOWSUMMARY="0" />
    <COLUMNS>
      <COLDETAILS COLUMN_NAME="PRODLINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SCHDATE" ISSELECTED="1" FILTER_VALS="1" />
      <COLDETAILS COLUMN_NAME="MACHINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATION" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PLANT" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="ITEMCODE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCLASS" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCATEGORY" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="WONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="CUSTOMER" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATOR" ISSELECTED="1" FILTER_VALS="" />
    </COLUMNS>
  </SPXML>
</XMLFILE>
                          ''';
                            final String label= "Employee Allotment";
                            final String htmlpath ='assets/js/bold_reportwithparameters.html';
                            if(Platform.isWindows){

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => WorkmenSheduleWindowsScreen( reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                  label: label,)),
                              );
                            }else{
                         *//*     Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BoldBIEmployeeAllotment()),

                              );*//*
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BoldReportViewerScreenwithparam(reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                  label: label,)),

                              );
                            }

                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.logout,
                                  color:AppColors.APPCOLOR,
                                ),
                                SizedBox(
                                  width: setWidth * 0.02,
                                ),
                                const Text(
                                  "Employee Allotment",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: setHeight * 0.02,
                        ),*/
                        /* InkWell(
                          onTap: () {
                            final String reportServiceUrl ="http://10.0.0.223:8441/api/ReportViewer";
                            final String reportPath ="~/BiReports/Employee_Allotment_DayWise.rdl";
                            final String xmlPayload = '''
                           <XMLFILE>
  <SPXML>
    <SPDETAILS FLAG="1" ORGSTRUCID="0" Ruleid="583" StartDate="2025-05-27T00:00:00" EndDate="2025-05-27T00:00:00" RULEBASEDAVL="0" ISXML="0" IsDefaultRule="1" USERID="3242" SHOWSUMMARY="0" />
    <COLUMNS>
      <COLDETAILS COLUMN_NAME="PRODLINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SCHDATE" ISSELECTED="1" FILTER_VALS="1" />
      <COLDETAILS COLUMN_NAME="MACHINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATION" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PLANT" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="ITEMCODE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCLASS" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCATEGORY" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="WONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="CUSTOMER" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATOR" ISSELECTED="1" FILTER_VALS="" />
    </COLUMNS>
  </SPXML>
</XMLFILE>
                          ''';
                            final String label= "Employee Allotment Daywise";
                            final String htmlpath ='assets/js/bold_reportwithparameters.html';
                            if(Platform.isWindows){

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => WorkmenSheduleWindowsScreen( reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                  label: label,)),
                              );

                            }else{
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BoldReportViewerScreenwithparam(reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                  label: label,)),

                              );
                            }

                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.logout,
                                  color: AppColors.APPCOLOR,
                                ),
                                SizedBox(
                                  width: setWidth * 0.02,
                                ),
                                const Text(
                                  "Employee Allotment Daywise",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height: setHeight * 0.02,
                        ),*/
                        /* InkWell(
                          onTap: () {
                            final String reportServiceUrl ="http://10.0.0.223:8441/api/ReportViewer";
                            final String reportPath ="~/BiReports/Employee_Non_Availibility.rdl";
                            final String xmlPayload = '''
                          <XMLFILE>
  <SPXML>
    <SPDETAILS FLAG="3" ORGSTRUCID="0" Ruleid="583" StartDate="2025-05-27T00:00:00" EndDate="2025-12-30T00:00:00" RULEBASEDAVL="0" ISXML="0" IsDefaultRule="1" USERID="3242" SHOWSUMMARY="0" />
    <COLUMNS>
      <COLDETAILS COLUMN_NAME="PRODLINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SCHDATE" ISSELECTED="1" FILTER_VALS="1" />
      <COLDETAILS COLUMN_NAME="MACHINE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATION" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PLANT" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="ITEMCODE" ISSELECTED="1" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCLASS" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="PRODUCTCATEGORY" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="SONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="WONO" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="CUSTOMER" ISSELECTED="0" FILTER_VALS="" />
      <COLDETAILS COLUMN_NAME="OPERATOR" ISSELECTED="1" FILTER_VALS="" />
    </COLUMNS>
  </SPXML>
</XMLFILE>
                          ''';
                            final String label= "Employee Non Availibility";
                            final String htmlpath ='assets/js/bold_reportwithparameters.html';
                            if(Platform.isWindows){


                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => WorkmenSheduleWindowsScreen( reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                  label: label,)),
                              );
                            }else{
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BoldReportViewerScreenwithparam(reportServiceUrl: reportServiceUrl,
                                  reportPath: reportPath,
                                  xmlPayload: xmlPayload,
                                  htmlPath: htmlpath,
                                  label: label,)),

                              );
                             *//* Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BoldReportEmployeeNonAvailbility()),
                              );*//*
                            }


                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.logout,
                                  color: AppColors.APPCOLOR,
                                ),
                                SizedBox(
                                  width: setWidth * 0.02,
                                ),
                                const Text(
                                  "Employee Non Availibility",

                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: setHeight * 0.02,
                        ),*/
                        /* InkWell(
                          onTap: () {

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        BoldReportListScreen()),
                              );

                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
    Icon(
    Icons.speaker_notes,
      // Adjust the size as needed
    color: AppColors.APPCOLOR,
    ),
                                SizedBox(
                                  width: setWidth * 0.02,
                                ),
                                const Text(
                                  "Dashboard",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),*/
                        /*  SizedBox(
                          height: setHeight * 0.02,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        KnowYourProductScreen(text: "",)));



                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.public_rounded,
                                  color: AppColors.APPCOLOR,
                                ),
                                SizedBox(
                                  width: setWidth * 0.02,
                                ),
                                const Text(
                                  "Know Your Product",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),*/


                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.02,
                          ),
                          child: Consumer<FinancialYearProvider>(
                            builder: (context, provider, _) {
                              if (provider.isLoading) {
                                return const ListTile(title: Text("Loading..."));
                              }

                              final selectedYear = provider.selectedYear;

                              return ListTile(
                                contentPadding: EdgeInsets.zero, // 🔑 IMPORTANT
                                dense: true,                     // 🔑 reduce height
                                visualDensity: VisualDensity.compact,
                                minLeadingWidth: 0,              // 🔑 remove extra space
                                leading:  Icon(
                                  Icons.calendar_month,
                                  color: themeController.primaryColor,
                                ),
                                title: const Text("Financial Year"),
                                subtitle: Text(
                                  selectedYear?.description ?? "Not Available",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onTap: () {
                                  _showFinancialYearDialog(context, provider);
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: setHeight * 0.02,
                        ),
                        InkWell(
                          onTap: () async {

                            if (!kIsWeb && Platform.isAndroid) {
                              // Close drawer first


                              // Wait a frame before calling async code
                              await Future.delayed(Duration(milliseconds: 100));

                              if (!mounted) return; // Ensure still mounted
                              requestStoragePermission();
                            }else
                            {
                              //   extractAndInstall();
                              // runExe();
                              await UpdateService().checkForUpdate();

                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                 Icon(
                                  Icons.lock,
                                  color: themeController.primaryColor,
                                ),
                                SizedBox(
                                  width: setWidth * 0.01,
                                ),
                                Text(
                                  "Check Update",
                                  style: GoogleFonts.lato(fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: setHeight * 0.03,
                        ),
                        InkWell(
                          onTap: () {
                            showLogoutDialog(context, () async {
                              // clear session
                              // SharedPreferences prefs = await SharedPreferences.getInstance();
                              // await prefs.clear();

                              // navigate to login
                           /*   Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => LoginScreen()),
                                    (route) => false,
                              );*/

                              Navigator.pushAndRemoveUntil(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: const Duration(milliseconds: 10),
                                  reverseTransitionDuration: const Duration(milliseconds: 10),
                                  pageBuilder: (_, animation, secondaryAnimation) =>
                                      LoginScreen(),
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
                                ), (route) => false,
                              );
                            });
                            /*   showAlertDialog(context);*/
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery.of(context).size.width * 0.02),
                            child: Row(
                              children: <Widget>[
                                 Icon(
                                  Icons.login,
                                  color: themeController.primaryColor,
                                ),
                                SizedBox(
                                  width: setWidth * 0.01,
                                ),
                                Text(
                                  "Logout",
                                  style: GoogleFonts.lato(fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: setHeight * 0.02,
                        ),




                      ],
                    ),
                  ),

                  Text("V 1.0.0", style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: themeController.primaryColor
                  ))
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
 /* void _showFinancialYearDialog(
      BuildContext context,
      FinancialYearProvider provider,
      )
  {
    showDialog(
      context: context,
      builder: (context) {
        final isDesktop =
            Theme.of(context).platform == TargetPlatform.windows ||
                Theme.of(context).platform == TargetPlatform.macOS ||
                Theme.of(context).platform == TargetPlatform.linux;

        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 420 : double.infinity,
            ),
            child: AlertDialog(
              title: const Text("Select Financial Year"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.years.length,
                  itemBuilder: (context, index) {
                    final year = provider.years[index];
                    final isSelected =
                        year.controlNo == provider.selectedYear?.controlNo;

                    return ListTile(
                        contentPadding: EdgeInsets.zero,   // 🔑 removes left/right padding
                        dense: true,                       // 🔑 reduces height
                        visualDensity: VisualDensity.compact,
                        minLeadingWidth: 0,                // 🔑 removes extra space before icon
                        horizontalTitleGap: 8,
                      title: Text(year.description ?? ''),
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected ? AppColors.APPCOLOR : null,
                      ),
                      tileColor: isSelected
                          ? AppColors.APPCOLOR.withOpacity(0.1)
                          : null,
                      onTap: () async{
                        provider.changeFinancialYear(year);
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String? years = prefs.getString('YEARVALUE');
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }*/
  void _showFinancialYearDialog(
      BuildContext context,
      FinancialYearProvider provider,
      ) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : 12,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 420 : double.infinity,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Title
                  const Text(
                    "Select Financial Year",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// 🔹 Divider
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  /// 🔹 List
                  Expanded(
                    child: ListView.separated(
                      itemCount: provider.years.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final year = provider.years[index];
                        final isSelected =
                            year.controlNo ==
                                provider.selectedYear?.controlNo;

                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          hoverColor:
                          themeController.primaryColor.withOpacity(0.06),
                          onTap: () {
                            provider.changeFinancialYear(year);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding:  EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? themeController.primaryColor.withOpacity(0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? themeController.primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  size: 20,
                                  color: isSelected
                                      ?themeController.primaryColor
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    year.description ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 🔹 Actions
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CANCEL"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

/*  void _showCustomDialog(BuildContext outerContext) {
    final TextEditingController loginusernameController = TextEditingController();
    final TextEditingController loginpwdController = TextEditingController();

    showDialog(
      context: outerContext,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: LayoutBuilder(
            builder: (context, constraints) {
             final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              final isDesktop = kIsWeb ||
                  Platform.isWindows ||
                  Platform.isLinux ||
                  Platform.isMacOS;

              final dialogWidth = isDesktop ? screenWidth * 0.5 : screenWidth * 0.9;
              final dialogHeight =
              isDesktop ? screenHeight * 0.5 : screenHeight * 0.9;

              final fieldWidth = dialogWidth * 0.85;
              final buttonWidth = dialogWidth * 0.4;
              final buttonHeight = isDesktop ? dialogHeight * 0.1 : dialogHeight * 0.09;

              // Validation state variables
              bool usernameIsEmpty = false;
              bool passwordIsEmpty = false;

              return StatefulBuilder(
                builder: (context, setState) {
                  bool showPassword = false;

                  return Container(
                    width: dialogWidth,
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Username Field
                          Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5, top: 30),
                            child: SizedBox(
                              width: fieldWidth,
                              child: TextField(
                                textInputAction: TextInputAction.next,
                                controller: loginusernameController,
                                decoration: InputDecoration(
                                  labelText: 'Authorized User Id',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: usernameIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: usernameIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: usernameIsEmpty ? Colors.red : Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Password Field
                          Padding(
                            padding: const EdgeInsets.only(left: 5, top: 25, bottom: 15),
                            child: SizedBox(
                              width: fieldWidth,
                              child: TextField(
                                obscureText: !showPassword,
                                controller: loginpwdController,
                                decoration: InputDecoration(
                                  labelText: 'Authorized User Password',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: passwordIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: passwordIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: passwordIsEmpty ? Colors.red : Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Submit Button
                          Container(
                            width: buttonWidth,
                            height: buttonHeight,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              onPressed: () async{
                                final username = loginusernameController.text.trim();
                                final password = loginpwdController.text.trim();

                                setState(() {
                                  usernameIsEmpty = username.isEmpty;
                                  passwordIsEmpty = password.isEmpty;
                                });

                                if (usernameIsEmpty || passwordIsEmpty) {
                                  // Don't proceed, fields are invalid
                                  return;
                                }else{
                                  List<LoginModel>? fetchedUsers = await fetchLoginDetails(context,loginusernameController.text,
                                      loginpwdController.text, "I", "")!;

                                  if(fetchedUsers != null)
                                    if(fetchedUsers[0].uSERID == -1){
                                      _showDialog(context, '', fetchedUsers[0].mESSAGE.toString());
                                    }else{
                                      Navigator.of(dialogContext).pop();
                                      showOTPCustomDialog(context,fetchedUsers![0].mOBILENO!,username,password,fetchedUsers![0].uSERID.toString(),"V");
                                    }

                                }


                                // close dialog if you want


                              },
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }*/
/*  Future<UserAuthOTPResponseModel?> fetchLoginDetails1(BuildContext context,
      String username, String password, String strFlag, String strOtp,String mobileNo,String userId) async {
    try {

      UserAuthOTPResponseModel userAuthOTPResponseModel = await _apiProvider.authenticateUser(
          context,
          mobileNo,
          userId,
          strFlag,
          strOtp);

      *//*if (users.isNotEmpty) {
        if (users[0].uSERID == -1) {
          // Show dialog using a valid context (e.g., root context or parent context)
          if (mounted) {
            _showDialog(context, '', users[0].mESSAGE.toString());
          }

        } else {
          var fetchotp = await _apiProvider.authenticateUser(
              context,
              users[0].mOBILENO.toString(),
              users[0].uSERID.toString(),
              strFlag,
              strOtp);

          // Ensure context is still valid
          //if (mounted) {

        //  }


          if (fetchotp.eRRORMSG!.iD.toString() == "-1") {
          //  if (mounted) {
              _showDialog(context, '', fetchotp.eRRORMSG!.mSG.toString());
              *//**//* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(fetchotp.eRRORMSG!.mSG.toString()),
                ));*//**//*
          //  }
          } else {
            if (strFlag != null && strFlag == "V" && fetchotp.eRRORMSG!.cODE == "200") {
            //  if (mounted) {

                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RegisterFingerprint(
                    strUsername: username,
                    strMobileno: users[0].mOBILENO.toString(),
                  ),
                ));
             // }
            } else {
             // if (mounted) {
                *//**//* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(fetchotp.eRRORMSG!.mSG.toString()),
                  ));*//**//*
                _showDialog(context, '', fetchotp.eRRORMSG!.mSG.toString());

            //  }
            }
          }

        }
      }*//*
      return userAuthOTPResponseModel;
    } catch (e) {
      print(e);
    } finally {

    }
  }*/
/*  void showOTPCustomDialog(BuildContext outerContext, String strMobileno,
      String strUsename, String strPassword,String userId,String flag) {
    final TextEditingController loginusernameController = TextEditingController();
    final TextEditingController loginpwdController = TextEditingController();
    TextEditingController loginotpController = TextEditingController();
    loginusernameController.text = strUsename;
    loginpwdController.text = strPassword;

    showDialog(
      context: outerContext,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              final isDesktop = kIsWeb ||
                  Platform.isWindows ||
                  Platform.isLinux ||
                  Platform.isMacOS;

              final dialogWidth = isDesktop ? screenWidth * 0.5 : screenWidth * 0.9;
              final dialogHeight =
              isDesktop ? screenHeight * 0.5 : screenHeight * 0.9;

              final fieldWidth = dialogWidth * 0.85;
              final buttonWidth = dialogWidth * 0.4;
              final buttonHeight = isDesktop ? dialogHeight * 0.1 : dialogHeight * 0.09;

              // Validation state variables
              bool usernameIsEmpty = false;
              bool passwordIsEmpty = false;
              bool isOtpEmpty = false;
              return StatefulBuilder(
                builder: (context, setState) {
                  bool showPassword = false;

                  return Container(
                    width: dialogWidth,
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Username Field
                          Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5, top: 30),
                            child: SizedBox(
                              width: fieldWidth,
                              child: TextField(
                                textInputAction: TextInputAction.next,
                                controller: loginusernameController,
                                decoration: InputDecoration(
                                  labelText: 'Authorized User Id',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: usernameIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: usernameIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: usernameIsEmpty ? Colors.red : Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Password Field
                          Padding(
                            padding: const EdgeInsets.only(left: 5, top: 25, bottom: 15),
                            child: SizedBox(
                              width: fieldWidth,
                              child: TextField(
                                obscureText: !showPassword,
                                controller: loginpwdController,
                                decoration: InputDecoration(
                                  labelText: 'Authorized User Password',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: passwordIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: passwordIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: passwordIsEmpty ? Colors.red : Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Submit Button
                          Container(
                            width: buttonWidth,
                            height: buttonHeight,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              onPressed: () async{
                                final username = loginusernameController.text.trim();
                                final password = loginpwdController.text.trim();

                                setState(() {
                                  usernameIsEmpty = username.isEmpty;
                                  passwordIsEmpty = password.isEmpty;
                                });

                                if (usernameIsEmpty || passwordIsEmpty) {
                                  // Don't proceed, fields are invalid
                                  return;
                                }else
                                {
                                  List<LoginModel>? fetchedUsers= await fetchLoginDetails(context,loginusernameController.text,
                                      loginpwdController.text, "E", "");
                                  if(fetchedUsers != null)
                                    if(fetchedUsers[0].uSERID == -1){
                                      _showDialog(context, '', fetchedUsers[0].mESSAGE.toString());
                                    }
                                }



                              },
                              child: const Text(
                                'Resend OTP',
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          // Mobile number display
                          const SizedBox(height: 10),
                          const Text(
                            'Mobile No',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            strMobileno,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),

                          // OTP
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 30, bottom: 0),
                            child: SizedBox(
                              width: fieldWidth,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                controller: loginotpController,
                                textInputAction: TextInputAction.done,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'OTP',
                                  border: const OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: isOtpEmpty ? Colors.red : Colors.black,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: isOtpEmpty ? Colors.red : Colors.black,
                                      width: 2.0,
                                    ),
                                  ),
                                  errorText: isOtpEmpty ? 'Please enter OTP' : null,
                                ),
                              ),
                            ),
                          ),

                          // Verify Button
                          Container(
                            width: buttonWidth,
                            height: buttonHeight,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              onPressed: () async {
                                setState(() {
                                  isOtpEmpty = loginotpController.text.trim().isEmpty;
                                });

                                if (!isOtpEmpty) {
                                  UserAuthOTPResponseModel? userAuthOTPResponseModel = await fetchLoginDetails1(context,
                                      loginusernameController.text,
                                      loginpwdController.text,
                                      "V",
                                      loginotpController.text,
                                      strMobileno,userId);
                                  if(userAuthOTPResponseModel!.eRRORMSG!.iD == -1){
                                    _showDialog(context, '', userAuthOTPResponseModel.eRRORMSG!.mSG.toString());
                                  }else{
                                    if (flag != null && flag == "V" && userAuthOTPResponseModel.eRRORMSG!.cODE == "200") {
                                      //  if (mounted) {
                                      Navigator.of(dialogContext).pop();
                                     *//* Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => RegisterFingerprint(
                                          strUsername: loginusernameController.text,
                                          strMobileno: strMobileno, loginResponseModel: loginResponseModel,
                                        ),
                                      ));*//*
                                    }else{
                                      //Navigator.of(dialogContext).pop();
                                      _showDialog(context, '', userAuthOTPResponseModel.eRRORMSG!.mSG.toString());
                                    }
                                  }
                                  *//* showOTPCustomDialog(
                                      context, strMobileno,  loginusernameController.text, loginpwdController.text,userId);*//*
                                }
                              },
                              child: const Text(
                                'Verify OTP',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }*/

/*  Future<List<LoginModel>?> fetchLoginDetails(

      BuildContext context,
      String username,
      String password,
      String strFlag,
      String strOtp,
      ) async {
    bool _isFetching = false;

    // Start loading
    if (mounted) {
      setState(() {
        _isFetching = true;
      });
    }

    try {
      // 1. Fetch login details
      List<LoginModel> fetchedUsers =
      await _apiProvider.getFingerprintLoginDetails(username, password);
      users = fetchedUsers;
      if (mounted) {
        setState(() {
          users = fetchedUsers;
          _isFetching = false;
        });
      }

      if (users.isEmpty) return fetchedUsers;

      final user = users[0];

      // 2. Check if login is invalid
      if (user.uSERID == -1) {
        if (mounted) {
          _showDialog(context, '', user.mESSAGE ?? 'Invalid login');
        }
        return fetchedUsers;
      }

      // 3. Authenticate OTP
      final fetchOtp = await _apiProvider.authenticateUser(
        context,
        user.mOBILENO ?? '',
        user.uSERID.toString(),
        strFlag,
        strOtp,
      );

      return fetchedUsers;


    } catch (e) {
      print("Error during fetchLoginDetails: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }*/






  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('ok'),
            ),
          ],
        );
      },
    );
  }
 void dispose() {
    // Cancel any active timers, subscriptions, or futures
    super.dispose();
  }


  Future<void> requestStoragePermission() async {
    bool updateAvailable = await apiCheckUpdateAvailable();

    if (!updateAvailable) {
      return;
    }

    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;

    if (androidInfo.version.sdkInt >= 30) {
      var manageExternalStorageStatus = await Permission.manageExternalStorage.status;
      if (!manageExternalStorageStatus.isGranted) {
        var result = await Permission.manageExternalStorage.request();
        if (!result.isGranted) {
          _showPermissionDeniedDialog();
        } else {
          downloadAndroidFile(context);
        }
      } else {
        downloadAndroidFile(context);
      }
    } else {
      var storagePermissionStatus = await Permission.storage.status;
      if (!storagePermissionStatus.isGranted) {
        var result = await Permission.storage.request();
        if (!result.isGranted) {
          _showPermissionDeniedDialog();
        } else {
          downloadAndroidFile(context);
        }
      } else {
        downloadAndroidFile(context);
      }
    }
  }

  // Show dialog when permission is denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Permission Required'),
            content: Text(
                'Storage permission is required to download the APK. Please allow the permissions and try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<bool> requestInstallPermission() async {
    if (!Platform.isAndroid) return false;

    if (_isRequestingInstallPermission) {
      debugPrint("Permission request already in progress");
      return false;
    }

    _isRequestingInstallPermission = true;

    try {
      final status = await Permission.requestInstallPackages.status;

      if (status.isGranted) {
        debugPrint("Install Packages permission already granted.");
        return true;
      }

      final result = await Permission.requestInstallPackages.request();
      return result.isGranted;
    } finally {
      _isRequestingInstallPermission = false;
    }
  }



  Future<bool> downloadAndroidFile(BuildContext context) async {
    await requestInstallPermission();

    try {
      final String url =
          '${AppConfig.RAW_BASE_URL}/DownloadAPK/DownloadApkFile';

      debugPrint('Downloading file...');
      showLoadingDialog(context, message: 'Downloading App');

      final request = http.Request('GET', Uri.parse(url));

      // ⏳ Increase timeout for large APKs
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 5),
      );

      if (streamedResponse.statusCode != 200) {
        throw Exception('Download failed');
      }

      // 📂 Use external storage (IMPORTANT for APK install)
      final Directory? directory = await getExternalStorageDirectory();
      final File file = File('${directory!.path}/app.apk');

      final IOSink sink = file.openWrite();
      await streamedResponse.stream.pipe(sink);
      await sink.close();

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!await file.exists()) {
        return false;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('App downloaded successfully!'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final installer = FlutterAppInstaller();
                await installer.installApk(filePath: file.path);
                Navigator.pop(context);
              },
              child: const Text('Install'),
            ),
          ],
        ),
      );

      return true;
    } on TimeoutException catch (e) {
      debugPrint('Download timeout: $e');

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return false;
    } catch (e, s) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      debugPrint('Error: $e');
      debugPrintStack(stackTrace: s);
      return false;
    }
  }
  Widget _buildProfileImage() {


    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        gaplessPlayback: true, // 🔥 prevents blank flicker
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            "assets/user.png",
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          );
        },
      );
    }

    return Image.asset(
      "assets/user.png",
      width: 120,
      height: 120,
      fit: BoxFit.cover,
    );
  }

}
