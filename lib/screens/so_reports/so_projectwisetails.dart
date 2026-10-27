import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/screens/so_reports/so_projectwise_controller.dart';
import 'package:erpflutter/screens/so_reports/so_reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/projectwise_detail_order_data_response.dart';
import '../../models/projectwise_response_model.dart';
import '../../provider/themecontroller.dart';
import '../../services/ApiProvider.dart';

class ProjectWiseDetails extends StatefulWidget {
  const ProjectWiseDetails({Key? key}) : super(key: key);

  @override
  State<ProjectWiseDetails> createState() => _ProjectWiseDetailsState();
}

class _ProjectWiseDetailsState extends State<ProjectWiseDetails> {
  int? expandedIndex;
  final ScrollController _horizontalController = ScrollController();
  bool _isOrderTableVisible = false;
  bool _isLoading = false;
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();


    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch both table data and dropdown data
      Provider.of<ProjectWiseDetailtProvider>(context, listen: false).fetchMasterProjectData();

    });
  }

  @override
  void dispose() {
    final provider = Provider.of<ProjectWiseDetailtProvider>(context);
    _horizontalController.dispose();
    provider.resetSelectedProjId();
   
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
    return  Center(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: themeController.primaryColor,
            foregroundColor: Colors.white,
          centerTitle: false,

          title:GestureDetector(
          onTap: () {
        // Handle tap here
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 10),
                reverseTransitionDuration: const Duration(milliseconds: 10),
                pageBuilder: (_, animation, secondaryAnimation) =>
                    SoReports(),
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
          MaterialPageRoute(builder: (context) => SoReports()),
        );*/
      },
      child:  Text(
            'Project Wise Details',
            style: GoogleFonts.lato(

              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            )
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
         /*     Navigator.pushReplacement(
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
        body: Stack(
          children: [
            Column(
              children: [
                // Filter section
                _buildFilterHeader(),
                // Table

              Visibility(
                    visible: _isOrderTableVisible,
                    child:Expanded(
                  child: _buildOrderTable(),
                )),


              ],
            ),
            // Buttons at the bottom right
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTable() {
    final salesOrderProvider = Provider.of<ProjectWiseDetailtProvider>(context);

    // If loading, show a loading indicator
    if (salesOrderProvider.isLoadingSalesOrder) {
      return Center(child: CircularProgressIndicator());
    }else if (salesOrderProvider.projList.isEmpty) {
      return Text("");
    }else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _horizontalController,
        child: SizedBox(
          // Fixed width ensuring all columns fit without overflow
          width: 1510,
          child: Column(
            children: [
              // Table header
              Container(
                color: Colors.grey[200],
                child: Row(
                  children: [
                    _buildHeaderCell('Priority', 80),
                    _buildHeaderCell('Sr. No.', 80),
                    _buildHeaderCell('SO. No.', 150),
                    _buildHeaderCell('SO. Line No.', 100),
                    _buildHeaderCell('SO. Date', 100),
                    _buildHeaderCell('Customer', 200),
                    _buildHeaderCell('Project No.', 100),
                    _buildHeaderCell('Product Code', 150),
                    _buildHeaderCell('Product Description', 200),
                    _buildHeaderCell('PO. No.', 150),
                    _buildHeaderCell('PO. Date', 100),
                    _buildHeaderCell('PO Diff. Days', 100),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: salesOrderProvider.orders
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final order = entry.value;
                      return Container(
                        color: Colors.green[100],
                        child: Column(
                          children: [
                            // Data row with expand/collapse button
                            Row(
                              children: [
                                _buildDataCell('', 80),
                                _buildDataCell(''.toString(), 80),
                                _buildDataCellWithButton(
                                  order.soNo,
                                  150,
                                  IconButton(
                                    icon: Icon(
                                      expandedIndex == index
                                          ? Icons.remove
                                          : Icons.add,
                                      color: Colors.blue,
                                      size: 16,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setState(() {
                                        expandedIndex =
                                        expandedIndex == index ? null : index;
                                      });
                                    },
                                  ),
                                ),
                                _buildDataCell(order.soNo.toString(), 100),
                                _buildDataCell(order.soDate, 100),
                                _buildDataCell(order.customer, 200),
                                _buildDataCell('', 100),
                                _buildDataCell(order.productCode, 150),
                                _buildDataCell(order.productDesc, 200),
                                _buildDataCell(order.poNo, 150),
                                _buildDataCell(order.poDate, 100),
                                _buildDataCell('', 100),
                              ],
                            ),

                            // Expanded view - only visible when row is expanded
                            if (expandedIndex == index &&
                                order.items.isNotEmpty)
                              _buildExpandedView(order),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            ],
          ),
        ),
      );
    }
  }

  Widget _buildFilterHeader() {
    final provider = Provider.of<ProjectWiseDetailtProvider>(context);

    return Container(
      padding: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Expanded(
        child: Row(
          children: [
            const Text(
              'Master Project No.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Text(
              '*',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 9),
            Container(
              width: 140, // Reduced width
              height: 30, // Reduced height
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 0),
                  provider.isLoading
                      ? const Center(child: SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)))
                      : Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        hint: const Text(
                          'Select Project',
                          overflow: TextOverflow.ellipsis,
                        ),
                        value: provider.selectedProjId,
                        onChanged: (newValue) {
                          provider.setSelectedProjId(newValue);
                          print('Selected PROJID: $newValue');
                        },
                        items: provider.projList.map((proj) {
                          return DropdownMenuItem<int>(
                            value: proj.projId,
                            child: Text(
                              proj.projDesc,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.filter_alt, color: Colors.white, size: 14),
              label: const Text(
                '',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              onPressed: () {
                setState(() {
                  _isLoading = true;  // Show the loader
                });
                final requestData = {
                  "XMLFILE": {
                    "SPXML": {
                      "ActionType": "Filter",
                      "SPDETAILS": {
                        "FLAG": "",
                        "USERID": "335",
                        "SELORGSTRUCTID": "4",
                        "PAGENO": "1",
                        "PROJID": "3"
                      }
                    }
                  }
                };
               var response= provider.fetchOrders(requestData);

               setState(() {
                 _isLoading = false;
                 _isOrderTableVisible = !_isOrderTableVisible; // Toggle visibility
                });


              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: const Size(40, 30), // Smaller button size
              ),
            ),
            const SizedBox(width: 6),
        /*    OutlinedButton.icon(
              icon: const Icon(Icons.file_download, size: 14),
              label: const Text(
                'Export',
                style: TextStyle(fontSize: 12),
              ),
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: const Size(80, 30), // Smaller button size
              ),
            ),*/
          ],
        ),
      ),
    );

  }


  // Expanded view with items data
  Widget _buildExpandedView(ProjectDetailSalesOrder order) {
    return Container(
      width: 1510, // Match parent width
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-table header
          Container(
            color: Colors.blue[50],
            child: Row(
              children: [
                _buildHeaderCell('Item Code', 150),
                _buildHeaderCell('Buyer Name', 110),
                _buildHeaderCell('Item Type', 110),
                _buildHeaderCell('Dimension', 110),
                _buildHeaderCell('MTA/MTO', 80),
                _buildHeaderCell('Availability /Req.', 170),
                _buildHeaderCell('Stock Available', 120),
                _buildHeaderCell('Open PO/WO Qty', 120),
                _buildHeaderCell('Quantity Required', 170),
                _buildHeaderCell('Pending Quantity', 170),
                _buildHeaderCell('Lead Time', 100),
              ],
            ),
          ),

          // Item rows
          ...order.items.map((item) => Container(
            color: Colors.pink[50],
            child: Row(
              children: [
                _buildDataCell(item.itemCode, 150),
                _buildDataCell(item.BuyerName, 110),
                _buildDataCell(item.itemType, 110),
                 _buildDataCell(item.Dimension, 110),
                _buildDataCell(item.MTA_MTO, 80),
                _buildDataCell(item.Availability, 170),
                 _buildDataCell(item.StockAvailable, 120),
                _buildDataCell(item.OpenPO_WOQty, 120),
                _buildDataCell(item.QuantityRequired.toString(), 170),
                _buildDataCell(item.PendingQuantity.toString(), 170),
                _buildDataCell(item.leadTime.toString(), 100),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[400]!, width: 1.0),
          right: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDataCell(String text, double width) {
    return Container(
      width: width,
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1.0),
          right: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDataCellWithButton(String text, double width, Widget button) {
    return Container(
      width: width,
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1.0),
          right: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          button,
        ],
      ),
    );
  }

}

class OrderData {
  final int priority;
  final int srNo;
  final String soNo;
  final int soLineNo;
  final String soDate;
  final String customer;
  final String projectNo;
  final String productCode;
  final String productDescription;
  final String poNo;
  final String poDate;
  final int poDiffDays;
  final List<ItemData> items;

  OrderData({
    required this.priority,
    required this.srNo,
    required this.soNo,
    required this.soLineNo,
    required this.soDate,
    required this.customer,
    required this.projectNo,
    required this.productCode,
    required this.productDescription,
    required this.poNo,
    required this.poDate,
    required this.poDiffDays,
    required this.items,
  });
}

class ItemData {
  final String itemCode;
  final String itemType;
  final String mtaMto;
  final String availabilityReq;
  final String stockAvailable;
  final String openPOWOQty;
  final String quantityRequired;
  final String pendingQuantity;
  final String leadTime;

  ItemData({
    required this.itemCode,
    required this.itemType,
    required this.mtaMto,
    required this.availabilityReq,
    required this.stockAvailable,
    required this.openPOWOQty,
    required this.quantityRequired,
    required this.pendingQuantity,
    required this.leadTime,
  });
}