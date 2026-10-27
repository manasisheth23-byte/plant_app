import 'dart:convert';

import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app_config.dart';
import '../../models/LoginResponseModel.dart';
import '../../provider/themecontroller.dart';
import '../login/login_controller.dart';

class ReportView extends StatefulWidget {
  final String pagesheetId;
  final String userId;
  final String token;


  const ReportView({
    super.key,
    required this.pagesheetId,
    required this.userId,
    required this.token,
  });
  @override
  State<ReportView> createState() => _ReportView();
}

class _ReportView extends State<ReportView> {
  late final WebViewController _webViewController;
  String? _webViewUrl;
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();

    // ✅ Lock landscape AFTER first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });

    // ✅ Initialize WebViewController ONCE
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            // allow all navigation
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  @override
  void dispose() {
    // ✅ Restore ALL orientations on exit
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return Consumer<LoginController>(
      builder: (context, data, _) {
        final url =
            "${AppConfig.RAW_BASE_URL}/ApiPageSet/PageSheetView"
            "?PAGESHEETID=${widget.pagesheetId}"
            "&USERID=${widget.userId}"
            "&TOKEN=${widget.token}";
        print(url);
        // ✅ Load URL only once
        if (_webViewUrl != url) {
          _webViewUrl = url;
          _webViewController.loadRequest(Uri.parse(url));
        }

        return PopScope(
          canPop: true,
          onPopInvoked: (_) async {
            final prefs = await SharedPreferences.getInstance();
            LoginResponseModel.fromJson(
              jsonDecode(prefs.getString('LOGINRESPONSE') ?? ''),
            );
          },
          child: Center(
            child: SizedBox(
              width: isDesktop ? 700 : double.infinity,
              child: Scaffold(
                appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: AppBar(
                                      backgroundColor:themeController.primaryColor,
                                      foregroundColor: Colors.white,
                                      title:  Text('Report',style:  GoogleFonts.lato(

                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),),
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                                    )),
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
              /*        Navigator.pushReplacement(
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
               ),
       */
                    ],
                  ),
                ),
                body: WebViewWidget(controller: _webViewController),
              ),
            ),
          ),
        );
      },
    );
  }
}
