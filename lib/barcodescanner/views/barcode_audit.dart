import 'dart:io';
import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/barcodescanner/view_models/audit_barcode_viewmodel.dart';
import 'package:erpflutter/barcodescanner/views/audit_list_item.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../Dashboard.dart';
import '../../plantappscreen/app_shell.dart';
import '../../provider/themecontroller.dart';
import '../../screens/BarcodeQrcodeScanner/barcodescan.dart';
import '../../screens/BarcodeQrcodeScanner/showcustomsnackbar.dart';

class BarcodeAuditScreen extends StatefulWidget {
  @override
  State<BarcodeAuditScreen> createState() => _BarcodeAuditScreen();
}

class _BarcodeAuditScreen extends State<BarcodeAuditScreen> {
  String serialNumber = "";
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      serialNumber = "";
      // Clear the barcode field when the screen opens
      final provider = context.read<AuditProvider>();
      provider.barcodeController.clear();
      provider.clearAuditData();
    });
  }
  int _idx = 1;
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return Center(
      child: SizedBox(
        width: isDesktop ? 700 : double.infinity,
        child: Scaffold(
              backgroundColor: isDesktop
                  ? Colors.white // dark app background for Windows/Desktop
                  : const Color(0xFFF5F7FB),

                appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: Center(
                        child: SizedBox(
                            width: isDesktop ? 700 : double.infinity,
                            child:AppBar(
                  title:  Text("Audit Check",style:  GoogleFonts.lato(

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
                      /*  Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => Dashboard()),
                        );*/
                      });
                    },
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
                    MaterialPageRoute(
                      builder: (_) => AppShell(
                        role: "Admin",
                        plant: plantName,
                        selectedIndex: index,

                      ),
                    ),
                  );
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
              child:Container(
        height: MediaQuery.of(context).size.height,
        color:const Color(0xFFF5F7FB),
        width: isDesktop ? 700 : double.infinity,
        padding: const EdgeInsets.all(0),
        child: Column(
            children: [
         /*     Container(
                color: AppColors.APPCOLOR,
                height: 60,
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 0,
                  bottom: 0,
                ),
                //  padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [

                    GestureDetector(

                      onTap: () {

                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppShell(role: "Admin", plant: '')));

                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Audit Check",
                      style: TextStyle(
                        fontFamily: "DMSans",
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),*/


              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Barcode / Serial no",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              // ---------------- BARCODE INPUT ----------------
              Card(
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child:  TextField(
                  controller: provider.barcodeController,
                  decoration: InputDecoration(
                    hintText: "Enter Barcode",
                    border: const OutlineInputBorder(),
                    suffixIcon: Platform.isAndroid
                        ? IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: () async {

                        serialNumber = "";
                        // Clear the barcode field when the screen opens
                        final provider = context.read<AuditProvider>();
                        provider.barcodeController.clear();
                        provider.clearAll();
                        final scannedCode = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BarcodeQRViewExample(),
                          ),
                        );

                        if (scannedCode != null && scannedCode.isNotEmpty) {

                          String serialNumber = "";
                          print(scannedCode);
                          if (scannedCode.contains("Serial No -")) {
                            serialNumber = scannedCode.split("Serial No -").last.trim();
                          }else
                          {
                            serialNumber=scannedCode;
                          }

                          print(serialNumber);
                          provider.barcodeController.text = serialNumber;
                          provider.fetchBarcodeItems("4");

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Scanned: $serialNumber'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    )
                        : null,
                  ),
                  onSubmitted: (value) {
        if (provider.barcodeController.text
            .trim()
            .isEmpty) {
        showCustomSnackBar(
        context: context,
        message: 'Please enter QR/Barcode',
        backgroundColor: Colors.red,
        );
        } else {
          provider.fetchBarcodeItems("4");
        }
                  },
                ),
              )),

              // ---------------- LIST VIEW ----------------
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildList(provider),
              ),
            ],
          )

              ,
        ))),
      ),
    );
  }

  // ------------------------------ LIST UI FUNCTION ------------------------------
  Widget _buildList(AuditProvider provider) {
    final transactions =
        provider.auditData?.transactionDetails?.transactions;

    if (transactions == null || transactions.isEmpty) {
      return const Center(child: Text("No data found"));
    }

    final lotDetails = provider.auditData?.transactionDetails?.lotDetails;

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final item = transactions[index];

        // Safely fetch lotDetail for the same index (if exists)
        final lotDetail = (lotDetails != null && lotDetails.length > index)
            ? lotDetails[index]
            : null;

        return InkWell(
            onTap: () {
              // <-- Your click action here
              print("Clicked item index: $index");
              print("Item Code: ${item.itemCode}");

              // Example navigation:
              // Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsScreen(item: item)));
            },
            child: BarcodeListItem(
          item: item,
          lotDetail: lotDetail , // handle null inside widget
        ));
      },
    );
  }
}
