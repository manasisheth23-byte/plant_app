import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/screens/so_reports/so_projectwisetails.dart';
import 'package:erpflutter/screens/so_reports/so_table_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../provider/sotable_provider.dart';
import '../../provider/themecontroller.dart';
import '../soreport/SoChartPage.dart';
class SoReports extends StatefulWidget {
  const SoReports({super.key});

  @override
  State<SoReports> createState() => _SoReports();
}


class _SoReports extends State<SoReports> {
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();

    // Lock orientation to portrait mode when this screen is opened
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  @override
  void dispose() {
    // Reset the orientation back to normal (landscape and portrait allowed)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,

    ]);
    super.dispose();
  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    themeController = Provider.of<ThemeController>(context, listen: false);
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return  Center(
      child: SizedBox(
        width: isDesktop ? 700 : double.infinity,
        child: Scaffold(
          backgroundColor: isDesktop
              ?  Colors.white // dark app background for Windows/Desktop
              : const Color(0xffF5F7FA), // light app background for mobile
          appBar:PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Center(
                  child: SizedBox(
                      width: isDesktop ? 700 : double.infinity,
                      child: AppBar(
            backgroundColor: themeController.primaryColor,
            foregroundColor: Colors.white,
            title: Text('So Reports',style:  GoogleFonts.lato(

              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),),

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
          /*      Navigator.pushReplacement(
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
          body: /*Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: [
                _buildReportCard('So Chart', Icons.pie_chart, context,"1"),
                SizedBox(height: 12),
                _buildReportCard('So Table', Icons.table_chart, context,"2"),
                SizedBox(height: 12),
                _buildReportCard('Project Wise Details', Icons.list, context,"3"),
              ],
            ),
          ),*/
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height,
              color:const Color(0xFFF5F7FB),
              width: isDesktop ? 700 : double.infinity,
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: [

                  reportCard(
                    title: "SO Chart",
                    subtitle: "View graphical sales order report",
                    icon: Icons.pie_chart_rounded,
                    color: Colors.blue,
                    reportId: "1",
                  ),
                  const SizedBox(height: 5),

                  reportCard(
                    title: "SO Table",
                    subtitle: "View sales order in table format",
                    icon: Icons.table_rows_rounded,
                    color: Colors.green,
                    reportId: "2",
                  ),
                  const SizedBox(height: 5),

                  reportCard(
                    title: "Project Wise Details",
                    subtitle: "Detailed project-wise report",
                    icon: Icons.assignment_rounded,
                    color: Colors.orange,
                    reportId: "3",
                  ),
                ],
              ),
            ),
          ),

        ),
      ),
    );
  }
  Widget reportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String reportId,
  }) {
    return Card(
      color: const Color(0xFFE3F2FD),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          // Handle navigation or action
          print("komal ${reportId}");
          print(MediaQuery
              .of(context)
              .orientation);
          print(MediaQuery
              .of(context)
              .size);


          if (reportId != null) {
            if (reportId == "1") {
              debugPrint("Navigating to SoChart");
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 10),
                  reverseTransitionDuration: const Duration(milliseconds: 10),
                  pageBuilder: (_, animation, secondaryAnimation) =>
                      ChangeNotifierProvider(
                        create: (context) => SoReportProvider(),
                        child: const SoChartScreen(),
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
             /* Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SoChartScreen()),
              );*/
              debugPrint("Returned from SoChart");
            }
            if (reportId == "2") {
              // When navigating to SOReport
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 10),
                  reverseTransitionDuration: const Duration(milliseconds: 10),
                  pageBuilder: (_, animation, secondaryAnimation) =>
                      ChangeNotifierProvider(
                        create: (context) => SoReportProvider(),
                        child: const SOReport(),
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
       /*       Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChangeNotifierProvider(
                        create: (context) => SoReportProvider(),
                        child: const SOReport(),
                      ),
                ),
              );*/
            }
            if (reportId == "3") {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 10),
                  reverseTransitionDuration: const Duration(milliseconds: 10),
                  pageBuilder: (_, animation, secondaryAnimation) =>
                      ProjectWiseDetails(),
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
                MaterialPageRoute(builder: (context) => ProjectWiseDetails()),
              );*/
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lato(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildReportCard(String title, IconData icon, BuildContext context,String strId) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 16),
        leading: Icon(icon, color: Colors.blue, size: 30),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
        onTap: () {
          // Handle navigation or action
          print(strId);

          if(strId != null)
          {
            if(strId =="1")
            {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 10),
                  reverseTransitionDuration: const Duration(milliseconds: 10),
                  pageBuilder: (_, animation, secondaryAnimation) =>
                      SoChartScreen(),
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
              /*Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SoChartScreen()),
              );*/
            }
            if(strId =="2")
            {
              // When navigating to SOReport
             /* Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (context) => SoReportProvider(),
                    child: const SOReport(),
                  ),
                ),
              );*/

              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 10),
                  reverseTransitionDuration: const Duration(milliseconds: 10),
                  pageBuilder: (_, animation, secondaryAnimation) =>
                      ChangeNotifierProvider(
                        create: (context) => SoReportProvider(),
                        child: const SOReport(),
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
            }
            if(strId =="3")
            {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 10),
                  reverseTransitionDuration: const Duration(milliseconds: 10),
                  pageBuilder: (_, animation, secondaryAnimation) =>
                      ProjectWiseDetails(),
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
                MaterialPageRoute(builder: (context) => ProjectWiseDetails()),
              );*/
            }
          }
        },
      ),
    );
  }
}
