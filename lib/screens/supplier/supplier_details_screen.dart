import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/app_theme.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/bussiness_partners_list_model.dart';
import '../../provider/themecontroller.dart';

class SupplierDetailsScreen extends StatelessWidget {
  BusinessPartnersListModel businessPartnersListModel;
  late ThemeController themeController;

  SupplierDetailsScreen(this.businessPartnersListModel, {super.key});



 /* Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }*/


  Future<void> _makePhoneCall(BuildContext context,String? phoneNumber) async {
    // Check if phone number exists
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number is not available.'),
        ),
      );
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.trim(),
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint("Could not launch $launchUri");
    }
  }

  Future<void> _sendEmail(String emailAddress) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
    );

    await launchUrl(emailUri);
  }
 /* Future<void> _sendEmail(BuildContext context,String? emailAddress) async {
    // Check if email exists
    if (emailAddress == null ||
        emailAddress.trim().isEmpty ||
        emailAddress.trim().toLowerCase() == 'null' ||
        emailAddress.trim().toUpperCase() == 'N/A') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email address is not available.'),
        ),
      );
      debugPrint("Email address is empty");
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailAddress.trim(),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      debugPrint("Could not launch email app");
    }
  }*/
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);
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
            backgroundColor: themeController.primaryColor,
            foregroundColor: Colors.white,
            title: Text('Supplier Details',style: GoogleFonts.lato(

              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            )),
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
               /* Navigator.pushReplacement(
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
         body:Center(
          child: Container(
              height: MediaQuery.of(context).size.height,
              color:const Color(0xFFF5F7FB),
              width: isDesktop ? 700 : double.infinity,
              padding: const EdgeInsets.all(5),
              child: SingleChildScrollView(
                  child: Column(
        children: [

        /// HEADER CARD
        Container(
          margin: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 5,
            bottom: 10,
          ),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
        color: const Color(0xffD78B25),
        borderRadius: BorderRadius.circular(24),
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
        Icons.business,
        color: Colors.white,
        size: isDesktop ? 35 : 30,
        ),
        ),

        const SizedBox(width: 20),

        Expanded(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

        Text(
        businessPartnersListModel.desc,
        style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: isDesktop ? 20 : 16,
        ),
        ),

        const SizedBox(height: 8),

        Text(
        businessPartnersListModel.code,
        style:  TextStyle(
        color: Colors.white70,
        fontSize: isDesktop ? 16 : 12,
        ),
        ),
        ],
        ),
        ),


        ],
        ),
        ),

        /// QUICK ACTIONS
          Container(
            margin: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 1,
              bottom: 5,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeController.primaryColor,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: actionButton(context,
                    Icons.call,
                    "Call",
                        () => _makePhoneCall(context,
                      businessPartnersListModel.phone,
                    ),
                  ),
                ),

                Container(
                  width: 1,
                  height: isDesktop ? 45 : 40,
                  color: Colors.white24,
                ),

                Expanded(
                  child: actionButton(context,
                    Icons.email,
                    "Email",
                        () => _sendEmail(
                      businessPartnersListModel.email,
                    ),
                  ),
                ),

           /*     Container(
                  width: 1,
                  height: isDesktop ? 45 : 40,
                  color: Colors.white24,
                ),

                Expanded(
                  child: actionButton(context,
                    Icons.location_on,
                    "Address",
                        () {},
                  ),
                ),*/
              ],
            ),
          ),

        const SizedBox(height: 10),

        /// DETAILS HEADER
        Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
        children: [
        Container(
        height: 10,
        width: 10,
        decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(3),
        ),
        ),
        const SizedBox(width: 10),
         Text(
        "SUPPLIER DETAILS",
        style: TextStyle(
        fontWeight: FontWeight.bold,
        color: themeController.primaryColor,
        fontSize: isDesktop ? 18 : 15,
        ),
        )
        ],
        ),
        ),

        const SizedBox(height:10),



          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                detailItem(context,
                  "Vendor Code",
                  businessPartnersListModel.vendorCode,
                ),

                detailItem(context,
                  "Currency",
                  businessPartnersListModel.uom,
                ),

                detailItem(context,
                  "Sales Person",
                  businessPartnersListModel.salespersonName,
                ),

                detailItem(context,
                  "Address",
                  businessPartnersListModel.address,
                ),

                detailItem(context,
                  "Phone",
                  businessPartnersListModel.phone,
                ),

                detailItem(context,
                  "Email",
                  businessPartnersListModel.email,

                ),
              ],
            ),
          ),


        ],
        )),
        ),
        ),
        ),
      ),
    );
  }
  Widget actionButton(BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      )
  {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: isDesktop ? 55 :40,
            width:  isDesktop ? 55 :40,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget infoCard(
      String title,
      String value,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffEFE6D6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xffC77700),
            ),
          )
        ],
      ),
    );
  }
  Widget detailItem(
      BuildContext context,
      String title,
      String? value, {
        bool showDivider = true,
      })
  {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 13,
              fontWeight: FontWeight.w700,
              color: themeController.primaryColor,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value == null || value.isEmpty ? "-" : value,
            style:  TextStyle(
              fontSize: isDesktop ? 17 : 10,
              color: Color(0xff1F2937),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          if (showDivider) ...[
            const SizedBox(height: 1),
            Divider(
              color: Colors.grey.shade300,
              thickness: 1,
            ),
          ],
        ],
      ),
    );
  }
}
