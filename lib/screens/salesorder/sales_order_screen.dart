import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/screens/salesorder/salesorder_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:provider/provider.dart';


import '../../models/SalesOrderListModel.dart';

import '../../provider/so_list_provider.dart';
import '../../provider/themecontroller.dart';




class SoListScreen extends StatefulWidget {
  @override
  _SoListScreenState createState() => _SoListScreenState();
}

class _SoListScreenState extends State<SoListScreen> {
  bool searchBarEnabled = false;
  TextEditingController searchController = TextEditingController();
  List<LIST>? filteredList; // Holds the filtered list
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      if (searchController.text.isEmpty) {
        setState(() {
          filteredList = null; // Clear the filtered list when input is empty
          Provider.of<SoListProvider>(context, listen: false).fetchSoList();
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SoListProvider>(context, listen: false).fetchSoList();
    });
    // Fetch the sales order list when the screen is initialized

  }

  void _performSearch(String query) {
    final provider = Provider.of<SoListProvider>(context, listen: false);
    if (provider.soListModel == null) return;

    setState(() {
      filteredList = provider.soListModel!.dATA!.lIST!
          .where((order) =>
              order.iNVCNUMB != null &&
              order.iNVCNUMB!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return PopScope(
      canPop: true,
      child:Center(
        child: SizedBox(
          width: isDesktop ? 700 : double.infinity,
          child: Scaffold(
            backgroundColor: isDesktop
                ?  Colors.white // dark app background for Windows/Desktop
                : const Color(0xFFF5F7FB), // light app background for mobile

          /*  appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: false,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,

              titleSpacing: 16,

              title: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: searchBarEnabled
                    ? Container(
                  key: const ValueKey("search"),
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xffF3F5F7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      _performSearch(value);
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Sales Order...",
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade600,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          setState(() {
                            searchController.clear();
                            searchBarEnabled = false;
                            filteredList = null;

                            Provider.of<SoListProvider>(
                              context,
                              listen: false,
                            ).fetchSoList();
                          });
                        },
                      ),
                    ),
                  ),
                )
                    : const Text(
                  "Sales Orders",
                  key: ValueKey("title"),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              actions: [
                if (!searchBarEnabled)
                  IconButton(
                    splashRadius: 22,
                    icon: const Icon(Icons.search_rounded),
                    onPressed: () {
                      setState(() {
                        searchBarEnabled = true;
                      });
                    },
                  ),
                const SizedBox(width: 8),
              ],
            ),*/
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Center(
                    child: SizedBox(
                        width: isDesktop ? 700 : double.infinity,
                        child:AppBar(
              backgroundColor: themeController.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: true,
              centerTitle: false,
              titleSpacing: 16,
              title: searchBarEnabled
                  ? Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xffF3F5F7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search Sales Order",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          searchBarEnabled = false;
                          searchController.clear();
                          filteredList = null;
                        });

                        Provider.of<SoListProvider>(
                          context,
                          listen: false,
                        ).fetchSoList();
                      },
                    ),
                  ),
                ),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sales Orders",
                     style: GoogleFonts.lato(

                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              )
                  ),

                ],
              ),
              actions: [
                if (!searchBarEnabled)
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        searchBarEnabled = true;
                      });
                    },
                  )
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
        /*          Navigator.pushReplacement(
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
            body: Consumer<SoListProvider>(
              builder: (context, provider, child) {
                final listToShow =
                    filteredList ?? provider.soListModel?.dATA?.lIST;

                if (provider.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.errorMessage.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        provider.errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                }

                if (listToShow == null || listToShow.isEmpty) {
                  return Center(
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        color: isDesktop
                            ?     const Color(0xFFE3F2FD)// dark app background for Windows/Desktop
                            : const Color(0xFFF5F7FB), // light app background for mobile

                        width: isDesktop ? 700 : double.infinity,
                        padding: const EdgeInsets.all(10),
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 70,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No Sales Orders Found",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    )),
                  );
                }

                return Center(
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        color:  const Color(0xFFE3F2FD), // light app background for mobile

                        width: isDesktop ? 700 : double.infinity,
                        padding: const EdgeInsets.all(0),
                        child:RefreshIndicator(
                  onRefresh: () async {
                    Provider.of<SoListProvider>(
                      context,
                      listen: false,
                    ).fetchSoList();
                  },
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                    itemCount: listToShow.length,
                    itemBuilder: (context, index) {
                      final order = listToShow[index];
                      final lineItems = order.tRANSLIST?.tRANS ?? [];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ProductCard(
                          strSODate: order.dUEDATE,
                          strStatus: order.sTATUS,
                          strinvcnum: order.iNVCNUMB,
                          strAmount: order.aMOUNT,
                          strCustName: order.sLDESC,
                          strDueDate: order.dUEDATE,
                          strCreatedBy: order.cREATEDBYNAME,
                          strSalesPerson: order.sALESPERSON,
                          onTap: () {
                            List<Map<String, String>> lineItemsDetails =
                            lineItems.map((lineItem) {
                              return {
                                "Product_Code":
                                lineItem.productCode ?? "N/A",
                                "Product_Description":
                                lineItem.productDescription ?? "N/A",
                                "QTY": lineItem.qTY ?? "N/A",
                                "UOMCODE": lineItem.uOMCODE ?? "N/A",
                                "UnitRate": lineItem.uNITRATE ?? "N/A",
                                "Amount": lineItem.iNVCAMOUNT ?? "N/A",
                                "LastSaleRate":
                                lineItem.lASTSALERATE ?? "N/A",
                                "DiliveryDate":
                                lineItem.dELIVERYDATE ?? "N/A",
                              };
                            }).toList();
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 10),
                                reverseTransitionDuration: const Duration(milliseconds: 10),
                                pageBuilder: (_, animation, secondaryAnimation) =>
                                    DetailsScreen(
                                      invoiceNumber: order.iNVCNUMB,
                                      customerName: order.sLDESC,
                                      amount: order.aMOUNT,
                                      dueDate: order.dUEDATE,
                                      formattedDate: order.dUEDATE,
                                      porefno: order.pORDERNO,
                                      porefdate: order.pORDERDATE,
                                      salestype: order.dOCTYPE,
                                      createdBy: order.cREATEDBYNAME,
                                      salesPerson: order.sALESPERSON,
                                      status: order.sTATUS,
                                      lineItems: lineItemsDetails,
                                      docid: order.dOCID,
                                      mid: order.mID,
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
                          /*  Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DetailsScreen(
                                  invoiceNumber: order.iNVCNUMB,
                                  customerName: order.sLDESC,
                                  amount: order.aMOUNT,
                                  dueDate: order.dUEDATE,
                                  formattedDate: order.dUEDATE,
                                  porefno: order.pORDERNO,
                                  porefdate: order.pORDERDATE,
                                  salestype: order.dOCTYPE,
                                  createdBy: order.cREATEDBYNAME,
                                  salesPerson: order.sALESPERSON,
                                  status: order.sTATUS,
                                  lineItems: lineItemsDetails,
                                  docid: order.dOCID,
                                  mid: order.mID,
                                ),
                              ),
                            );*/
                          },
                        ),
                      );
                    },
                  ),
                )));
              },
            ),
          ),
        ),
      ),
    );
  }
