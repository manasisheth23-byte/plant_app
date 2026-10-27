import 'dart:convert';
import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome, rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import 'BoldReportList.dart';

class BoldBIDashboardViewerScreen extends StatefulWidget {
  final String dashboardId;
  final String userID;

  const BoldBIDashboardViewerScreen({
    super.key,
    required this.dashboardId,
    required this.userID,
  });

  @override
  State<BoldBIDashboardViewerScreen> createState() =>
      _BoldBIDashboardViewerScreenState();
}

class _BoldBIDashboardViewerScreenState
    extends State<BoldBIDashboardViewerScreen> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();

    // Lock orientation to landscape only (Android/iOS only)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _loadDashboard();
  }
  Future<void> _loadDashboard() async {
    try {
      final String apiUrl =
          "${AppConfig.RAW_BASE_URL}/BIDashboard/GetBIServerDetails";

      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("ServerUrl: ${data['ServerUrl']}");
        debugPrint("SiteIdentifier: ${data['SiteIdentifier']}");

        // Load local HTML
        String htmlString =
        await rootBundle.loadString('assets/js/boldbi_dashbordandroid.html');

        final controller = WebViewController();

        controller
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) async {
                debugPrint("Local HTML finished loading");

                // Inject dashboard details (must be JSON.stringify-ed)
               /* final js = """
                window.postMessage(JSON.parse('${jsonEncode({
                  '__DASHBOARD_ID__': widget.dashboardId,
                  '__URL__': AppConfig.RAW_BASE_URL + "/BIDashboard/AuthorizationServer?UserID=335",
                  '__SERVER_URL__': "${data['ServerUrl']}/${data['SiteIdentifier']}",
                  '__USER_ID__' : widget.userID,
                })}'), '*');
              """;
               print("JS code: $js");*/
                final dataMap = {
                  '__DASHBOARD_ID__': widget.dashboardId,
                  '__URL__': AppConfig.RAW_BASE_URL + "/BIDashboard/AuthorizationServer?UserID="+widget.userID,
                  '__SERVER_URL__': "${data['ServerUrl']}/${data['SiteIdentifier']}",
                  '__USER_ID__': widget.userID,
                };

              print("Data to inject: $dataMap");

                final js = """
    window.postMessage(${jsonEncode(dataMap)}, '*');
  """;

                print("JS code: $js");
                //  print("Injected data to WebView: ${jsonEncode(js)}");
                //print("url: $url ");
                await controller.runJavaScript(js);

              },
            ),
          )
          ..loadHtmlString(htmlString); // load after setting delegate

        setState(() {
          _controller = controller;
        });
      } else {
        throw Exception('Failed to load server details');
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
      }
    }
  }

  /*Future<void> _loadDashboard() async {
    try {
      final String apiUrl =
          "${AppConfig.RAW_BASE_URL}/BIDashboard/GetBIServerDetails";

      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("ServerUrl: ${data['ServerUrl']}");
        debugPrint("SiteIdentifier: ${data['SiteIdentifier']}");

        // Load local HTML
        String htmlString =
        await rootBundle.loadString('assets/js/boldbi_dashboard.html');

        // Setup controller
        final controller = WebViewController();
        controller
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) async {
                debugPrint("Local HTML loaded: $url");

                // Now inject dashboard details after HTML page is ready
                String js = """
                window.postMessage(${jsonEncode({
                  '__DASHBOARD_ID__': widget.dashboardId,
                  '__URL__': AppConfig.RAW_BASE_URL + "/BIDashboard/AuthorizationServer",
                  '__SERVER_URL__': "${data['ServerUrl']}/${data['SiteIdentifier']}",
                })}, '*');
              """;

                await controller.runJavaScript(js);
              },
            ),
          );

        // 👉 load HTML only after controller setup
        await controller.loadHtmlString(htmlString);

        setState(() {
          _controller = controller;
        });
      } else {
        throw Exception('Failed to load server details');
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
      }
    }
  }*/

  /*Future<void> _loadDashboard() async {
    try {
      final String apiUrl =
          "${AppConfig.RAW_BASE_URL}/BIDashboard/GetBIServerDetails";

      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("ServerUrl: ${data['ServerUrl']}");
        debugPrint("SiteIdentifier: ${data['SiteIdentifier']}");
        // Load local HTML
        String htmlString =
        await rootBundle.loadString('assets/js/boldbi_dashboard.html');

        // Setup controller
        final controller = WebViewController();
        controller
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) async {
                // Inject dashboard details after page load
                String js = """
                  window.postMessage(${jsonEncode({
                  '__DASHBOARD_ID__': widget.dashboardId,
                  '__URL__': AppConfig.RAW_BASE_URL+"/BIDashboard/AuthorizationServer",
                  '__SERVER_URL__': "${data['ServerUrl']}/${data['SiteIdentifier']}",
                })}, '*');
                """;

                controller.runJavaScript(js);
              },
            ),
          )
          ..loadHtmlString(htmlString);

        setState(() {
          _controller = controller;
        });
      } else {
        throw Exception('Failed to load server details');
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
        );
      }
    }
  }
*/
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return PopScope(
        canPop: true, // prevent default back behavior
        onPopInvoked: (didPop) {
          print("Mobile back pressed");

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BoldReportListScreen()),
          );
        },
        child:  Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.APPCOLOR,
        foregroundColor: Colors.white,
        title:  Text("Dashboard",style:  GoogleFonts.lato(

          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Do something before going back
            print("Back pressed");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      BoldReportListScreen()),
            );
          },
        ),
      ),
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
                final plantName = context.read<PlantProvider>().plantName;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppShell(
                      role: "Admin",
                      plant: plantName,
                      selectedIndex: index,

                    ),
                  ),
                );
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
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller!),
    ));
  }
}

