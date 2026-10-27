// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

class BoldBIDashboardWeb extends StatefulWidget {
  final String dashboardId;

  const BoldBIDashboardWeb({super.key, required this.dashboardId});

  @override
  State<BoldBIDashboardWeb> createState() => _BoldBIDashboardWebState();
}

class _BoldBIDashboardWebState extends State<BoldBIDashboardWeb> {
  late final String _viewType;
  late final html.DivElement _container;
  bool hasError = false;

  @override
  void initState() {
    super.initState();

    _viewType =
    "boldbi_${widget.dashboardId}_${DateTime.now().millisecondsSinceEpoch}";

    _container = html.DivElement()
      ..id = "dashboard_${widget.dashboardId}"
      ..style.width = "100%"
      ..style.height = "100%";

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
          (int viewId) => _container,
    );

    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final response = await http.get(Uri.parse(
          "${AppConfig.RAW_BASE_URL}/BIDashboard/GetBIServerDetails"));
      SharedPreferences prefs = await SharedPreferences
          .getInstance();
      String? UserID = prefs.getString('USERID');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final serverUrl = "${data['ServerUrl']}/${data['SiteIdentifier']}";
        //+widget.userId
        final authUrl =
            "${AppConfig.RAW_BASE_URL}/BIDashboard/AuthorizationServer?UserID="+UserID!;

        // Inject SDK if not already
        if (html.document.getElementById("boldbi_sdk") == null) {
          final script = html.ScriptElement()
            ..id = "boldbi_sdk"
            ..src =
                "https://cdn.boldbi.com/embedded-sdk/latest/boldbi-embed.js"
            ..type = "text/javascript";

          script.onLoad.listen((event) {
            _initDashboard(serverUrl, authUrl);
          });

          html.document.body?.append(script);
        } else {
          _initDashboard(serverUrl, authUrl);
        }
      } else {
        throw Exception("Failed to load server details");
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) setState(() => hasError = true);
    }
  }

  void _initDashboard(String serverUrl, String authUrl) {
    final initScript = html.ScriptElement()
      ..type = "text/javascript"
      ..innerHtml = """
        var dashboard = BoldBI.create({
          serverUrl: "$serverUrl",
          dashboardId: "${widget.dashboardId}",
          embedContainerId: "dashboard_${widget.dashboardId}",
          embedType: "component",
          environment: "onpremise",
          mode: BoldBI.Mode.View,
          expirationTime: 10000,
          authorizationServer: { url: "$authUrl" }
        });
        dashboard.loadDashboard();
      """;

    html.document.body?.append(initScript);
  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title:  Text("Dashboard",
            style:  GoogleFonts.lato(

              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            )),
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
      body: hasError
          ? const Center(child: Text("Failed to load dashboard"))
          : HtmlElementView(viewType: _viewType),
    );
  }
}
