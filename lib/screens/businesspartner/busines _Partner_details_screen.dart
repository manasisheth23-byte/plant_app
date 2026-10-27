import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/app_theme.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Dashboard.dart';
import '../../models/bussiness_partners_list_model.dart';
import '../../provider/themecontroller.dart';

class BusinessPartnersDetailsScreen extends StatelessWidget {
  BusinessPartnersListModel businessPartnersListModel;
  late ThemeController themeController;

  BusinessPartnersDetailsScreen(this.businessPartnersListModel, {super.key});



  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _sendEmail(String emailAddress) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
    );

    await launchUrl(emailUri);
  }


  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.APPCOLOR,
        foregroundColor: Colors.white,
        title: Text('Business Partner',style: TextStyle(
          fontFamily: 'Roboto',
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        )),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Dashboard(),));


            },
            icon: Icon(Icons.home),
          ),
        ],
      ),

      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 230,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: AppTheme.light_green_400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 57,
                      backgroundColor: Colors.white,
                      child: Text(businessPartnersListModel.desc.toString().length > 0 ? businessPartnersListModel.desc.toString()[0] : '', style: TextStyle(fontSize: 33)),
                    ),
                    SizedBox(height: 8),
                    Text(businessPartnersListModel.desc, style: TextStyle(fontSize: 21)),
                    SizedBox(height: 8),
                    Text(businessPartnersListModel.code, style: TextStyle(fontSize: 16))
                  ],
                ),
              ),
              Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(color: AppTheme.light_green_400, border: Border(top: BorderSide(width: 0.5), bottom: BorderSide(width: 0.5), )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(onPressed: (){
                      _makePhoneCall(businessPartnersListModel.phone);
                    }, icon: Icon(Icons.call, size: 45)),
                    VerticalDivider(
                      width: 0.3,
                      color: Colors.black,
                    ),
                    IconButton(onPressed: (){
                      _sendEmail(businessPartnersListModel.email);
                    }, icon: Icon(Icons.mail, size: 45)),
                  ]
          
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text('Vendor Code', style: TextStyle(fontSize: 16, color: AppTheme.blue_600)),
                    Text(businessPartnersListModel.vendorCode),
          
                    SizedBox(height: 20),
                    Text('Currency', style: TextStyle(fontSize: 16, color: AppTheme.blue_600)),
                    Text(businessPartnersListModel.uom),
          
                    SizedBox(height: 20),
                    Text('Sales Person', style: TextStyle(fontSize: 16, color: AppTheme.blue_600)),
                    Text(businessPartnersListModel.salespersonName),
          
                    SizedBox(height: 20),
                    Text('Address', style: TextStyle(fontSize: 16, color: AppTheme.blue_600)),
                    Text(businessPartnersListModel.address),
          
                    SizedBox(height: 20),
                    Text('Phone', style: TextStyle(fontSize: 16, color: AppTheme.blue_600)),
                    Text(businessPartnersListModel.phone),
          
                    SizedBox(height: 20),
                    Text('Email', style: TextStyle(fontSize: 16, color: AppTheme.blue_600)),
                    Text(businessPartnersListModel.email),
          
          
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }*/
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);

    return Center(
      child: SizedBox(
        width: isDesktop ? 700 : double.infinity,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Center(
              child: SizedBox(
                width: isDesktop ? 700 : double.infinity,
                child: AppBar(
                  backgroundColor: themeController.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  title:  Text(
                    "Business Partner",
                    style:  GoogleFonts.lato(

                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    )
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                       /* Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Dashboard(),
                          ),
                        );*/
                      },
                      icon: const Icon(Icons.home_outlined),
                    )
                  ],
                ),
              ),
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

                /*const NavigationDestination(
                        icon: Icon(Icons.menu,size: 30),
                        selectedIcon: Icon(Icons.menu,size: 30, color: C.blue),
                        label: 'More',
                      ),*/

              ],
            ),
          ),
          body: Center(
            child: Container(
              width: isDesktop ? 700 : double.infinity,
              color: const Color(0xffF5F7FB),
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    ///================ HEADER ===================

                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xffD78B25),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [

                          CircleAvatar(
                            radius: isDesktop ? 36 : 28,
                            backgroundColor: Colors.white.withOpacity(.2),
                            child: Text(
                              businessPartnersListModel.desc.isNotEmpty
                                  ? businessPartnersListModel.desc[0].toUpperCase()
                                  : "",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 28 : 22,
                              ),
                            ),
                          ),

                          const SizedBox(width: 18),

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

                                const SizedBox(height: 6),

                                Text(
                                  "Code : ${businessPartnersListModel.code}",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: isDesktop ? 15 : 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    ///================ ACTIONS ===================

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xff173F73),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [

                          Expanded(
                            child: actionButton(
                              context,
                              Icons.call,
                              "Call",
                                  () => _makePhoneCall(
                                  businessPartnersListModel.phone),
                            ),
                          ),

                          Container(
                            width: 1,
                            height: 45,
                            color: Colors.white24,
                          ),

                          Expanded(
                            child: actionButton(
                              context,
                              Icons.email,
                              "Email",
                                  () => _sendEmail(
                                  businessPartnersListModel.email),
                            ),
                          ),

                          Container(
                            width: 1,
                            height: 45,
                            color: Colors.white24,
                          ),

                      /*    Expanded(
                            child: actionButton(
                              context,
                              Icons.location_on,
                              "Address",
                                  () {},
                            ),
                          ),*/
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [

                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius:
                              BorderRadius.circular(3),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Text(
                            "BUSINESS PARTNER DETAILS",
                            style: TextStyle(
                              color: const Color(0xff173F73),
                              fontWeight: FontWeight.bold,
                              fontSize:
                              isDesktop ? 18 : 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      margin:
                      const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withOpacity(.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [

                          detailItem(
                            context,
                            "Vendor Code",
                            businessPartnersListModel.vendorCode,
                          ),

                          detailItem(
                            context,
                            "Currency",
                            businessPartnersListModel.uom,
                          ),

                          detailItem(
                            context,
                            "Sales Person",
                            businessPartnersListModel.salespersonName,
                          ),

                          detailItem(
                            context,
                            "Address",
                            businessPartnersListModel.address,
                          ),

                          detailItem(
                            context,
                            "Phone",
                            businessPartnersListModel.phone,
                          ),

                          detailItem(
                            context,
                            "Email",
                            businessPartnersListModel.email,
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget actionButton(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Container(
              height: isDesktop ? 54 : 42,
              width: isDesktop ? 54 : 42,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isDesktop ? 28 : 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget detailItem(
      BuildContext context,
      String title,
      String? value, {
        bool showDivider = true,
      }) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    return Container(
      width: double.infinity, // <-- Important
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xff1565C0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            (value == null || value.trim().isEmpty) ? "-" : value,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: isDesktop ? 15 : 13,
              color: const Color(0xff1F2937),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (showDivider) ...[
            const SizedBox(height: 10),
            Divider(
              color: Colors.grey.shade300,
              thickness: 1,
              height: 1,
            ),
          ],
        ],
      ),
    );
  }
}
