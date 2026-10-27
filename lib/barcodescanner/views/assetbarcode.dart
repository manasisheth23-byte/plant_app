import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/barcodescanner/view_models/audit_barcode_viewmodel.dart';
import 'package:erpflutter/barcodescanner/views/audit_list_item.dart';
import '../../Dashboard.dart';
import '../../plantappscreen/app_shell.dart';
import '../../provider/themecontroller.dart';
import '../../screens/BarcodeQrcodeScanner/barcodescan.dart';
import '../../screens/BarcodeQrcodeScanner/showcustomsnackbar.dart';

class AssetbarcodeScreen extends StatefulWidget {
  const AssetbarcodeScreen({super.key});

  @override
  State<AssetbarcodeScreen> createState() => _AssetbarcodeScreen();
}

class _AssetbarcodeScreen extends State<AssetbarcodeScreen> {
  String serialNumber = "";
  bool _firstLoad = true;
  late ThemeController themeController;

  // ✅ FIX: CLEAR ON FIRST DEPENDENCY LOAD
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_firstLoad) {
     // context.read<AuditProvider>().clearAll();
      serialNumber = "";
      _firstLoad = false;
    }
  }
  @override
  void initState() {
    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      serialNumber = "";
      // Clear the barcode field when the screen opens
      final provider = context.read<AuditProvider>();
      provider.barcodeController.clear();
      provider.clearAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuditProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);

    return Scaffold(
        backgroundColor: isDesktop
        ? Colors.white // dark app background for Windows/Desktop
            : const Color(0xFFF5F7FB),
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Center(
                  child: SizedBox(
                      width: isDesktop ? 700 : double.infinity,
                      child:AppBar(
                        title:  Text("Asset Barcode/QR Code",style:  GoogleFonts.lato(

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

                            Navigator.of(context).pop();
                            /*  WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => Dashboard()),
              );
            });*/
                          },
                        ),
                      )))),
      body:Center(
          child: Container(
    height: MediaQuery.of(context).size.height,
    color:const Color(0xFFF5F7FB),
    width: isDesktop ? 700 : double.infinity,
    padding: const EdgeInsets.all(0),
    child: Column(
        children: [
      /*    Container(
            color: themeController.primaryColor,
            height: 75,
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 15,
              bottom: 0,
            ),
            //  padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [

                GestureDetector(
                  onTap: () {



                  },
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Asset Barcode/QR Code",
                  style: TextStyle(

                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700
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
                "Barcode / QR Code",
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
                    // ✅ CLEAR BEFORE SCANNER OPENS
                    provider.clearAll();
                    setState(() => serialNumber = "");

                    final scannedCode = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BarcodeQRViewExample(),
                      ),
                    );

                    if (scannedCode != null &&
                        scannedCode.toString().isNotEmpty) {
                      serialNumber = scannedCode.contains("Serial No -")
                          ? scannedCode
                          .split("Serial No -")
                          .last
                          .trim()
                          : scannedCode;

                      provider.barcodeController.text = serialNumber;
                      provider.fetchBarcodeItems("5");

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
              onSubmitted: (_) {
    if (provider.barcodeController.text
        .trim()
        .isEmpty) {
    showCustomSnackBar(
    context: context,
    message: 'Please enter QR/Barcode',
    backgroundColor: Colors.red,
    );
    } else {
      provider.fetchBarcodeItems("5");
    }
              },
            )),
          ),

          // ✅ UI STATE HANDLING
          if (provider.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.auditData?.transactionDetails?.transactions != null)
            Expanded(
              child: ListView.builder(
                itemCount: provider.auditData!
                    .transactionDetails!.transactions!.length,
                itemBuilder: (context, index) {
                  final item = provider.auditData!
                      .transactionDetails!.transactions![index];

                  final lotDetail = provider.auditData!
                      .transactionDetails!.lotDetails?.isNotEmpty ==
                      true
                      ? provider.auditData!
                      .transactionDetails!.lotDetails!.first
                      : null;

                  if (lotDetail == null) return const SizedBox.shrink();

                  return BarcodeListItem(
                    item: item,
                    lotDetail: lotDetail,
                  );
                },
              ),
            )
          else
            const Expanded(
              child: Center(child: Text("No data found")),
            ),
        ],
      ))),
    );
  }
}
