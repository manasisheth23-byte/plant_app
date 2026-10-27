import 'dart:io';

import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/models/LoginResponseModel.dart';
import 'package:erpflutter/screens/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../app_config.dart';


class ReportViewWindows extends StatefulWidget {
  final String pagesheetId;
  final String userId;
  final String token;

  const ReportViewWindows({
    super.key,
    required this.pagesheetId,
    required this.userId,
    required this.token,
  });

  @override
  State<ReportViewWindows> createState() => _ReportViewWindowsState();
}

class _ReportViewWindowsState extends State<ReportViewWindows> {
  final WebviewController _webviewController = WebviewController();
  LoginResponseModel? loginResponseModel;
  bool _isWebViewReady = false;
  bool _isUrlLoaded = false;
  bool _isPageLoading = true;
  // ---------------- ORIENTATION HELPERS ----------------
  Future<void> _setLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _setPortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();

    // 🔹 Lock landscape only once (after first frame)
    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setLandscape();
      });
    }

    // 🔹 Initialize WebView for Windows
    if (Platform.isWindows) {
      _initWindowsWebView();
    }
  }

  /*Future<void> _initWindowsWebView() async {
    await _webviewController.initialize();
    setState(() {
      _isWebViewReady = true;
    });
  }*/
  /*Future<void> _initWindowsWebView() async {
    try {
      await _webviewController.initialize();

      setState(() {
        _isWebViewReady = true;
      });
    } catch (e) {
      debugPrint("WebView initialize error: $e");
    }
  }*/
  Future<void> _initWindowsWebView() async {
    try {
      await _webviewController.initialize();

      _webviewController.loadingState.listen((state) {
        if (!mounted) return;

        setState(() {
          _isPageLoading = state != LoadingState.navigationCompleted;
        });
      });

      setState(() {
        _isWebViewReady = true;
      });
    } catch (e) {
      debugPrint("WebView initialize error: $e");
    }
  }
  // ---------------- DISPOSE ----------------
/*
  @override
  void dispose() {
    // 🔹 Restore portrait when leaving screen
    if (Platform.isAndroid) {
      _setPortrait();
    }
    super.dispose();
  }
*/
  @override
  void dispose() {
    if (Platform.isWindows) {
      _webviewController.dispose();
    }

    if (Platform.isAndroid) {
      _setPortrait();
    }

    super.dispose();
  }
  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop && Platform.isAndroid) {
          _setPortrait();
        }
      },
      child: Consumer<LoginController>(
        builder: (context, data, _) {

          final webviewUrl =
              "${AppConfig.RAW_BASE_URL}/ApiPageSet/PageSheetView"
              "?PAGESHEETID=${widget.pagesheetId}"
              "&USERID=${widget.userId}"
              "&TOKEN=${widget.token}";
         // final login = controller.loginResponseModel!;
          /*final String webviewUrl =
              "${AppConfig.RAW_BASE_URL}/ApiPageSet/PageSheetView"
              "?PAGESHEETID=${widget.pagesheetId}"
              "&USERID=${login.data!.userid}"
              "&TOKEN=${login.data!.token}";*/
          print(webviewUrl);

          // 🔹 Load URL only once
        /*  if (Platform.isWindows &&
              _isWebViewReady &&
              !_isUrlLoaded) {
            _webviewController.loadUrl(webviewUrl);
            _isUrlLoaded = true;
          }*/
          if (Platform.isWindows &&
              _isWebViewReady &&
              !_isUrlLoaded) {

            debugPrint("Loading URL...");
            debugPrint(webviewUrl);

            _webviewController.loadUrl(webviewUrl);

            _isUrlLoaded = true;
          }
          return Center(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.APPCOLOR,
                foregroundColor: Colors.white,
                title:  Text('Report',style:  GoogleFonts.lato(

                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),),
              ),
              body: Platform.isWindows
                  ? (!_isWebViewReady
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : Stack(
                children: [
                  Webview(_webviewController),

                  if (_isPageLoading)
                    Container(
                      color: Colors.white,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ))
                  : const Center(
                child: Text(
                  "Android WebView handled separately",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              /*body: Platform.isWindows
                  ? (_isWebViewReady
                  ? Webview(_webviewController)
                  : const Center(child: CircularProgressIndicator()))
                  : const Center(
                child: Text(
                  "Android WebView handled separately",
                  style: TextStyle(fontSize: 16),
                ),
              ),*/
            ),
          );
        },
      ),
    );
  }
}
