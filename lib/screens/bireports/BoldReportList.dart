import 'dart:convert';
import 'dart:io';
import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/bireports/BoldBIDashboardViewer.dart';
import 'package:erpflutter/screens/bireports/BoldBIReportViewerWindows.dart';
import 'package:erpflutter/screens/bireports/boldbi_dashboard.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Dashboard.dart';
import '../../provider/themecontroller.dart';

class BoldReportListScreen extends StatefulWidget {
  @override
  _BoldReportListScreenState createState() => _BoldReportListScreenState();
}

class _BoldReportListScreenState extends State<BoldReportListScreen> {
  List<dynamic> _dashboards = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    fetchDashboards();
  }

  Future<void> fetchDashboards() async {
    final url = Uri.parse(AppConfig.RAW_BASE_URL+'/BIDashboard/GetDashboards');
    print(url);
   // final url = Uri.parse('http://10.0.0.223:8444/BIDashboard/GetDashboards');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _dashboards = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load dashboards. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }
  late ThemeController themeController;

  late bool? isMobile ;
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    int crossAxisCount = screenSize.width > 600 ? 6 : 3;
    double screenHeight = screenSize.height;
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    final width = MediaQuery.of(context).size.width;

    isMobile = width < 700;
    return PopScope(
        canPop: true, // prevent default back behavior
        child: Center(
          child: SizedBox(
            width: isDesktop ? 700 : double.infinity,
            child: Scaffold(
                  appBar: AppBar(
              backgroundColor: themeController.primaryColor,
              foregroundColor: Colors.white,
              title: Text('Dashboards',style: GoogleFonts.lato(

                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ) ,)),
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
                  body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
              ? Center(child: Text(_error))
              : Padding(
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
              gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // ✅ runtime value OK
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
                childAspectRatio:isDesktop? 0.95 : 0.95, // Adjust item height
              ),
              itemCount: _dashboards.length,
              itemBuilder: (context, index) {
                final item = _dashboards[index];
                final color = C.colors[index % C.colors.length];
                return InkWell(
                  onTap: () async {

                    SharedPreferences prefs = await SharedPreferences
                        .getInstance();
                    String? UserID = prefs.getString('USERID');
                    if(kIsWeb ){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BoldBIDashboardWeb(
                              dashboardId: item['Id']
                          ),
                        ),
                      );

                    }
                    else if(!kIsWeb && Platform.isAndroid){
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BoldBIDashboardViewerScreen(
                            dashboardId: item['Id'],
                            userID: UserID!,
                          ),
                        ),
                      );
                    }
                    else if(!kIsWeb && Platform.isWindows){
                      Navigator.push(
                        context,
                        MaterialPageRoute(

                          builder: (_) =>BoldBIWindowsScreen(
                            dashboardId: item['Id'],
                            userID:UserID!,
                          ),
                        ),
                      );
                    }
                  },
                  child:/* Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/report.png',
                              height: 40,
                              width: 40,
                              fit: BoxFit.contain,
                              color: AppColors.APPCOLOR,
                            ),
                          ),

                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item['Name'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,

                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  )*/
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile! ? 8 : 6,
                      vertical: isMobile! ? 10 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: C.line),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(.06),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: isMobile! ? 42 : 32,
                          height: isMobile! ? 42 : 32,
                          decoration: BoxDecoration(
                            color: color.withOpacity(.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/report.png',
                              height: isMobile! ? 22 : 18,
                              width: isMobile! ? 22 : 18,
                              color: color,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile! ? 8 : 6),
                        Text(
                          item['Name'] ?? '',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isMobile! ? 11 : 10,
                            fontWeight: FontWeight.w600,
                            color: C.deep,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
                  ),
                ),
          ),
        ));
  }
}
