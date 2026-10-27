

import 'dart:developer';
import 'package:erpflutter/app_colors.dart';

import 'package:erpflutter/screens/BarcodeQrcodeScanner/showcustomsnackbar.dart';
import 'package:erpflutter/screens/BarcodeQrcodeScanner/spinkitcircle.dart';
import 'package:erpflutter/screens/BarcodeQrcodeScanner/vibration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';








class KioskModeQRViewExample extends StatefulWidget {



  @override
  State<StatefulWidget> createState() => _KioskModeQRViewExampleState();
}

class _KioskModeQRViewExampleState extends State<KioskModeQRViewExample> {
  Barcode? result;
  String? strUserName;

  late final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool dataScanned = false; // Track whether data has been scanned;

  TextEditingController qrTextController = TextEditingController();
  getUaserdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs != null) {
      setState(() {
        strUserName = prefs.getString('USERNAME') ?? null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final setHeight = MediaQuery.of(context).size.height;
    final setWidth = MediaQuery.of(context).size.width;
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Center(
              child: SizedBox(
                  width: isDesktop ? 700 : double.infinity,
                  child:AppBar(

        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.APPCOLOR,

    /*    leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => DashboardUI(
                        loginResponseModel: widget.loginResponseModel,
                        userName: strUserName)));
          },
        ),*/
        title: const Text(
          'Scan QR/Barcode'),
      )))),
      body: dataScanned ? Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                height: setHeight * 0.08,
                width: setWidth * 0.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     SpinKitCircle(
                      color: AppColors.APPCOLOR,
                      size: 35,
                    ),
                    SizedBox(
                      width: setWidth * 0.025,
                    ),
                    const Text(
                      'Loading...',
                      style: TextStyle(color: AppColors.APPCOLOR),
                    )
                  ],
                ),
              ),
            )
          : _buildQrView(context),
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
                    color: Colors.red,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 90,
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
        Positioned(
          top: 0,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
            width: MediaQuery.of(context).size.width,
            child: TextField(
              controller: qrTextController,
              decoration: InputDecoration(
                hintText: 'QR/Barcode',
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.APPCOLOR)),
                suffixIcon: IconButton(
                  onPressed: () async{

                    if(qrTextController.text.toString().trim().isEmpty){
                      showCustomSnackBar(context: context, message: 'Please enter QR/Barcode', backgroundColor: Colors.red);

                    } else{
                      setState(() {
                        dataScanned = true;
                      });
                    }
                  },
                  icon: Icon(Icons.send, color: AppColors.APPCOLOR),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (dataScanned) return;

    final barcode = capture.barcodes.first;

    if (barcode.rawValue == null) return;

    setState(() {
      result = barcode;
      dataScanned = true;
    });

    await controller.stop();

    print('@@@@@@@@@@@ ');
    print(result!.rawValue!);

    _vibrate();
  }


  bool isVibrating = false;

  void _vibrate() async {
    if (await Vibration.hasVibrator() == true && !isVibrating) {
      isVibrating = true;
      Vibration.vibrate(duration: 200);
      // Delay for a short period before allowing another vibration
      await Future.delayed(const Duration(milliseconds: 200));
      isVibrating = false;
    }
  }



  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