/*
class BoldBIDashboardViewerScreen extends StatefulWidget {
  final String dashboardId;
  const BoldBIDashboardViewerScreen({
    super.key, required this.dashboardId
  });
  @override
  State<BoldBIDashboardViewerScreen> createState() => _BoldBIDashboardViewerScreenState();
}

class _BoldBIDashboardViewerScreenState extends State<BoldBIDashboardViewerScreen> {
  WebViewController? _controller;

  */
/* final String xmlPayload = '''
<XMLFILE>
  <SPXML>
    <SPDETAILS FLAG="1" ORGSTRUCID="0" RULEID="583" USERID="3242" />
  </SPXML>
</XMLFILE>
''';*/
/*


  @override
  void initState() {
    super.initState();

    // Lock orientation to landscape only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _loadDashboard();

  }
  Future<void> _loadDashboard() async {
    try {

      // await _controller.initialize();
      final String apiUrl = AppConfig.RAW_BASE_URL+'/BIDashboard/GetBIServerDetails';
      //final String apiUrl = AppConfig.BASE_URL+'/BIDashboard/GetBIServerDetails';
      // 1. API Call
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 2. Load local HTML
        String htmlString = await rootBundle.loadString('assets/js/boldbi_dashboard.html');

        // 3. Replace placeholders

        // 4. Encode and load into WebView
         */
/* final encodedHtml = Uri.dataFromString(
          htmlString,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ).toString();*/
/*

             String encodedHtml = """
  window.postMessage(${jsonEncode({
          '__DASHBOARD_ID__': widget.dashboardId ?? '',
               '__URL__': AppConfig.RAW_BASE_URL+"/BIDashboard/AuthorizationServer",
          '__SERVER_URL__': data['ServerUrl']+"/"+data['SiteIdentifier'] ?? '',

        })}, '*');
""";
          _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
              NavigationDelegate(
                  onPageFinished: (url) async {
                    // Send the XML payload using postMessage
                    // String sanitizedXml = widget.xmlPayload.replaceAll('\n', '').replaceAll("'", "\\'");

                    _controller!.runJavaScript(encodedHtml);
                  }
              ));
        final controller = WebViewController();
        controller
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(NavigationDelegate(
            onPageFinished: (url) {
              // controller.runJavaScript(encodedHtml); // ✅ Now it's safe
            },
          ))
          ..loadHtmlString(htmlString);

        setState(() {
          _controller = controller;

        });
      } else {
        throw Exception('Failed to load server details');
      }
    } catch (e) {
      debugPrint('Error: $e');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator()) // ✅ Show loader while loading
          : WebViewWidget(controller: _controller!), // ✅ Safe usage
    );
  }

}
*/
