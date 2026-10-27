import 'dart:developer';
import 'dart:io';

import 'package:erpflutter/plantappscreen/app_shell.dart';
import 'package:erpflutter/plantappscreen/theme.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/screens/BarcodeQrcodeScanner/spinkitcircle.dart';
import 'package:erpflutter/screens/BarcodeQrcodeScanner/vibration.dart';
import '../../barcodescanner/view_models/barcoderegistration_viewmodel.dart';
import '../../provider/themecontroller.dart';

class BarcodeQRViewExample extends StatefulWidget {
  const BarcodeQRViewExample({Key? key}) : super(key: key);

  @override
  State<BarcodeQRViewExample> createState() => _BarcodeQRViewExampleState();
}

class _BarcodeQRViewExampleState extends State<BarcodeQRViewExample>
    with WidgetsBindingObserver {
  late ThemeController themeController;

  late MobileScannerController _controller;
  bool _dataScanned = false;
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  // 🔄 Handle app lifecycle (background / resume)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;

    if (state == AppLifecycleState.resumed) {
      _controller.start();
    } else if (state == AppLifecycleState.paused) {
      _controller.stop();
    }
  }
  int _idx = 1;
  @override
  Widget build(BuildContext context) {
    themeController = Provider.of<ThemeController>(context, listen: false);
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    return PopScope(
      canPop: true,
      onPopInvoked: (_) async {
        if (_isPopping) return;
        _isPopping = true;
        await _controller.stop();
      },
      child: Center(
        child: SizedBox(
          width: isDesktop ? 700 : double.infinity,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: themeController.primaryColor,
              foregroundColor: Colors.white,
              title:  Text('Scan QR / Barcode',style:  GoogleFonts.lato(

                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              )),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  if (_isPopping) return;
                  _isPopping = true;
                  await _controller.stop();
                  if (mounted) Navigator.pop(context);
                },
              ),
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
             /*     Navigator.pushReplacement(
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
            body: _dataScanned ? _loadingView(context) : _scannerView(context),
          ),
        ),
      ),
    );
  }

  // 🔍 Scanner View
  Widget _scannerView(BuildContext context) {
    return Consumer<BarcodeProvider>(
      builder: (context, provider, _) {

        if (Platform.isWindows) {
          return const Center(
            child: Text(
              'Camera scanning works on Windows\nEnsure webcam permission is granted.',
              textAlign: TextAlign.center,
            ),
          );
        }

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [

            MobileScanner(
              controller: _controller,
              fit: BoxFit.cover,
              onDetect: _onDetect,
              errorBuilder: (context, error) {
                return Center(
                  child: Text(
                    'Camera Error: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              },
            ),

            // 🔦 Flash Toggle
            Positioned(
              bottom: 90,
              child: ElevatedButton(
                onPressed: () async {
                  await _controller.toggleTorch();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.black54,
                ),
                child: Icon(
                  _controller.value.torchState == TorchState.on
                      ? Icons.flash_off
                      : Icons.flash_on,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 📸 Barcode Detection
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_dataScanned || _isPopping) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    log('📦 Scanned Code: $code');

    setState(() {
      _dataScanned = true;
      _isPopping = true;
    });

    _vibrate();

    // 🛑 Stop camera before navigation
    await _controller.stop();

    // 🧠 Delay pop safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pop(context, code);
      }
    });
  }

  // ⏳ Loading View
  Widget _loadingView(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        height: h * 0.08,
        width: w * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              spreadRadius: 1,
            )
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitCircle(color: Colors.blue, size: 35),
            SizedBox(width: 10),
            Text('Loading...', style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  // 📳 Vibration
  bool _isVibrating = false;

  Future<void> _vibrate() async {
    if (_isVibrating) return;
    if (await Vibration.hasVibrator() != true) return;

    _isVibrating = true;
    Vibration.vibrate(duration: 200);
    await Future.delayed(const Duration(milliseconds: 200));
    _isVibrating = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }
}
