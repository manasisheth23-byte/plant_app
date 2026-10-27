
/*
import 'dart:async';
import 'dart:developer';
import 'dart:io';



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:vibration/vibration.dart';

import '../../provider/themecontroller.dart';
import '../../screens/UnreadNotificationProvider.dart';
import '../view_models/barcoderegistration_viewmodel.dart';

class QRASNViewExample extends StatefulWidget {




  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRASNViewExample> {
  String? scannedQty;
  Barcode? result;
  QRViewController? controller;
  TextEditingController barcodeDataController = TextEditingController();
  static const platform = MethodChannel('com.example/barcode_scanner');
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool dataScanned = false; // Track whether data has been scanned
  Timer? _debounceTimer;
  bool toshowDialog = false;
  String? apiEndpoint;
  late ThemeController themeController;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  bool _isManualMode = false;
  final TextEditingController _manualQrController = TextEditingController();

  @override
  void initState() {





    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    super.initState();


  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
      // DeviceOrientation.landscapeLeft,
      // DeviceOrientation.landscapeRight,
    ]);
    controller?.dispose();
    _debounceTimer?.cancel(); // Cancel the timer when the widget is disposed

    super.dispose();
  }

  final FocusNode _focusNode = FocusNode();

  void showInvalidBarcodeDialog(String message, Color color) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        Future.delayed(Duration(milliseconds: 800), () {
          Navigator.pop(context);
        });

        return AlertDialog(
          backgroundColor: color,
          title: const Text(
            'Invalid',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
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

  void showSuccessDialog(String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(milliseconds: 800), () {
          Navigator.pop(context);
        });

        return AlertDialog(
          backgroundColor: Colors.green,
          title: const Text(
            'Success',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
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






  @override
  Widget build(BuildContext context) {

    final setWidth = MediaQuery.of(context).size.width;
    final setHeight = MediaQuery.of(context).size.height;

    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);

    return  Center(
        child: SizedBox(
        width: isDesktop ? 700 : double.infinity,
        child:Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor:  themeController.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0, // Remove elevation
            title: Text(
             "7886868",
              style: GoogleFonts.lato(

                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            titleSpacing: -10,

          ),
      body: Consumer<BarcodeProvider>(builder: (context, provider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Scanned Quantity Table
            Table(
              border: TableBorder.all(
                color: Color.fromARGB(160, 78, 78, 78),
              ),
              columnWidths: {

              },
              children: [
                TableRow(
                  children: [
                    const headTableCell(title: "Quantity"),
                     const headTableCell(title: "Balance"),

                    const headTableCell(title: "Scanned"),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Container(
                        height: 61,
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "6",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                     TableCell(
                      child: Container(
                        height: 61,
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "7",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Container(
                        height: 61,
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: provider.isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color.fromARGB(255, 224, 222, 222),
                            ),
                          )
                              : const Text(
                            "55",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: setHeight * 0.015,
            ),
            // Scan QR code text
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                "Scan QR Code",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            // QR code scanner

            Expanded(child: _buildQrView(context)),

            // Barcode input and send button
            Center(
              child: Container(
                height: 60,
                width: setWidth * 0.96,
                color: const Color.fromARGB(255, 255, 255, 255),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: barcodeDataController,
                          decoration: const InputDecoration(
                            hintText: 'Enter QR Code',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {

                            // print(
                            //     'scanned qty is : ---------${provider.scannedQty}');
                          });
                          // Update the scannedQty in the provider
                          // setState(() {});
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Color(0xFF00D09F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
        )));
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (_debounceTimer?.isActive ?? false) {
        return;
      }
      setState(() {
        result = scanData;

        dataScanned = true; // Set the flag when data is scanned
      });


      // Vibrate the phone

      _vibrate();

      // Access the scanned data here, for example:
      if (result != null) {
        // savebarcodeCameraQRApi(result!.code!);
        print("Scanned Data: ${result!.code}");

        controller.pauseCamera();
        // });
        Future.delayed(Duration(seconds: 2), () {
          controller.resumeCamera();
        });
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  bool isVibrating = false;

  void _vibrate() async {
    if (await Vibration.hasVibrator() == true && !isVibrating) {
      isVibrating = true;
      Vibration.vibrate(duration: 200);
      // Delay for a short period before allowing another vibration
      await Future.delayed(const Duration(milliseconds: 100));
      isVibrating = false;
    }
  }

  void _copyToClipboard(String data) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data copied to clipboard'),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 220.0
        : 300.0;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
              borderColor: const Color.fromARGB(255, 209, 15, 1),
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: scanArea),
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.08,
          child: ElevatedButton(
            onPressed: () async {
              if (controller != null) {
                await controller!.toggleFlash();
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
            ),
            child: FutureBuilder(
              future: controller?.getFlashStatus(),
              builder: (context, snapshot) {
                return (snapshot.data == false)
                    ? const Icon(Icons.flash_on)
                    : const Icon(Icons.flash_off);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class headTableCell extends StatelessWidget {
  const headTableCell({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Container(
        height: 61,
        color: Color(0xFF00D09F),
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}*/
// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:io';


