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
import 'package:shared_preferences/shared_preferences.dart';

import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/screens/BarcodeQrcodeScanner/spinkitcircle.dart';
import 'package:erpflutter/screens/BarcodeQrcodeScanner/vibration.dart';
import '../../Dashboard.dart';
import '../../provider/themecontroller.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<QRViewExample> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample>
    with WidgetsBindingObserver {
  late ThemeController themeController;
  late MobileScannerController _controller;
  bool _scanned = false;
  bool _exiting = false;
  String? strUserName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.noDuplicates,
    );

    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    strUserName = prefs.getString('USERNAME');
  }

  // 🔄 Lifecycle safety
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!mounted) return;

    if (state == AppLifecycleState.resumed) {
      await _safeStart();
    } else if (state == AppLifecycleState.paused) {
      await _safeStop();
    }
  }
  int _idx = 1;
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    themeController = Provider.of<ThemeController>(context, listen: false);
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    final unreadProvider = Provider.of<UnreadNotificationProvider>(context);
    return  Center(
      child: SizedBox(
        width: isDesktop ? 700 : double.infinity,
        child: Scaffold(
            appBar:PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Center(
                    child: SizedBox(
                        width: isDesktop ? 700 : double.infinity,
                        child: AppBar(
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
                  if (_exiting) return;
                  _exiting = true;
                  await _safeStop();
                  Navigator.of(context).pop();
                 /* Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Dashboard()),
                  );*/
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
         /*       Navigator.pushReplacement(
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
            body: _scanned ? _loading(h, w) : _scanner(),
          ),
      ),
    );
  }

  Widget _scanner() {
    if (Platform.isWindows) {
      return const Center(child: Text('Camera not supported on Windows'));
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [

        MobileScanner(
          controller: _controller,
          fit: BoxFit.cover,
          onDetect: _onDetect,
        ),

        // 🔦 Flash
        Positioned(
          bottom: 90,
          child: ElevatedButton(
            onPressed: () async {
              await _controller.toggleTorch();
              setState(() {});
            },
            child: Icon(
              _controller.value.torchState == TorchState.on
                  ? Icons.flash_off
                  : Icons.flash_on,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned || _exiting) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    log('Scanned: $code');
    _vibrate();

    setState(() => _scanned = true);

    // 🛑 STOP camera before dialog
    await _safeStop();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Scan Result"),
        content: Text(code),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );

    // 🚪 Exit scanner safely
    if (!_exiting) {
      _exiting = true;
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Dashboard()),
        );
      }
    }
  }

  Widget _loading(double h, double w) => Center(
    child: Container(
      height: h * 0.08,
      width: w * 0.6,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitCircle(color: Colors.blue, size: 35),
          SizedBox(width: 10),
          Text("Loading..."),
        ],
      ),
    ),
  );

  bool _vibrating = false;
  void _vibrate() async {
    if (_vibrating) return;
    if (await Vibration.hasVibrator() != true) return;

    _vibrating = true;
    Vibration.vibrate(duration: 200);
    await Future.delayed(const Duration(milliseconds: 200));
    _vibrating = false;
  }

  Future<void> _safeStop() async {
    try {
      await _controller.stop();
    } catch (_) {}
  }

  Future<void> _safeStart() async {
    try {
      await _controller.start();
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }
}
