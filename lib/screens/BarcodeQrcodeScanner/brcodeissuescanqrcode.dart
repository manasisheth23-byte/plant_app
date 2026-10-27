import 'dart:developer';
import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/barcodescanner/models/transactiondetailsresponse_model.dart';
import 'package:erpflutter/barcodescanner/view_models/barcoderegistration_viewmodel.dart';
import 'package:erpflutter/screens/BarcodeQrcodeScanner/showcustomsnackbar.dart';
import 'package:erpflutter/screens/BarcodeQrcodeScanner/spinkitcircle.dart';
import 'package:erpflutter/screens/BarcodeQrcodeScanner/vibration.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../barcodescanner/views/barcoderegistration_view.dart';
import '../../models/barcode_provider.dart';
import '../../provider/themecontroller.dart';

class BarcodeIssueQRViewExample extends StatefulWidget {
  final Transactionl lot;
  final String? documentNo;

  const BarcodeIssueQRViewExample({
    super.key,
    required this.lot,
    required this.documentNo,
  });

  @override
  State<StatefulWidget> createState() => _BarcodeQRViewExampleState();
}

class _BarcodeQRViewExampleState extends State<BarcodeIssueQRViewExample>
    with WidgetsBindingObserver {
  TextEditingController qrTextController = TextEditingController();
  late ThemeController themeController;

  late MobileScannerController controller;
  bool scanningLocked = false; // prevents Android 15 crash
  late BuildContext safeContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    safeContext = context;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: [BarcodeFormat.qrCode, BarcodeFormat.code128, BarcodeFormat.code39],
      detectionSpeed: DetectionSpeed.noDuplicates,  // 🔥 Android 15 required
      returnImage: false,
    );
  }

  // Prevent crash when app resumes on Android 15
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!mounted) return;

    if (state == AppLifecycleState.resumed) {
      try {
        await controller.start();
      } catch (e) {
        log("Lifecycle start error: $e");
      }
    } else if (state == AppLifecycleState.paused) {
      try {
        await controller.stop();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final setHeight = MediaQuery.of(context).size.height;
    final setWidth = MediaQuery.of(context).size.width;
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    themeController = Provider.of<ThemeController>(context, listen: false);

    return  Scaffold(
        appBar:  PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Center(
                child: SizedBox(
                    width: isDesktop ? 700 : double.infinity,
                    child:AppBar(
          backgroundColor: themeController.primaryColor,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          title:  Text("Scan QR/Barcode",style:  GoogleFonts.lato(

            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            /*  Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => BarcodeRegistrationView()),
              );*/
            },
          ),
        )))),

        body: scanningLocked
            ? _loadingWidget(setHeight, setWidth)
            : _scannerView(),
      );

  }

  Widget _scannerView() {
    themeController = Provider.of<ThemeController>(context, listen: false);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        MobileScanner(
          controller: controller,
          fit: BoxFit.cover,

          // -------------------------
          // SAFE DETECTION HANDLER
          // -------------------------
          onDetect: (capture) async {
            if (scanningLocked) return;

            final value = capture.barcodes.first.rawValue;
            if (value == null || value.isEmpty) return;

            setState(() => scanningLocked = true);

            _vibrate();

            // Stop camera safely (Android 15 fix)
            try {
              await controller.stop();
            } catch (e) {
              log("Camera stop error: $e");
            }

            log("Scanned: $value");

            final provider =
            Provider.of<BarcodeProvider>(safeContext, listen: false);

            try {
              final result =  await provider.syncBarcodeIssueList(
                safeContext,
                [],
                "3",
                widget.lot,
                value,
                widget.documentNo,
              );
              setState(() => scanningLocked = false);

              _showResultDialog(result);

            } catch (e) {
              log("Provider error: $e");
              if (mounted) Navigator.pop(context);
            }
          },
        ),

        Positioned(
          bottom: 90,
          child: ElevatedButton(
            onPressed: () async {
              await controller.toggleTorch();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
            ),
            child: Icon(
              controller.value.torchState == TorchState.on
                  ? Icons.flash_off
                  : Icons.flash_on,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 10, left: 8, right: 8,top: 10),
            width: MediaQuery.of(context).size.width,
            child: TextField(
              controller: qrTextController,
              decoration: InputDecoration(
                hintText: 'Enter QR / Barcode',
                focusedBorder:  UnderlineInputBorder(
                  borderSide: BorderSide(color: themeController.primaryColor),
                ),
                suffixIcon: IconButton(
                  onPressed: () async {
                    if (qrTextController.text.trim().isEmpty) {
                      showCustomSnackBar(
                        context: context,
                        message: 'Please enter QR/Barcode',
                        backgroundColor: Colors.red,
                      );
                    } else {
                      final provider =
                      Provider.of<BarcodeProvider>(safeContext, listen: false);

                      try {
                        final result =  await provider.syncBarcodeIssueList(
                          safeContext,
                          [],
                          "3",
                          widget.lot,
                          qrTextController.text.trim(),
                          widget.documentNo,
                        );
                        setState(() => scanningLocked = false);

                        _showResultDialog(result);

                      } catch (e) {
                        log("Provider error: $e");
                        if (mounted) Navigator.pop(context);
                      }
                    }
                  },
                  icon:  Icon(Icons.send, color: themeController.primaryColor),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingWidget(double h, double w) {
    return Center(
      child: Container(
        height: h * 0.08,
        width: w * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 3, spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitCircle(color: Colors.blue, size: 35),
            SizedBox(width: w * 0.03),
            const Text('Loading...', style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  bool isVibrating = false;
  void _vibrate() async {
    if (await Vibration.hasVibrator() == true && !isVibrating) {
      isVibrating = true;
      Vibration.vibrate(duration: 200);
      await Future.delayed(const Duration(milliseconds: 200));
      isVibrating = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      controller.dispose();
    } catch (_) {}
    super.dispose();
  }

  void _showResultDialog(ScanResult result) {
    final bool isSuccess = result.isSuccess;
    final Color dialogColor = isSuccess ? Colors.green : Colors.red;
    final Color borderColor = isSuccess ? Colors.green : Colors.red;
    final String titleText = isSuccess ? 'Success' : 'Invalid';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.of(context).pop();
        });

        return AlertDialog(
          backgroundColor: dialogColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: borderColor, width: 2),
          ),
          title: Text(
            titleText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            result.message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight:FontWeight.w700,
            ),
          ),
          actions: [],
        );
      },
    ).then((_) {
      if (!mounted) return;

    setState(() {
      scanningLocked = false;
      qrTextController.text = "";
    });
    });
  }

}
