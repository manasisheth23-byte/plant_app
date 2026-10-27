import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../../plantappscreen/app_shell.dart';
import '../../provider/themecontroller.dart';
import '../ChangePasswordScreen.dart';
import '../companylist/company_list_screen.dart';
import 'login.dart';
import 'login_viewmodel.dart';



class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final String activityName;
  late  String otp;
  final  String userId;

  OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.activityName,
    required this.otp,
    required this.userId,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  bool _isOtpInvalid = false; // ✅ ERROR FLAG
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = 'Not Authorized',
      LocalIP = "-";
  bool _isAuthenticating = false;
  bool authenticated = false;
  bool isSupported = false;
  bool isAuthenticated = false;
  String message = "Checking biometric support...";
  final List<FocusNode> _focusNodes =
  List.generate(6, (_) => FocusNode());

  int _secondsRemaining = 60;
  Timer? _timer;
  late ThemeController themeController;
  @override
  void initState() {
    super.initState();
    _startTimer();
  }
  String maskMobileNumber(String mobile) {
    if (mobile.length < 10) return mobile;

    String countryCode = "";
    String number = mobile;

    // Extract country code if exists
    if (mobile.startsWith("+")) {
      int spaceIndex = mobile.indexOf(" ");
      if (spaceIndex != -1) {
        countryCode = mobile.substring(0, spaceIndex + 1);
        number = mobile.substring(spaceIndex + 1);
      }
    }

    // Remove spaces
    number = number.replaceAll(" ", "");

    if (number.length < 10) return mobile;

    String firstTwo = number.substring(0, 2);
    String lastTwo = number.substring(number.length - 2);

    return "$countryCode$firstTwo••• •••$lastTwo";
  }
  void _startTimer() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_secondsRemaining == 0) {
            timer.cancel();
          } else {
            setState(() {
              _secondsRemaining--;
            });
          }
        });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  String get otp =>
      _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    themeController = Provider.of<ThemeController>(context, listen: false);
    return PopScope(
        canPop: false, // prevents automatic back
        onPopInvokedWithResult: (didPop, result) async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>  LoginScreen(),
            ),
          );
        },
        child:Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFF020817),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isDesktop =
                    constraints.maxWidth > 900;

                /// 📱 MOBILE → FULL SCREEN
                if (!isDesktop) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom:
                      MediaQuery.of(context)
                          .viewInsets
                          .bottom,
                    ),
                    child: _buildContent(
                        isDesktop: false),
                  );
                }

                /// 🖥️ DESKTOP → CENTER CARD
                return Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                      const BoxConstraints(
                          maxWidth: 480),
                      child: Container(
                        decoration:
                        BoxDecoration(
                          color:
                          themeController.darkColor,
                          borderRadius:
                          BorderRadius
                              .circular(
                              24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(
                                  0.5),
                              blurRadius: 20,
                              offset:
                              const Offset(
                                  0, 10),
                            )
                          ],
                        ),
                        child: _buildContent(
                            isDesktop: true),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }

  Widget _buildContent(
      {required bool isDesktop}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// ===== HEADER =====
        Container(
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(
              vertical: 40),
          decoration: BoxDecoration(
            color: themeController.primaryColor,
            borderRadius: isDesktop
                ? const BorderRadius.only(
              topLeft:
              Radius.circular(
                  24),
              topRight:
              Radius.circular(
                  24),
            )
                : BorderRadius.zero,
          ),
          child: Column(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color:
                      Colors.white24),
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "OTP Verification",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "A 6-digit code has been sent to\n${maskMobileNumber(widget.phone)}\nOTP: ${widget.otp}",
                textAlign:
                TextAlign.center,
                style: const TextStyle(
                  color:
                  Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        /// ===== BODY =====
        Padding(
          padding:
          const EdgeInsets.all(25),
          child: Column(
            children: [
              /// OTP BOXES
              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceAround,
                children:
                List.generate(
                  6,
                      (index) =>
                      _otpBox(index),
                ),
              ),
              SizedBox(
                  height: 5),


              /// ERROR TEXT
              if (_isOtpInvalid)
                const Text(
                  "Please enter valid 6-digit OTP",
                  style: TextStyle(color: Colors.red),
                ),

              const SizedBox(
                  height: 5),

              Visibility(
                  visible: false,

                  child: Text(
                    _secondsRemaining > 0
                        ? "Code expires in 0:${_secondsRemaining.toString().padLeft(2, '0')}"
                        : "",
                    style: TextStyle(
                      color:
                      _secondsRemaining >
                          0
                          ? Colors
                          .white70
                          : Colors
                          .red,
                    ),
                  ))  ,

              SizedBox(
                  height: 5),

              TextButton(
                onPressed: _secondsRemaining == 0
                    ? () async {
                  showLoader(context);

                  final loginVM = context.read<LoginViewModel>();

                  try {
                    await loginVM.authenticateUserOtp(
                      context: context,
                      token: loginVM.loginResponse?.data?.token ?? "",
                      mobileNo: loginVM.loginResponse?.data?.MOBILENO ?? "",
                      userId: loginVM.loginResponse?.data?.userid ?? "",
                      strFlag: "E",
                      strOtp: "",
                    );

                    dismissLoader(context);

                    if (loginVM.status == LoginStatus.success) {
                      if (loginVM.code == "200") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loginVM.message ?? ""),
                            backgroundColor: Colors.green,
                          ),
                        );

                        setState(() {
                          widget.otp=loginVM.otp.toString();
                        });


                      }else
                      {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(loginVM.message ?? ""),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }

                      _startTimer(); // restart timer
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loginVM.error ?? "Something went wrong"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  } finally {
                    dismissLoader(context); // always close loader
                  }
                }
                    : null,
                child: Text(
                  _secondsRemaining == 0
                      ? "Resend OTP"
                      : "Resend in $_secondsRemaining sec",
                  style:  TextStyle(color: Color.lerp(
                    themeController.darkColor,
                    Colors.white,
                    0.7, // 30% lighter
                  )!),
                ),
              ),


              const SizedBox(height: 5),

              /// VERIFY BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeController.primaryColor, // 👈 your color
                    foregroundColor: Colors.white, // text/icon color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final otpValue = otp;

                    if (otpValue.length != 6) {
                      setState(() {
                        _isOtpInvalid = true;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Enter 6-digit OTP"),
                        ),
                      );
                      return;
                    } else {
                      showLoader(context);

                      final loginVM = context.read<LoginViewModel>();

                      try {

                        if(widget.activityName != null  && widget.activityName == "FORGOTPASSWORD")
                        {
                          await loginVM.authenticateUserOtp(
                            context: context,
                            token:  "",
                            mobileNo: widget.phone ?? "",
                            userId: widget.userId ?? "",
                            strFlag: "V",
                            strOtp: otpValue,
                          );
                        }else {
                          await loginVM.authenticateUserOtp(
                            context: context,
                            token: loginVM.loginResponse?.data?.token ?? "",
                            mobileNo: loginVM.loginResponse?.data?.MOBILENO ?? "",
                            userId: loginVM.loginResponse?.data?.userid ?? "",
                            strFlag: "V",
                            strOtp: otpValue,
                          );
                        }
                        if (loginVM.status == LoginStatus.success) {

                          if (loginVM.code == "200") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(loginVM.message ?? ""),
                                backgroundColor: Colors.green,
                              ),
                            );

                            if(widget.activityName != null  && widget.activityName == "FORGOTPASSWORD")
                            {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ChangePasswordScreen(activityName: 'FORGOTPASSWORD', userId: widget.userId,)),
                                    (route) => false,
                              );
                            }else {

                              bool canAuthenticate = await auth.isDeviceSupported() &&
                                  await auth.canCheckBiometrics;

                              if (loginVM.loginResponse!.data!.ISVERIFIED != null &&
                                  loginVM.loginResponse!.data!.ISVERIFIED.toString() == "true" ) {
                                if (!canAuthenticate) {
                                  setState(() {
                                    _isAuthenticating = false;
                                    _authorized = 'Biometric authentication not available.';
                                  });
                                  //return;
                                  //   _nextScrebredirect();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                        const TransactionListScreen()),
                                        (route) => false,
                                  );
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
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                            const TransactionListScreen()),
                                            (route) => false,
                                      );
                                    }
                                  });
                                  //

                                }

                              }
                              else {
                                //  _nextScrebredirect();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const TransactionListScreen()),
                                      (route) => false,
                                );
                              }

                            }
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
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      } finally {
                        dismissLoader(context);
                      }
                    }

                    setState(() {
                      _isOtpInvalid = false;
                    });

                    print("OTP Entered: $otpValue");
                  },
                  child: const Text("Verify & Continue"),
                ),
              ),
              const SizedBox(
                  height: 30),

              /// BIOMETRICS
              Container(
                padding:
                const EdgeInsets
                    .all(18),
                decoration:
                BoxDecoration(
                  color:
                  Colors.white,
                  borderRadius:
                  BorderRadius
                      .circular(
                      18),
                  border: Border.all(
                    color: const Color(
                        0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Or verify with biometrics",
                      style: TextStyle(
                        color: Colors
                            .black,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(
                        height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Container(
                            width: 150, // desired width
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child:
                            _buildBiometricButton(
                              icon: Icons.fingerprint,
                              label: "Fingerprint",
                              //    onTap: authenticate,
                              onTap: () async {
                                final otpValue = otp;

                                if (otpValue.length != 6) {
                                  setState(() {
                                    _isOtpInvalid = true;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Enter 6-digit OTP"),
                                    ),
                                  );
                                  return;
                                } else {
                                  showLoader(context);

                                  final loginVM = context.read<LoginViewModel>();

                                  try {

                                    if(widget.activityName != null  && widget.activityName == "FORGOTPASSWORD")
                                    {
                                      await loginVM.authenticateUserOtp(
                                        context: context,
                                        token:  "",
                                        mobileNo: widget.phone ?? "",
                                        userId: widget.userId ?? "",
                                        strFlag: "V",
                                        strOtp: otpValue,
                                      );
                                    }else {
                                      await loginVM.authenticateUserOtp(
                                        context: context,
                                        token: loginVM.loginResponse?.data?.token ?? "",
                                        mobileNo: loginVM.loginResponse?.data?.MOBILENO ?? "",
                                        userId: loginVM.loginResponse?.data?.userid ?? "",
                                        strFlag: "V",
                                        strOtp: otpValue,
                                      );
                                    }
                                    if (loginVM.status == LoginStatus.success) {

                                      if (loginVM.code == "200") {
                                        /*  ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(loginVM.message ?? ""),
                                            backgroundColor: Colors.green,
                                          ),
                                        );*/

                                        if(widget.activityName != null  && widget.activityName == "FORGOTPASSWORD")
                                        {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    ChangePasswordScreen(activityName: 'FORGOTPASSWORD', userId: widget.userId,)),
                                                (route) => false,
                                          );
                                        }else {

                                          bool canAuthenticate = await auth.isDeviceSupported() &&
                                              await auth.canCheckBiometrics;

                                          if (loginVM.loginResponse!.data!.ISVERIFIED != null &&
                                              loginVM.loginResponse!.data!.ISVERIFIED.toString() == "true" ) {
                                            if (!canAuthenticate) {
                                              setState(() {
                                                _isAuthenticating = false;
                                                _authorized = 'Biometric authentication not available.';
                                              });
                                              //return;
                                              //   _nextScrebredirect();
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                    const TransactionListScreen()),
                                                    (route) => false,
                                              );
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
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                        const TransactionListScreen()),
                                                        (route) => false,
                                                  );
                                                }
                                              });
                                              //

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

                                        }
                                      }else
                                      {
                                        /* ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(loginVM.message ?? ""),
                                            backgroundColor: Colors.red,
                                          ),
                                        );*/
                                      }



                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(loginVM.error ?? "Something went wrong"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  } finally {
                                    dismissLoader(context);
                                  }
                                }

                                setState(() {
                                  _isOtpInvalid = false;
                                });

                                print("OTP Entered: $otpValue");
                              },
                            )),
                        const SizedBox(
                            width: 15),
                        Visibility(
                            visible: false,

                            child: Expanded(
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
                  ],
                ),
              ),

              const SizedBox(
                  height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  LoginScreen(),
                    ),
                  );
                  // Navigate or perform action here
                },
                child:  Text(
                  "← Back to Login",
                  style: TextStyle(
                    color:Color.lerp(
                      themeController.darkColor,
                      Colors.white,
                      0.7, // 30% lighter
                    )!,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  void _clearPreviousOtp(int currentIndex) {
    for (int i = 0; i < currentIndex; i++) {
      _controllers[i].clear();
    }

    // Move focus to first cleared box
    _focusNodes[0].requestFocus();
  }
  Widget _buildFaceIdButton({
    required String assetPath, // path to your image in assets
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
            16),
        border: Border.all(
          color:
          const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment
            .center,
        children: [
          Image.asset(
            assetPath,
            width: 40,
            height: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(
              height: 8),
          Text(
            label,
            style:
            const TextStyle(
              fontSize: 13,
              color:
              Colors.black87,
            ),
          )
        ],
      ),
    );


  }
  /// 🔥 OTP BOX WITH RED HIGHLIGHT
  Widget _otpBox(int index) {
    return SizedBox(
      width: 45,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {

            if (_controllers[index].text.isEmpty && index > 0) {

              // Clear ONLY previous box
              _controllers[index - 1].clear();

              // Move focus to previous box
              _focusNodes[index - 1].requestFocus();

              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isOtpInvalid ? Colors.red : Colors.transparent,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isOtpInvalid ? Colors.red : Colors.blue,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            }

            if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }

            if (_isOtpInvalid) {
              setState(() {
                _isOtpInvalid = false;
              });
            }
          },
        ),
      ),
    );
  }
  void _clearAllOtp() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
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
            borderRadius:
            BorderRadius.circular(
                16),
            border: Border.all(
              color:
              const Color(0xFFE2E8F0),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: Colors.black87),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
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
}