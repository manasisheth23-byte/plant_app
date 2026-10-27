import 'dart:io';

//import 'package:device_apps/device_apps.dart';

import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/helpers/api_helpers.dart';
import 'package:erpflutter/helpers/api_request.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/utils/loading_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:erpflutter/screens/konowledgebase/commanfileweb.dart';

import '../../app_colors.dart';
import '../../models/product_details_model.dart';
import '../../provider/themecontroller.dart';
import '../../services/ApiProvider.dart';

class WebViewChart extends StatefulWidget {
  final String solId;
  final String title;
  final String sofolder;

  const WebViewChart({
    Key? key,
    required this.solId,
    required this.title,
    required this.sofolder,
  }) : super(key: key);

  @override
  State<WebViewChart> createState() => _WebViewChartState();
}

class _WebViewChartState extends State<WebViewChart> {
  bool isLoading = true;
  ProductsDetailsModel? dataModel;
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchData());
  }

  Future<void> fetchData() async {
    final result =
    await ApiProvider().getProductDetails(widget.solId, widget.sofolder);
    setState(() {
      dataModel = result;
      isLoading = false;
    });
  }

  void _openInWebView(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InAppWebViewScreen(url: url),
      ),
    );
  }
  Future<String> downloadAndSaveFile(String url, String fileName) async {

    try {
      Uri struri = Uri.parse(url);
      /* if (kIsWeb) {
        // Web download
        final response = await http.get(struri);

        if (response.statusCode != 200) {
          throw Exception("Failed to download file. Status code: ${response.statusCode}");
        }

        final bytes = response.bodyBytes;
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);

        return "Downloaded via browser";
      } else*/ {
        // Show loading dialog
        showLoadingDialog(context, message: 'Downloading file...');

        // Make the API request
        final response = await ApiRequest.get(url: url);

        // Check the response status
        if (response.statusCode != 200) {
          Navigator.of(context, rootNavigator: true).pop();
          // Navigator.pop(context);
          throw Exception(
              "Failed to download file. Status code: ${response.statusCode}");
        }

        // Get the external storage directory
        Directory? directory;
        //= await getExternalStorageDirectory();
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
        } else {
          directory = await getApplicationDocumentsDirectory(); // Safe fallback
        }
        if (directory == null) {
          Navigator.of(context, rootNavigator: true).pop();
          // Navigator.pop(context);
          throw Exception("External storage directory not found");
        }

        // Create the attachments directory
        final attachmentsDir = Directory('${directory.path}/AttachmentsFile');
        if (!await attachmentsDir.exists()) {
          await attachmentsDir.create(recursive: true);
        }

        // Save the file $fileName
        final file = File("${attachmentsDir.path}/$fileName");
        await file.writeAsBytes(response.bodyBytes, flush: true);

        // Navigator.pop(context); // Dismiss loading dialog
        Navigator.of(context, rootNavigator: true).pop();
        // Verify if the file exists
        if (await file.exists()) {
          return file.path;
        } else {
          throw Exception("File could not be saved");
        }
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("DB insert error: $e")),
      );// Ensure the dialog is dismissed on error
      print("Error: $e");
      return '';
    }
  }


  /* Future<void> downloadFileWeb(String url, String fileName) async {
    try {
      // Show loading dialog if you have one
      showLoadingDialog(context, message: 'Downloading file...');

      final response =  await ApiRequest.get(url: url);
      //ApiRequest.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception("Failed to download file. Status code: ${response.statusCode}");
      }

      // Convert response bytes to blob
      final blob = html.Blob([response.bodyBytes]);
      final urlBlob = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: urlBlob)
        ..setAttribute("download", fileName)
        ..click();

      html.Url.revokeObjectUrl(urlBlob); // Clean up

      Navigator.of(context, rootNavigator: true).pop(); // Dismiss dialog
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(); // Ensure dialog is dismissed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download error: $e")),
      );
      print("Error: $e");
    }
  }
*/
  /*Future<void> openFile(String fileName, String fileExtension, String fileurl,String folderName) async {


    Directory? dir;

    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory(); // Safe fallback
    }

    if (dir != null) {
      //final filePath = '${dir.path}/AttachmentsFile/$fileName' ?? '';
      bool exists =

      await File('${dir!.path}/AttachmentsFile/$fileName' ?? '')
          .exists();
      if(Platform.isAndroid){
        if (!(await Permission.storage.isGranted)) {
          await Permission.storage.request();
        }
      }
      if (exists) {
        print('File exists--->');
        try {
          await OpenFile.open('${dir.path}/AttachmentsFile/$fileName');
        } catch (e) {
          print('$e');
        }
      } else {

        String path = await downloadAndSaveFile(
            AppConfig.BASE_URL +
                "/CommonLibrary/GetFile" +
                '?FolderName=$folderName&FileName=$fileName',
            fileName);
        print(path);
        if (path.isNotEmpty) {
          try {
            await OpenFile.open(path);
          } catch (e) {
            print('$e');
          }
        }
      }
      // Open or use file here
      //print("File path: $filePath");
    }
  }*/


  Future<void> openFile(String fileName, String fileExtension, String fileUrl, String folderName,BuildContext context) async {

    if (kIsWeb) {

      WebViewAll.openFileweb(fileName, fileUrl);
    } else {

      Directory? dir;

      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory(); // Safe fallback
      }

      if (dir != null) {
        //final filePath = '${dir.path}/AttachmentsFile/$fileName' ?? '';
        bool exists =

        await File('${dir!.path}/AttachmentsFile/$fileName' ?? '')
            .exists();
        if(Platform.isAndroid){
          if (!(await Permission.storage.isGranted)) {
            await Permission.storage.request();
          }
        }
        if (exists) {
          print('File exists--->');
          try {
            if (Platform.isAndroid) {
              openImage('${dir.path}/AttachmentsFile/$fileName',context);
            }else{
              await OpenFile.open('${dir.path}/AttachmentsFile/$fileName');
            }


          } catch (e) {
            print('$e');
          }
        } else {

          String path = await downloadAndSaveFile(

              fileUrl,
              fileName);
          print(path);
          if (path.isNotEmpty) {
            try {
              if (Platform.isAndroid) {
               // openImage(path,context);
              }else{
                await OpenFile.open(path);
              }
             // await OpenFile.open(path);
            } catch (e) {
              print('$e');
            }
          }
        }
        // Open or use file here
        //print("File path: $filePath");
      }
      // await openFileNative(fileName, fileUrl);
    }
    /*   if (kIsWeb) {
      // Web: trigger browser download
      try {
        final anchor = html.AnchorElement(href: AppConfig.BASE_URL +
            "/CommonLibrary/GetFile" +
            '?FolderName=$folderName&FileName=$fileName')
          ..setAttribute("download", fileName)
          ..click();
        print("File downloaded via browser: $fileName");
      } catch (e) {
        print("Error downloading file on web: $e");
      }
    }
    else {

      Directory? dir;

      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
        if (!(await Permission.storage.isGranted)) {
          await Permission.storage.request();
        }
      } else {
        dir = await getApplicationDocumentsDirectory(); // iOS, Windows
      }

      if (dir != null) {
        final filePath = '${dir.path}/AttachmentsFile/$fileName';
        final file = File(filePath);

        if (await file.exists()) {
          // File exists locally, open it
          try {
            await OpenFile.open(filePath);
          } catch (e) {
            print("Error opening existing file: $e");
          }
        } else {
          // File does not exist, download and save
          try {
            String path = await downloadAndSaveFile(AppConfig.BASE_URL +
                "/CommonLibrary/GetFile" +
                '?FolderName=$folderName&FileName=$fileName', fileName);
            if (path.isNotEmpty) {
              await OpenFile.open(path);
            }
          } catch (e) {
            print("Error downloading/opening file: $e");
          }
        }
      }
    }*/
  }