// import 'package:cssflutter/Screens/complaint_submit_screen.dart';
import 'package:erpflutter/barcodescanner/views/asn_scanning_details.dart';
import 'package:erpflutter/provider/themecontroller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../../provider/barcode_provider.dart';

class QRViewExampleans extends StatefulWidget {
  final String mId;
  final String dId;
  final String itemId;
  final String tId;
  final String planQty;
  final int index;
  // final String avlQty;
  final String scanqty;
  final String balanceQty;
  final String itemCode;
  final String flag;
  final String orgID;
  final String slid;
  final String projId;
  final String doctype;
  final String docno;
  final String docdate;
  final String title;

  QRViewExampleans({
    Key? key,
    required this.mId,
    required this.dId,
    required this.itemId,
    required this.tId,
    required this.planQty,
    required this.index,
    // required this.avlQty,
    required this.scanqty,
    required this.balanceQty,
    required this.itemCode,
    required this.flag,
    required this.orgID,
    required this.slid,
    required this.projId,
    required this.doctype,
    required this.docno,
    required this.docdate,
    required this.title,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExampleans> {
  String? scannedQty;
  Barcode? result;
  //QRViewController? controller;
  late final MobileScannerController controller =
  MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  TextEditingController barcodeDataController = TextEditingController();
  static const platform = MethodChannel('com.example/barcode_scanner');
 // final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool dataScanned = false; // Track whether data has been scanned
  Timer? _debounceTimer;
  bool toshowDialog = false;
  String? apiEndpoint;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.stop();
    }

    controller.start();
  }

  bool _isManualMode = false;
  final TextEditingController _manualQrController = TextEditingController();

  @override
  void initState() {
    print(widget.mId);
    print(widget.dId);
    print(widget.itemId);
    print(widget.tId);
    print(widget.planQty);
    // print(widget.avlQty);
    print(widget.itemId);

    identifyflag();
    // _buildQrView(context);

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    invoiceDetailsApi();
    super.initState();

    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // _focusNode.requestFocus();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
      // DeviceOrientation.landscapeLeft,
      // DeviceOrientation.landscapeRight,
    ]);
    controller?.dispose();
    _debounceTimer?.cancel(); // Cancel the timer when the widget is disposed

