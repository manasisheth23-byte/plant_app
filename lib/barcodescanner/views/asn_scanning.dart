import 'package:erpflutter/barcodescanner/views/newansScanningeinvoiceDetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../plantappscreen/app_shell.dart';
import '../../plantappscreen/theme.dart';
import '../../provider/themecontroller.dart';
import '../../screens/UnreadNotificationProvider.dart';
import '../../screens/companylist/model/transaction_model.dart';
import '../../screens/plantlist/plant_provider.dart';
import '../../services/ApiProvider.dart';
import '../models/asn_scanning_response.dart';
import 'asn_scanning_details.dart';

class ASNScanningScreen extends StatefulWidget {


  @override
  State<ASNScanningScreen> createState() => _ASNScanningScreenState();
}

class _ASNScanningScreenState extends State<ASNScanningScreen> {
  bool isLoading = false;
  late Future<List<TRANSACTIONSASN>> asnList;
  TextEditingController docTypeController = TextEditingController();
  TextEditingController docNumberController = TextEditingController();
  String searchDocNo = "";
  String searchDocType = "";
  late ThemeController themeController;
  final ScrollController _horizontalController = ScrollController();
  int _idx = 0;
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    asnList = ApiProvider().fetchASNList(   mid: "0",
      docId: "0",);


  }
  @override
  void dispose() {
    // Allow any orientation when leaving DetailsScreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setHeight = MediaQuery.of(context).size.height;
    final setWidth = MediaQuery.of(context).size.width;
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);

    return Center(
        child: SizedBox(
            width: isDesktop ? 700 : double.infinity,
            child:Scaffold(
              backgroundColor:  Color(0xFFF5F7FB),
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Center(
              child: SizedBox(
                  width: isDesktop ? 700 : double.infinity,
                  child:AppBar(
                    title:  Text("Advanced Shipping Note",
                        style: GoogleFonts.lato(

                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        )),
                    centerTitle: false,
                    backgroundColor:  themeController.primaryColor,
                    foregroundColor: Colors.white,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {

                          Navigator.of(context).pop();

                        });


                      },
                    ),
                  )))),


              body: FutureBuilder<List<TRANSACTIONSASN>>(
                future: asnList,

                  builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  final list = snapshot.data ?? [];
                  List<TRANSACTIONSASN> filteredList = list;

                  if (searchDocType.isNotEmpty || searchDocNo.isNotEmpty) {
                    filteredList = list.where((item) {
                      final type = (item.documentType ?? "").toLowerCase();
                      final number = (item.documentNo ?? "").toLowerCase();

                      return type.contains(searchDocType) &&
                          number.contains(searchDocNo);
                    }).toList();
                  }

                  if (list.isEmpty) {
                    return const Center(child: Text("No Data Found"));
                  }


                  return Column(
                    children: [
                      // TextFeilds Section....


                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  height: setHeight * 0.07,
                                  child: TextFormField(
                                    controller: docTypeController,
                                    onChanged: (value) {
                                      setState(() {
                                        searchDocType = value.trim().toLowerCase();
                                      });
                                    },
                                    decoration: InputDecoration(
                                        hintText: "Search By Type",
                                        hintStyle: TextStyle(fontSize: 15)),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  height: setHeight * 0.07,
                                  child: TextFormField(
                                    controller: docNumberController,
                                    onChanged: (value) {
                                      setState(() {
                                        searchDocNo = value.trim().toLowerCase();
                                      });
                                    },
                                    decoration: InputDecoration(
                                        hintText: "Search By Number",
                                        hintStyle: TextStyle(fontSize: 15)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: setHeight * 0.01,
                      ),

                    /*  Table(
                        border: TableBorder.all(
                            color: const Color.fromARGB(255, 218, 218, 218)),
                        columnWidths: {
                          0: FixedColumnWidth(
                            setWidth * 0.12,
                          ),
                          1: FixedColumnWidth(
                            setWidth * 0.18,
                          ),
                          2: FixedColumnWidth(
                            setWidth * 0.14,
                          ),
                        },
                        children: [
                          // Table Heading***********
                          TableRow(
                            decoration: BoxDecoration(
                              color: Color(0xFF00D09F),
                            ),
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Type",
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 14, 14, 14),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Document No",
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 2, 2, 2),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Document Date",
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Customer Name",
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 14, 14, 14),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),*/


                    /*  Expanded(
                          child: filteredList.isEmpty
                              ? const Center(
                            child: Text(
                              "",
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                              :  ListView.builder(
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              Color backgroundColor = index % 2 == 0
                                  ? Color.fromARGB(255, 226, 226, 226)
                                  : Color.fromARGB(255, 207, 207, 207);
                              final item = filteredList[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ASNScanningDetailScreen(mid: item.mID??"",docId: item.dOCID??"",
                                    docNo: item.documentNo?? "",docDate: item.documentDate??"",)),
                                  );
                                },
                                child: Table(
                                  border: TableBorder.all(
                                      color: const Color.fromARGB(
                                          255, 218, 218, 218)),
                                  columnWidths: {
                                    0: FixedColumnWidth(
                                      setWidth * 0.12,
                                    ),
                                    1: FixedColumnWidth(
                                      setWidth * 0.18,
                                    ),
                                    2: FixedColumnWidth(
                                      setWidth * 0.14,
                                    ),
                                  },
                                  children: [
                                    // Table Dataaaaa
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: backgroundColor,
                                      ),
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              item.documentType ?? "",
                                              style: TextStyle(
                                                color: Color(0xFF00D09F),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              item.documentNo ?? "",
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    221, 78, 78, 78),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              item.documentDate ?? "",
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    221, 78, 78, 78),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              item.suppler ?? "",
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    221, 78, 78, 78),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ))*/
                      Expanded(
                        child: Scrollbar(
                          controller: _horizontalController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _horizontalController,
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width:  isDesktop ? 700 : double.infinity,
                              child: Column(
                                children: [
                                  //================ HEADER =================
                                  Table(
                                    border: TableBorder.all(color: Colors.grey.shade300),
                                 columnWidths: const {
                                   0: FlexColumnWidth(1.3),
                                   1: FlexColumnWidth(1.8),
                                   2: FlexColumnWidth(1.5),
                                   3: FlexColumnWidth(4.5),
                                  },
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: themeController.primaryColor,
                                        ),
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(2,12,2,12),
                                            child: Text(
                                              "Type",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(2,12,2,12),
                                            child: Text(
                                              "Document No",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(2,12,2,12),
                                            child: Text(
                                              "Document Date",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(2,12,2,12),
                                            child: Text(
                                              "Customer Name",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  //================ BODY =================
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: filteredList.length,
                                      itemBuilder: (context, index) {
                                        final item = filteredList[index];
                                        print("Product Code : ${item.productCode}");
                                        print("Description  : ${item.productDescription}");
                                        print("Quantity     : ${item.quantity}");
                                        print("Scanned      : ${item.scanned}");
                                        print("MID          : ${item.mID}");
                                        print("DOCID        : ${item.dOCID}");
                                        print("TID          : ${item.tID}");
                                        print("ITEMID       : ${item.iTEMID}");
                                        print("Scan Status  : ${item.scanStatus}");
                                        return InkWell(
                                          onTap: () {
                                          /*  Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) => InvoiceDetailedScreennew(
                                                    documentType: item
                                                        .documentType
                                                        .toString(),
                                                    documentNo:item
                                                        .documentNo
                                                        .toString(),
                                                    documentDate: item
                                                        .documentDate
                                                        .toString(),
                                                    docid: item
                                                        .dOCID
                                                        .toString(),
                                                    mid: item.mID
                                                        .toString(),
                                                    flag: "14",
                                                    slid: "0",
                                                    orgid: "",
                                                    projid: "0",
                                                    // tid: snapshot.data!.tRANSACTIONDETAILS!.tRANSACTIONS![index].tID.toString(),
                                                    title: ""),
                                              ),
                                            );*/
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ASNScanningDetailScreen(
                                                  mid: item.mID ?? "",
                                                  docId: item.dOCID ?? "",
                                                  docNo: item.documentNo ?? "",
                                                  docDate: item.documentDate ?? "",
                                                ),
                                              ),
                                            );
                                          },
                                          child: Table(
                                            border: TableBorder.all(
                                              color: Colors.grey.shade300,
                                            ),
                                            columnWidths: const {
                                              0: FlexColumnWidth(1.3),
                                              1: FlexColumnWidth(1.8),
                                              2: FlexColumnWidth(1.5),
                                              3: FlexColumnWidth(4.5),
                                            },
                                            children: [
                                              TableRow(
                                                decoration: BoxDecoration(
                                                  color: index.isEven
                                                      ? Colors.white
                                                      : const Color(0xffF5F5F5),
                                                ),
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(5),
                                                    child: Text(
                                                      item.documentType ?? "",
                                                      style: const TextStyle(
                                                        color: Color(0xFF00D09F),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(5),
                                                    child: Text(
                                                      item.documentNo ?? "",
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(5),
                                                    child: Text(
                                                      item.documentDate ?? "",
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(5),
                                                    child: Text(
                                                      item.suppler ?? "",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
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

                    /* const NavigationDestination(icon: Icon(Icons.grid_view_outlined,size: 30), selectedIcon: Icon(Icons.grid_view,size: 30, color: C.blue), label: 'Shop Floor'),*/
                    NavigationDestination(
                      icon: Badge( label: Text(unreadProvider.unreadCount.toString()), child: const Icon(Icons.notifications_outlined,size: 30)),
                      selectedIcon: const Icon(Icons.notifications,size: 30, color: C.blue),
                      label: 'Alerts',
                    ),
                    const NavigationDestination(icon: Icon(Icons.bar_chart_outlined,size: 30), selectedIcon: Icon(Icons.bar_chart,size: 30, color: C.blue), label: 'Reports'),
                    const NavigationDestination(icon: Icon(Icons.chat_bubble_outline,size: 30), selectedIcon: Icon(Icons.chat_bubble,size: 30, color: C.blue), label: 'Copilot'),
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
    )));
  }
}