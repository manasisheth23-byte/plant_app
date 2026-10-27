import 'dart:convert';
import 'dart:io';
import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/helpers/api_request.dart';
import 'package:erpflutter/utils/loading_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers/api_helpers.dart';
import '../../models/LoginResponseModel.dart';
import '../../models/approve_reject_request_model.dart';
import '../../models/approve_reject_response_model.dart';
import '../../models/get_approval_history_request_model.dart';
import '../../models/get_approval_history_response_model.dart';
import '../../models/get_approval_list_response_model.dart';
import '../../provider/themecontroller.dart';
import '../../utils/CommonUtils.dart';
import '../../utils/SizeConfig.dart';
import '../../utils/global_variables.dart';
import '../../utils/hex_color.dart';
import '../../widgetcontrolls/TextControll.dart';
import 'approval_png_file_screen.dart';
import 'approvals_controller.dart';
import 'approvals_list_screen.dart';
import 'package:http/http.dart' as http;

class ApprovalsDetailsScreen extends StatefulWidget {
  final LISTAPPROVAL data;
  final LoginResponseModel? loginResponseModel;

  ApprovalsDetailsScreen(this.data, this.loginResponseModel, {Key? key})
      : super(key: key);

  @override
  _ApprovalsDetailsScreen createState() =>
      _ApprovalsDetailsScreen(data, loginResponseModel);
}

class _ApprovalsDetailsScreen extends State<ApprovalsDetailsScreen> {
  final LISTAPPROVAL data;
  LoginResponseModel? loginResponseModel;

  _ApprovalsDetailsScreen(this.data, this.loginResponseModel) {
    printLargeString('Approvals data ---> ${data.toJson()}');
  }

  final TextEditingController rMARKController = TextEditingController();
  GetApproveHistoryResponseModel approvehistoryresponse =
  GetApproveHistoryResponseModel();
  SizeConfig sizeConfig = SizeConfig();
  MediaQueryData? _mediaQueryData;
  SharedPreferences? prefs;
  late ThemeController themeController;

  Future<String> downloadAndSaveFile(String url, String fileName) async {
    try {
      // Show loading dialog
      showLoadingDialog(context, message: 'Downloading file...');

      // Make the API request
      final response = await ApiRequest.get(url: url);

      // Check the response status
      if (response.statusCode != 200) {
        Navigator.pop(context);
        throw Exception(
            "Failed to download file. Status code: ${response.statusCode}");
      }

      // Get the external storage directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory(); // Safe fallback
      }
      if (directory == null) {
        Navigator.pop(context);
        throw Exception("External storage directory not found");
      }

      // Create the attachments directory
      final attachmentsDir = Directory('${directory.path}/AttachmentsFile');
      if (!await attachmentsDir.exists()) {
        await attachmentsDir.create(recursive: true);
      }

      // Save the file
      final file = File("${attachmentsDir.path}/$fileName");
      await file.writeAsBytes(response.bodyBytes, flush: true);

      Navigator.pop(context); // Dismiss loading dialog

      // Verify if the file exists
      if (await file.exists()) {
        return file.path;
      } else {
        throw Exception("File could not be saved");
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("DB insert error: $e")),
      );
      print("Error: $e");
      return '';
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

