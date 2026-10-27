import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../app_colors.dart';
import '../../provider/themecontroller.dart';
import '../../utils/SizeConfig.dart';
import '../login/login_controller.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_colors.dart';
import '../login/login_controller.dart';

class InventoryListDetailsFragment extends StatelessWidget {
  late ThemeController themeController;

  InventoryListDetailsFragment({Key? key}) : super(key: key);
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return Consumer<LoginController>(
      builder: (context, data, _) {
        return Scaffold(
          backgroundColor: const Color(0xffF4F6FA),

          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Center(
                  child: SizedBox(
                      width: isDesktop ? 700 : double.infinity,
                      child:AppBar(
            elevation: 0,
            backgroundColor: themeController.primaryColor,
            foregroundColor: Colors.white,
            title:  Text(
              "Inventory Detail",
              style:  GoogleFonts.lato(

                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
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
                ),*/

              ],
            ),
          ),
          body: Center(
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  color:const Color(0xFFF5F7FB),
                  width: isDesktop ? 700 : double.infinity,
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [

                ///==========================
                /// HEADER CARD
                ///==========================
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xffDD9020),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [

                      Container(
                        height: isDesktop ? 70 : 50,
                        width: isDesktop ? 70 : 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.15),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child:  Icon(
                          Icons.inventory_2,
                          color: Colors.white,
                          size: isDesktop ? 40 : 30,
                        ),
                      ),

                      const SizedBox(width: 18),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              data.itemdesc,
                              style:  TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: isDesktop ? 24 : 15,
                              ),
                            ),

                           /* const SizedBox(height: 8),

                            Text(
                              data.itemCode,
                              style:  TextStyle(
                                color: Colors.white70,
                                fontSize: isDesktop ? 16 : 12,
                              ),
                            ),*/
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                ///==========================
                /// ACTION CARD
                ///==========================
            /*    Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff214B84),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      _action(Icons.inventory, "Stock"),

                      Container(
                        width: 1,
                        height: 45,
                        color: Colors.white24,
                      ),

                      _action(Icons.currency_rupee, "Price"),

                      Container(
                        width: 1,
                        height: 45,
                        color: Colors.white24,
                      ),

                      _action(Icons.factory, "Plant"),
                    ],
                  ),
                ),

                const SizedBox(height: 25),*/

                ///==========================
                /// TITLE
                ///==========================
                Row(
                  children:  [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.orange,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "INVENTORY DETAILS",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: themeController.primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                ///==========================
                /// DETAILS CARD
                ///==========================
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.grey.withOpacity(.15),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  child: Column(
                    children: [

                      _detailTile("Item Code", data.itemCode),

                      _detailTile("Plant", data.plant),

                      _detailTile("Unit Price", data.unitprice),

                      _detailTile("Main Group", data.maninGroup),

                      _detailTile("Sub Group", data.subGroup),

                      _detailTile("Item Type", data.itemtype),

                      _detailTile(
                          "In Stock Quantity", data.inStockQuantity),
                    ],
                  ),
                ),
              ],
            ),
          ))),
        );
      },
    );
  }

  Widget _action(IconData icon, String title) {
    return Column(
      children: [

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        )
      ],
    );
  }

  Widget _detailTile(String title, String? value) {
    if (value == null || value == "null" || value.isEmpty) {
      value = "-";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              color: Color(0xff0D5BCF),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 10),

          const Divider(height: 1),
        ],
      ),
    );
  }
}

