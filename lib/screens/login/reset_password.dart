
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/ApiProvider.dart';
import 'login.dart';
import 'login_viewmodel.dart';
import 'otp_verification.dart';


class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  String selectedType = "SMS";
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendResetOTP() async {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter email id"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      var response = await ApiProvider().forgotpassword(
        context,
        "I",
        emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.sYSMSGS!.eRRORMSGS! ?? "Reset OTP sent successfully",
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020817),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 900;

            Widget content = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 25,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F4D5A),
                    borderRadius: isDesktop
                        ? const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    )
                        : BorderRadius.zero,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "← Back to Login",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Reset Password",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Enter your registered email to receive a reset OTP.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                /// BODY
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "EMAIL",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),

                      /// INPUT FIELD
                      TextField(
                        controller: emailController,
                        style: const TextStyle(
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Enter Email Id",
                          hintStyle: const TextStyle(
                            color: Color(0xFF6B7280),
                          ),
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "SEND RESET VIA",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: optionButton(
                              icon: Icons.sms_outlined,
                              label: "SMS OTP",
                              selected: selectedType == "SMS",
                              onTap: () async{
                                setState(() {
                                  selectedType = "SMS";
                                });

                                print("SMS selected");
                                final loginVM = context.read<LoginViewModel>();

                                String emailid = emailController.text;
                                if (emailid.isEmpty) {
                                  _showMsg("Enter Email Id", Colors.red);
                                }else
                                  {
                                    var response=    await ApiProvider().forgotpassword(
                                      context,
                                      "I", // "SMS" or "EMAIL"
                                      emailController.text.trim(),
                                    );

                                    if (response.sYSMSGS?.iD != "-1") {
                                      await loginVM.authenticateUserOtp(context: context, token: "", mobileNo: response.sYSMSGS!.mOBILENO.toString(), userId: response.sYSMSGS!.iD.toString(), strFlag: 'I', strOtp: "");
                                      if (loginVM.status == LoginStatus.success) {


                                          if (loginVM.code == "200") {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(loginVM.message ?? ""),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => OtpVerificationScreen(phone: response.sYSMSGS!.mOBILENO.toString(),activityName: 'FORGOTPASSWORD', otp:loginVM.otp.toString(), userId: response.sYSMSGS!.iD.toString(),),
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

                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(loginVM.error ?? ""),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } else {
                                      _showMsg(response.sYSMSGS?.eRRORMSGS ?? "", Colors.red);
                                    }
                                  }
                              },
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: optionButton(
                              icon: Icons.email_outlined,
                              label: "Email Link",
                              selected: selectedType == "EMAIL",
                              onTap: () async{
                                setState(() {
                                  selectedType = "EMAIL";
                                });

                                print("Email selected");

                                final loginVM = context.read<LoginViewModel>();

                                String emailid = emailController.text;
                                if (emailid.isEmpty) {
                                  _showMsg("Enter Email Id", Colors.red);
                                }else
                                {
                                  var response=    await ApiProvider().forgotpassword(
                                    context,
                                    "I", // "SMS" or "EMAIL"
                                    emailController.text.trim(),
                                  );

                                  if (response.sYSMSGS?.iD != "-1") {
                                    _showMsg(response.sYSMSGS?.eRRORMSGS ?? "Something went wrong", Colors.green);

                                  } else {
                                    _showMsg(response.sYSMSGS?.eRRORMSGS ?? "Something went wrong", Colors.red);
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      /// BUTTON
                  /*    SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF1F3B64),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                            await sendResetOTP();
                          },
                          child: isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            "Send Reset OTP",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),*/

                      const SizedBox(height: 25),

                      const Center(
                        child: Text(
                          "Need help? Contact IT Admin",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Center(
                        child: Text(
                          "support@cloud9ebiz.com",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );

            if (!isDesktop) {
              return SingleChildScrollView(
                child: content,
              );
            }

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 480,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1220),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.black.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: content,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  void _showMsg(String msg,Color bgColo) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:

        Text(msg),
          backgroundColor: bgColo,
        ));
  }
  Widget optionButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1F3B64)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF1F3B64)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.white
                  : const Color(0xFF1F3B64),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: selected
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}