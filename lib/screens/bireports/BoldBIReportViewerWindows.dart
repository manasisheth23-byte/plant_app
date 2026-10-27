import 'dart:convert';
import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:webview_windows/webview_windows.dart';

class BoldBIWindowsScreen extends StatefulWidget {
  final String dashboardId;
  final String userID;
  const BoldBIWindowsScreen({super.key, required this.dashboardId,required this.userID});

  @override
  State<BoldBIWindowsScreen> createState() => _BoldBIWindowsScreenState();
}

class _BoldBIWindowsScreenState extends State<BoldBIWindowsScreen> {
  final _controller = WebviewController();
  bool _isWebViewReady = false;
  final String apiUrl = AppConfig.RAW_BASE_URL+'/BIDashboard/GetBIServerDetails';
 // final String apiUrl = 'http://10.0.0.223:8444/BIDashboard/GetBIServerDetails';

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      await _controller.initialize();

      // 1. API Call
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 2. Load local HTML
        String htmlString = await rootBundle.loadString('assets/js/boldbi_dashboard.html');

        // 3. Replace placeholders
        htmlString = htmlString
            .replaceAll('__DASHBOARD_ID__',widget.dashboardId ?? '')
            .replaceAll('__URL__', AppConfig.RAW_BASE_URL+"/BIDashboard/AuthorizationServer?UserID="+widget.userID!,)
            .replaceAll('__SERVER_URL__', data['ServerUrl']+"/"+data['SiteIdentifier'] ?? '');


        // 4. Encode and load into WebView
        final encodedHtml = Uri.dataFromString(
          htmlString,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ).toString();

        await _controller.loadUrl(encodedHtml);
// Open Chrome DevTools to debug JS/CORS errors
       //await _controller.openDevTools();
        setState(() {
          _isWebViewReady = true;
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
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.APPCOLOR,
          foregroundColor: Colors.white,
          title: Text("Dashboard",style: GoogleFonts.lato(

            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),)),
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
      body: _isWebViewReady
          ? Webview(_controller)
          : Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
