import 'dart:io';

import 'package:erpflutter/barcodescanner/models/invoicedetailsmodel.dart';
import 'package:erpflutter/barcodescanner/views/qrcodescanner.dart';
import 'package:erpflutter/provider/barcode_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../provider/themecontroller.dart';
import '../../screens/UnreadNotificationProvider.dart';


class GRNBroughtOutScreen extends StatefulWidget {


  @override
  State<GRNBroughtOutScreen> createState() => _GRNBroughtOutScreenState();
}

class _GRNBroughtOutScreenState extends State<GRNBroughtOutScreen> {


  TextEditingController docTypeController = TextEditingController();
  TextEditingController docNumberController = TextEditingController();
  String searchDocNo = '';
  late ThemeController themeController;
  int _idx = 0;
  InvoiceDetailsModelAns? invoiceModel;
  bool hasSearched = false;
  String apiMessage = "";
  TextEditingController qrController = TextEditingController();
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    //  plantlist = ApiProvider().fetchPlantLIst(widget.orgStrucId);
  }

  @override
  void dispose() {
    // Allow any orientation when leaving DetailsScreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }
  Future<void> invoiceDetailsApi(String qrCode) async {
    setState(() {
      _isLoading = true;
    });

    try {
      invoiceModel = await Provider.of<BarcodeProviderAns>(
        context,
        listen: false,
      ).getASNInvoiceDetails(
        qrCode,
        "",
        "15",
        "",
        "",
        "",
      );

      if (!mounted) return;

      setState(() {
        hasSearched = true;

        if (invoiceModel == null ||
            invoiceModel!.transactionDetails?.mast == null) {
          apiMessage =
          invoiceModel?.transactionDetails?.message?.isNotEmpty == true
              ? invoiceModel!.transactionDetails!.message!
              : "No Record Found.";
        } else {
          apiMessage = "";
        }

        qrController.clear();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  /*invoiceDetailsApi(String qrcode) async {


    invoiceModel = await Provider.of<BarcodeProviderAns>(
      context,
      listen: false,
    ).getASNInvoiceDetails(
      "",
      '',
      "15",
      "",
      "",
      "",
    );

    if (invoiceModel != null) {
      setState(() {});
    }
  }*/

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
              appBar: AppBar(
                iconTheme: const IconThemeData(color: Colors.white),
                backgroundColor: themeController.primaryColor,
                title:  Text(
                  "ASN No. Scanning",
                  style: GoogleFonts.lato(

                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),


              body:  ListView(
                padding: const EdgeInsets.all(16),
                children: [

              Row(
              children: [
              Expanded(
              child: TextField(
                controller: qrController,
                decoration: InputDecoration(
                  hintText: "Enter / Scan QR Code",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),

          const SizedBox(width: 8),

          // Search Button
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
              onPressed: () {
                FocusScope.of(context).unfocus();

                if (qrController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter QR Code"),
                    ),
                  );
                  return;
                }

                invoiceDetailsApi(qrController.text.trim());
              },
            ),
          ),

          const SizedBox(width: 8),

          // Scanner Button
                if(Platform.isAndroid)
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: themeController.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
              ),
              onPressed: () async {

                final qrCode = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QRScanScreen(),
                  ),
                );

                if (qrCode != null && qrCode.isNotEmpty) {
                  qrController.text = qrCode;
                  invoiceDetailsApi(qrCode);
                }
              },
            ),
          ),
          ],
        ),
                  // ASN Details
            if (invoiceModel != null &&
        invoiceModel!.transactionDetails?.mast != null)
        Card(
    margin: const EdgeInsets.only(top: 10),
    child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

    /// ASN DETAILS
    Row(
    children: [
    Expanded(
    child: buildField(
    "ASN No.",
    invoiceModel!.transactionDetails!.mast!.documentNo ?? "",
    ),
    ),
    Expanded(
    child: buildField(
    "ASN Date",
    invoiceModel!.transactionDetails!.mast!.documentDate ?? "",
    ),
    ),
    ],
    ),

    const SizedBox(height: 15),

    buildField(
    "Supplier Name",
    invoiceModel!.transactionDetails!.mast!.supplier ?? "",
    ),

    const SizedBox(height: 15),

    Row(
    children: [
    Expanded(
    child: buildField(
    "Bill No.",
    invoiceModel!.transactionDetails!.mast!.billNo ?? "",
    ),
    ),
    Expanded(
    child: buildField(
    "Bill Date",
    invoiceModel!.transactionDetails!.mast!.billDate ?? "",
    ),
    ),
    ],
    ),

    const Divider(height: 30),

    const Text(
    "Items",
    style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),

    const SizedBox(height: 10),

    ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: invoiceModel!
        .transactionDetails!
        .transactions
        ?.length ??
    0,
    separatorBuilder: (_, __) =>
    const SizedBox(height: 8),
    itemBuilder: (context, index) {
    final item = invoiceModel!
        .transactionDetails!
        .transactions![index];

    return Card(
    elevation: 1,
    child: ListTile(
    leading: CircleAvatar(
    child: Text("${index + 1}"),
    ),
    title: Text(item.productDescription ?? ""),
    subtitle: Text(
    "${item.productCode} (${item.uom})"),
    trailing: Column(
    mainAxisAlignment:
    MainAxisAlignment.center,
    children: [
    const Text("Qty"),
    Text(
    item.quantity ?? "0",
    style: const TextStyle(
    fontWeight: FontWeight.bold,
    ),
    ),
    ],
    ),
    ),
    );
    },
    ),

    ],
    ),
    ),
    )
    else if (hasSearched)
     Padding(
    padding: EdgeInsets.all(30),
    child: Center(
    child: Text(
      apiMessage,
    style: TextStyle(
    fontSize: 18,
    color: Colors.red,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    ),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),

                  SizedBox(height: 90),
                ],
              ),

           /*   bottomNavigationBar: SafeArea(
                minimum: EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      savebarcodeCameraQRApi(
                        invoiceModel!.transactionDetails?.mast?.mid ?? '',
                        invoiceModel!.transactionDetails?.mast?.docId ?? '',
                        "",
                        invoiceModel!.transactionDetails?.mast?.tid ?? '',
                          invoiceModel!.transactionDetails?.mast?.gateEntry ?? ''
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeController.primaryColor, // Button background
                      foregroundColor: Colors.white, // Icon & Text color
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Save & Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                ),*/
              bottomNavigationBar: (invoiceModel != null &&
                  invoiceModel!.transactionDetails?.mast != null)
                  ? SafeArea(
                minimum: const EdgeInsets.all(16),
                child: SizedBox(
                  width: isDesktop ? 300 : double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      savebarcodeCameraQRApi(
                        invoiceModel!.transactionDetails?.mast?.mid ?? '',
                        invoiceModel!.transactionDetails?.mast?.docId ?? '',
                        "",
                        invoiceModel!.transactionDetails?.mast?.tid ?? '',
                        invoiceModel!.transactionDetails?.mast?.gateEntry ?? '',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeController.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Save & Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
                  : null,
              ),
            ));
  }
  void showSuccessDialog(String message,String title) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });

        return AlertDialog(
          backgroundColor: Colors.green,
          title:  Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [],
        );
      },
    );
  }
 /* savebarcodeCameraQRApi(String mId,String docId,String itemId,String tId,String gateentry) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var getUserId = prefs.getString("USERID");
    print("Get Yourrrrrrrrrrrrrrrrrrrr Asset Barcode UserId $getUserId");


    final response = await Provider.of<BarcodeProviderAns>(context, listen: false)
        .SaveSalesQrScanAns(
        mId,
       tId,
        docId,
        getUserId!,
      itemId,
        "",
      "",
       "",
      gateentry,
       "SaveASNQRScan",);
    print(response);
    if (response == true &&
        Provider.of<BarcodeProviderAns>(context, listen: false).barcodeMessage ==
            "QR/BarCode Successfully Added") {
      print(
          "======================================================================================");
      showSuccessDialog(" Successfully Send");

      // barcodeDataController.clear();
      // _focusNode.requestFocus();
    }
  }*/
  bool _isLoading = false;
  savebarcodeCameraQRApi(
      String mId,
      String docId,
      String itemId,
      String tId,
      String gateEntry,
      ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var getUserId = prefs.getString("USERID");

    final provider = Provider.of<BarcodeProviderAns>(
      context,
      listen: false,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await provider.SaveSalesQrScanAns(
        mId,
        tId,
        docId,
        getUserId!,
        itemId,
        "",
        "",
        "",
        gateEntry,
        "SaveASNQRScan",
      );

      if (!mounted) return;

      if (response == true) {
        showSuccessDialog(provider.barcodeMessage ?? '',provider.barcodeMessageTitle ?? '');

        setState(() {
          qrController.clear();
          invoiceModel = null;
          hasSearched = false;
          apiMessage = "";
        });
      } else {
        showInvalidBarcodeDialog(
          provider.barcodeMessage ?? "Something went wrong",
          Colors.red,
        );
      }
    } catch (e) {
      if (mounted) {
        showInvalidBarcodeDialog(
          e.toString(),
          Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  void showInvalidBarcodeDialog(String message, Color color) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });

        return AlertDialog(
          backgroundColor: color,
          title: const Text(
            '',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [],
        );
      },
    );
  }
  Widget buildField(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}