    super.dispose();
  }

  final FocusNode _focusNode = FocusNode();

  void showInvalidBarcodeDialog(String message, Color color) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        Future.delayed(Duration(milliseconds: 800), () {
          Navigator.pop(context,true);
        });

        return AlertDialog(
          backgroundColor: color,
          title: const Text(
            'Invalid',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
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

  void showSuccessDialog(String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(milliseconds: 800), () {
          Navigator.pop(context,true);
        });

        return AlertDialog(
          backgroundColor: Colors.green,
          title: const Text(
            'Success',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
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

  invoiceDetailsApi() async {
    final response = await Provider.of<BarcodeProviderAns>(context, listen: false)
        .InvoiceDetailsProvider(widget.mId, widget.dId, widget.flag,
        widget.slid, widget.orgID, /*  widget.tId, */ widget.projId);

    print(response);
  }

  identifyflag() async {
    if (widget.flag == "8") {
      apiEndpoint = "SaveSalesInvoiceQRScan";
    }
    if (widget.flag == "9") {
      apiEndpoint = "SaveGRNQRCode";
    }
    if (widget.flag == "14") {
      apiEndpoint = "SaveASNQRScan";
    }
    if (widget.flag == "10") {
      apiEndpoint = "SaveReturnQRScan";
    }
    if (widget.flag == "11") {
      apiEndpoint = "SaveSalesQRScan";
    }
  }

  savebarcodeCameraQRApi(String text) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var getUserId = prefs.getString("USERID");
    print("Get Yourrrrrrrrrrrrrrrrrrrr Asset Barcode UserId $getUserId");

    print(widget.mId);
    print(widget.dId);
    print(widget.itemId);
    print(widget.tId);
    print(widget.planQty);
    print(widget.balanceQty);
    print(widget.itemId);
    final response = await Provider.of<BarcodeProviderAns>(context, listen: false)
        .SaveSalesQrScan(
        widget.mId,
        widget.tId,
        widget.dId,
        getUserId!,
        widget.itemId,
        text,
        widget.planQty,
        widget.balanceQty,
        apiEndpoint.toString());
    print(response);
    if (response == true &&
        Provider.of<BarcodeProviderAns>(context, listen: false).barcodeMessage ==
            "QR/BarCode Successfully Added") {
      print(
          "======================================================================================");

      await invoiceDetailsApi();

      final provider =
      Provider.of<BarcodeProviderAns>(context, listen: false);

      final scanned = int.tryParse(
          provider.scannedquantity!
              .tRANSACTIONDETAILS!
              .tRANSACTIONS![widget.index]
              .scanned ??
              "0") ??
          0;

      final qty = int.tryParse(widget.planQty) ?? 0;

      if (scanned == qty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ASNScanningDetailScreen(
              mid: widget.mId ?? "",
              docId: widget.dId ?? "",
              docNo: widget.docno ?? "",
              docDate: widget.docdate ?? "",
            ),
          ),
        );

      }
      showSuccessDialog("QR/BarCode Successfully Added");

      // barcodeDataController.clear();
      // _focusNode.requestFocus();
    } else if (Provider.of<BarcodeProviderAns>(context, listen: false)
        .barcodeMessage ==
        "QR/BarCode Is Already Scanned") {
      print(response);

      showInvalidBarcodeDialog("QR/BarCode Is Already Scanned", Colors.blue);
    } else if (Provider.of<BarcodeProviderAns>(context, listen: false)
        .barcodeMessage ==
        "InValid QR/BarCode") {
      print(response);

      showInvalidBarcodeDialog("InValid QR/BarCode", Colors.red);
    } else if (Provider.of<BarcodeProviderAns>(context, listen: false)
        .barcodeMessage ==
        "QR/BAR Code Scanning Completed !") {
      print(response);

      showInvalidBarcodeDialog("QR/BAR Code Scanning Completed !", Colors.red);
    } else {
      showInvalidBarcodeDialog("InValid QR/BarCode", Colors.red);
      barcodeDataController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    print(" TID is ::::::::::::::::::::::::");
    print(" TID is ::::::::::::::::::::::::");
    print(" TID is ::::::::::::::::::::::::");
    print(widget.tId);
    print(" TID is ::::::::::::::::::::::::");
    print(" TID is ::::::::::::::::::::::::");

    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final setWidth = MediaQuery.of(context).size.width;
    final setHeight = MediaQuery.of(context).size.height;
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    late ThemeController themeController;
    print("Api End Point********************************** $apiEndpoint");
    themeController = Provider.of<ThemeController>(context, listen: false);
    return WillPopScope(
        onWillPop: () async {
          await invoiceDetailsApi();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ASNScanningDetailScreen(
                mid: widget.mId ?? "",
                docId: widget.dId ?? "",
                docNo: widget.docno ?? "",
                docDate: widget.docdate ?? "",
              ),
            ),
          );
          //setState(() {});
          return true;
        },
        child: Center(
          child: SizedBox(
            width: isDesktop ? 700 : double.infinity,
            child: Scaffold(
              backgroundColor: Colors.white,

              appBar: AppBar(
                foregroundColor: Colors.white,

                iconTheme: const IconThemeData(color: Colors.white),
                backgroundColor:  themeController.primaryColor,// Set the background color to transparent
                elevation: 0, // Remove elevation
                title: Text(
                  widget.itemCode,
                  style: GoogleFonts.lato(

                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                titleSpacing: -10,
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    // borderRadius: BorderRadius.only(
                    //     bottomLeft: Radius.circular(15),
                    //     bottomRight: Radius.circular(15)),
                 /*   gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(204, 70, 73, 231), // Start color
                        Color.fromARGB(214, 155, 39, 176), // End color
                      ],
                    ),*/
                  ),
                ),
              ),
              body: Consumer<BarcodeProviderAns>(builder: (context, provider, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Scanned Quantity Table
                    Table(
                      border: TableBorder.all(
                        color: Color.fromARGB(160, 78, 78, 78),
                      ),
                      columnWidths: {
                        1: (widget.flag == "11")
                            ? FixedColumnWidth(
                          setWidth * 0.32,
                        )
                            : const IntrinsicColumnWidth(),
                        // 2: FixedColumnWidth(
                        //         setWidth * 0.08,
                        //       ),
                      },
                      children: [
                        TableRow(
                          children: [
                            const headTableCell(title: "Quantity"),
                            (widget.flag == "11")
                                ? const headTableCell(title: "Balance")
                                : Container(),
                            const headTableCell(title: "Scanned"),
                          ],
                        ),
                        TableRow(
                          children: [
                            TableCell(
                              child: Container(
                                height: 61,
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    widget.planQty,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            (widget.flag == "11")
                                ? TableCell(
                              child: Container(
                                height: 61,
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    widget.balanceQty,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            )
                                : const SizedBox(),
                            TableCell(
                              child: Container(
                                height: 61,
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: (provider.isLoading == true)
                                      ? const SpinKitThreeBounce(
                                    size: 15,
                                    color: Color.fromARGB(255, 224, 222, 222),
                                  )
                                      : Text(
                                    provider
                                        .scannedquantity!
                                        .tRANSACTIONDETAILS!
                                        .tRANSACTIONS![widget.index]
                                        .scanned
                                        .toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: setHeight * 0.015,
                    ),
                    // Scan QR code text
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Scan QR Code",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    // QR code scanner
                    if(Platform.isAndroid)
                    Expanded(child: _buildQrView(context)),

                    // Barcode input and send button
                    Center(
                      child: Container(
                        height: 60,
                        width: setWidth * 0.96,
                        padding: const EdgeInsets.only(
                          left: 20.0,
                          top: 0,
                          right: 10,
                          bottom: 0,
                        ),
                        color: const Color.fromARGB(255, 255, 255, 255),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: barcodeDataController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter QR Code',
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    savebarcodeCameraQRApi(
                                        barcodeDataController.text);
                                    invoiceDetailsApi();
                                    // print(
                                    //     'scanned qty is : ---------${provider.scannedQty}');
                                  });
                                  // Update the scannedQty in the provider
                                  // setState(() {});
                                },
                                icon: const Icon(
                                  Icons.send,
                                  color: Color(0xFF00D09F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ));
  }
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_debounceTimer?.isActive ?? false) {
      return;
    }

    final barcode = capture.barcodes.first;

    if (barcode.rawValue == null) {
      return;
    }

    setState(() {
      result = barcode;
      dataScanned = true;
    });

    savebarcodeCameraQRApi(barcode.rawValue!);
    invoiceDetailsApi();

    _vibrate();

    print("Scanned Data: ${barcode.rawValue}");

    await controller.stop();

    Future.delayed(const Duration(seconds: 2), () async {
      await controller.start();
    });
  }
 /* void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (_debounceTimer?.isActive ?? false) {
        return;
      }
      setState(() {
        result = scanData;

        dataScanned = true; // Set the flag when data is scanned
      });
      savebarcodeCameraQRApi(result!.code!);
      invoiceDetailsApi();

      // Vibrate the phone

      _vibrate();

      // Access the scanned data here, for example:
      if (result != null) {
        // savebarcodeCameraQRApi(result!.code!);
        print("Scanned Data: ${result!.code}");

        controller.pauseCamera();
        // });
        Future.delayed(Duration(seconds: 2), () {
          controller.resumeCamera();
        });
      }
    });
  }*/

  bool isVibrating = false;

  void _vibrate() async {
    if (await Vibration.hasVibrator() == true && !isVibrating) {
      isVibrating = true;
      Vibration.vibrate(duration: 200);
      // Delay for a short period before allowing another vibration
      await Future.delayed(const Duration(milliseconds: 100));
      isVibrating = false;
    }
  }

  void _copyToClipboard(String data) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data copied to clipboard'),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 220.0
        : 300.0;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        MobileScanner(
          controller: controller,
          onDetect: _onDetect,
          scanWindow: Rect.fromCenter(
            center: Offset(
              MediaQuery.of(context).size.width / 2,
              MediaQuery.of(context).size.height / 2,
            ),
            width: scanArea,
            height: scanArea,
          ),
          overlayBuilder: (context, constraints) {
            return Center(
              child: Container(
                width: scanArea,
                height: scanArea,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 209, 15, 1),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.08,
          child: ElevatedButton(
            onPressed: () async {
              if (controller != null) {
                await controller.toggleTorch();
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
            ),
            child: const Icon(Icons.flash_on),
          ),
        ),
      ],
    );
  }
}

class headTableCell extends StatelessWidget {
  const headTableCell({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: Container(
        height: 61,
        color: Color(0xFF00D09F),
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}



