import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/app_theme.dart';
import 'package:erpflutter/models/bussiness_partners_list_model.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/screens/supplier/supplier_controller.dart';
import 'package:erpflutter/screens/supplier/supplier_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../provider/themecontroller.dart';
import '../../utils/SizeConfig.dart';
import 'busines _Partner_details_screen.dart';

class BusinessPartnerScreen extends StatefulWidget {
  const BusinessPartnerScreen({super.key});

  @override
  State<BusinessPartnerScreen> createState() => _BusinessPartnerScreenState();
}

class _BusinessPartnerScreenState extends State<BusinessPartnerScreen> {
  final TextEditingController searchController = TextEditingController();
  bool searchBarEnabled = false; // Track search bar visibility
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();
    // Add listener to the search controller
    searchController.addListener(() {
      // If the search text is empty, reset and refresh
      if (searchController.text.isEmpty) {
        Provider.of<SupplierController>(context, listen: false).searchValue = "";
        Provider.of<SupplierController>(context, listen: false).searchflag = "0"; // Reset the search flag
        Provider.of<SupplierController>(context, listen: false).pagingController.refresh();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final supplierController = Provider.of<SupplierController>(context, listen: false);

    // Initialize paging controller and search parameters
    supplierController.pagingController = PagingController(firstPageKey: 0);
    supplierController.callValue = 0;
    supplierController.searchflag = "0";
    supplierController.searchValue = "";

    supplierController.pagingController.addPageRequestListener((pageKey) {
      supplierController.fetchPage(pageKey, 'CUSTOMER');
    });
  }
  Widget buildInfoRow(IconData icon, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xff173F73),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            (value != null && value.trim().isNotEmpty)
                ? value
                : "-",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
  void _resetSearch() {
    final supplierController =
    Provider.of<SupplierController>(context, listen: false);
    setState(() {
      searchController.clear(); // Clear the search text
      supplierController.searchValue = "";
      supplierController.searchflag = "0"; // Disable search flag
    });
    supplierController.pagingController.refresh(); // Refresh to show original data
  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async{
        if(searchBarEnabled){
          setState(() {
            searchController.text="";
            searchBarEnabled = false;
          });
          Provider.of<SupplierController>(context, listen: false).searchValue = "";
          Provider.of<SupplierController>(context, listen: false).searchflag = "0"; // Reset the search flag
          Provider.of<SupplierController>(context, listen: false).pagingController.refresh();
          setState(() {});
        } else {
          if(!didPop){
            Navigator.pop(context);
          }
        }
      },
      child: Center(
        child: SizedBox(
          width: isDesktop ? 700 : double.infinity,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Center(
                    child: SizedBox(
                        width: isDesktop ? 700 : double.infinity,
                        child:AppBar(
              backgroundColor: themeController.primaryColor,
              foregroundColor: Colors.white,
              title: searchBarEnabled
                  ? buildSearchBar()
                  : Text('Business Partners',
                  style:  GoogleFonts.lato(

                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  )
              ), // Show the search bar if enabled
              actions: [
                // Search icon to enable the search bar
                if (!searchBarEnabled) // Only show the search icon if the search bar is not enabled
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        searchBarEnabled = true; // Show the search bar
                      });
                    },
                  ),
              ],
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
            body: Consumer<SupplierController>(builder: (context, data, _) {
              return Center(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  color:const Color(0xFFF5F7FB),
                  width: isDesktop ? 700 : double.infinity,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      flex: 50,
                      child: SizedBox(
                        height: SizeConfig.screenHeight! * 100,
                        child: RefreshIndicator(
                          onRefresh: () => Future.sync(() => data.pagingController.refresh()),
                          child: PagedListView<int, BusinessPartnersListModel>(
                            pagingController: data.pagingController,
                            builderDelegate: PagedChildBuilderDelegate<BusinessPartnersListModel>(
                              itemBuilder: (context, item, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration: const Duration(milliseconds: 10),
                                          reverseTransitionDuration: const Duration(milliseconds: 10),
                                          pageBuilder: (_, animation, secondaryAnimation) =>
                                              BusinessPartnersDetailsScreen(item),
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
                                /*      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BusinessPartnersDetailsScreen(item),
                                        ),
                                      );*/

                                      _resetSearch();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(.03),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          /// Left Indicator
                                          Container(
                                            width: 4,
                                            height: 95,
                                            decoration: BoxDecoration(
                                              color: const Color(0xff173F73),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),

                                          const SizedBox(width: 14),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                /// Business Partner Name
                                                Text(
                                                  item.desc ?? "-",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xff1B2B48),
                                                  ),
                                                ),

                                                const SizedBox(height: 8),

                                                buildInfoRow(
                                                  Icons.person_outline,
                                                  item.contactPerson,
                                                ),

                                                const SizedBox(height: 8),

                                                buildInfoRow(
                                                  Icons.mail_outline,
                                                  item.email,
                                                ),

                                                const SizedBox(height: 8),

                                                buildInfoRow(
                                                  Icons.phone_outlined,
                                                  item.mobile?.isNotEmpty == true
                                                      ? item.mobile
                                                      : item.phone,
                                                ),

                                                const SizedBox(height: 8),

                                                buildInfoRow(
                                                  Icons.location_on_outlined,
                                                  item.city,
                                                ),
                                              ],
                                            ),
                                          ),


                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                           /* builderDelegate: PagedChildBuilderDelegate<BusinessPartnersListModel>(
                              itemBuilder: (context, item, index) => Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => BusinessPartnersDetailsScreen(item)),
                                    );
                                  },
                                  child: Material(
                                    elevation: 2,
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(5)),
                                        color: Colors.white,
                                      ),
                                      height: 120,
                                      padding: EdgeInsets.all(8),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.desc,
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  (item.contactPerson != null && item.contactPerson != '')
                                                      ? Icons.person
                                                      : Icons.person_off_rounded,
                                                  color: AppTheme.blue_600,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  item.contactPerson,
                                                  style: TextStyle(fontSize: 16, color: Colors.grey, overflow: TextOverflow.ellipsis),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  (item.email != null && item.email != '')
                                                      ? Icons.mail
                                                      : Icons.mail_lock_rounded,
                                                  color: AppTheme.blue_600,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 8),
                                                Flexible(
                                                  child: Text(
                                                    item.email,
                                                    style: TextStyle(color: AppTheme.blue_600, overflow: TextOverflow.ellipsis),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  (item.phone != null && item.phone != '')
                                                      ? Icons.phone
                                                      : Icons.phone_disabled,
                                                  color: AppTheme.blue_600,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  item.mobile,
                                                  style: TextStyle(color: Colors.grey, overflow: TextOverflow.ellipsis),
                                                ),
                                                Spacer(),
                                                Icon(
                                                  (item.city != null && item.city != '')
                                                      ? Icons.location_on_rounded
                                                      : Icons.wrong_location_sharp,
                                                  color: AppTheme.blue_600,
                                                  size: 16,
                                                ),
                                                Text(item.city),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),*/
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
              );
            }),
          ),
        ),
      ),
    );
  }

  // Builds the search bar for the Business Partner Screen
  Widget buildSearchBar() {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: TextField(
          controller: searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            // Trigger search when the user submits the input
            Provider.of<SupplierController>(context, listen: false).searchValue = value;
            Provider.of<SupplierController>(context, listen: false).searchflag = "1"; // Set the search flag
            Provider.of<SupplierController>(context, listen: false).pagingController.refresh();
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  searchBarEnabled = false; // Hide the search bar
                });
                searchController.clear(); // Clear the search field
                Provider.of<SupplierController>(context, listen: false).searchValue = ""; // Reset search value
                Provider.of<SupplierController>(context, listen: false).searchflag = "0"; // Reset the search flag
                Provider.of<SupplierController>(context, listen: false).pagingController.refresh(); // Refresh the list
              },
            ),
            hintText: 'Search...',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
