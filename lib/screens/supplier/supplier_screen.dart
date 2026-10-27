
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

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  bool searchBarEnabled = false;
  TextEditingController searchController = TextEditingController();
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();

    // Add listener to handle text field changes
    searchController.addListener(() {
      // Do not hide the search bar when the field is empty, just reset search results
      if (searchController.text.isEmpty) {
        _resetSearch(); // Reset search results when text field becomes empty
      }
    });
  }

  @override
  void didChangeDependencies() {
    final supplierController =
    Provider.of<SupplierController>(context, listen: false);

    supplierController.pagingController = PagingController(firstPageKey: 0);
    supplierController.callValue = 0;
    supplierController.searchflag = "0";
    supplierController.searchValue = "";

    // Fetch initial data
    supplierController.pagingController.addPageRequestListener((pageKey) {
      supplierController.fetchPage(pageKey, 'SUPPLIER');
    });
    super.didChangeDependencies();
  }

  void _handleSearch(String value) {
    final supplierController =
    Provider.of<SupplierController>(context, listen: false);

    if (value.isNotEmpty) {
      // Perform search and update the list
      supplierController.searchValue = value;
      supplierController.searchflag = "1"; // Enable search flag
    } else {
      // Clear search and show full list
      supplierController.searchValue = "";
      supplierController.searchflag = "0"; // Disable search flag
    }

    // Refresh the list after search
    supplierController.pagingController.refresh();
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

  Future<bool> _onWillPop() async {
    if (searchBarEnabled) {
      // If the search bar is enabled, close it and reset the search
      setState(() {
        searchBarEnabled = false;// Disable the search bar
        _resetSearch();
        searchController.text="";
      });
      return false; // Prevent the default back navigation
    }
    return true; // Allow back navigation to Dashboard
  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return PopScope(
      canPop: true, // Handle back button behavior
      child: Center(
        child: SizedBox(
          width: isDesktop ? 700 : double.infinity,
          child: Scaffold(
            backgroundColor: const Color(0xffF5F2F7),
            appBar:PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Center(
                    child: SizedBox(
                        width: isDesktop ? 700 : double.infinity,
                        child: AppBar(
              backgroundColor:  themeController.primaryColor,
              foregroundColor: Colors.white,
              title: searchBarEnabled
                  ? Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(5)),
                child: Center(
                  child: TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      // Trigger search on submitting the search value
                      _handleSearch(value);
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _resetSearch();
                          searchBarEnabled=false;
                          searchController.text="";
                        },
                      ),
                      hintText: 'Search...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              )
                  :  Text('Supplier',style:  GoogleFonts.lato(

                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              )),
              actions: [
                searchBarEnabled
                    ? Container() // Hide search icon if the search bar is already enabled
                    : IconButton(
                  onPressed: () {
                    setState(() {
                      searchBarEnabled = true; // Show the search bar
                    });
                  },
                  icon: const Icon(Icons.search,color: Colors.white, size: 27),
                )
              ],
              /*leading:
              new IconButton(
                icon: new Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  //  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => Dashboard()));
                },
              ),*/

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
                              onRefresh: () =>
                                  Future.sync(() => data.pagingController.refresh()),
                              child: PagedListView<int, BusinessPartnersListModel>(
                                pagingController: data.pagingController,

                                builderDelegate:
                                PagedChildBuilderDelegate<BusinessPartnersListModel>(
                                  itemBuilder: (context, item, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      child: GestureDetector(
                                        onTap: () async {
                                         /* await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SupplierDetailsScreen(item),
                                            ),
                                          );*/
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              transitionDuration: const Duration(milliseconds: 10),
                                              reverseTransitionDuration: const Duration(milliseconds: 10),
                                              pageBuilder: (_, animation, secondaryAnimation) =>
                                                  SupplierDetailsScreen(item),
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
                                                color: Colors.black.withOpacity(0.03),
                                                blurRadius: 10,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [

                                              /// Left Color Indicator
                                              Container(
                                                width: 4,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color:  themeController.primaryColor,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),

                                              const SizedBox(width: 14),

                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [

                                                    /// Supplier Name
                                                    Text(
                                                      item.desc ?? "",
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style:  TextStyle(
                                                        fontSize: 17,
                                                        fontWeight: FontWeight.w700,
                                                        color:  themeController.primaryColor,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 12),

                                                    Row(
                                                      children: [
                                                         Icon(
                                                          Icons.person_outline,
                                                          size: 18,
                                                          color:  themeController.primaryColor,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            item.contactPerson ?? "-",
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              color: Colors.grey.shade700,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    const SizedBox(height: 8),

                                                    Row(
                                                      children: [
                                                         Icon(
                                                          Icons.mail_outline,
                                                          size: 18,
                                                          color:  themeController.primaryColor,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            item.email ?? "-",
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              color: Colors.grey.shade700,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    const SizedBox(height: 8),

                                                    Row(
                                                      children: [
                                                         Icon(
                                                          Icons.phone_outlined,
                                                          size: 18,
                                                          color:  themeController.primaryColor,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          item.phone ?? "-",
                                                          style: TextStyle(
                                                            color: Colors.grey.shade700,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    const SizedBox(height: 8),

                                                    Row(
                                                      children: [
                                                         Icon(
                                                          Icons.location_on_outlined,
                                                          size: 18,
                                                          color:  themeController.primaryColor,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            item.city ?? "-",
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              color: Colors.grey.shade700,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ))),
                  ],
                )),
              );
            }),
          ),
        ),
      ),
    );
  }
  Widget errorIndicator(BuildContext context) {
    return Container(
      child: Center(
        child: Text('No records found!'),
      ),
    );
  }
}
