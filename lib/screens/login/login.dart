import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:erpflutter/helpers/battery_optimization.dart';
import 'package:erpflutter/screens/login/reset_password.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:windows_taskbar/windows_taskbar.dart';
import '../../Constants.dart';
import '../../app_config.dart';
import '../../database/app_preferences.dart';
import '../../database/database_service.dart';
import '../../database/secure_storage_service.dart';
import '../../main.dart';
import '../../models/getnotificationmodel.dart';
import '../../provider/financialyear_provider.dart';
import '../../provider/get_notification_provider.dart';
import 'package:app_settings/app_settings.dart';
import '../../provider/themecontroller.dart';
import '../UnreadNotificationProvider.dart';
import '../companylist/company_list_screen.dart';
import '../ico_image.dart';
import '../ico_writer.dart';
import 'login_controller.dart';
import 'login_viewmodel.dart';
import 'otp_verification.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
   final LocalAuthentication auth = LocalAuthentication();
  String _authorized = 'Not Authorized',
      LocalIP = "-";
  bool _isAuthenticating = false;
  bool authenticated = false;
  bool isSupported = false;
  bool isAuthenticated = false;
  String message = "Checking biometric support...";
  static const platform = MethodChannel('com.cloud9.c9projecttracker/settings');
  late LoginViewModel loginVM1;
  bool _rememberMe = false;
  late ThemeController themeController;

  static const batteryChannel = MethodChannel('com.cloud9.plantapp/battery');

  Future<void> requestIgnoreBatteryOptimization() async {
    final disabled = await BatteryOptimization.isDisabled();

    if (!disabled) {
      await batteryChannel.invokeMethod(
        'requestIgnoreBatteryOptimizations',
      );
    }
  }
  void initState() {
    super.initState();

    loginVM1 = context.read<LoginViewModel>();
    _loadSavedCredentials();

  /*  WidgetsBinding.instance.addPostFrameCallback((_) {
     requestIgnoreBatteryOptimization();
    });*/
  }
  Future<void> _loadSavedCredentials() async {
    bool rememberMe = await SecureStorageService.isRememberMe();
    if (rememberMe) {
      String? username = await SecureStorageService.getUsername();
      String? password = await SecureStorageService.getPassword();
      setState(() {
        _rememberMe = true;
        _userController.text = username ?? '';
        _passController.text = password ?? '';
      });
    }

    print(rememberMe);
    print(_rememberMe);
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _openBiometricSettings() async {
    try {
      await platform.invokeMethod('openBiometricSettings');
    } on PlatformException catch (e) {
      print("Failed to open biometric settings: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    themeController = Provider.of<ThemeController>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {

          /// 📱 MOBILE
          if (constraints.maxWidth < 600) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration:  BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(
                      themeController.primaryColor,
                      Colors.white,
                      0.3, // 30% lighter
                    )!,
                    themeController.darkColor,

                    Color.lerp(
                      themeController.primaryColor,
                      Colors.white,
                      0.3, // 30% lighter
                    )!,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(

                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery
                          .of(context)
                          .size
                          .height,
                    ),
                    child: IntrinsicHeight(
                      child: _buildLoginContent(isMobile: true),
                    ),
                  ),

              ),
            );
          }

          /// 🖥️ DESKTOP
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration:  BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeController.darkColor,
                  themeController.primaryColor,
                  themeController.darkColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Container(
                width: 450,
                decoration: BoxDecoration(
                  color: const Color(0xFF000000),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _buildLoginContent(isMobile: false),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginContent({required bool isMobile}) {
    final size = MediaQuery
        .of(context)
        .size;

    // Responsive values
    bool isDesktop = size.width > 800;

    double logoSize = isDesktop ? 120 : 90;
    double titleSize = isDesktop ? 38 : 28;
    double subtitleSize = isDesktop ? 16 : 12;
    double footerSize = isDesktop ? 13 : 10;
    return SafeArea(
      child: SingleChildScrollView(
      child:Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        /// ================= HEADER =================
        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
          decoration: BoxDecoration(
            color: themeController.darkColor,
            borderRadius: isMobile
                ? BorderRadius.zero
                : const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: logoSize,
                width: logoSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.blueAccent.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Container(
                    height: logoSize ,
                    width: logoSize ,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Image(
                        image: AssetImage("assets/logologin.png"),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Welcome back",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Sign in to Cloud9 Business Suite",
                style: TextStyle(
                  color:
                  Color.lerp(
                    themeController.primaryColor,
                    Colors.white,
                    0.5, // 60% lighter
                  )!,
                  fontSize:Platform.isIOS ? 17 : 14,
                ),
              ),
            ],
          ),
        ),

        /// ================= FORM =================
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                /// Employee ID
                _buildTextField(
                  controller: _userController,
                  hint: "Employee ID",
                  icon: Icons.person_outline,
                  isPassword: false,
                ),

                const SizedBox(height: 18),

                /// Password
                Selector<LoginViewModel, bool>(
                  selector: (_, vm) => vm.showPassword,
                  builder: (_, showPassword, __) {
                    return _buildTextField(
                      controller: _passController,
                      hint: "Password",
                      icon: Icons.lock_outline,
                      isPassword: !showPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color:
                          Color.lerp(
                            themeController.primaryColor,
                            Colors.white,
                            0.2, // 60% lighter
                          )!,
                        ),
                        onPressed: () {
                          context
                              .read<LoginViewModel>()
                              .togglePassword();
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),

                /// Remember + Forgot
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                        visible: true,

                        child:    Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                      print(_rememberMe);
                                    });
                                  },
                                  activeColor:themeController.primaryColor,
                                ),

                                 Text(
                                  "Remember me",
                                  style: TextStyle(color:
                                  Color.lerp(
                                    themeController.primaryColor,
                                    Colors.white,
                                    0.7, // 60% lighter
                                  )!),
                                ),
                              ],
                            ),

                          ],
                        ),),
                    GestureDetector(
                        onTap: () {
                          print("Forgot password clicked");
                           Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResetPasswordScreen(),
                            ),
                          );

                          //  _submitForgotPassword(context);
                        },
                        child:  Text(
                          "Forgot password?",
                          style: TextStyle(
                            color:
                            Color.lerp(
                              themeController.primaryColor,
                              Colors.white,
                              0.7, // 60% lighter
                            )!,
                            fontSize:Platform.isIOS ? 16 : 13,
                          ),
                        )),
                  ],
                ),

                const SizedBox(height: 10),

                /// Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:

    themeController.darkColor
    ,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      _submit(context);

                    },

                    child:  Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize:Platform.isIOS ? 19 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// Divider
                Row(
                  children:  [
                    Expanded(
                      child: Divider(color: Colors.white24),
                    ),
                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "or sign in with",
                        style: TextStyle(
                            color:
                            Color.lerp(
                              themeController.primaryColor,
                              Colors.white,
                              0.8, // 60% lighter
                            )!,
                            fontSize:Platform.isIOS ? 15 : 12),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.white24),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// Biometric Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // centers horizontally

                  children: [
                    /*Expanded(
                      child:*/

                      Container(
                          width: 150, // desired width
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child:
                          _buildBiometricButton(
                        icon: Icons.fingerprint,
                        label: "Fingerprint",
                        //    onTap: authenticate,
                        onTap: () async{
                          print("Widget tapped");

                          _submitFingerprint(context);
                        },
                      )),
                   // ),
                    const SizedBox(width: 16),
                    Visibility(
                        visible: false,

                        child:Expanded(
                      child: _buildFaceIdButton(
                        assetPath: "assets/face.png",
                        label: "Face ID",
                        onTap: () {
                          print("Face ID tapped");
                        },
                      ),
                    )),
                  ],
                ),

                const SizedBox(height: 30),

                 Text(
                  "Cloud9 Business Suite v1.0.0 - cloud9ebiz.com",
                  style: TextStyle(
                    color: Color.lerp(
                      themeController.primaryColor,
                      Colors.white,
                      0.8, // 60% lighter
                    )!,
                    fontSize:Platform.isIOS ? 14 : 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    )));
  }
  Widget _buildFaceIdButton({
    required String assetPath, // path to your image in assets
    required String label,
    required VoidCallback onTap,
  }) {

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,               // 👈 Handle click here
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                assetPath,
                width: 40,
                height: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style:  TextStyle(
                  fontSize:Platform.isIOS ? 16 : 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }
  static Widget _buildBiometricButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,   // 👈 Add this
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,               // 👈 Handle click here
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: Colors.black87),
              const SizedBox(height: 6),
              Text(
                label,
                style:  TextStyle(
                  fontSize:Platform.isIOS ? 16 : 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isPassword,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style:  TextStyle(
        color: themeController.primaryColor,
        fontWeight: FontWeight.w500,
      ),
      validator: (value) =>
      value == null || value.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFE5E7EB),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF6B7280),
        ),
        prefixIcon:
        Icon(icon, color: const Color(0xFF6B7280)),
        suffixIcon: suffixIcon,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        errorStyle:  TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize:Platform.isIOS ? 5 : 12,
        ),
      ),
    );
  }
  void showLoader(BuildContext context, {String message = "Loading..."}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 15),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
        );
      },
    );
  }

  void dismissLoader(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
  Future<String> _setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for iOS
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // Get the token
    String? token = await messaging.getToken();

    print("Firebase Messaging Token: $token");

    return token ?? '';
  }

  void _submit(BuildContext context) async {


    if (!_formKey.currentState!.validate()) return;
    showLoader(context);
    final loginVM = context.read<LoginViewModel>();
    final username = _userController.text.trim();
    final password = _passController.text.trim();

    final connectivityResult =
    await Connectivity().checkConnectivity();

    bool hasInternet =
        connectivityResult != ConnectivityResult.none;

    if (hasInternet) {
      await loginVM.login(username, password);
      if (loginVM.status == LoginStatus.success) {
        if (Platform.isAndroid) {
          String firebaseToken = await _setupFirebaseMessaging();
          AppPreferences.saveFcmToken( firebaseToken);
        }
        String? fcmtoken = await AppPreferences.getFcmToken();
        final userData = loginVM.loginResponse?.data;

        print("ISOTP: ${userData?.ISOTP}");
        print("UserName: ${userData?.username}");
        print("UserType: ${userData?.usertypeid}");
        print("Token: ${userData?.token}");
        print(_rememberMe);
        /// 🔹 1. Run FCM + Device update in parallel
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("ISLOGGEDIN", true);

        prefs.setString("USERID", userData!.userid.toString());
        prefs.setString("USERNAME", userData!.username.toString());
        prefs.setString("TOKEN", userData!.token.toString());
        prefs.setString("ORGSTRUCTID", userData!.orgstrucid.toString());
        prefs.setString("POSID", userData!.posid.toString());
        prefs.setString("LOGINRESPONSE", jsonEncode(loginVM.loginResponse));
        prefs.setString('ENABLEBIOMETRIC', userData!.ISVERIFIED.toString());
        prefs.setString('CONTROLNO', userData!.controlno.toString());
        await loginVM1.updateDeviceInfo(loginVM.loginResponse!, fcmtoken);
        await SecureStorageService.saveCredentials(
            username, password);
        Provider.of<GetNotificationProvider>(context, listen: false)
            .loadNotificationCount("0");


        if (hasInternet) {
          await loginVM.authenticateUserOtp(context: context, token: userData!.token, mobileNo: userData!.MOBILENO.toString(), userId: userData!.userid.toString(), strFlag: 'I', strOtp: '');

          if (loginVM.status == LoginStatus.success) {


            if (_rememberMe) {
              print("remeber me");
              await SecureStorageService.setUsername(username);
              await SecureStorageService.setPassword(password);
              await SecureStorageService.setRememberMe(_rememberMe);
            } else {
              print("remeber me not");
              await SecureStorageService.clearCredentials();
            }
            Provider.of<GetNotificationProvider>(context, listen: false)
                .loadNotificationCount("0");
            bool rememberMe = await SecureStorageService.isRememberMe();
            print(rememberMe);
            context.read<FinancialYearProvider>().loadTransactions();
            Provider.of<LoginController>(context, listen: false)
                .getUser("username", "password", loginVM.loginResponse);
            try {
              await DatabaseService().insertDocMast( loginVM.loginResponse!);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("DB insert error: $e")),
              );
              print("DB insert error: $e");
            }

            if(userData?.ISOTP != null && userData?.ISOTP =="true") {
              if (loginVM.code == "200") {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loginVM.message ?? ""),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loginVM.message ?? ""),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } else {
            /*ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loginVM.error ?? "Something went wrong"),
                backgroundColor: Colors.red,
              ),
            );*/
          }


        }
        dismissLoader(context);
        await SecureStorageService.setIsVerifiedn(
          loginVM.loginResponse?.data?.ISVERIFIED?.toLowerCase() == "true",
        );

        bool canAuthenticate = await auth.isDeviceSupported() &&
            await auth.canCheckBiometrics;

        if (loginVM.loginResponse!.data!.ISVERIFIED != null &&
            loginVM.loginResponse!.data!.ISVERIFIED == "true" && userData?.ISOTP != null && userData?.ISOTP !="true") {
          if (!canAuthenticate) {
            setState(() {
              _isAuthenticating = false;
              _authorized = 'Biometric authentication not available.';
            });
            //return;
         //   _nextScrebredirect();
            if(userData?.ISOTP != null && userData?.ISOTP =="false") {
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
            /*  Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionListScreen(),
                ),
              );*/
            }else
            {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 10),
                  reverseTransitionDuration: const Duration(milliseconds: 10),
                  pageBuilder: (_, animation, secondaryAnimation) =>
                      OtpVerificationScreen(phone: userData!.MOBILENO.toString(),activityName: 'SIGNIN', otp:loginVM.otp.toString(), userId: '0',),
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
                MaterialPageRoute(
                  builder: (context) => OtpVerificationScreen(phone: userData!.MOBILENO.toString(),activityName: 'SIGNIN', otp:loginVM.otp.toString(), userId: '0',),
                ),
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
                if(userData?.ISOTP != null && userData?.ISOTP =="false") {
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
                /*  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionListScreen(),
                    ),
                  );*/
                }else
                {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 10),
                      reverseTransitionDuration: const Duration(milliseconds: 10),
                      pageBuilder: (_, animation, secondaryAnimation) =>
                          OtpVerificationScreen(phone: userData!.MOBILENO.toString(),activityName: 'SIGNIN', otp:loginVM.otp.toString(), userId: '0',),
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
                    MaterialPageRoute(
                      builder: (context) => OtpVerificationScreen(phone: userData!.MOBILENO.toString(),activityName: 'SIGNIN', otp:loginVM.otp.toString(), userId: '0',),
                    ),
                  );*/
                }
              }
            });
            //

          }
        }
        else {
        //  _nextScrebredirect();
          if(userData?.ISOTP != null && userData?.ISOTP =="false") {
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
          /*  Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TransactionListScreen(),
              ),
            );*/
          }else
          {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 10),
                reverseTransitionDuration: const Duration(milliseconds: 10),
                pageBuilder: (_, animation, secondaryAnimation) =>
                    OtpVerificationScreen(phone: userData!.MOBILENO.toString(),activityName: 'SIGNIN', otp:loginVM.otp.toString(), userId: '0',),
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
              MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(phone: userData!.MOBILENO.toString(),activityName: 'SIGNIN', otp:loginVM.otp.toString(), userId: '0',),
              ),
            );*/
          }
        }


      }
      else  if (loginVM.status == LoginStatus.error) {
        dismissLoader(context);
        print(loginVM.error);
       /* ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loginVM.message ?? "Login failed"),
            backgroundColor: Colors.red,
          ),
        );*/
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loginVM.error ??
                  loginVM.message ??
                  "Login failed",
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

    } else {
      final savedCreds =
      await SecureStorageService.getCredentials();

      if (savedCreds != null &&
          savedCreds["username"] == username &&
          savedCreds["password"] == password) {
        loginVM.setOfflineSuccess();
      } else {
        loginVM.setOfflineError(
            "No internet & no saved credentials");
      }
    }


  }

  void _submitFingerprint(BuildContext context) async {


    if (!_formKey.currentState!.validate()) return;
    showLoader(context);
    final loginVM = context.read<LoginViewModel>();
    final username = _userController.text.trim();
    final password = _passController.text.trim();

    final connectivityResult =
    await Connectivity().checkConnectivity();

    bool hasInternet =
        connectivityResult != ConnectivityResult.none;

    if (hasInternet) {
      await loginVM.login(username, password);
      if (loginVM.status == LoginStatus.success) {

        String? fcmtoken = await AppPreferences.getFcmToken();
        final userData = loginVM.loginResponse?.data;

        print("ISOTP: ${userData?.ISOTP}");
        print("UserName: ${userData?.username}");
        print("UserType: ${userData?.usertypeid}");
        print("Token: ${userData?.token}");

        /// 🔹 1. Run FCM + Device update in parallel

        await loginVM1.updateDeviceInfo(loginVM.loginResponse!, fcmtoken);
        await SecureStorageService.saveCredentials(
            username, password);


        if (hasInternet) {
          await loginVM.authenticateUserOtp(context: context, token: userData!.token, mobileNo: userData!.MOBILENO.toString(), userId: userData!.userid.toString(), strFlag: 'I', strOtp: '');

          if (loginVM.status == LoginStatus.success) {
            if (_rememberMe) {
              await SecureStorageService.setUsername(username);
              await SecureStorageService.setPassword(password);
              await SecureStorageService.setRememberMe(true);
            } else {
              await SecureStorageService.clearCredentials();
            }
            Provider.of<GetNotificationProvider>(context, listen: false)
                .loadNotificationCount("0");

            context.read<FinancialYearProvider>().loadTransactions();
            Provider.of<LoginController>(context, listen: false)
                .getUser("username", "password", loginVM.loginResponse);
            try {
              await DatabaseService().insertDocMast( loginVM.loginResponse!);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("DB insert error: $e")),
              );
              print("DB insert error: $e");
            }

            if(userData?.ISOTP != null && userData?.ISOTP =="true") {
              if (loginVM.code == "200") {
              /*  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loginVM.message ?? ""),
                    backgroundColor: Colors.green,
                  ),
                );*/
              } else {
               /* ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loginVM.message ?? ""),
                    backgroundColor: Colors.red,
                  ),
                );*/
              }
            }


          } else {
            /*ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loginVM.error ?? "Something went wrong"),
                backgroundColor: Colors.red,
              ),
            );*/
          }


        }
        dismissLoader(context);
        bool canAuthenticate = await auth.isDeviceSupported() &&
            await auth.canCheckBiometrics;
print(loginVM.loginResponse!.data!.ISVERIFIED);
        if (loginVM.loginResponse!.data!.ISVERIFIED != null &&
            (loginVM.loginResponse!.data!.ISVERIFIED.toString()) == "true" && userData?.ISOTP != null && userData?.ISOTP.toString() !="true") {
          if (!canAuthenticate) {
            setState(() {
              _isAuthenticating = false;
              _authorized = 'Biometric authentication not available.';
            });
            //return;
            //   _nextScrebredirect();
            if(userData?.ISOTP != null && userData?.ISOTP =="false") {
             /* Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionListScreen(),
                ),
              );*/
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
            }else
            {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 10),
                  reverseTransitionDuration: const Duration(milliseconds: 10),
                  pageBuilder: (_, animation, secondaryAnimation) =>
                      OtpVerificationScreen(phone: userData!.MOBILENO.toString(),activityName: 'SIGNIN', otp:loginVM.otp.toString(), userId: '0',),
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
                MaterialPageRoute(
                  builder: (context) => OtpVerificationScreen(phone: userData!.MOBILENO.toString(),activityName: 'SIGNIN', otp:loginVM.otp.toString(), userId: '0',),
                ),
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
                if(userData?.ISOTP != null && userData?.ISOTP =="false") {
               /*   Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionListScreen(),
                    ),
                  );*/
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
                }else
                {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 10),
                      reverseTransitionDuration: const Duration(milliseconds: 10),
                      pageBuilder: (_, animation, secondaryAnimation) =>
                          OtpVerificationScreen(phone: userData!.MOBILENO.toString(),activityName: 'SIGNIN', otp:loginVM.otp.toString(), userId: '0',),
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
                    MaterialPageRoute(
                      builder: (context) => OtpVerificationScreen(phone: userData!.MOBILENO.toString(),activityName: 'SIGNIN', otp:loginVM.otp.toString(), userId: '0',),
                    ),
                  );*/
                }
              }
            });
            //

          }
        }
       else if (loginVM.loginResponse!.data!.ISVERIFIED != null &&
            (loginVM.loginResponse!.data!.ISVERIFIED.toString()) == "true" && userData?.ISOTP != null && userData?.ISOTP.toString() =="true") {
          if(userData?.ISOTP != null && userData?.ISOTP =="false") {
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
              MaterialPageRoute(
                builder: (context) => const TransactionListScreen(),
              ),
            );*/

          }else
          {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 10),
                reverseTransitionDuration: const Duration(milliseconds: 10),
                pageBuilder: (_, animation, secondaryAnimation) =>
                    OtpVerificationScreen(phone: userData!.MOBILENO.toString(),activityName: 'SIGNIN', otp:loginVM.otp.toString(), userId: '0',),
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
              MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(phone: userData!.MOBILENO.toString(),activityName: 'SIGNIN', otp:loginVM.otp.toString(), userId: '0',),
              ),
            );*/
          }
        }
       else {
          //  _nextScrebredirect();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text( "Fingerprint is not registered"),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (Platform.isWindows) {
          getNotificationCount();
          await Future.delayed(Duration(seconds: 2));
          int readcount = Constant.unreadCount ?? 0;
          if (readcount > 0) {
            updateWindowsBadge(readcount);
          }
        }
      }
      else  if (loginVM.status == LoginStatus.error) {
        dismissLoader(context);
        print(loginVM.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loginVM.error ?? "Login failed"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

    } else {
      final savedCreds =
      await SecureStorageService.getCredentials();

      if (savedCreds != null &&
          savedCreds["username"] == username &&
          savedCreds["password"] == password) {
        loginVM.setOfflineSuccess();
      } else {
        loginVM.setOfflineError(
            "No internet & no saved credentials");
      }
    }


  }
  Future<void> getNotificationCount() async {
    try {
      final notificationProvider = Provider.of<GetNotificationProvider>(context, listen: false);

      // Wait for data to be fetched
      await notificationProvider.GetNotification("0");

      // Safely access the list
      List<NitificationLIST> notifications =
          notificationProvider.getNotificationModel?.dATA?.lIST ?? [];

      // Sort unread first
      notifications.sort((a, b) {
        return (a.ISREAD == "0" ? 0 : 1).compareTo(b.ISREAD == "0" ? 0 : 1);
      });

      // Count unread
      Constant.unreadCount = notifications
          .where((item) => item.ISREAD == "0")
          .length;
      final unreadProvider = Provider.of<UnreadNotificationProvider>(context, listen: false);
      unreadProvider.setUnreadCount(
        notifications
            .where((item) => item.ISREAD == "0")
            .length,
      );
      print("Unread count: $Constant.unreadCount");
    } catch (e) {
      print("Error fetching notification count: $e");
    }
  }

  void updateWindowsBadge(int badgeCount) async {
    if (badgeCount > 0) {
      final badgePath = await createBadgeIcon(badgeCount);

      WindowsTaskbar.setOverlayIcon(
        ThumbnailToolbarAssetIcon(badgePath),
        tooltip: '$badgeCount new notifications',
      );
    } else {
      WindowsTaskbar.resetOverlayIcon();
    }
  }

  Future<String> createBadgeIcon(int count) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 64.0;

    // Draw background
    final paint = Paint()
      ..color = Colors.red;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    // Draw text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )
      ..layout();

    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final icoPath = '${dir.path}/badge_icon.ico';

    // Encode ICO manually using IcoWriter
    final icoBytes = encodeIco([
      IcoImage(pngBytes, width: size.toInt(), height: size.toInt()),
    ]);

    final icoFile = File(icoPath);
    await icoFile.writeAsBytes(icoBytes);

    return icoPath;
  }

  Uint8List encodeIco(List<IcoImage> images) {
    final writer = IcoWriter();
    return writer.encode(images);
  }

  Future<void> connectWebSocket(String userId) async {
    // If already connected, close old connection
    if (Constant.rawSocket != null && Constant.rawSocket!.readyState == WebSocket.open) {
      print('Closing old socket');
      await Constant.rawSocket!.close();
    }
    String wsUrl = AppConfig.RAW_BASE_URL.replaceFirst('http', 'ws');
    Constant.rawSocket =
    await WebSocket.connect('$wsUrl/ERPAPI/WebSocketHandlerUserWise_API.ashx?USERID=$userId');
    //Constant.rawSocket = await WebSocket.connect('ws://10.0.0.223:8442/ERPAPI/WebSocketHandlerUserWise.ashx?USERID=$userId');
    Constant.channel = IOWebSocketChannel(Constant.rawSocket!);
    //_channel = IOWebSocketChannel.connect(Uri.parse('ws://10.0.0.223:8442/ERPAPI/WebSocketHandlerUserWise.ashx?USERID=$userId'),
    //  );
    Future.delayed(Duration(seconds: 10), () {

    });

    // Listen to incoming messages
    Constant.channel!.stream.listen(
          (data) {
        print('Received: $data');
        getNotificationCount();
        final context = navigatorKey.currentContext;
        print('context: $context');
        if (context != null) {
          final context = navigatorKey.currentContext;
          print('context: $context');
          if (context != null) {
            /*showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Notification'),
                  content: Text(data ?? 'No Body'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );*/
          }
        }

        int readcount = Constant.unreadCount ?? 0;
        // if(readcount > 0){
        Constant.unreadCount = Constant.unreadCount! + 1;
        updateWindowsBadge(Constant.unreadCount!);
        // }
        // You can use setState or notifyListeners here to update UI
      },
      onDone: () {
        print('WebSocket closed');
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
    );
  }
  void _submitForgotPassword(BuildContext context) async {

    showLoader(context);
    final loginVM = context.read<LoginViewModel>();
    final username = _userController.text.trim();
    final password = _passController.text.trim();

    final connectivityResult =
    await Connectivity().checkConnectivity();

    bool hasInternet =
        connectivityResult != ConnectivityResult.none;

    if (hasInternet) {
      await loginVM.login(username, password);
      if (loginVM.status == LoginStatus.success) {
        await SecureStorageService.saveCredentials(
            username, password);

        final userData = loginVM.loginResponse?.data;

        print("ISOTP: ${userData?.ISOTP}");
        print("UserName: ${userData?.username}");
        print("UserType: ${userData?.usertypeid}");
        print("Token: ${userData?.token}");

        if (hasInternet) {
          await loginVM.authenticateUserOtp(context: context, token: userData!.token, mobileNo: userData!.MOBILENO.toString(), userId: userData!.userid.toString(), strFlag: 'I', strOtp: '');

          if (loginVM.status == LoginStatus.success) {
            if (loginVM.code == "200") {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loginVM.message ?? ""),
                  backgroundColor: Colors.green,
                ),
              );


            }else
            {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loginVM.message ?? ""),
                  backgroundColor: Colors.red,
                ),
              );
            }


          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loginVM.error ?? "Something went wrong"),
                backgroundColor: Colors.red,
              ),
            );
          }


        }
        dismissLoader(context);
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 10),
            reverseTransitionDuration: const Duration(milliseconds: 10),
            pageBuilder: (_, animation, secondaryAnimation) =>
                OtpVerificationScreen(phone: userData!.MOBILENO.toString(),activityName: 'SIGNIN', otp:loginVM.otp.toString(), userId: '0',),
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
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(phone: userData!.MOBILENO.toString(), activityName: 'SIGNIN', otp: loginVM.otp.toString(), userId: '0',),
          ),
        );*/
        /* if(userData?.isOtp != null && userData?.isOtp =="false") {
          Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) =>
            const HomeDashboardScreen()),
            (route) => false,
      );
      }else
        {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(phone: userData!.mobileNo,),
            ),
          );
        }*/

      }
      else  if (loginVM.status == LoginStatus.error) {
        dismissLoader(context);
        print(loginVM.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loginVM.error ?? "Login failed"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

    } else {
      final savedCreds =
      await SecureStorageService.getCredentials();

      if (savedCreds != null &&
          savedCreds["username"] == username &&
          savedCreds["password"] == password) {
        loginVM.setOfflineSuccess();
      } else {
        loginVM.setOfflineError(
            "No internet & no saved credentials");
      }
    }


  }

}