/*  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(

        appBar: AppBar(
          backgroundColor: AppColors.APPCOLOR,
          foregroundColor: Colors.white,
          title: searchBarEnabled
              ? Container(
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
                      onSubmitted: (value) async {
                        _performSearch(value);
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              searchBarEnabled = false;
                              filteredList = null;
                              Provider.of<SoListProvider>(context, listen: false)
                                  .fetchSoList();
                            });
                          },
                        ),
                        hintText: 'Search...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                )
              : const Text('Sales Order List',style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          )),
          actions: [
            searchBarEnabled
                ? Container()
                : IconButton(
                    onPressed: () {
                      setState(() {
                        searchBarEnabled = true;
                      });
                    },
                    icon: Icon(Icons.search, size: 27),
                  ),
          ],
          *//*leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()),
              );
            },
          ),*//*
        ),
        body: Consumer<SoListProvider>(
          builder: (context, provider, child) {
            final listToShow = filteredList ?? provider.soListModel?.dATA?.lIST;

            if (provider.loading) {
              return Center(child: CircularProgressIndicator());
            } else if (provider.errorMessage.isNotEmpty) {
              return Center(child: Text('Error: ${provider.errorMessage}'));
            } else if (listToShow == null || listToShow.isEmpty) {
              return Center(child: Text('No Sales Orders found.'));
            }

            return ListView.builder(
              itemCount: listToShow.length,
              itemBuilder: (context, index) {
                final order = listToShow[index];
                final lineItems = order.tRANSLIST?.tRANS ?? [];

                return ProductCard(
                  strSODate: order.dUEDATE,
                  strStatus: order.sTATUS,
                  strinvcnum: order.iNVCNUMB,
                  strAmount: order.aMOUNT,
                  strCustName: order.sLDESC,
                  strDueDate: order.dUEDATE,
                  strCreatedBy: order.cREATEDBYNAME,
                  strSalesPerson: order.sALESPERSON,
                  onTap: () {
                    // Prepare the list of line items for the DetailsScreen
                    List<Map<String, String>> lineItemsDetails =
                        lineItems.map((lineItem) {
                      return {
                        "Product_Code": lineItem.productCode ?? "N/A",
                        "Product_Description":
                            lineItem.productDescription ?? "N/A",
                        "QTY": lineItem.qTY ?? "N/A",
                        "UOMCODE": lineItem.uOMCODE ?? "N/A",
                        "UnitRate": lineItem.uNITRATE ?? "N/A",
                        "Amount": lineItem.iNVCAMOUNT ?? "N/A",
                        "LastSaleRate": lineItem.lASTSALERATE ?? "N/A",
                        "DiliveryDate": lineItem.dELIVERYDATE ?? "N/A",
                      };
                    }).toList();

                    // Navigate to DetailsScreen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(
                          invoiceNumber: order.iNVCNUMB,
                          customerName: order.sLDESC,
                          amount: order.aMOUNT,
                          dueDate: order.dUEDATE,
                          formattedDate: order.dUEDATE,
                          porefno: order.pORDERNO,
                          porefdate: order.pORDERDATE,
                          salestype: order.dOCTYPE,
                          createdBy: order.cREATEDBYNAME,
                          salesPerson: order.sALESPERSON,
                          status: order.sTATUS,
                          lineItems: lineItemsDetails,
                          docid: order.dOCID,
                          mid: order.mID,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }*/
}
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    this.strSODate,
    this.strStatus,
    this.strinvcnum,
    this.strAmount,
    this.strCustName,
    this.strDueDate,
    this.strCreatedBy,
    this.strSalesPerson,
    this.onTap,
  });

  final String? strSODate;
  final String? strStatus;
  final String? strinvcnum;
  final String? strAmount;
  final String? strCustName;
  final String? strDueDate;
  final String? strCreatedBy;
  final String? strSalesPerson;
  final VoidCallback? onTap;

  Color get statusColor {
    switch ((strStatus ?? "").toLowerCase()) {
      case "approved":
      case "completed":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "cancelled":
      case "rejected":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 1),
      color: Colors.white, // light app background for mobile

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              /// Header
              Row(
                children: [

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xffEEF5FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Color(0xff1565C0),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          strinvcnum ?? "-",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          strCustName ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      strStatus ?? "",
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Divider(color: Colors.grey.shade200),

              const SizedBox(height: 10),

              Row(
                children: [

                  Expanded(
                    child: _info(
                      Icons.calendar_today_outlined,
                      "Due Date",
                      strDueDate,
                    ),
                  ),

                  Expanded(
                    child: _info(
                      Icons.person_outline,
                      "Sales Person",
                      strSalesPerson,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [

                  Expanded(
                    child: _info(
                      Icons.badge_outlined,
                      "Created By",
                      strCreatedBy,
                    ),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        const Text(
                          "Amount",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          "₹ ${strAmount ?? "0"}",
                          style: const TextStyle(
                            color: Color(0xff1565C0),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(
      IconData icon,
      String title,
      String? value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Icon(
          icon,
          size: 18,
          color: Colors.grey,
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value ?? "-",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

/*class ProductCard extends StatelessWidget {
  ProductCard({
    super.key,
    this.strSODate,
    this.strStatus,
    this.strinvcnum,
    this.strAmount,
    this.strCustName,
    this.strDueDate,
    this.strCreatedBy,
    this.strSalesPerson,
    this.pkid,
    this.onTap,
  });

  final String? strSODate;
  final String? strStatus;
  final String? strinvcnum;
  final String? strAmount;
  final String? strCustName;
  final String? strDueDate;
  final String? strCreatedBy;
  final String? strSalesPerson;
  final int? pkid;
  final VoidCallback? onTap;

  *//*String get formattedDate {
    try {
      final date = DateFormat('dd-MMM-yyyy').parse(strSODate ?? '');
      String strgetDate = DateFormat('dd MMM').format(date);
      String strgetDate1 = strgetDate[0] +
          "" +
          strgetDate[1] +
          "\n" +
          strgetDate[3] +
          strgetDate[4] +
          "" +
          strgetDate[5];
      return strgetDate1;
    } catch (e) {
      return 'Invalid Date';
    }
  }*//*
  String get formattedDate {
    try {
      final date = DateFormat('dd-MMM-yyyy').parse(strSODate ?? '');

      String day = DateFormat('dd').format(date);      // 01
      String month = DateFormat('MMM').format(date);   // Jan
      String year = DateFormat('yyyy').format(date);   // 2025

      return "$day\n$month\n$year";  // multi-line output
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    double boxWidth = width < 500 ? width * 0.22 : width * 0.07;
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        // 🔥 Shadow strength
         // optional
         shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),

      // 🔥 BORDER
      side: BorderSide(
        color: Colors.grey.shade300,

        width: 1,
      ),
    ),
        color: Colors.white,



        child: Padding(
          padding: EdgeInsets.symmetric(
        horizontal: width < 600 ? 0 : 12,
          vertical: width < 600 ? 2 : 8,
        ),
          child: Row(
            children: [

              if (strStatus == "Draft") ...[

                Container(
                  margin: EdgeInsets.all(0),
                  width: boxWidth,
                  height: height * 0.13,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],

                    // 🔥 BORDER
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),

                    // 🔥 CORNER RADIUS
                    borderRadius: BorderRadius.circular(10),

                    // 🔥 SHADOW
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,      // soft shadow
                        blurRadius: 8,              // spread of the shadow
                        offset: Offset(0, 3),       // position: x, y
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          child: Center(
                            child: Text(
                              formattedDate,
                              style: GoogleFonts.lato(
                                  fontSize: 10, fontWeight: FontWeight.normal),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        width: double.infinity,
                        decoration: BoxDecoration(color:Colors.grey),
                        child: Align(
                          alignment: Alignment.center,
                          child: Center(
                            child: Text(
                              strStatus!,
                              style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (strStatus == "Approved") ...[

                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFE4FFC8),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.all(0),

                  // 🔥 FIXED for mobile
                  width: boxWidth,
                  height: height * 0.13,

                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            formattedDate,
                            style: GoogleFonts.lato(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        width: double.infinity,
                        decoration: BoxDecoration(color: Color(0xFF82AF6F)),
                        child: Center(
                          child: Text(
                            strStatus!,
                            style: GoogleFonts.lato(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ]
              else if (strStatus == "Not Released") ...[

                Container(
                  margin: EdgeInsets.all(0),
                  width: boxWidth,
                  height: height * 0.13,
                  decoration:

              BoxDecoration(
              color: Colors.yellow[100],

              // 🔥 BORDER
              border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
              ),

              // 🔥 CORNER RADIUS
              borderRadius: BorderRadius.circular(10),

              // 🔥 SHADOW
              boxShadow: [
              BoxShadow(
              color: Colors.black12,      // soft shadow
              blurRadius: 8,              // spread of the shadow
              offset: Offset(0, 3),       // position: x, y
              ),
              ],
              ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          child: Center(
                            child: Text(
                              formattedDate,
                              style: GoogleFonts.lato(
                                  fontSize: 10, fontWeight: FontWeight.normal),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.yellow),
                        child: Align(
                          alignment: Alignment.center,
                          child: Center(
                            child: Text(
                              strStatus!,
                              style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
                else ...[

                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFBDE0FE),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.all(0),

                  // 🔥 FIXED for mobile
                  width: boxWidth,
                  height: height * 0.13,

                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            formattedDate,
                            style: GoogleFonts.lato(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        width: double.infinity,
                        decoration: BoxDecoration(color:Color(0xFF428BCA)),
                        child: Center(
                          child: Text(
                            strStatus!,
                            style: GoogleFonts.lato(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
              Expanded(
                child: Container(

                  padding: const EdgeInsets.only(
                      right: 2, left: 10, top: 2, bottom: 2),
                  child: Column(
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              strinvcnum!,
                              style: GoogleFonts.lato(),
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Text(
                                    '\u{20B9}${strAmount!}',
                                    style: GoogleFonts.lato(),
                                  ),
                                  SizedBox(
                                    width: width * 0.02,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        height: 3,
                      ),
                      Container(
                        child: Column(
                          children: [
                            // Customer Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    "Customer",
                                    style: GoogleFonts.lato(
                                      color: Colors.blueAccent[100],
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  width: 8,
                                ),
                                Expanded(
                                  child: Text(
                                    strCustName ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lato(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                           *//* SizedBox(height: height * 0.004),
                            // Due Date Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    "Due Date",
                                    style: GoogleFonts.lato(
                                      color: Colors.blueAccent[100],
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  width: 20,
                                ),
                                Expanded(
                                  child: Text(
                                    strDueDate ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lato(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),*//*
                            SizedBox(height: height * 0.004),
                            // Created by Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    "Created by",
                                    style: GoogleFonts.lato(
                                      color: Colors.blueAccent[100],
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  width: 8,
                                ),
                                Expanded(
                                  child: Text(
                                    strCreatedBy ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lato(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.004),
                            // Sales Person Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    "Sales Person",
                                    style: GoogleFonts.lato(
                                      color: Colors.blueAccent[100],
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  width: 8,
                                ),
                                Expanded(
                                  child: Text(
                                    strSalesPerson ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.lato(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.001),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}*/
