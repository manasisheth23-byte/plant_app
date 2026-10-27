import 'dart:async';
import 'dart:io';

import 'package:erpflutter/provider/themecontroller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:vibration/vibration.dart';
import 'dart:async';
import 'dart:io';

import 'package:erpflutter/provider/themecontroller.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({Key? key}) : super(key: key);

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  late final MobileScannerController controller;

  Barcode? result;

  bool isScanned = false;

  @override
  void initState() {
    super.initState();

    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void reassemble() {
    super.reassemble();

    if (Platform.isAndroid) {
      controller.stop();
    }

    controller.start();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200);
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (isScanned) return;

    final barcode = capture.barcodes.first;

    if (barcode.rawValue == null) return;

    isScanned = true;
    result = barcode;

    await controller.stop();

    await _vibrate();

    if (!mounted) return;

    Navigator.pop(context, barcode.rawValue);
  }

  late ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    final scanArea =
    MediaQuery.of(context).size.width < 400 ? 220.0 : 300.0;

    themeController =
        Provider.of<ThemeController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: themeController.primaryColor,
        title: const Text(
          "Scan QR Code",
          style: TextStyle(
            fontSize: 16.5,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
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
                      color: Colors.blue,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        /*  Positioned(
            bottom: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(18),
              ),
              onPressed: () async {
                await controller.toggleTorch();
                setState(() {});
              },
              child: ValueListenableBuilder<TorchState>(
                valueListenable: controller.torchState,
                builder: (context, state, child) {
                  return Icon(
                    state == TorchState.on
                        ? Icons.flash_off
                        : Icons.flash_on,
                  );
                },
              ),
            ),
          ),*/
          Positioned(
            bottom: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(18),
              ),
              onPressed: () async {
                await controller.toggleTorch();
                setState(() {});
              },
              child: Icon(
                controller.value.torchState == TorchState.on
                    ? Icons.flash_off
                    : Icons.flash_on,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/*
class QRScanScreen extends StatefulWidget {
  const QRScanScreen({Key? key}) : super(key: key);

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? controller;
  Barcode? result;

  bool isScanned = false;

  @override
  void reassemble() {
    super.reassemble();

    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }

    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200);
    }
  }

  void _onQRViewCreated(QRViewController qrController) {
    controller = qrController;

    controller!.scannedDataStream.listen((scanData) async {
      if (isScanned) return;

      isScanned = true;

      result = scanData;

      await controller?.pauseCamera();

      await _vibrate();

      if (!mounted) return;

      Navigator.pop(context, scanData.code);
    });
  }
  late ThemeController themeController;
  @override
  Widget build(BuildContext context) {
    final scanArea = MediaQuery.of(context).size.width < 400 ? 220.0 : 300.0;
    themeController = Provider.of<ThemeController>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor:  themeController.primaryColor,
        title: const Text("Scan QR Code", style: const TextStyle(
          fontSize: 16.5,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),),
        centerTitle: false,
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.blue,
              borderRadius: 12,
              borderLength: 30,
              borderWidth: 8,
              cutOutSize: scanArea,
            ),
          ),

          Positioned(
            bottom: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(18),
              ),
              onPressed: () async {
                await controller?.toggleFlash();
                setState(() {});
              },
              child: FutureBuilder(
                future: controller?.getFlashStatus(),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return const Icon(Icons.flash_off);
                  }
                  return const Icon(Icons.flash_on);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/
