import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../database/app_preferences.dart';
import '../models/ChangePasswordResponseModel.dart';

import '../plantappscreen/app_shell.dart';
import '../provider/themecontroller.dart';
import 'ProfileScreen.dart';
import 'companylist/company_list_screen.dart';
import 'login/login.dart';
import 'login/login_controller.dart';


class ChangePasswordScreen extends StatefulWidget {
  final String activityName;
  final String userId;
   ChangePasswordScreen({super.key, required this.activityName, required this.userId

  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late LoginController loginVM1;

  bool oldPassVisible = false;
  bool newPassVisible = false;
  bool confirmPassVisible = false;
  late ThemeController themeController;

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  ChangePasswordResponseModel? changepasswordresponse;

  @override
  void initState() {
    super.initState();
    loginVM1 = context.read<LoginController>();
  }

  /// Password validation function
  Map<String, bool> validatePassword(String password) {
    return {
      "Minimum 8 characters": password.length >= 8,
      "At least one uppercase letter": password.contains(RegExp(r'[A-Z]')),
      "At least one number": password.contains(RegExp(r'[0-9]')),
      "At least one special character": password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    };
  }


  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    themeController = Provider.of(context, listen: false);

    final passwordValidation = validatePassword(newPasswordController.text);
    return Scaffold(
      backgroundColor: isDesktop
          ? Colors.black // dark app background for Windows/Desktop
          : const Color(0xFFF5F7FB), // light app background for mobile
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {

            bool isDesktop = constraints.maxWidth > 900;

            return Center(
              child: Container(
                width: isDesktop ? 650 : double.infinity,
                height: double.infinity,
                margin: EdgeInsets.symmetric(
                  vertical: isDesktop ? 25 : 0,
                  horizontal: isDesktop ? 20 : 0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF5F7FB), // Screen background
                  borderRadius: BorderRadius.circular(
                      isDesktop ? 25 : 0),
                  boxShadow: isDesktop
                      ? [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ]
                      : [],
                ),
                child:   ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 30 : 18,
                    vertical: 20,
                  ),
                  children: [

                    /// HEADER
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {

              if(widget.activityName != null  && widget.activityName == "FORGOTPASSWORD")
              {

              } else if(widget.activityName != null  && widget.activityName == "COMPANY")
              {
                /*Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionListScreen(),
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
              }else {
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
                          selectedIndex: 4,

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
               /* Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppShell(
                      role: "Admin",
                      plant: plantName,
                      selectedIndex: 4,

                    ),
                  ),
                );*/
              }
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,

                            color: const Color(0xff0F172A),
                          ),
                        ),

                        Expanded(
                          child: Text(
                            "Change Password",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isDesktop ? 22 : 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff0F172A),
                            ),
                          ),
                        ),

                        SizedBox(width: 40),
                      ],
                    ),
            if(widget.activityName != null  && widget.activityName != "FORGOTPASSWORD")...[
                    SizedBox(height: 30),

                    /// CURRENT PASSWORD
                    passwordField(
                      hint: "Current Password",
                      visible: oldPassVisible,
                      onTap: () {
                        setState(() {
                          oldPassVisible = !oldPassVisible;
                        });
                      },
                      controller: oldPasswordController,
                    ),
],
                    SizedBox(height: 18),

                    /// NEW PASSWORD
                    passwordField(
                      hint: "New Password",
                      visible: newPassVisible,
                      onTap: () {
                        setState(() {
                          newPassVisible = !newPassVisible;
                        });
                      },
                      controller: newPasswordController,
                    ),

                    SizedBox(height: 18),

                    /// CONFIRM PASSWORD
                    passwordField(
                      hint: "Confirm New Password",
                      visible: confirmPassVisible,
                      onTap: () {
                        setState(() {
                          confirmPassVisible = !confirmPassVisible;
                        });
                      },
                      controller: confirmPasswordController,
                    ),

                    SizedBox(height: 15),

                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Password Requirements",
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 18),

                          requirementItem(
                            "Minimum 8 characters",
                            passwordValidation["Minimum 8 characters"]!,
                          ),

                          requirementItem(
                            "At least one uppercase letter",
                            passwordValidation["At least one uppercase letter"]!,
                          ),

                          requirementItem(
                            "At least one number",
                            passwordValidation["At least one number"]!,
                          ),

                          requirementItem(
                            "At least one special character",
                            passwordValidation["At least one special character"]!,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 15),

                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeController.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {

                          String oldPass = oldPasswordController.text;
                          String newPass = newPasswordController.text;
                          String confirmPass = confirmPasswordController.text;

                          final validation = validatePassword(newPass);

                          if (oldPass.isEmpty && widget.activityName != null  && widget.activityName != "FORGOTPASSWORD") {
                            _showMsg("Enter Current Password", Colors.red);
                          } else if (newPass.isEmpty) {
                            _showMsg("Enter New Password", Colors.red);
                          } else if (confirmPass.isEmpty) {
                            _showMsg("Re-Enter New Password", Colors.red);
                          } else if (newPass != confirmPass) {
                            _showMsg("Passwords do not match", Colors.red);
                          } else if (!validation.values.every((v) => v)) {
                            _showMsg(
                              "Password does not meet all requirements",
                              Colors.red,
                            );
                          } else {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            String? stringValuebaseTOKEN = prefs.getString('TOKEN');
                            String? stringValuebaseUserId = prefs.getString('USERID');

                              final response;
                            showLoader(context);
            if(widget.activityName != null  && widget.activityName == "FORGOTPASSWORD")
            {
               response =
              await loginVM1.ChanagePasswordapicall(
                oldPass,
                newPass,
                confirmPass,
                "",
                widget.userId,
                  "FORGOTPASSWORD"
              );
            }else {
               response =
              await loginVM1.ChanagePasswordapicall(
                oldPass,
                newPass,
                confirmPass,
                stringValuebaseTOKEN!,
                stringValuebaseUserId!,
                  "CHANGEPASSWORD"
              );
            }
                            dismissLoader(context);

                            if (response.successData != null) {

                              _showMsg(
                                response.successData!.errorMsg ??
                                    "Password updated successfully",
                                Colors.green,
                              );
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
                                ),
                                    (route) => false,
                              );
                             /* Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(),
                                ),
                                    (route) => false,
                              );*/
                            } else if (response.failureData != null) {
                              _showMsg(
                                response.failureData!.message ??
                                    "Something went wrong",
                                Colors.red,
                              );
                            } else {
                              _showMsg(
                                response.error ??
                                    "Unknown error occurred",
                                Colors.red,
                              );
                            }
                          }
                        },
                        child: Text(
                          "Update Password",
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 25),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

  }

  Widget passwordField({
    required String hint,
    required bool visible,
    required VoidCallback onTap,
    required TextEditingController controller,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xffE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: !visible,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: const Icon(
            Icons.lock_outline,
            color: Color(0xff64748B),
          ),
          hintText: hint,
          suffixIcon: IconButton(
            icon: Icon(
              visible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: onTap,
          ),
        ),
      ),
    );
  }

  Widget requirementItem(String text, bool isValid) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 11,
          ),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(

              color: isValid ? Colors.green : const Color(0xff475569),
            ),
          ),
        ],
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
  void _showMsg(String msg,Color bgColo) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:

    Text(msg),
          backgroundColor: bgColo,
        ));
  }
}