/*  Future<bool> isHmiDevice() async {
    // HMI has only HiGallery installed
    return await DeviceApps.isAppInstalled('com.hisilicon.higallery');
  }*/
  Future<void> openImage(String filePath, BuildContext context) async {
  /*  bool isHmi = await DeviceApps.isAppInstalled('com.hisilicon.higallery');

    if (isHmi) {
      // On HMI, open images internally, others show message
      if (filePath.endsWith('.png') || filePath.endsWith('.jpg') ||
          filePath.endsWith('.jpeg')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                Scaffold(
                  appBar: AppBar(backgroundColor: AppColors.APPCOLOR,
                      foregroundColor: Colors.white,
                      title: Text("Preview")),
                  body: PhotoView(imageProvider: FileImage(File(filePath))),
                ),
          ),
        );
      } else {
        // Unsupported file type on HMI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cannot open this file on HMI")),
        );
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              Scaffold(
                appBar: AppBar(title: Text("Preview")),
                body: PhotoView(
                  imageProvider: FileImage(File(filePath)),
                ),
              ),
        ),
      );
    }
    else*/{
      await OpenFile.open(filePath);
    }
  }
  int _idx = 0;
  Widget build(BuildContext context) {
    final solution = dataModel?.sOLDETAILS?.sOLUTIONS?.isNotEmpty ?? false
        ? dataModel!.sOLDETAILS!.sOLUTIONS!.first
        : null;
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    final attachments =
        solution?.aTTCHMNTINFO?.aTTACHMENTS?.iNFO ?? [];
    themeController = Provider.of(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return Center(
      child: SizedBox(
        width: isDesktop ? 700 : double.infinity,
        child: Scaffold(
          appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Center(
        child: SizedBox(
        width: isDesktop ? 700 : double.infinity,
        child:AppBar(
            title: Text(widget.title, style:
            GoogleFonts.lato(

              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            )),
            centerTitle: true,
            backgroundColor:  themeController.primaryColor,
            foregroundColor: Colors.white,
          )))),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                    (states) {
                  if (states.contains(MaterialState.selected)) {
                    return const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    );
                  }
                  return const TextStyle(
                    fontSize: 9,
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
       /*         Navigator.pushReplacement(
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

                /* const NavigationDestination(
                      icon: Icon(Icons.menu,size: 30),
                      selectedIcon: Icon(Icons.menu,size: 30, color: C.blue),
                      label: 'More',
                    ),*/

              ],
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  color:const Color(0xFFF5F7FB),
                  width: isDesktop ? 700 : double.infinity,
                  padding: const EdgeInsets.all(10),
                  child:SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (solution != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: HtmlWidget(
                      solution.dESCRIPTION ?? "",
                      onTapUrl: (url) async {
                        _openInWebView(url);
                        return true;
                      },
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No product details available"),
                  ),

                const SizedBox(height: 20),

                // 📂 Attachments Section
                if (attachments.isNotEmpty) ...[
                  const Text(
                    "Attachments:",
                    style:
                    TextStyle(fontWeight:FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
        if (Platform.isAndroid) ...[
          SizedBox(
            height: 80.0 * attachments!.length, // height of horizontal list
            child: ListView.builder(

              scrollDirection: Axis.vertical,
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final file = attachments[index];
                return Card(
                  color:  themeController.primaryColor,
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: () {
                        openFile(
                          file.nEWFILENAME.toString(),
                          file.eXTENSION.toString(),
                          "${AppConfig.RAW_BASE_URL}${file.dOWNLOADURL}",
                          file.fOLDERNAME.toString(),
                          context,
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file, color: Colors.white),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  file.oRIGINALFILENAME ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis, // 👈 prevents overflow
                                ),
                                Text(
                                  file.eXTENSION ?? "",
                                  style: const TextStyle(color: Colors.white70),
                                  overflow: TextOverflow.ellipsis, // optional
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                             /* openFile(
                                file.nEWFILENAME.toString(),
                                file.eXTENSION.toString(),
                                "${AppConfig.RAW_BASE_URL}${file.dOWNLOADURL}",
                                file.fOLDERNAME.toString(),
                                context,
                              );*/
                            },
                            child: const Icon(Icons.download, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

              },
            ),
          )
        ]else...[
          SizedBox(
            height: 80, // height of horizontal list
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final file = attachments[index];
                return Card(
                  color:  themeController.primaryColor,
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // 👈 wrap content
                      children: [
                        const Icon(Icons.attach_file, color: Colors.white),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              file.oRIGINALFILENAME ?? "",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                            Text(
                              file.eXTENSION ?? "",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            openFile(
                              file.nEWFILENAME.toString(),
                              file.eXTENSION.toString(),
                              "${AppConfig.RAW_BASE_URL}${file.dOWNLOADURL}",
                              file.fOLDERNAME.toString(),
                              context,
                            );
                          },
                          child: const Icon(Icons.download, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],






                ],
              ],
            ),
          ))),
        ),
      ),
    );
  }
}

class InAppWebViewScreen extends StatefulWidget {
  final String url;
  const InAppWebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  late final WebViewController _controller;
  WebviewController? _windowsController;
  double _progress = 0.0;
  bool _windowsReady = false;
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.url));
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      _windowsController = WebviewController();
      _initWindowsWebView();
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (progress) =>
                setState(() => _progress = progress / 100.0),
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  Future<void> _initWindowsWebView() async {
    if (_windowsController == null) return;
    await _windowsController!.initialize();
    await _windowsController!.loadUrl(widget.url);
    setState(() => _windowsReady = true);
  }

  @override
  void dispose() {
    _windowsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    themeController = Provider.of(context, listen: false);

    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      body = WebViewWidget(controller: _controller);
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      body = _windowsReady
          ? Webview(_windowsController!)
          : const Center(child: CircularProgressIndicator());
    } else {
      body =
      const Center(child: Text('WebView not supported on this platform'));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeController.primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          widget.url.length > 30
              ? "${widget.url.substring(0, 30)}..."
              : widget.url,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          if (!kIsWeb && defaultTargetPlatform != TargetPlatform.windows)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.reload(),
            ),
        ],
        bottom: _progress < 1.0 &&
            !kIsWeb &&
            defaultTargetPlatform != TargetPlatform.windows
            ? PreferredSize(
          preferredSize: const Size.fromHeight(3.0),
          child: LinearProgressIndicator(value: _progress),
        )
            : null,
      ),
      body: body,
    );
  }
}