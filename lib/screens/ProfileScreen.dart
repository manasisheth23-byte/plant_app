

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_colors.dart';
import '../app_config.dart';

import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:io';
import '../database/app_preferences.dart';
import '../database/secure_storage_service.dart';
import '../models/LoginResponseModel.dart';
import '../models/auth_user_otp_response_model.dart';

import '../models/login_response_model.dart';
import '../plantappscreen/app_shell.dart';
import '../provider/financialyear_provider.dart';
import '../provider/themecontroller.dart';
import '../repository/ConfigService.dart';
import '../services/ApiProvider.dart';
import 'ChangePasswordScreen.dart';
import 'colorScreen.dart';
import 'fingerprintregister/fingerprint_register_screen.dart';
import 'login/login.dart';




class ProfileScreen extends StatefulWidget {

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  LoginResponseModel? user;
  List<LoginModel> users = [];
  String? userName,date,positiondesc;
  late ThemeController themeController;
  String? imageUrl;
  Uint8List? _image;
  File? selectedImage;
  String profile = '';
  ApiProvider _repo = ApiProvider();
  late FinancialYearProvider provider;
  bool isLoading = false;
  bool  _isFetching  = false;
  LoginResponseModel? loginResponseModel;

  @override
  void initState() {
    super.initState();
    _loadUser();
     provider = context.read<FinancialYearProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinancialYearProvider>().loadTransactions();
    });
    getData();
  }
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    if (!mounted) return;




    setState(() {
      selectedImage = File(pickedFile.path);

    });
    await _uploadImage(selectedImage!);
  }
  void getData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs = await SharedPreferences.getInstance();
    setState(() {
      loginResponseModel = LoginResponseModel.fromJson(
          jsonDecode(prefs.getString('LOGINRESPONSE') ?? ''))!;
    });

  }
  Widget _buildProfileImage() {
    if (selectedImage != null) {
      return Image.file(
        selectedImage!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }

    if (imageUrl == null ||
        imageUrl!.isEmpty ||
        imageUrl!.toLowerCase() == "null") {
      return Image.asset(
        "assets/user.png",
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      imageUrl!,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        "assets/user.png",
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      ),
    );
  }
  /*Widget _buildProfileImage() {
    if (selectedImage != null) {
      return Image.file(
        selectedImage!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        gaplessPlayback: true, // 🔥 IMPORTANT FIX
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        gaplessPlayback: true, // 🔥 prevents blank flicker
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            "assets/user.png",
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          );
        },
      );
    }

    return Image.asset(
      "assets/user.png",
      width: 120,
      height: 120,
      fit: BoxFit.cover,
    );
  }*/

  Future<void> _uploadImage(File image) async {

    final uri =
    Uri.parse('${ConfigService.baseUrl}Authentication/EditProfileImage');
    final request = http.MultipartRequest('POST', uri);
    request.headers['X-Auth-Token'] = user!.data!.token!;

    request.fields['FILENAME'] = 'dummy_image';
    request.fields['FILEEXT'] = 'jpg';
    request.fields['IMG'] = image.path;
    print("===== MULTIPART REQUEST =====");

    print("URL: $uri");

    print("=== HEADERS ===");
    print(request.headers);

    print("=== FIELDS ===");
    request.fields.forEach((k, v) => print("$k : $v"));

    print("=== FILES ===");
    for (var file in request.files) {
      print("field: ${file.field}");
      print("filename: ${file.filename}");
      print("length: ${file.length}");
    }

    setState(() {
      isLoading = true;
    });

    final response = await request.send();
    print(response);
    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      print('Uploaded successfully!');
    } else {
      print('Upload failed with status code: ${response.statusCode}');
    }
  }
  Future<bool> _showExitDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit App"),
        content: const Text(
          "Are you sure you want to exit the application?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Button background color
              foregroundColor: Colors.white, // Text color
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    ) ??
        false;
  }
  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 900;
    provider = context.read<FinancialYearProvider>();

    themeController = Provider.of<ThemeController>(context, listen: false);
    final width = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await _showExitDialog();

        if (shouldExit) {
          exit(0); // import 'dart:io';
        }
      },
      child: Scaffold(
      //  backgroundColor: const Color(0xffF5F7FB),
        backgroundColor: isDesktop
            ? Colors.white // dark app background for Windows/Desktop
            : const Color(0xFFF5F7FB), // light app background for mobile
          body: LayoutBuilder(
            builder: (context, constraints) {

              bool isDesktop = constraints.maxWidth > 900;

              return Center(
                child: ConstrainedBox(

                  constraints: BoxConstraints(

                    maxWidth: isDesktop ? 700 : double.infinity,
                  ),
                  child: Column(
                    children: [

                      /// HEADER
                     Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: isDesktop ? 40 : 15,
                          bottom: 28,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              themeController.darkColor,
                              themeController.primaryColor,
                            ],
                          ),
                        ),

                        child: Column(
                          children: [

                            /// APPBAR
                          /*  Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [

                                  InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppShell(role: "Admin", plant: '')));

                                    },
                                    child: const Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const Expanded(
                                    child: Center(
                                      child: Text(
                                        "Profile",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),


                                ],
                              ),
                            ),

                            const SizedBox(height: 20),*/

                            /// PROFILE IMAGE
                            InkWell(
                              onTap:  () {
                                //   _pickImageFromGallery();
                              },
                              child: CircleAvatar(
                                radius: isDesktop ? 60 : 50,
                                backgroundColor: Colors.grey.shade200,
                                child: ClipOval(
                                  child: _buildProfileImage(),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            /// NAME
                            Text(
                              userName ?? "",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isDesktop ? 24 : 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            /// ROLE
                            Text(
                              loginResponseModel?.data?.usertype ?? '',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isDesktop ? 14 : 12,
                              ),
                            ),
                            const SizedBox(height: 4),

                            /// ROLE
                            Text(
                              loginResponseModel?.data?.email ?? '',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isDesktop ? 14 : 12,
                              ),
                            ),
                            const SizedBox(height: 4),

                            /// ROLE
                            Text(
                              provider.selectedYear?.description.toString() ?? "",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isDesktop ? 14 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                    //  const SizedBox(height: 20),

                      /// MENU
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 0 : 0,
                            vertical: isDesktop ? 0 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FB), // Screen background
                            borderRadius: BorderRadius.circular(
                              isDesktop ? 0 : 0,
                            ),
                            boxShadow: isDesktop
                                ? [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ]
                                : [],
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 25),
                            child: Column(
                              children: [

                                profileTile(
                                  icon: Icons.lock_outline,
                                  title: "Change Password",
                                  context: context,
                                ),

                              /*  profileTile(
                                  icon: Icons.dark_mode_outlined,
                                  title: "Theme",
                                  trailing: "Light",
                                  context: context,
                                ),*/
                                profileTile(
                                  icon: Icons.lock_outline,
                                  title: "Register Fingerprint",
                                  context: context,
                                ),
                                profileTile(
                                  icon: Icons.lock_outline,
                                  title: "Financial Year",
                                  context: context,
                                ),
                                const SizedBox(height: 8),

                                Divider(
                                  color: Colors.grey.shade300,
                                ),

                                const SizedBox(height: 8),

                                ListTile(
                                  onTap: () {
                                    showLogoutDialog(context);
                                  },
                                  leading: Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.logout,
                                      color: Colors.red,
                                    ),
                                  ),
                                  title: const Text(
                                    "Logout",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),


      ),
    );
  }
  /// 🔥 LOGOUT CONFIRMATION DIALOG
  void showLogoutDialog(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 420 : double.infinity,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 36,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Logout?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,

                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Are you sure you want to logout from your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setBool("ISLOGGEDIN", true);
                          bool rememberMe = await SecureStorageService.isRememberMe();
                          print(rememberMe);
                          await SecureStorageService.setLoggedIn(false);
                          await SecureStorageService.setIsVerifiedn(false);
                          Navigator.pop(context);
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
                     /*  Navigator.of(context, rootNavigator: true)
                              .pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => LoginScreen()),
                                (route) => false,
                          );*/

                       /*   context
                              .read<HomeDashboardViewModel>()
                              .clearDashboardData();
                          await SecureStorageService.setLoggedIn(false);
                          await SecureStorageService.setIsVerifiedn(false);
                          Navigator.pop(context);
                          Navigator.of(context, rootNavigator: true)
                              .pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => LoginScreen()),
                                (route) => false,
                          );*/
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text("Logout",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget profileTile({
    required IconData icon,
    required String title,
    String? trailing,
    BuildContext? context,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 600;

        return Container(
          margin: EdgeInsets.only(bottom: isDesktop ? 14 : 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: ListTile(
            minVerticalPadding: isDesktop ? 10 : 4,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 20 : 14,
              vertical: isDesktop ? 6 : 2,
            ),

            leading: Container(
              height: isDesktop ? 50 : 40,
              width: isDesktop ? 50 : 40,
              decoration: BoxDecoration(
                color: themeController.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: themeController.primaryColor,
                size: isDesktop ? 24 : 20,
              ),
            ),

            title: Text(
              title,
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                fontWeight: FontWeight.w500,
                color: themeController.darkColor,
              ),
            ),

            trailing: trailing != null
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trailing,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isDesktop ? 14 : 12,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: isDesktop ? 16 : 14,
                  color: Colors.grey.shade500,
                ),
              ],
            )
                : Icon(
              Icons.arrow_forward_ios,
              size: isDesktop ? 16 : 14,
              color: Colors.grey.shade500,
            ),

            onTap: () {
              if (title == "Register Fingerprint") {
                _showCustomDialog(context);
              }else if (title == "Change Password") {

                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 10),
                    reverseTransitionDuration: const Duration(milliseconds: 10),
                    pageBuilder: (_, animation, secondaryAnimation) =>
                        ChangePasswordScreen(activityName: 'PROFILE', userId: '0',),
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
               /* Navigator.push(
                  context!,
                  MaterialPageRoute(
                    builder: (_) =>  ChangePasswordScreen(activityName: 'PROFILE', userId: '0',),
                  ),
                );*/
              } else if (title == "Theme") {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 10),
                    reverseTransitionDuration: const Duration(milliseconds: 10),
                    pageBuilder: (_, animation, secondaryAnimation) =>
                        ColorScreen(),
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
               /* Navigator.push(
                  context!,
                  MaterialPageRoute(
                    builder: (_) => const ColorScreen(),
                  ),
                );*/
              }else if (title == "Financial Year") {

                _showFinancialYearDialog(context, provider);
                setState(() {

                });
              }
            },
          ),
        );
      },
    );
  }

  Future<void> _loadUser() async {
    userName = await AppPreferences.getUserName();
    positiondesc = await AppPreferences.getpositionDesce();
    user = await SecureStorageService.getUser();

    final imgDesc = user?.data?.imgdesc;

    if (imgDesc != null && imgDesc.isNotEmpty) {
      imageUrl = "${ConfigService.getBaseOnlyUrl()}/$imgDesc";
    } else {
      imageUrl = "";
    }

    if (mounted) setState(() {});
  }

  void _showCustomDialog(BuildContext outerContext) {
    final TextEditingController loginusernameController = TextEditingController();
    final TextEditingController loginpwdController = TextEditingController();

    showDialog(
      context: outerContext,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              final isDesktop = kIsWeb ||
                  Platform.isWindows ||
                  Platform.isLinux ||
                  Platform.isMacOS;

              final dialogWidth = isDesktop ? screenWidth * 0.5 : screenWidth * 0.9;
              final dialogHeight =
              isDesktop ? screenHeight * 0.5 : screenHeight * 0.9;

              final fieldWidth = dialogWidth * 0.85;
              final buttonWidth = dialogWidth * 0.4;
              final buttonHeight = isDesktop ? dialogHeight * 0.1 : dialogHeight * 0.09;

              // Validation state variables
              bool usernameIsEmpty = false;
              bool passwordIsEmpty = false;

              return StatefulBuilder(
                builder: (context, setState) {
                  bool showPassword = false;

                  return Container(
                    width: dialogWidth,
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Username Field
                          Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5, top: 30),
                            child: SizedBox(
                              width: fieldWidth,
                              child: TextField(
                                textInputAction: TextInputAction.next,
                                controller: loginusernameController,
                                decoration: InputDecoration(
                                  labelText: 'Authorized User Id',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: usernameIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: usernameIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: usernameIsEmpty ? Colors.red : themeController.darkColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Password Field
                          Padding(
                            padding: const EdgeInsets.only(left: 5, top: 25, bottom: 15),
                            child: SizedBox(
                              width: fieldWidth,
                              child: TextField(
                                obscureText: !showPassword,
                                controller: loginpwdController,
                                decoration: InputDecoration(
                                  labelText: 'Authorized User Password',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: passwordIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: passwordIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: passwordIsEmpty ? Colors.red : themeController.darkColor,
                                      width: 2,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Submit Button
                          Container(
                            width: buttonWidth,
                            height: buttonHeight,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ElevatedButton(
                              style:  ElevatedButton
                                  .styleFrom(

                                backgroundColor:themeController.primaryColor,

                                minimumSize:
                                const Size
                                    .fromHeight(
                                  38,
                                ),

                                shape:
                                RoundedRectangleBorder(

                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    12,
                                  ),
                                ),
                              ),

                              onPressed: () async{
                                final username = loginusernameController.text.trim();
                                final password = loginpwdController.text.trim();

                                setState(() {
                                  usernameIsEmpty = username.isEmpty;
                                  passwordIsEmpty = password.isEmpty;
                                });

                                if (usernameIsEmpty || passwordIsEmpty) {
                                  // Don't proceed, fields are invalid
                                  return;
                                }else{
                                  List<LoginModel>? fetchedUsers = await fetchLoginDetails(context,loginusernameController.text,
                                      loginpwdController.text, "I", "");

                                  if(fetchedUsers != null)
                                    if(fetchedUsers[0].uSERID == -1){
                                      _showDialog(context, '', fetchedUsers[0].mESSAGE.toString());
                                    }else{
                                      Navigator.of(dialogContext).pop();
                                      showOTPCustomDialog(context,fetchedUsers![0].mOBILENO!,username,password,fetchedUsers![0].uSERID.toString(),"V");
                                    }

                                }


                                // close dialog if you want


                              },
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
  Future<UserAuthOTPResponseModel?> fetchLoginDetails1(BuildContext context,
      String username, String password, String strFlag, String strOtp,String mobileNo,String userId) async {
    try {

      UserAuthOTPResponseModel userAuthOTPResponseModel = await _repo.authenticateUserBiometry(
          context,
          mobileNo,
          userId,
          strFlag,
          strOtp);

      /*if (users.isNotEmpty) {
        if (users[0].uSERID == -1) {
          // Show dialog using a valid context (e.g., root context or parent context)
          if (mounted) {
            _showDialog(context, '', users[0].mESSAGE.toString());
          }

        } else {
          var fetchotp = await _apiProvider.authenticateUser(
              context,
              users[0].mOBILENO.toString(),
              users[0].uSERID.toString(),
              strFlag,
              strOtp);

          // Ensure context is still valid
          //if (mounted) {

        //  }


          if (fetchotp.eRRORMSG!.iD.toString() == "-1") {
          //  if (mounted) {
              _showDialog(context, '', fetchotp.eRRORMSG!.mSG.toString());
              *//* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(fetchotp.eRRORMSG!.mSG.toString()),
                ));*//*
          //  }
          } else {
            if (strFlag != null && strFlag == "V" && fetchotp.eRRORMSG!.cODE == "200") {
            //  if (mounted) {

                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RegisterFingerprint(
                    strUsername: username,
                    strMobileno: users[0].mOBILENO.toString(),
                  ),
                ));
             // }
            } else {
             // if (mounted) {
                *//* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(fetchotp.eRRORMSG!.mSG.toString()),
                  ));*//*
                _showDialog(context, '', fetchotp.eRRORMSG!.mSG.toString());

            //  }
            }
          }

        }
      }*/
      return userAuthOTPResponseModel;
    } catch (e) {
      print(e);
    } finally {

    }
  }
  void showOTPCustomDialog(BuildContext outerContext, String strMobileno,
      String strUsename, String strPassword,String userId,String flag) {
    final TextEditingController loginusernameController = TextEditingController();
    final TextEditingController loginpwdController = TextEditingController();
    TextEditingController loginotpController = TextEditingController();
    loginusernameController.text = strUsename;
    loginpwdController.text = strPassword;

    showDialog(
      context: outerContext,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              final isDesktop = kIsWeb ||
                  Platform.isWindows ||
                  Platform.isLinux ||
                  Platform.isMacOS;

              final dialogWidth = isDesktop ? screenWidth * 0.5 : screenWidth * 0.9;
              final dialogHeight =
              isDesktop ? screenHeight * 0.5 : screenHeight * 0.9;

              final fieldWidth = dialogWidth * 0.85;
              final buttonWidth = dialogWidth * 0.4;
              final buttonHeight = isDesktop ? dialogHeight * 0.1 : dialogHeight * 0.09;

              // Validation state variables
              bool usernameIsEmpty = false;
              bool passwordIsEmpty = false;
              bool isOtpEmpty = false;
              return StatefulBuilder(
                builder: (context, setState) {
                  bool showPassword = false;

                  return Container(
                    width: dialogWidth,
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Username Field
                          Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5, top: 30),
                            child: SizedBox(
                              width: fieldWidth,
                              child: TextField(
                                textInputAction: TextInputAction.next,
                                controller: loginusernameController,
                                decoration: InputDecoration(
                                  labelText: 'Authorized User Id',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: usernameIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: usernameIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: usernameIsEmpty ? Colors.red : themeController.darkColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Password Field
                          Padding(
                            padding: const EdgeInsets.only(left: 5, top: 25, bottom: 15),
                            child: SizedBox(
                              width: fieldWidth,
                              child: TextField(
                                obscureText: !showPassword,
                                controller: loginpwdController,
                                decoration: InputDecoration(
                                  labelText: 'Authorized User Password',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: passwordIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: passwordIsEmpty ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: passwordIsEmpty ? Colors.red : themeController.darkColor,
                                      width: 2,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showPassword = !showPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Submit Button
                          Container(
                            width: buttonWidth,
                            height: buttonHeight,
                            margin: const EdgeInsets.symmetric(vertical: 7),
                            child: ElevatedButton(
                              style:   ElevatedButton
                                  .styleFrom(

                                backgroundColor:themeController.primaryColor,

                                minimumSize:
                                const Size
                                    .fromHeight(
                                  38,
                                ),

                                shape:
                                RoundedRectangleBorder(

                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    12,
                                  ),
                                ),
                              ),
                              onPressed: () async{
                                final username = loginusernameController.text.trim();
                                final password = loginpwdController.text.trim();

                                setState(() {
                                  usernameIsEmpty = username.isEmpty;
                                  passwordIsEmpty = password.isEmpty;
                                });

                                if (usernameIsEmpty || passwordIsEmpty) {
                                  // Don't proceed, fields are invalid
                                  return;
                                }else
                                {
                                  List<LoginModel>? fetchedUsers= await fetchLoginDetails(context,loginusernameController.text,
                                      loginpwdController.text, "E", "");
                                  if(fetchedUsers != null)
                                    if(fetchedUsers[0].uSERID == -1){
                                      _showDialog(context, '', fetchedUsers[0].mESSAGE.toString());
                                    }
                                }



                              },
                              child: const Text(
                                'Resend OTP',
                                style: TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          // Mobile number display
                          const SizedBox(height: 10),
                          const Text(
                            'Mobile No',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            strMobileno,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),

                          // OTP
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 30, bottom: 0),
                            child: SizedBox(
                              width: fieldWidth,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                controller: loginotpController,
                                textInputAction: TextInputAction.done,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText: 'OTP',
                                  border: const OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: isOtpEmpty ? Colors.red : Colors.black,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: isOtpEmpty ? Colors.red : Colors.black,
                                      width: 2.0,
                                    ),
                                  ),
                                  errorText: isOtpEmpty ? 'Please enter OTP' : null,
                                ),
                              ),
                            ),
                          ),

                          // Verify Button
                          Container(
                            width: buttonWidth,
                            height: buttonHeight,
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            child: ElevatedButton(
                              style:  ElevatedButton
                                  .styleFrom(

                                backgroundColor:themeController.primaryColor,

                                minimumSize:
                                const Size
                                    .fromHeight(
                                  38,
                                ),

                                shape:
                                RoundedRectangleBorder(

                                  borderRadius:
                                  BorderRadius
                                      .circular(
                                    12,
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                setState(() {
                                  isOtpEmpty = loginotpController.text.trim().isEmpty;
                                });

                                if (!isOtpEmpty) {
                                  UserAuthOTPResponseModel? userAuthOTPResponseModel = await fetchLoginDetails1(context,
                                      loginusernameController.text,
                                      loginpwdController.text,
                                      "V",
                                      loginotpController.text,
                                      strMobileno,userId);
                                  if(userAuthOTPResponseModel!.eRRORMSG!.iD == -1){
                                    _showDialog(context, '', userAuthOTPResponseModel.eRRORMSG!.mSG.toString());
                                  }else{
                                    if (flag != null && flag == "V" && userAuthOTPResponseModel.eRRORMSG!.cODE == "200") {
                                      //  if (mounted) {
                                      Navigator.of(dialogContext).pop();
                                     Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => RegisterFingerprint(
                                          strUsername: loginusernameController.text,
                                          strMobileno: strMobileno,
                                        ),
                                      ));
                                    }else{
                                      //Navigator.of(dialogContext).pop();
                                      _showDialog(context, '', userAuthOTPResponseModel.eRRORMSG!.mSG.toString());
                                    }
                                  }
                                  /* showOTPCustomDialog(
                                      context, strMobileno,  loginusernameController.text, loginpwdController.text,userId);*/
                                }
                              },
                              child: const Text(
                                'Verify OTP',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('ok'),
            ),
          ],
        );
      },
    );
  }
  Future<List<LoginModel>?> fetchLoginDetails(
      BuildContext context,
      String username,
      String password,
      String strFlag,
      String strOtp,
      ) async {

    if (mounted) {
      setState(() {
        _isFetching = true; // Declare this at class level
      });
    }

    try {

      // Fetch login details
      List<LoginModel> fetchedUsers =
      await _repo.getFingerprintLoginDetails(username, password);

      if (mounted) {
        setState(() {
          users = fetchedUsers;
        });
      }

      print("Fetched Users Count: ${fetchedUsers.length}");

      if (fetchedUsers.isEmpty) {
        return [];
      }

      final user = fetchedUsers.first;

      print("USERID = ${user.uSERID}");
      print("MOBILE = ${user.mOBILENO}");
      print("MESSAGE = ${user.mESSAGE}");

      // Invalid login
      if (user.uSERID == -1) {
        if (mounted) {
          _showDialog(
            context,
            '',
            user.mESSAGE ?? 'Invalid login',
          );
        }

        return fetchedUsers;
      }

      // Authenticate OTP
      await _repo.authenticateUserBiometry(
        context,
        user.mOBILENO ?? '',
        user.uSERID?.toString() ?? '',
        strFlag,
        strOtp,
      );

      return fetchedUsers;

    } catch (e, stackTrace) {

      print("Error during fetchLoginDetails:");
      print(e);
      print(stackTrace);

      return null;

    } finally {

      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }

    }
  }
  void _showFinancialYearDialog(
      BuildContext context,
      FinancialYearProvider provider,
      ) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : 12,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 420 : double.infinity,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Title
                  const Text(
                    "Select Financial Year",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// 🔹 Divider
                  const Divider(height: 1),
                  const SizedBox(height: 8),

                  /// 🔹 List
                  Expanded(
                    child: ListView.separated(
                      itemCount: provider.years.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final year = provider.years[index];
                        final isSelected =
                            year.controlNo ==
                                provider.selectedYear?.controlNo;

                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          hoverColor:
                          themeController.primaryColor.withOpacity(0.06),
                          onTap: () {

                            provider.changeFinancialYear(year);

                            Navigator.pop(context);
                            setState(() {

                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ?themeController.primaryColor.withOpacity(0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? themeController.primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  size: 20,
                                  color: isSelected
                                      ?themeController.primaryColor
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    year.description ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 🔹 Actions
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CANCEL"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}