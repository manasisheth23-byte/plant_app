import 'dart:developer';
import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/screens/BarcodeQrcodeScanner/showcustomsnackbar.dart';
import 'package:erpflutter/screens/BarcodeQrcodeScanner/spinkitcircle.dart';
import 'package:erpflutter/screens/BarcodeQrcodeScanner/vibration.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../barcodescanner/models/physical_barcode_itemdata.dart';
import '../../barcodescanner/view_models/barcoderegistration_viewmodel.dart';
import '../../models/barcode_provider.dart';

class PhysicalBarcodeQRView extends StatefulWidget {
  final TransactionDetail barcodeTableData;
  final String strOpnId;
  final VoidCallback? onBarcodeScanned;

  const PhysicalBarcodeQRView({
    super.key,
    required this.barcodeTableData,
    required this.strOpnId,
    this.onBarcodeScanned,
  });

  @override
  State<PhysicalBarcodeQRView> createState() => _PhysicalBarcodeQRViewState();
}

class _PhysicalBarcodeQRViewState extends State<PhysicalBarcodeQRView> {
  MobileScannerController? controller;
  bool dataScanned = false;
  bool isVibrating = false;
  TextEditingController qrTextController = TextEditingController();

  /// 🔑 Key to force rebuild scanner
  Key _scannerKey = UniqueKey();

  @override
  void dispose() {
    controller?.dispose();
    qrTextController.dispose();
    super.dispose();
  }

  /// Request camera permission
  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isGranted) return true;

    if (status.isDenied || status.isRestricted) {
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    if (!status.isGranted) {
      showCustomSnackBar(
        context: context,
        message: 'Camera permission is required to scan QR/barcode.',
        backgroundColor: Colors.red,
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.APPCOLOR,
        title:  Text(
          'Scan QR / Barcode',
          style: GoogleFonts.lato(

            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<bool>(
        future: _requestCameraPermission(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data == true) {
            // Permission granted
            controller ??= MobileScannerController(
              facing: CameraFacing.back,
              torchEnabled: false,
            );
            return dataScanned ? _loadingWidget() : _buildScanner();
          } else {
            // Permission denied
            return const Center(
              child: Text(
                'Camera permission denied.\nPlease allow camera access in settings.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildScanner() {
    return Consumer<BarcodeProvider>(
      builder: (context, provider, _) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            MobileScanner(
              key: _scannerKey,
              controller: controller!,
              onDetect: (capture) async {
                if (dataScanned) return;
                if (capture.barcodes.isEmpty) return;

                final code = capture.barcodes.first.rawValue;
                if (code == null || code.isEmpty) return;

                setState(() => dataScanned = true);
                _vibrate();

                final ScanResult result =
                await provider.syncPhysicalBarcodeList(
                  context,
                  '4',
                  widget.barcodeTableData,
                  code,
                  widget.strOpnId,
                );

                _showResultDialog(result);
              },
            ),
            Positioned(
              bottom: 90,
              child: ElevatedButton(
                onPressed: () async {
                  await controller!.toggleTorch();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
                child: Icon(
                  controller!.value.torchState == TorchState.on
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
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.APPCOLOR),
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
                          setState(() {
                            dataScanned = true;
                          });
                          final ScanResult result =
                          await provider.syncPhysicalBarcodeList(
                            context,
                            '4',
                            widget.barcodeTableData,
                            qrTextController.text.trim(),
                            widget.strOpnId,
                          );

                          _showResultDialog(result);
                        }
                      },
                      icon: const Icon(Icons.send, color: AppColors.APPCOLOR),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _loadingWidget() {
    return const Center(
      child: SpinKitCircle(color: Colors.blue, size: 40),
    );
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
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            result.message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [],
        );
      },
    ).then((_) {
      if (!mounted) return;

      setState(() {
        qrTextController.text = "";
        dataScanned = false;
        _scannerKey = UniqueKey(); // rebuild scanner
      });

      widget.onBarcodeScanned?.call();
    });
  }

  void _vibrate() async {
    if (await Vibration.hasVibrator() == true && !isVibrating) {
      isVibrating = true;
      Vibration.vibrate(duration: 200);
      await Future.delayed(const Duration(milliseconds: 200));
      isVibrating = false;
    }
  }
}
