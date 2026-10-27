import 'package:erpflutter/barcodescanner/models/asn_scanning_response.dart';
import 'package:erpflutter/barcodescanner/views/asn_scanning.dart';
import 'package:erpflutter/provider/barcode_provider.dart';
import 'package:erpflutter/services/ApiProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../plantappscreen/app_shell.dart';
import '../../plantappscreen/theme.dart';
import '../../provider/themecontroller.dart';
import '../../screens/BarcodeQrcodeScanner/scanqr.dart';
import '../../screens/UnreadNotificationProvider.dart';
import '../../screens/plantlist/plant_provider.dart';
import 'asn_qrcode.dart';


class ASNScanningDetailScreen extends StatefulWidget {
  final String mid;
  final String docId;
  final String docNo;
  final String docDate;

  const ASNScanningDetailScreen({
    Key? key,
    required this.mid,
    required this.docId,
    required this.docNo,
    required this.docDate,
  }) : super(key: key);

  @override
  State<ASNScanningDetailScreen> createState() =>
      _ASNScanningDetailScreenState();
}

class _ASNScanningDetailScreenState extends State<ASNScanningDetailScreen> {
  late ThemeController themeController;
  int _idx = 0;
  late Future<List<TRANSACTIONSASN>> asnList;

  final ScrollController _horizontalController = ScrollController();
  Future<List<TRANSACTIONSASN>> fetchASNList() async {
    return await ApiProvider().fetchASNList(
      mid: widget.mid,
      docId: widget.docId,
    );
  }
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    asnList = fetchASNList();
  }





  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final setHeight = MediaQuery.of(context).size.height;
    final setWidth = MediaQuery.of(context).size.width;
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);

    return Consumer<BarcodeProviderAns>(
        builder: (context, value, child) {
        return Center(
            child: SizedBox(
                width: isDesktop ? 700 : double.infinity,
                child:Scaffold(
          backgroundColor: Colors.white,
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
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => ASNScanningScreen()),
                              );
                             // Navigator.of(context).pop();

                            });


                          },
                        ),
                      )))),

          body: Column(
            children: [
              // TextFeilds Section....

              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox(
                        height: setHeight * 0.07,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.padding_outlined,
                              size: 25,
                            ),
                            Text(widget.docNo,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 15))
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                          height: setHeight * 0.07,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.date_range_rounded,
                                size: 25,
                              ),
                              Text(
                                widget.docDate,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 15),
                              )
                            ],
                          )),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: setHeight * 0.01,
              ),



          /*    Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: {
                *//*  0: FixedColumnWidth(setWidth * 0.18),
                  1: FlexColumnWidth(),
                  2: FixedColumnWidth(setWidth * 0.12),
                  3: FixedColumnWidth(setWidth * 0.12),*//*
                  0: FixedColumnWidth(isDesktop ? setWidth * 0.10 : setWidth * 0.18),
                  1:  FixedColumnWidth(isDesktop ? setWidth * 0.13 : setWidth * 0.12),
                  2: FixedColumnWidth(isDesktop ? setWidth * 0.10 : setWidth * 0.12),
                  3: FixedColumnWidth(isDesktop ? setWidth * 0.10 : setWidth *0.12),

                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: themeController.primaryColor,
                    ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Item Code",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Description",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(
                          child: Text(
                            "Quantity",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(
                          child: Text(
                            "Scanned",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ],
              ),*/

              //================== Data ==================
              Expanded(
                child: FutureBuilder<List<TRANSACTIONSASN>>(
                  future: asnList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No Data Found"));
                    }

                    final list = snapshot.data!;

                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];

                        final balance =
                            (int.tryParse(item.quantity ?? "0") ?? 0) -
                                (int.tryParse(item.scanned ?? "0") ?? 0);

                        Color backgroundColor = index.isEven
                            ? const Color(0xffF5F5F5)
                            : Colors.white;

                        return InkWell(
                          onTap: () async {
                            // Your existing navigation code
                          },
                          child: Table(
                            border: TableBorder.all(color: Colors.grey.shade300),
                            columnWidths: {
                          /*    0: FixedColumnWidth(setWidth * 0.18),
                              1: FlexColumnWidth(),
                              2: FixedColumnWidth(setWidth * 0.12),
                              3: FixedColumnWidth(setWidth * 0.12),*/
                              0: FixedColumnWidth(isDesktop ? setWidth * 0.10 : setWidth * 0.18),
                              1:  FixedColumnWidth(isDesktop ? setWidth * 0.13 : setWidth * 0.12),
                              2: FixedColumnWidth(isDesktop ? setWidth * 0.10 : setWidth * 0.12),
                              3: FixedColumnWidth(isDesktop ? setWidth * 0.10 : setWidth *0.12),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: themeController.primaryColor,
                                ),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Item Code",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      "Description",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Center(
                                      child: Text(
                                        "Quantity",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Center(
                                      child: Text(
                                        "Scanned",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                              TableRow(
                                decoration: BoxDecoration(color: backgroundColor),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: InkWell(
                                      onTap: () async {
                                        SharedPreferences prefs = await SharedPreferences.getInstance();


                                        String? orgstID = prefs.getString('ORGSTRUCTID');
                                        final result = await Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => QRViewExampleans(
                                              mId: item.mID ?? "",
                                              dId: item.dOCID ?? "",
                                              tId: item.tID ?? "",
                                              itemId: item.iTEMID ?? "",
                                              itemCode: item.productCode ?? "",
                                              planQty: item.quantity ?? "0",
                                              scanqty: item.scanned ?? "0",

                                              // Calculated Balance
                                              balanceQty: (
                                                  (int.tryParse(item.quantity ?? "0") ?? 0) -
                                                      (int.tryParse(item.scanned ?? "0") ?? 0)
                                              ).toString(),

                                              // Document Details
                                              doctype: item.documentType ?? "",
                                              docno: item.documentNo ?? "",
                                              docdate: item.documentDate ?? "",

                                              // Screen Parameters
                                              title: "ASN Scanning",

                                              // If QRViewExample requires these
                                              index: index,
                                              flag: '14', orgID:orgstID??"", slid: '', projId: '',

                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          setState(() {
                                            asnList = fetchASNList();
                                          });
                                        }
                                      },
                                      child: Text(
                                        item.productCode ?? "",
                                        style: const TextStyle(
                                          color: Color(0xFF00D09F),
                                          fontWeight: FontWeight.bold,

                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(item.productDescription ?? ""),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Center(
                                      child: Text(item.quantity ?? "0"),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Center(
                                      child: Text( item.scanned?? "0"),
                                    ),
                                  ),

                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ASNScanningScreen()),
                    );
                   /* Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (context) => ASNScanningScreen(
                              orgID15: widget.orgid,
                              invoiceFlag: widget.flag,
                              title: widget.title,
                              mId: '',
                              docId: '')),
                    );*/
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: themeController.primaryColor,
                    ),
                    width: isDesktop ? 300 : setWidth,
                    child: const Center(
                      child: Text(
                        "Save & Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
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
                 NavigationDestination(
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
    );
  }
}