import 'dart:convert';
import 'dart:io';
import 'dart:io';

import 'package:erpflutter/helpers/api_request.dart';

import 'package:erpflutter/services/ApiProvider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:intl/intl.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;



import '../../models/auth_user_otp_response_model.dart';
import '../../models/login_response_model.dart';

import '../../models/service_engineer_regsiter_response_model.dart';
import '../../provider/themecontroller.dart';
import '../../utils/SizeConfig.dart';
import '../ProfileScreen.dart';
import '../login/login.dart';




class RegisterFingerprint extends StatefulWidget {
  String? strUsername;
  String? strMobileno;
 // LoginResponseModel? loginResponseModel;
  RegisterFingerprint({required this.strUsername,required this.strMobileno}) {
    // TODO: implement LoginUI
  }

  @override
  _RegisterFingerprint createState() => _RegisterFingerprint(strUsername,strMobileno);
}

class _RegisterFingerprint extends State<RegisterFingerprint> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = 'false';
  TextEditingController mobilenoController = TextEditingController();
  TextEditingController authUserIdController = TextEditingController();
  TextEditingController authUserpwdController = TextEditingController();
  TextEditingController authUserOtpController = TextEditingController();
  TextEditingController authmobilenoController = TextEditingController();
  bool _isAuthorizedUserFieldsVisible = false; // Control visibility
  SizeConfig sizeConfig = SizeConfig();
  MediaQueryData? _mediaQueryData;
  double? screenWidth;
  double? screenHeight;
  double? blockSizeHorizontal;
  bool? isConnectivity = false;
  XFile? _image;
  XFile? _image1;
  bool isSelected = false;
  ImagePicker _picker = ImagePicker();
  final ImagePicker _picker1 = ImagePicker();
  String? strUsername;
  String? strMobileno;
  bool _isFetching = false; // To track ongoing fetch operation
  // List<LoginModel> users = [];
  bool isLoading = false;
  var showpassword = false;

  //final ApiService apiService = ApiService();
  String base64Image1 = '',
      base64Image2 = '';
  bool _isPickingImage = false;
  bool _obscureText = true;
  String _biometricsStatus = '';
  String _status = '';
  File? _imageFile;
  final ApiProvider _repo = ApiProvider();
  late ThemeController themeController;

  // UserAuthOTPResponseModel? _fetchotp;
  // ServiceEngineerRegisterResponseModel? _response;
  _RegisterFingerprint(this.strUsername, this.strMobileno);

  List<LoginModel> users = [];
  UserAuthOTPResponseModel? _fetchotp;
  ServiceEngineerRegisterResponseModel? _response;


  Future<void> _checkBiometricTypes() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

      setState(() {
        if (canCheckBiometrics) {
          _status = availableBiometrics.isNotEmpty
              ? 'Biometric types available: ${availableBiometrics.join(', ')}'
              : 'No biometrics available';
        } else {
          _status = 'Biometrics not available';
        }
      });

      print(availableBiometrics.length);
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
      print('Error checking biometrics: $e');
    }
  }

  Future<void> _openCamera1() async {
    final XFile? image = await _picker1.pickImage(source: ImageSource.camera);
    print('@@@@@@@@@$image');

    if (image != null) {
      setState(() {
        _image1 = image;
      });
      print('@@@@@@@$_image1!.path!');
      print('@@@@@@@@@$_image1!.name!');
      base64Image2 = await _convertImageToBase64(image.path);
      print(base64Image2);
    }
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      print("Camera permission denied");
    }
  }

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    print('@@@@@@@@@$image');

    if (image != null) {
      setState(() {
        _image = image;
      });
      print('@@@@@@@$_image!.path!');
      print('@@@@@@@@@$_image!.name!');
      base64Image1 = await _convertImageToBase64(image.path);
      print(base64Image1);
    }
  }

  Future<String> _convertImageToBase64(String imagePath) async {
    // Read the image file
    final File imageFile = File(imagePath);
    // Read the bytes
    final List<int> imageBytes = await imageFile.readAsBytes();
    // Convert bytes to Base64 string
    final String base64String = base64Encode(imageBytes);
    return base64String;
  }

  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _checkBiometrics();
    _checkBiometricTypes();
    authmobilenoController.text = strMobileno!;
    authUserIdController.text = strUsername!;
  }

  static const platform = MethodChannel('com.cloud9.plantapp/settings');

  void toggleButton() {
    setState(() {
      isSelected = !isSelected;
    });
  }

  Future<void> _openBiometricSettings() async {
    try {
      await platform.invokeMethod('openBiometricSettings');
    } on PlatformException catch (e) {
      print("Failed to open biometric settings: '${e.message}'.");
    }
  }

  Future<void> _checkBiometrics() async {
    final canCheckBiometrics = await auth.canCheckBiometrics;
    final availableBiometrics = await auth.getAvailableBiometrics();

    setState(() {
      _authorized = canCheckBiometrics
          ? 'Can check biometrics: $availableBiometrics'
          : 'Biometrics not available';
    });
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


  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
     themeController = Provider.of(context, listen: false);

    List<BiometricType> availableBiometrics;
    SizeConfig().init(context);
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = (screenWidth! / 100);
    var blockSizeVertical = (screenHeight! / 100);
    double screenfontWidth = MediaQuery
        .of(context)
        .size
        .width;

    return PopScope(
      canPop: true, //When false, blocks the current route from being popped.
      onPopInvoked: (didPop) {

      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,

        appBar:PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Center(
                child: SizedBox(
                    width: isDesktop ? 700 : double.infinity,
                    child: AppBar(
          backgroundColor: themeController.primaryColor,
          foregroundColor: Colors.white,
          title: Text('Fingerprint Register',
              style: TextStyle(color: Colors.white)),
          actions: [
          ],
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(),
                ),
              );
            },
          ),
        )))),
        body: Center(
                child:Container(
                    height: MediaQuery.of(context).size.height,
                    color:const Color(0xFFF5F7FB),
                    width: isDesktop ? 700 : double.infinity,
                    padding: const EdgeInsets.all(10),
                    child:SingleChildScrollView(
                        child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),


                    Container(
                      width: Platform.isWindows
                          ? MediaQuery
                          .of(context)
                          .size
                          .width * 0.4 // 60% width for desktop
                          : MediaQuery
                          .of(context)
                          .size
                          .width * 0.95, // 95% width for mobile
                      height: SizeConfig.safeBlockVertical! * 12,
                      child: Container(
                        margin: EdgeInsets.all(20),
                        child: ElevatedButton(
                          child:Text(
                            "Add Fingerprint",
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style:

                          ElevatedButton
                              .styleFrom(

                            backgroundColor:themeController.primaryColor,


                            minimumSize:
                            const Size
                                .fromHeight(
                              48,
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
                            if (Platform.isAndroid) {
                              _openBiometricSettings();
                            }
                          },
                        ),
                      ),
                    ),


                    // Service Engineer Section
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text("Workman Photo",),
                                Spacer(),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundImage: _image != null
                                          ? FileImage(File(_image!.path))
                                          : AssetImage("assets/user.png") as ImageProvider,
                                    ),
                                    Positioned(
                                      bottom: 4,
                                      right: 4,
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          iconSize: 35,
                                          icon: Icon(Icons.camera_alt),
                                          onPressed: () {
                                            // Open camera or image picker
                                            if (Platform.isAndroid) {
                                              requestCameraPermission();
                                              _openCamera();
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 30),

                            TextField(
                              maxLength: 10,
                              keyboardType: TextInputType.number,
                              controller: mobilenoController,
                              decoration: InputDecoration(
                                labelText: 'Mobile Number',
                                counterText: '',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: themeController.primaryColor, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color:themeController.primaryColor, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            Row(
                              children: [
                                Text("Authorized User Photo",),
                                Spacer(),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundImage: _image1 != null
                                          ? FileImage(File(_image1!.path))
                                          : AssetImage("assets/user.png") as ImageProvider,
                                    ),
                                    Positioned(
                                      bottom: 4,
                                      right: 4,
                                      child: Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          iconSize: 35,
                                          icon: Icon(Icons.camera_alt),
                                          onPressed: () {
                                            // Open camera or image picker
                                            if (Platform.isAndroid) {
                                              requestCameraPermission();
                                              _openCamera1();
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),


                            Divider(),

                            TextField(

                              keyboardType: TextInputType.text,
                              controller: authUserIdController,
                              decoration: InputDecoration(
                                labelText: 'Authorized User Id',
                                counterText: '',
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: themeController.primaryColor, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),


                            TextField(
                              controller: authUserpwdController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                labelText: 'Authorized User Password',
                                border: OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            if (!_isAuthorizedUserFieldsVisible) ...[
                              Container(
                                width: Platform.isWindows
                                    ? MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.4 // 60% width for desktop
                                    : MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.95, // 95% width for mobile
                                height: SizeConfig.safeBlockVertical! * 12,
                                child: Container(
                                  margin: EdgeInsets.all(20),
                                  child: ElevatedButton(
                                      child: Text(
                                        "Sent OTP",
                                        style: TextStyle(
                                          fontSize: isDesktop ? 16 : 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style:  ElevatedButton
                                          .styleFrom(

                                        backgroundColor:themeController.primaryColor,

                                        minimumSize:
                                        const Size
                                            .fromHeight(
                                          48,
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
                                        if (authUserIdController.text.isEmpty) {
                                          _showMsg("Please Enter user id", Colors.red);
                                        /*  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Text("Please Enter user id"),
                                          ));*/
                                        } else if (authUserpwdController.text.isEmpty) {
                                          _showMsg("Please Enter Password", Colors.red);
                                        /*  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            content: Text("Please Enter Password"),
                                          ));*/
                                        } else {
                                          fetchLoginDetails(
                                              authUserIdController.text,
                                              authUserpwdController.text, "I", "");
                                        }
                                      }
                                  ),
                                ),
                              ),

                            ],
                            if (_isAuthorizedUserFieldsVisible) ...[
                              Container(
                                width: Platform.isWindows
                                    ? MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.4 // 60% width for desktop
                                    : MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.95, // 95% width for mobile
                                height: SizeConfig.safeBlockVertical! * 12,
                                child: Container(
                                  margin: EdgeInsets.all(20),
                                  child: ElevatedButton(
                                    child:Text(
    "Resend OTP",
    style: TextStyle(
    fontSize: isDesktop ? 16 : 14,
    color: Colors.white,
    fontWeight: FontWeight.w600,
    ),
    ),
                                    style:
                                    ElevatedButton
                                        .styleFrom(


    backgroundColor: isSelected ? Colors.grey : themeController.primaryColor,

                                      minimumSize:
                                      const Size
                                          .fromHeight(
                                        48,
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

                                      if (authUserIdController.text.isEmpty) {
                                        _showMsg("Please Enter user id", Colors.red);
                                     /*   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text("Please Enter user id"),
                                        ));*/
                                      } else if (authUserpwdController.text.isEmpty) {
                                       /* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text("Please Enter Password"),
                                        ));*/
                                        _showMsg("Please Enter Password", Colors.red);

                                      } else {
                                        fetchLoginDetails(
                                            authUserIdController.text, authUserpwdController.text,
                                            "E", "");
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Text(
                                'OTP wil be recived on below Mobile number',
                                style: TextStyle(fontWeight: FontWeight.bold),


                              ),
                              TextField(
                                controller: authmobilenoController,
                              ),
                              SizedBox(height: 15),
                              TextField(
                                maxLength: 10,
                                keyboardType: TextInputType.number,
                                controller: authUserOtpController,
                                decoration: InputDecoration(
                                  labelText: 'OTP',
                                  counterText: '',
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: themeController.primaryColor, width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: themeController.primaryColor, width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),

                              Container(
                                width: Platform.isWindows
                                    ? MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.4 // 60% width for desktop
                                    : MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.95, // 95% width for mobile
                                height: SizeConfig.safeBlockVertical! * 12,
                                child: Container(
                                  margin: EdgeInsets.all(20),
                                  child: ElevatedButton(
                                    child:Text("Verify OTP",
    style: TextStyle(
    fontSize: isDesktop ? 16 : 14,
    color: Colors.white,
    fontWeight: FontWeight.w600,
    ),
    ),


                                    style:  ElevatedButton
                                        .styleFrom(

                                      backgroundColor: isSelected ? Colors.grey : themeController.primaryColor,

                                      minimumSize:
                                      const Size
                                          .fromHeight(
                                        48,
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
                                      if (authUserOtpController.text.isEmpty) {
                                       /* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text("Please Enter OTP"),
                                        ));*/
                                        _showMsg("Please Enter OTP", Colors.red);
                                      } else {
                                        fetchLoginDetails(authUserIdController.text,
                                            authUserpwdController.text, "V",
                                            authUserOtpController.text);
                                      }
                                    },
                                  ),
                                ),
                              ),

                            ],


                          ],
                        ),
                      ),
                    ),

                    Container(
                      width: Platform.isWindows
                          ? MediaQuery
                          .of(context)
                          .size
                          .width * 0.4 // 60% width for desktop
                          : MediaQuery
                          .of(context)
                          .size
                          .width * 0.95, // 95% width for mobile
                      height: SizeConfig.safeBlockVertical! * 12,
                      child: Container(
                        margin: EdgeInsets.all(20),
                        child: ElevatedButton(
                          child: Text(
                            "Submit",
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style:  ElevatedButton
                              .styleFrom(

                            backgroundColor: isSelected ? themeController.primaryColor : Colors
                                .grey,

                            minimumSize:
                            const Size
                                .fromHeight(
                              48,
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
                            if (isSelected) {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String? stringValuebaseUSERID = prefs.getString('USERID');
                              String? stringValuebaseFCMKey = prefs.getString('FCMTOKEN');
                              bool canCheckBiometrics = await auth.canCheckBiometrics;
                              availableBiometrics = await auth.getAvailableBiometrics();

                              setState(() {
                                if (canCheckBiometrics) {
                                  _status = availableBiometrics.isNotEmpty
                                      ? 'Biometric types available: ${availableBiometrics.join(
                                      ', ')}'
                                      : 'No biometrics available';

                                  return;
                                } else {
                                  _status = 'Biometrics not available';
                                /*  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(_status),));*/
                                  _showMsg(_status, Colors.red);
                                  return;
                                }
                              });

                              if (base64Image1 != null && base64Image1 == "") {
                                _showMsg("Please Capture Workman photo", Colors.red);

                                return;
                              }
                              if (mobilenoController.text.isEmpty) {


                                _showMsg("Please Enter Mobile no", Colors.red);
                                return;
                              }

                              if (base64Image2 != null && base64Image2 == "") {
                                _showMsg("Please Capture Authorized User photo", Colors.red);

                                return;
                              }
                              print(availableBiometrics.length);

                              AlertDialog alert = AlertDialog(
                                content: Row(children: [
                                  CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(left: 7),
                                      child: Text("Loading...")),
                                ]),
                              );

                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                },
                              );

                              ServiceEngineerRegisterResponseModel? response = await _repo
                                  .registerServiceEngineer(
                                  context, mobilenoController.text, base64Image1,
                                  base64Image2, stringValuebaseUSERID.toString(),
                                  _fetchotp!.eRRORMSG!.lOGINID!.toString());

                              setState(() {
                                if (_response != null)
                                  _response = response;
                              });
                              // Get the message from the first response

                              if (response != null) {
                                Navigator.pop(
                                    context);
                                if (response.uSERID == -1) {

                                  _showMsg('${response.mESSAGE}', Colors.red);
                                 /* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('${response.mESSAGE}'),
                                  ));*/
                                } else {
                                  storeTextFileInSDCard(_fetchotp!.eRRORMSG!.iD!.toString(),
                                      stringValuebaseUSERID.toString(),
                                      stringValuebaseFCMKey.toString());
                                  _showMsg('${response.mESSAGE}', Colors.green);
                                 /* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('${response.mESSAGE}'),
                                  ));*/
                                  // Clear Shared Preferences
                                  /*  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.clear();*/
                                  // Replace with your actual login page navigation logic
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()),
                                  );
                                  await Future.delayed(Duration(seconds: 1)); // Wait for 1 second
                                  // Redirect to login page
                                }
                              }
                              // _authenticate();
                            }

                            ///  }


                          },
                        ),
                      ),
                    ),

                  ],
                )))),
      ),
    );
  }


  Future<void> _authenticate() async {
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access this feature',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print(e);
    }

    setState(() {
      _authorized = authenticated ? 'true' : 'false';
    });
  }

  Future<void> fetchLoginDetails(String username, String password, String strFlag,
      String strOtp) async {
    setState(() {
      _isFetching = true; // Start fetching
    });

    try {
      List<LoginModel> fetchedUsers = await _repo.getFingerprintLoginDetails(
          username, password);

      if (!mounted) return; // Check if the widget is still mounted

      setState(() {
        users = fetchedUsers;
        _isFetching = false; // End fetching
      });

      // Your existing logic to handle fetched users
      if (users.isNotEmpty) {
        if (users[0].uSERID == -1) {
          _showMsg(users[0].mESSAGE.toString(), Colors.red);
        /*  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(users[0].mESSAGE.toString()),
          ));*/
        } else {
          UserAuthOTPResponseModel fetchotp = await _repo.authenticateUserBiometry(
              context, users[0].mOBILENO.toString(), users[0].uSERID.toString(), strFlag, strOtp);


          setState(() {
            _fetchotp = fetchotp;
            if (fetchotp.eRRORMSG!.iD.toString() == "-1") {

              _showMsg(fetchotp.eRRORMSG!.mSG.toString(), Colors.red);
            /*  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(fetchotp.eRRORMSG!.mSG.toString()),
              ));*/
            } else {
              if (strFlag != null && strFlag == "I") {
                setState(() {
                  _isAuthorizedUserFieldsVisible =
                  !_isAuthorizedUserFieldsVisible; // Toggle visibility

                });
              }
              if (strFlag != null && strFlag == "V") {
                toggleButton();
              }
              _showMsg(fetchotp.eRRORMSG!.mSG.toString(), Colors.green);

            /*  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(fetchotp.eRRORMSG!.mSG.toString()),
              ));*/
            }
          });
        }
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false; // Ensure we stop fetching in case of error
        });
      }
    }
  }


  Future<void> storeTextFileInSDCard(String userid, String strUSERLOGINID, String fcmkey) async {
    String textfiledata = strUSERLOGINID + "LOGINID" + userid + "USERID" + fcmkey;

    try {
      // Handle permission based on Android version
      if (Platform.isAndroid) {
        if (await _requestStoragePermission()) {
          Directory? baseDir = await getExternalStorageDirectory(); // App-specific folder
          if (baseDir == null) {
            print("❌ Could not get external storage directory");
            return;
          }

          Directory folder = Directory("/storage/emulated/0/Download/ERPTEXTFILE");
          if (!(await folder.exists())) {
            await folder.create(recursive: true);
          }

          File file = File("${folder.path}/FCMDetail.txt");
          if (await file.exists()) {
            await file.delete();
          }

          await file.writeAsString(textfiledata);
          print("✅ File saved at: ${file.path}");
        } else {
          print("❌ Storage permission denied");
        }
      }
    } catch (e) {
      print("❌ Error writing file: $e");
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
  void _showMsg(String msg,Color bgColo) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:

        Text(msg),
          backgroundColor: bgColo,
        ));
  }
}