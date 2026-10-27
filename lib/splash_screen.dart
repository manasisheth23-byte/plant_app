import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/provider/financialyear_provider.dart';
import 'package:erpflutter/screens/alerts/alerts_list.dart';
import 'package:erpflutter/screens/companylist/company_list_screen.dart';
import 'package:erpflutter/screens/login/login.dart';

import 'package:erpflutter/screens/login/login_controller.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Dashboard.dart';
import 'database/secure_storage_service.dart';
import 'models/LoginResponseModel.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var isLogout;
  var enablebiometry;
  String _authorized = 'Not Authorized';
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;
  bool authenticated = false;
  bool isSupported = false;
  bool isAuthenticated = false;

  @override
  void initState() {

    super.initState();
    if (!kIsWeb && Platform.isAndroid) {
      requestStoragePermission();
      _requestStoragePermission();
    }
    _setPreferredOrientations();
    _startApp();
   // _checkLoginStatus();
  }

  Future<void> _startApp() async {
    try {


      await Future.delayed(const Duration(seconds: 2));

      bool isLoggedIn = await SecureStorageService.isLoggedIn();
      bool getIsVerifiedn = await SecureStorageService.getIsVerifiedn();
     // print(getIsVerifiedn);
      // Check login/token

      if (!mounted) return;
      bool canAuthenticate = await auth.isDeviceSupported() &&
          await auth.canCheckBiometrics;

      if (getIsVerifiedn != null &&
          getIsVerifiedn == true ) {
        if (!canAuthenticate) {
          setState(() {
            _isAuthenticating = false;
            _authorized = 'Biometric authentication not available.';
          });
          //return;
          //   _nextScrebredirect();
          if (isLoggedIn) {


         /*   Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) =>  TransactionListScreen()),
                  (route) => false,
            );*/

            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 10),
                reverseTransitionDuration: const Duration(milliseconds: 10),
                pageBuilder: (_, animation, secondaryAnimation) =>
                    TransactionListScreen(),
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
              ), (route) => false,
            );


          } else {
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 10),
                reverseTransitionDuration: const Duration(milliseconds: 10),
                pageBuilder: (_, animation, secondaryAnimation) =>
                    LoginScreen(),
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
              ), (route) => false,
            );
         /*   Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
            );*/
          }
        }
        else {

          try {
            setState(() {
              _isAuthenticating = true;
              _authorized = 'Authenticating';
            });
            authenticated = await auth.authenticate(
              localizedReason:
              'Scan your fingerprint to authenticate',
              options: const AuthenticationOptions(
                stickyAuth: true,
                biometricOnly: true,
              ),
            );
            setState(() {
              _isAuthenticating = false;
              _authorized = 'Authenticating';
            });
          } on PlatformException catch (e) {
            print(e);
            setState(() {
              _isAuthenticating = false;
              if (e.code == 'LockedOut') {
                _authorized =
                'Too many failed attempts. Try again in 30 seconds.';
              } else {
                _authorized = 'Error - ${e.message}';
              }
              print(_authorized);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(_authorized),
              ));
            });
            return;
          }
          if (!mounted) {
            return;
          }
          final String message = authenticated ? 'true' : 'false';
          setState(() {
            _authorized = message;

            if (_authorized == "true") {
              print(_authorized);
              print("@@@@@@@");

              //call Database UI
              //  _nextScrebredirect();
              if (isLoggedIn) {

                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 10),
                    reverseTransitionDuration: const Duration(milliseconds: 10),
                    pageBuilder: (_, animation, secondaryAnimation) =>
                        TransactionListScreen(),
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
                  ), (route) => false,
                );
            /*    Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) =>  TransactionListScreen()),
                      (route) => false,
                );*/




              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 10),
                    reverseTransitionDuration: const Duration(milliseconds: 10),
                    pageBuilder: (_, animation, secondaryAnimation) =>
                        LoginScreen(),
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
                  ), (route) => false,
                );
               /* Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                );*/
              }
            }
          });
          //

        }
      }
      else {
        if (isLoggedIn) {
          Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 10),
              reverseTransitionDuration: const Duration(milliseconds: 10),
              pageBuilder: (_, animation, secondaryAnimation) =>
                  TransactionListScreen(),
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
            ), (route) => false,
          );

         /* Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) =>  TransactionListScreen()),
                (route) => false,
          );*/




        } else {
          Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 10),
              reverseTransitionDuration: const Duration(milliseconds: 10),
              pageBuilder: (_, animation, secondaryAnimation) =>
                  LoginScreen(),
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
            ), (route) => false,
          );
        /*  Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
          );*/
        }
      }

    } catch (e) {
      debugPrint("Splash error: $e");

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 10),
          reverseTransitionDuration: const Duration(milliseconds: 10),
          pageBuilder: (_, animation, secondaryAnimation) =>
              LoginScreen(),
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
        ), (route) => false,
      );
     /* Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
      );*/
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }
    return false;
  }
  Future<void> requestStoragePermission() async {


    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;

    if (androidInfo.version.sdkInt >= 30) {
      var manageExternalStorageStatus = await Permission.manageExternalStorage.status;
      if (!manageExternalStorageStatus.isGranted) {
        var result = await Permission.manageExternalStorage.request();
        if (!result.isGranted) {
        //  _showPermissionDeniedDialog();
        } else {

        }
      } else {

      }
    } else {
      var storagePermissionStatus = await Permission.storage.status;
      if (!storagePermissionStatus.isGranted) {
        var result = await Permission.storage.request();
        if (!result.isGranted) {
         // _showPermissionDeniedDialog();
        } else {

        }
      } else {

      }
    }
  }

  // Show dialog when permission is denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Permission Required'),
            content: Text(
                'Storage permission is required to download the APK. Please allow the permissions and try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _setPreferredOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 10));

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      enablebiometry = prefs.getString("ENABLEBIOMETRIC") ?? "false";
      bool loggedIn = prefs.getBool("ISLOGGEDIN") ?? false;
      isLogout = prefs.getString("ISLOGOUT") ?? "true";
      if (loggedIn) {
        context.read<FinancialYearProvider>().loadTransactions();
        if (enablebiometry == "true" || enablebiometry == "True") {


          setState(() {
            _authenticateWithBiometrics();
          });
        }else{
          _navigateToDashboard(prefs);
        }

      } else {
        _navigateToLoginPage();
      }


    } catch (e) {
      // Handle any errors here (optional)
      _navigateToLoginPage(); // Fallback to login page
    }
  }
  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    enablebiometry = prefs.getString("ENABLEBIOMETRIC") ?? "false";
    bool loggedIn = prefs.getBool("ISLOGGEDIN") ?? false;
    isLogout = prefs.getString("ISLOGOUT") ?? "true";

    if (!mounted) return;
    setState(() {
      _isAuthenticating = true;
      _authorized = 'Authenticating';
    });

    try {
      /*authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );*/
      if (Platform.isWindows) {
        _navigateToDashboard(prefs);
      } else {
        authenticated = await auth.authenticate(
          localizedReason: 'Please authenticate',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
      }
    } on PlatformException catch (e) {
      print(e);
      if (!mounted) return;
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isAuthenticating = false;
      _authorized = authenticated ? 'true' : 'false';
    });

    if (authenticated) {
      _navigateToDashboard(prefs);
    }
  }

  void _navigateToDashboard(SharedPreferences prefs) {
    final loginResponse = prefs.getString('LOGINRESPONSE');
    if (loginResponse != null) {
      Provider.of<LoginController>(context, listen: false).loginResponseModel =
          LoginResponseModel.fromJson(jsonDecode(loginResponse));
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 10),
        reverseTransitionDuration: const Duration(milliseconds: 10),
        pageBuilder: (_, animation, secondaryAnimation) =>
            TransactionListScreen(),
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
   /* Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TransactionListScreen()),
    );*/
  }

  void _navigateToLoginPage() {

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 10),
        reverseTransitionDuration: const Duration(milliseconds: 10),
        pageBuilder: (_, animation, secondaryAnimation) =>
        LoginScreen(),
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
    /*Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF12426E),
     body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Image.asset('assets/splashscreen.png'),
        ),
      ),
    );
  }
}
