import 'dart:io';

import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/barcodescanner/view_models/barcoderegistration_viewmodel.dart';
import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../Dashboard.dart';
import '../../provider/themecontroller.dart';
import '../../screens/BarcodeQrcodeScanner/barcodescan.dart';
import '../../screens/BarcodeQrcodeScanner/scanqr.dart';
import '../../screens/BarcodeQrcodeScanner/showcustomsnackbar.dart';
import '../view_models/audit_barcode_viewmodel.dart';

class BarcodeScreen extends StatefulWidget {
  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  String serialNumber = "";
  late ThemeController themeController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BarcodeProvider>(context, listen: false);

      // Clear old data
      provider.barcodeLookupList.clear();
      provider.barcodeController.clear();

      // SAFE: runs after build
      provider.loadAllTransactionsRegistration();
      provider.loadDocumentNumbers();

      provider.scrollController.addListener(() {
        if (provider.scrollController.position.pixels >=
            provider.scrollController.position.maxScrollExtent - 200) {
          // provider.loadMoreTransactions();
        }
      });
    });
  }
  int _idx = 1;
  @override
  Widget build(BuildContext context) {
    themeController = Provider.of<ThemeController>(context, listen: false);
    final isDesktop = MediaQuery.of(context).size.width >= 700;
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
            title:  Text("Registration",style:  GoogleFonts.lato(

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
                final provider = Provider.of<BarcodeProvider>(context, listen: false);
                provider.barcodeController.clear();
                provider.barcodeLookupList.clear();
                Navigator.of(context).pop();
              /*  WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => Dashboard()),
                  );
                });*/
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
          body: Consumer<BarcodeProvider>(
            builder: (context, provider, child) {
              return Center(
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      color:const Color(0xFFF5F7FB),
                      width: isDesktop ? 700 : double.infinity,
                      padding: const EdgeInsets.all(10),
                      child:Column(
                children: [
                  const SizedBox(height: 10),

                  // ---- Barcode Input ----
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Barcode / Serial no",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Card(
                      elevation: 4,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
              controller: provider.barcodeController,
              decoration: InputDecoration(
              hintText: "Enter Barcode",
              border: const OutlineInputBorder(),
                suffixIcon: Platform.isAndroid
                    ? IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: () async {
                    var scannedCode = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BarcodeQRViewExample(),
                      ),
                    );

                    if (scannedCode != null && scannedCode.isNotEmpty) {
                      if (scannedCode.startsWith("[") && scannedCode.endsWith("]")) {
                        scannedCode = scannedCode.substring(1, scannedCode.length - 1);
                      }
                      // 🔥 Clear list before loading new barcode
                     provider.barcodeLookupList.clear();
                      provider.notifyListeners();

                      print(scannedCode);
                      if (scannedCode.contains("Serial No -")) {
                        serialNumber = scannedCode.split("Serial No -").last.trim();
                      }else
                      {
                        serialNumber=scannedCode;
                      }

                      print(serialNumber);
                      provider.barcodeController.text = serialNumber;

                      // 🔥 Load new barcode data
                      provider.loadBarcodeRegistrationLookup(serialNumber.toString().trim());

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
                  if (value.startsWith("[") && value.endsWith("]")) {
                    value = value.substring(1, value.length - 1);
                  }
                  provider.barcodeLookupList.clear();
                  provider.notifyListeners();
                  provider.loadBarcodeRegistrationLookup(value.toString().trim());
                }

              }
              ),
              )),




          /*        Container(height: 1, color: Colors.black),*/

                  // ---- Data List / Message ----
                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : provider.barcodeLookupList.isEmpty
                        ? const Center(
                      child: Text(
                        "No data found",

                      ),
                    )
                        : /*ListView.builder(
                      controller: provider.scrollController,
                      itemCount: provider.barcodeLookupList.length,
                      itemBuilder: (context, index) {
                        final transaction =
                        provider.barcodeLookupList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            title: Text(
                              transaction.itemDesc ?? 'N/A',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text("Invoice Type: ${transaction.invcType ?? '-'}"),
                                Text("Invoice No: ${transaction.invcNumb ?? '-'}"),
                                Text("Item Code: ${transaction.itemCode ?? '-'}"),
                                Text("Qty: ${transaction.qty ?? '-'}"),
                              ],
                            ),
                            trailing: Text(transaction.lotId ?? ''),
                          ),
                        );
                      },
                    ),*/
                    ListView.builder(
                      controller: provider.scrollController,
                      itemCount: provider.barcodeLookupList.length,
                      itemBuilder: (context, index) {
                        final transaction = provider.barcodeLookupList[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Card(
                            elevation: 3,
                            shadowColor: Colors.grey.withOpacity(.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left Blue Line
                                    Container(
                                      width: 4,
                                      height: 115,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade900,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [

                                          /// Item Name
                                          Text(
                                            transaction.itemDesc ?? "N/A",
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xff0B3C73),
                                            ),
                                          ),

                                          const SizedBox(height: 12),

                                          _infoRow(
                                            Icons.receipt_long_outlined,
                                            "Invoice Type",
                                            transaction.invcType ?? "-",
                                          ),

                                          const SizedBox(height: 8),

                                          _infoRow(
                                            Icons.description_outlined,
                                            "Invoice No",
                                            transaction.invcNumb ?? "-",
                                          ),

                                          const SizedBox(height: 8),

                                          _infoRow(
                                            Icons.qr_code,
                                            "Item Code",
                                            transaction.itemCode ?? "-",
                                          ),

                                          const SizedBox(height: 8),

                                          _infoRow(
                                            Icons.inventory_2_outlined,
                                            "Qty",
                                            transaction.qty?.toString() ?? "-",
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    // Right Side
                                    Column(
                                      children: [
                                        Text(
                                          transaction.lotId ?? "",
                                          style: const TextStyle(
                                            color:Colors.grey,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                      /*  const Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey,
                                          size: 28,
                                        ),*/
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  ),

                  // ---- Submit Button (only visible if data is available) ----
                  if (provider.barcodeLookupList.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: SafeArea(
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:  themeController.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {

                              print(provider.barcodeLookupList.length);
                              provider.syncBarcodeList(context,provider.barcodeLookupList,"1");
                             // provider.barcodeLookupList.clear();
                            //  provider.barcodeController.clear();
                             //

                            },
                            child: const Text(
                              "Submit",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )));
            },
          ),
        ),
      ),
    );
  }
  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xff0B3C73),
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
              children: [
                TextSpan(
                  text: "$title: ",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