      /*final response = await ApiRequest
          .get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0', // pretend to be a browser
        },
      )
          .timeout(const Duration(minutes: 2));*/
      final response = await ApiRequest.get(url: url);
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
  Future<Directory> _getPlatformDirectory() async {

    if (Platform.isAndroid) {
      return (await getExternalStorageDirectory())!;
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows) {
      return await getApplicationDocumentsDirectory();
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }
  /*Future<Directory> _getPlatformDirectory() async {
    if (Platform.isAndroid) {
      return (await getExternalStorageDirectory())!;
    } else if (Platform.isWindows) {
      return await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }*/

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

  Future<void> openFile(
      String fileName, String fileExtension, String fileurl, String folderName)
  async {
    Directory? dir;

    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory(); // Safe fallback
    }

    if (dir != null) {
      final filePath = '${dir.path}/AttachmentsFile/$fileName';
      final file = File(filePath);

      if (Platform.isAndroid) {
        if (!(await Permission.storage.isGranted)) {
          await Permission.storage.request();
        }
      }

      final exists = await file.exists();
      if (exists) {
        print('File exists --->');
        try {
         // if (Platform.isAndroid) {
            await OpenFile.open(filePath);
         // }
        } catch (e) {
          print('$e');
        }
      } else {
        String path = await downloadAndSaveFile(
          AppConfig.BASE_URL +
              DownloadAttachmentFile +
              '?FolderName=$folderName&FileName=$fileName',
          fileName,
        );
        print(path);
        if (path.isNotEmpty) {
          try {
           /// if (!Platform.isAndroid) {
              await OpenFile.open(path);
           // }
          } catch (e) {
            print('$e');
          }
        }
      }
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

  @override
  void initState() {
    super.initState();

    print('data------------------------> ${data.toJson()}');

    getData();

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
              fontSize: Platform.isIOS ? 16 : 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              fontSize: Platform.isIOS ? 19 : 15,
            ),
          ),
        ],
      ),
    );
  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    _mediaQueryData = MediaQuery.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        Future.microtask(() {
          if (!mounted) return;
          setState(() {
            loginResponseModel = LoginResponseModel.fromJson(
              jsonDecode(prefs.getString('LOGINRESPONSE') ?? ''),
            );
          });
        });

        // Also push navigation in a microtask to stay outside pointer event cycle
        Future.microtask(() {
          if (!mounted) return;
          /* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ApprovalsListFragment(
                loginResponseModel: loginResponseModel,
              ),
            ),
          );*/
        });
      },
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
              titleSpacing: 1,
              centerTitle: Platform.isWindows ? true : false,
              backgroundColor: themeController.primaryColor,
              foregroundColor: Colors.white,
              title: Text(
                "Approval Details",
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: Platform.isIOS ? 18 : 14,
                  fontWeight: FontWeight.normal,
                ),
              ),

            )))),
            bottomNavigationBar: NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                      (states) {
                    if (states.contains(MaterialState.selected)) {
                      return TextStyle(
                        fontSize: Platform.isIOS ? 14 : 10,
                        fontWeight: FontWeight.w600,
                      );
                    }
                    return  TextStyle(
                      fontSize: Platform.isIOS ? 13 : 9,
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

                  /*const NavigationDestination(icon: Icon(Icons.grid_view_outlined,size: 30), selectedIcon: Icon(Icons.grid_view,size: 30, color: C.blue), label: 'Shop Floor'),*/
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

                 /* const NavigationDestination(
                    icon: Icon(Icons.menu,size: 30),
                    selectedIcon: Icon(Icons.menu,size: 30, color: C.blue),
                    label: 'More',
                  ),*/

                ],
              ),
            ),
            body:Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  color:const Color(0xFFF5F7FB),
                  width: isDesktop ? 700 : double.infinity,
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
              child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(

                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(2)),

                          ),
                          child: Column(
                            children: [
                              Column(
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
                                                    fontSize: Platform.isIOS ? 16 : 11.5,
                                                  ),
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                data.iNVCNUMB ?? "",
                                                style: GoogleFonts.lato(
                                                  fontSize: Platform.isIOS ? 17 : 13,
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
                                              fontSize:  Platform.isIOS ? 16 : 11,
                                              color: Colors.black87,
                                            ),
                                          ),

                                          const SizedBox(height: 3),

                                          Text(
                                            "₹ ${data.dOCAMT}",
                                            style: GoogleFonts.lato(
                                              fontSize: Platform.isIOS ? 16 : 11,
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
                                                  fontSize: Platform.isIOS ? 13 : 10,
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
                                                  fontSize:  Platform.isIOS ? 21 : 18,
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

                                  /*  Container(
                                    width: Platform.isAndroid
                                        ? double.infinity
                                        : (MediaQuery.of(context).size.width *
                                        0.38),
                                    color: Colors.black,
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              data.iNVCNUMB!,
                                              style:  GoogleFonts.lato(
                                                fontSize: 16,
                                                color: Colors.white,

                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              data.iNVCDATE!,
                                              style: GoogleFonts.lato(
                                                fontSize: 16,
                                                color: Colors.white,

                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: Platform.isAndroid
                                        ? double.infinity
                                        : (MediaQuery.of(context).size.width *
                                        0.38),
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              data.iNVCTYPE!,
                                              style: GoogleFonts.lato(
                                                fontSize: 14,
                                                color: Colors.blue,

                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '\u{20B9}${data.dOCAMT!}',
                                              style: GoogleFonts.lato(
                                                fontSize: 14,
                                                color: Colors.blue,

                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: Platform.isAndroid
                                        ? double.infinity
                                        : (MediaQuery.of(context).size.width *
                                        0.38),
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                         Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Account",
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              color: Colors.blue,

                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            data.sLDESC?.toString() ?? "",
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              color: Colors.black,

                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: Platform.isAndroid
                                        ? double.infinity
                                        : (MediaQuery.of(context).size.width *
                                        0.38),
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                         Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "GL Account",
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              color: Colors.blue,

                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              data.gLDESC?.toString() ?? "",
                                              style: GoogleFonts.lato(
                                                fontSize: 14,
                                                color: Colors.black,

                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: Platform.isAndroid
                                        ? double.infinity
                                        : (MediaQuery.of(context).size.width *
                                        0.38),
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                         Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Release By",
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              color: Colors.blue,

                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              data.cREATEDBYNAME?.toString() ??
                                                  "",
                                              style: GoogleFonts.lato(
                                                fontSize: 14,
                                                color: Colors.black,

                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: Platform.isAndroid
                                        ? double.infinity
                                        : (MediaQuery.of(context).size.width *
                                        0.38),
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                         Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Due Date",
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              color: Colors.blue,

                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              data.dUEDATE?.toString() ?? "",
                                              style: GoogleFonts.lato(
                                                fontSize: 14,
                                                color: Colors.black,

                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),*/
                                ],
                              ),

                              const SizedBox(height: 0),
                              Container(
                                width: (Platform.isAndroid || Platform.isIOS)
                                    ? double.infinity
                                    : (MediaQuery.of(context).size.width * 0.38),
                                padding: const EdgeInsets.all(4),
                                child:  Text(
                                  "Remark",
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.lato(
                                    color: Colors.blue,
                                    fontSize: Platform.isIOS ? 16 : 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 0),
                              Container(
                                margin: const EdgeInsets.fromLTRB(12,0,12,12),
                                child: TextField(
                                  controller: rMARKController,
                                  minLines: 1,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: "Enter approval remarks...",
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 0),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      margin:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 10),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: SizedBox(
                                          width: (Platform.isAndroid || Platform.isIOS)
                                              ? double.infinity
                                              : SizeConfig.safeBlockHorizontal! *
                                              10,
                                          height:
                                          SizeConfig.safeBlockVertical! * 6,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF1C6FB5),
                                              minimumSize: const Size(
                                                double.infinity,
                                                55,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18),
                                              ),
                                            ),
                                            onPressed: () async {
                                              if (rMARKController
                                                  .text.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "Please Enter Remark"),
                                                  ),
                                                );
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return const Center(
                                                      child:
                                                      CircularProgressIndicator(),
                                                    );
                                                  },
                                                );
                                                CommonUtils commonUtils =
                                                CommonUtils();
                                                bool isConnectivity =
                                                await commonUtils.check();
                                                if (isConnectivity) {
                                                  ApproveRejectRequestModel
                                                  approverejectRequestModel =
                                                  ApproveRejectRequestModel();
                                                  approverejectRequestModel
                                                      .xMLFILE =
                                                      XMLFILE();
                                                  approverejectRequestModel
                                                      .xMLFILE!.sTATUSID =
                                                  "2";
                                                  approverejectRequestModel
                                                      .xMLFILE!.dOCID = data.dOCID;
                                                  approverejectRequestModel
                                                      .xMLFILE!.uSERID =
                                                      userId;
                                                  approverejectRequestModel
                                                      .xMLFILE!.fLAG = "I";
                                                  approverejectRequestModel
                                                      .xMLFILE!.mENUID =
                                                      data.mENUID;
                                                  approverejectRequestModel
                                                      .xMLFILE!.iD = data.iD;
                                                  approverejectRequestModel
                                                      .xMLFILE!
                                                      .iSNEXTLVLUSER =
                                                  "0";
                                                  approverejectRequestModel
                                                      .xMLFILE!.mID =
                                                      data.mID.toString();
                                                  approverejectRequestModel
                                                      .xMLFILE!
                                                      .nEXTLVLREMARK =
                                                  "0";
                                                  approverejectRequestModel
                                                      .xMLFILE!
                                                      .oRGSTRUCID =
                                                      orgStructId;
                                                  approverejectRequestModel
                                                      .xMLFILE!.controlno = controlno;
                                                  approverejectRequestModel
                                                      .xMLFILE!.pOSID = posId;
                                                  approverejectRequestModel
                                                      .xMLFILE!.rEMARK =
                                                      rMARKController.text;
                                                  approverejectRequestModel
                                                      .xMLFILE!.tOKEN =
                                                      token;

                                                  ApproveRejectResponseModel
                                                  response = await Provider
                                                      .of<ApprovalsController>(
                                                      context,
                                                      listen: false)
                                                      .GetApproveReject(
                                                    approverejectRequestModel,
                                                    context,
                                                  );
                                                  Navigator.of(context)
                                                      .pop(); // Dismiss loader
                                                  if (response != null) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(response
                                                            .data
                                                            ?.errormsgs ??
                                                            ""),
                                                      ),
                                                    );
                                                    Navigator.pop(context, true);



                                                  }
                                                } else {
                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "Please check Internet Connection"),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            child: TextControll(
                                              value: 'Approve',
                                              textStyle: GoogleFonts.lato(
                                                color: Colors.white,

                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 10),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: SizedBox(
                                          width:(Platform.isAndroid || Platform.isIOS)
                                              ? double.infinity
                                              : SizeConfig.safeBlockHorizontal! *
                                              10,
                                          height:
                                          SizeConfig.safeBlockVertical! * 6,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFE0922F),
                                              minimumSize: const Size(
                                                double.infinity,
                                                55,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(18),
                                              ),
                                            ),
                                            onPressed: () async {
                                              if (rMARKController
                                                  .text.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "Please Enter Remark"),
                                                  ),
                                                );
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return const Center(
                                                      child:
                                                      CircularProgressIndicator(),
                                                    );
                                                  },
                                                );
                                                CommonUtils commonUtils =
                                                CommonUtils();
                                                bool isConnectivity =
                                                await commonUtils.check();
                                                if (isConnectivity) {
                                                  ApproveRejectRequestModel
                                                  approverejectRequestModel =
                                                  ApproveRejectRequestModel();
                                                  approverejectRequestModel
                                                      .xMLFILE =
                                                      XMLFILE();
                                                  approverejectRequestModel
                                                      .xMLFILE!.sTATUSID =
                                                  "3";
                                                  approverejectRequestModel
                                                      .xMLFILE!.dOCID = data.dOCID;
                                                  approverejectRequestModel
                                                      .xMLFILE!.uSERID =
                                                      userId;
                                                  approverejectRequestModel
                                                      .xMLFILE!.fLAG = "R";
                                                  approverejectRequestModel
                                                      .xMLFILE!.mENUID =
                                                      data.mENUID;
                                                  approverejectRequestModel
                                                      .xMLFILE!.iD = data.iD;
                                                  approverejectRequestModel
                                                      .xMLFILE!
                                                      .iSNEXTLVLUSER =
                                                  "0";
                                                  approverejectRequestModel
                                                      .xMLFILE!.mID =
                                                      data.mID.toString();
                                                  approverejectRequestModel
                                                      .xMLFILE!
                                                      .nEXTLVLREMARK =
                                                  "0";
                                                  approverejectRequestModel
                                                      .xMLFILE!
                                                      .oRGSTRUCID =
                                                      orgStructId;
                                                  approverejectRequestModel
                                                      .xMLFILE!.controlno = controlno;
                                                  approverejectRequestModel
                                                      .xMLFILE!.pOSID = posId;
                                                  approverejectRequestModel
                                                      .xMLFILE!.rEMARK =
                                                      rMARKController.text;
                                                  approverejectRequestModel
                                                      .xMLFILE!.tOKEN =
                                                      token;

                                                  ApproveRejectResponseModel
                                                  response = await Provider
                                                      .of<ApprovalsController>(
                                                      context,
                                                      listen: false)
                                                      .GetApproveReject(
                                                    approverejectRequestModel,
                                                    context,
                                                  );
                                                  Navigator.of(context).pop();
                                                  if (response != null) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(response
                                                            .data
                                                            ?.errormsgs ??
                                                            ""),
                                                      ),
                                                    );
                                                    //Navigator.pop(context);
                                                    Navigator.pop(context, true);
                                                  }
                                                } else {
                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "Please check Internet Connection"),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            child: TextControll(
                                              value: 'Reject',
                                              textStyle: GoogleFonts.lato(
                                                color: Colors.white,

                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 0),
                              MouseRegion(
                                onHover: (_) {},
                                child: GestureDetector(
                                  onTap: () {
                                    var fileName = data.mID! +
                                        (data.rPTID == null
                                            ? "0"
                                            : data.rPTID!);
                                    openDoc(
                                      context: context,
                                      fileName: fileName,
                                      fileExtension: "pdf",
                                      fileUrl: "",
                                    );
                                  },
                                  child: Container(
                                    width: SizeConfig.safeBlockHorizontal! * 100,
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(0.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Container(

                                          padding: const EdgeInsets.all(4.0),
                                          child:  Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "View Documents",
                                              style: GoogleFonts.lato(
                                                fontSize: Platform.isIOS ? 16 : 14,
                                                color: Colors.black,

                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(4.0),
                                          child: const Align(
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.view_list,
                                              size: 30.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (data.aTTCHMNTINFO?.aTTACHMENTS?.iNFO != null)
                                MouseRegion(
                                  onHover: (_) {},
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      height: (100.0 *
                                          (data.aTTCHMNTINFO!
                                              .aTTACHMENTS!
                                              .iNFO!
                                              .length)) +
                                          100,
                                      child: Column(
                                        children: [
                                          Container(
                                            width:
                                            SizeConfig.safeBlockHorizontal! *
                                                100,
                                            color: Colors.white,
                                            padding: const EdgeInsets.all(12.0),
                                            child:  Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Attachment File",
                                                style: GoogleFonts.lato(
                                                  fontSize: Platform.isIOS ? 18 : 14,
                                                  color: Colors.black,

                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: data
                                                  .aTTCHMNTINFO!
                                                  .aTTACHMENTS!
                                                  .iNFO!
                                                  .length,
                                              itemBuilder: (context, index) {
                                                final info = data
                                                    .aTTCHMNTINFO!
                                                    .aTTACHMENTS!
                                                    .iNFO![index];
                                                return SizedBox(
                                                  height: 100,
                                                  child: ListTile(
                                                    onTap: () {
                                                      openFile(
                                                        info.nEWFILENAME
                                                            .toString(),
                                                        info.eXTENSION
                                                            .toString(),
                                                        "${AppConfig.BASE_URL}${info.dOWNLOADURL}",
                                                        info.fOLDERNAME
                                                            .toString(),
                                                      );
                                                    },
                                                    title: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 1.5),
                                                      child: Container(
                                                        decoration:
                                                        const BoxDecoration(
                                                          color: Colors.white,
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .only(
                                                            right: 10,
                                                            bottom: 10,
                                                            top: 10,
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  "File Type-${info.eXTENSION}",
                                                                  style:
                                                                  GoogleFonts.lato(
                                                                    fontSize: Platform.isIOS ? 18 : 14,
                                                                    color: Colors
                                                                        .red,

                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 5),
                                                              Align(
                                                                alignment:
                                                                Alignment
                                                                    .center,
                                                                child: Text(
                                                                  info.nEWFILENAME
                                                                      .toString(),
                                                                  style:
                                                                  GoogleFonts.lato(
                                                                    fontSize: Platform.isIOS ? 18 : 14,
                                                                    color: Colors
                                                                        .black,

                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                  ),
                                                                ),
                                                              ),
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
                                          const Divider(
                                            color: Colors.grey,
                                            height: 20,
                                            thickness: 1,
                                            indent: 20,
                                            endIndent: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              Container(
                                width: SizeConfig.safeBlockHorizontal! * 100,
                                color: Colors.white,
                                padding: const EdgeInsets.all(0.0),
                                child:  Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Approval History",
                                    style: GoogleFonts.lato(
                                      fontSize: Platform.isIOS ? 21 : 14,
                                      color: Colors.blue,


                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: FutureBuilder<GetApproveHistoryResponseModel>(
                            key: ValueKey(
                                '${data.dOCID}_${data.mENUID}_${data.mID}'), // helps avoid rebuild issues
                            future: ApproveHistoryapicall(
                              context,
                              data.dOCID!,
                              data.mENUID!,
                              data.mID!,
                              loginResponseModel!.data!.orgstrucid?? "",
                              loginResponseModel!.data!. posid?? "",
                              loginResponseModel!.data!.token?? "",
                              loginResponseModel!.data!.userid?? "",
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                GetApproveHistoryResponseModel?
                                approveResponseModel = snapshot.data;
                                if (approveResponseModel != null &&
                                    approveResponseModel.data != null) {
                                  return SingleChildScrollView(
                                    child: Column(
                                      children: <Widget>[
                                        for (int k = 0;
                                        k <
                                            approveResponseModel
                                                .data!.list.length;
                                        k++) ...[
                                          Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${approveResponseModel.data!.list[k].releasecount!} Release',
                                                textAlign: TextAlign.start,
                                                style: GoogleFonts.lato(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize:Platform.isIOS ? 18 : 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(color: Colors.grey),
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
                                          ],
                                          const SizedBox(width: 100, height: 5),
                                        ],
                                      ],
                                    ),
                                  );
                                } else {
                                  return  Center(
                                    child: Text(
                                      "No Records to display",
                                      style: GoogleFonts.lato(fontSize: 14),
                                    ),
                                  );
                                }
                              }
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 20, bottom: 20),
                                  child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
                        fontSize:Platform.isIOS ? 18 : 14,
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
                          fontSize:Platform.isIOS ? 13 : 11,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      date,
                      style: GoogleFonts.lato(
                        color: Colors.grey,
                        fontSize: Platform.isIOS ? 13 : 11,
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
  Future<GetApproveHistoryResponseModel> ApproveHistoryapicall(
      BuildContext context,
      String strDocid,
      String strMenuId,
      String strMid,
      String strOrgstuctid,
      String strPostId,
      String strToken,
      String strUserId,
      ) async {
    try {
      CommonUtils commonUtils = CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {
        if (!mounted) {
          return approvehistoryresponse;
        }
        GetApproveHistoryRequestModel approvehistoryrequestmodel =
        GetApproveHistoryRequestModel();
        approvehistoryrequestmodel.xMLFILE = XMLFILEAPPROVEHISTORY();
        approvehistoryrequestmodel.xMLFILE!.dOCID = strDocid;
        approvehistoryrequestmodel.xMLFILE!.fLAG = "1";
        approvehistoryrequestmodel.xMLFILE!.fROMDATE = "";
        approvehistoryrequestmodel.xMLFILE!.mENUID = strMenuId;
        approvehistoryrequestmodel.xMLFILE!.mID = strMid;
        approvehistoryrequestmodel.xMLFILE!.oRGSTRUCTID = orgStructId;
        approvehistoryrequestmodel.xMLFILE!.controlno = controlno;
        approvehistoryrequestmodel.xMLFILE!.pAGENO = 1;
        approvehistoryrequestmodel.xMLFILE!.pOSID = strPostId;
        approvehistoryrequestmodel.xMLFILE!.tODATE = "";
        approvehistoryrequestmodel.xMLFILE!.tOKEN = strToken;
        approvehistoryrequestmodel.xMLFILE!.uSERID = strUserId;

        approvehistoryresponse =
        await Provider.of<ApprovalsController>(context, listen: false)
            .GetApprovalHistory(approvehistoryrequestmodel, context);

        print(
            'apporval details-------------> ${approvehistoryresponse.data?.toString()}');
      } else {
        return approvehistoryresponse;
      }
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
    }
    return approvehistoryresponse;
  }
}
