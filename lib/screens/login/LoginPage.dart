import 'dart:async';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:erpflutter/Constants.dart';
import 'package:erpflutter/Dashboard.dart';
import 'package:erpflutter/app_colors.dart';
import 'package:erpflutter/database/database_service.dart';
import 'package:erpflutter/main.dart';
import 'package:erpflutter/models/getnotificationmodel.dart';
import 'package:erpflutter/provider/financialyear_provider.dart';
import 'package:erpflutter/provider/get_notification_provider.dart';
import 'package:erpflutter/repository/LoginApiRepository.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/companylist/company_list_screen.dart';
import 'package:erpflutter/screens/ico_image.dart';
import 'package:erpflutter/screens/ico_writer.dart';
import 'package:erpflutter/utils/CommonUtils.dart';
import 'package:erpflutter/utils/SizeConfig.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:windows_taskbar/windows_taskbar.dart';
import '../../app_config.dart';
import '../../barcodescanner/view_models/barcoderegistration_viewmodel.dart';
import '../../helpers/api_request.dart';
import '../../models/CheckDeviceRequestModel.dart';
import '../../models/CheckDeviceResponseModel.dart';
import '../../models/ClientEngagementReqestModel.dart';
import '../../models/ClientEngagementResponseModel.dart';
import '../../models/LoginRequestModel.dart';
import '../../models/LoginResponseModel.dart';
import '../../models/UpdateUserDeviceInfoRequestModel.dart';
import '../../models/UpdateUserDeviceInfoResponseModel.dart';
import '../../models/auth_user_otp_response_model.dart';
import '../../services/ApiProvider.dart';
import '../../utils/loading_dialog.dart';
import 'login_controller.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';


class LoginPage extends StatefulWidget {
  LoginPage() {
    // TODO: implement LoginUI
  }

  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  TextEditingController loginusernameController = TextEditingController();
  TextEditingController loginpwdController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool showOtpField = false;
  LoginResponseModel? response;
  SharedPreferences? prefs;
  SizeConfig sizeConfig = SizeConfig();
  MediaQueryData? _mediaQueryData;
  double? screenWidth;
  double? screenHeight;
  double? blockSizeHorizontal;
  bool? isConnectivity = false;
  String? strSLedger = "01-Jan-1900 00:00:00";
  UpdateUserDeviceInfoResponseModel? updatedeviceinforesponse;
  ClientEngagementResponseModel? clientEngagementResponseModel;
  String _authorized = 'Not Authorized',
      LocalIP = "-";
  bool _isAuthenticating = false;
  bool authenticated = false;
  final LocalAuthentication auth = LocalAuthentication();
  String? strDefaultDate = "01-Jan-1900 00:00:00";
  Timer? timer;
  String? ipv4, strDeviceName;
  String strOldFcmKey = "";
  String firebaseToken = "";
  var showpassword = false;
  UserAuthOTPResponseModel? fetchotp;
  ApiProvider _apiProvider = ApiProvider();
  String buttonText = 'Sign In';
  Color _colorapk = Colors.white;
  bool _isRequestingInstallPermission = false;

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

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    requestInstallPermission();
  }


  Future<bool> requestInstallPermission() async {
    if (!Platform.isAndroid) return false;

    if (_isRequestingInstallPermission) {
      debugPrint("Permission request already in progress");
      return false;
    }

    _isRequestingInstallPermission = true;

    try {
      final status = await Permission.requestInstallPackages.status;

      if (status.isGranted) {
        debugPrint("Install Packages permission already granted.");
        return true;
      }

      final result = await Permission.requestInstallPackages.request();
      return result.isGranted;
    } finally {
      _isRequestingInstallPermission = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = (screenWidth! / 100);
    var blockSizeVertical = (screenHeight! / 100);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F5), // light grey background
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth = constraints.maxWidth < 600 ? constraints.maxWidth * 0.9 : 400;

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              child: Container(
                width: cardWidth,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          children: const [
                            SizedBox(
                              width: 200,
                              child: Image(
                                image: AssetImage("assets/applogo.png"),
                              ),
                            ),
                            SizedBox(height: 4),

                          ],
                        ),

                        // Blue bar at top
                        Container(
                          height: 4,
                          color: AppColors.APPCOLOR,
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Enterprise Resource Planning",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // User ID
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            textInputAction: TextInputAction.next,
                            controller: loginusernameController,
                            style: const TextStyle(color: Colors.black),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 1.0),
                              ),
                              labelText: 'User Name',
                            ),
                            onChanged: (value) {
                              print('User Name changed: $value'); // You can perform any action here
                              setState(() {
                                buttonText = 'Sign In';
                                showOtpField = false;
                                otpController.text = "";
                              });
                            },
                          ),
                        ),


                        const SizedBox(height: 20),

                        // Password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            obscureText: showpassword == false ? true : false,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (term) {
                              // process
                              apicall();
                            },
                            controller: loginpwdController,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    showpassword = !showpassword;
                                  });
                                },
                                child: showpassword ? Icon(Icons.remove_red_eye_outlined) : Icon(
                                    Icons.remove_red_eye_rounded),
                              ),
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 1.0),
                              ),
                              labelText: 'Password',
                            ),
                            onChanged: (value) {
                              print('User Name changed: $value'); // You can perform any action here
                              setState(() {
                                buttonText = 'Sign In';
                                showOtpField = false;
                                otpController.text = "";
                              });
                            },

                          ),
                        ),

                        const SizedBox(height: 20),

                        // Remember + Forgot


                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: SizeConfig.safeBlockVertical! * 7,
                          child: ElevatedButton(
                            onPressed: () {
                              apicall();
                            },
                            child: const Text("Sign In"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.APPCOLOR, // set button color
                              foregroundColor: Colors.white, // text/icon color
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        if (showOtpField)...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              textInputAction: TextInputAction.next,
                              controller: otpController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black, width: 1.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black, width: 1.0),
                                ),
                                labelText: 'OTP',
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: SizeConfig.safeBlockVertical! * 7,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (otpController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text("Please Enter OTP"),
                                  ));
                                } else {
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

                                  SharedPreferences prefs = await SharedPreferences.getInstance();

                                  // prefs = await SharedPreferences.getInstance();
                                  if (prefs != null) {
                                    print('Logged in--->');

                                    prefs.setString("USERID", response!.data!.userid.toString());

                                    prefs.setString(
                                        "USERNAME", response!.data!.username.toString());

                                    prefs.setString("TOKEN", response!.data!.token.toString());
                                    /*   prefs.setString(
                            "ORGSTRUCTID", response!.data!.orgstrucid.toString());*/
                                    prefs.setString("POSID", response!.data!.posid.toString());

                                    String Loginresponse = jsonEncode(response);
                                    prefs.setString("LOGINRESPONSE", Loginresponse);


                                    prefs.setString(
                                        'ENABLEBIOMETRIC', response!.data!.ISVERIFIED.toString());
                                  }

                                  UserAuthOTPResponseModel fetchotp = await _apiProvider
                                      .authenticateUser(
                                      context, response!.data!.MOBILENO.toString(),
                                      response!.data!.userid, "V", otpController.text,'');


                                  if (fetchotp.eRRORMSG!.cODE.toString() == "350") {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(fetchotp.eRRORMSG!.mSG.toString()),
                                    ));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(fetchotp.eRRORMSG!.mSG.toString()),
                                    ));
                                    deleteFcmDetailFile();
                                    prefs.setBool("ISLOGGEDIN", true);
                                    //windows notification
                                    if (Platform.isWindows) {
                                      connectWebSocket(response!.data!.userid);
                                    }
                                    Provider.of<LoginController>(context, listen: false)
                                        .getUser("username", "password", response);


                                     if (Platform.isAndroid) {
                                      firebaseToken = await _setupFirebaseMessaging();
                                      prefs.setString('FCMTOKEN', firebaseToken);
                                    }

                                    //await compute(UpdateUserDeviceInfoapicall(), 1);

                                    await DatabaseService().insertDocMast(response!);


                                    print('Started calling API');

                                    UpdateUserDeviceInfoRequestModel updateUserDeviceInfoRequestModel =
                                    UpdateUserDeviceInfoRequestModel();
                                    updateUserDeviceInfoRequestModel.xMLFILE = XMLFILEDEVICEINFO();
                                    updateUserDeviceInfoRequestModel.xMLFILE!.uSERID =
                                        response!.data!.userid;
                                    updateUserDeviceInfoRequestModel.xMLFILE!.tOKEN =
                                        response!.data!.token;
                                    updateUserDeviceInfoRequestModel.xMLFILE!.dEVICETYPE =
                                    "android";
                                    updateUserDeviceInfoRequestModel.xMLFILE!.fLAG = "I";
                                    updateUserDeviceInfoRequestModel.xMLFILE!.dEVICEID =
                                        firebaseToken;

                                    updatedeviceinforesponse =
                                    await Provider.of<LoginController>(context, listen: false)
                                        .UpdateUserDeviceInfoDetails(
                                        updateUserDeviceInfoRequestModel);


                                    print('calling syncSLedgerModel API');
                                    /* strSLedger = prefs.getString('syncSLedgerLastSyncDate');
                            SyncSLedgerModel syncSLedgerModel =
                            await Provider.of<LoginController>(context, listen: false)
                                .syncSLedgerData({
                            "XMLFILE": {
                            "FLAG": "1",
                            "LASTSYNCDATE": strSLedger ?? "01-Jan-1900 00:00:00",
                            "MID": "0",
                            "ORGSTRUCTID": response!.data!.orgstrucid,
                            "POSID": response!.data!.posid,
                            "TOKEN": response!.data!.token.toString(),
                            "USERID": response!.data!.userid
                            }
                            });
                            print('Got syncSLedgerModel data--->');
                            await DatabaseService().insertOrUpdateSLedger(syncSLedgerModel);
                            if (syncSLedgerModel != null) {
                            if (syncSLedgerModel.dATA != null) {
                            if (prefs != null) {
                            prefs.setString("syncSLedgerLastSyncDate",
                            syncSLedgerModel.dATA!.sYNCDATETIME ??
                            "01-Jan-1900 00:00:00");
                            }
                            }
                            }*/
                                    //_loadBarcodeData();

                                    bool canAuthenticate = await auth.isDeviceSupported() &&
                                        await auth.canCheckBiometrics;

                                    if (response!.data!.ISVERIFIED != null &&
                                        response!.data!.ISVERIFIED == "true") {
                                      if (!canAuthenticate) {
                                        setState(() {
                                          _isAuthenticating = false;
                                          _authorized = 'Biometric authentication not available.';
                                        });
                                        //return;
                                        _nextScrebredirect();
                                      }
                                      else {
                                        Navigator.pop(context);
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
                                          print(_authorized);

                                          if (_authorized == "true") {
                                            //call Database UI
                                            _nextScrebredirect();
                                          }
                                        });
                                        //

                                      }
                                    }
                                    else {
                                      _nextScrebredirect();
                                    }
                                  }
                                }
                              },
                              child: const Text("Verify OTP"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, // set button color
                                foregroundColor: Colors.white, // text/icon color
                              ),
                            ),
                          ),

                        ],

                        if (!kIsWeb && Platform.isAndroid)...[
                          Visibility(
                              visible: false, // bool
                              child:  InkWell(
                                onTap: () async {
                                  print("Click event on Container");

                                  if (mounted) {
                                    setState(() {
                                      _colorapk = AppColors.TEXTC;
                                    });
                                  }

                                  Future.delayed(Duration(seconds: 1), () {
                                    if (mounted) { // Check if widget is still in tree
                                      setState(() {
                                        _colorapk = Colors.white;
                                      });
                                    }
                                  });

                                  if (!kIsWeb && Platform.isAndroid) {
                                    // Close drawer first


                                    // Wait a frame before calling async code
                                    await Future.delayed(Duration(milliseconds: 100));

                                    if (!mounted) return; // Ensure still mounted
                                    requestStoragePermission();
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: MediaQuery
                                          .of(context)
                                          .size
                                          .width * 0.02),
                                  child: Row(
                                    children: <Widget>[
                                      const Icon(
                                        Icons.download,
                                        color: AppColors.APPCOLOR,
                                      ),

                                      Text(
                                        "Download Apk",
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ))

                        ]
                      ],
                    )),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<String> generateHybridKey() async {
    final info = "";
    //await DeviceInfoPlugin().windowsInfo;
    final uuid = const Uuid().v4();
    return "$uuid";
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


  void _nextScrebredirect() {
    try {
      if (Navigator.canPop(context)) {
        /* Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => Dashboard()));*/
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TransactionListScreen(),
          ),
        );
      } else {
        /* Navigator.push(context, MaterialPageRoute(builder: (_) => Dashboard()));*/
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TransactionListScreen(),
          ),
        );
      }
    } catch (e) {
      print("Navigation error in _nextScrebredirect: $e");
    }
  }

  void apicall() async {
    if (loginusernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please Enter user name")),
      );
      return;
    }
    if (loginpwdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please Enter Password")),
      );
      return;
    }

    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(backgroundColor: Colors.white),
          Container(margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
        ],
      ),
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => alert,
    );

    try {
      CommonUtils commonUtils = CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (!isConnectivity) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please check Internet Connection")),
        );
        return;
      }

      LoginRequestModel loginRequestModel = LoginRequestModel();
      loginRequestModel.xMLFILE = XMLFILElogin();
      loginRequestModel.xMLFILE!.lOGINID = loginusernameController.text;
      loginRequestModel.xMLFILE!.pASSWORD = loginpwdController.text;
      loginRequestModel.xMLFILE!.uSERID = 0;
      loginRequestModel.xMLFILE!.rFID = '';
      loginRequestModel.xMLFILE!.DEVICENAME = strDeviceName;
      loginRequestModel.xMLFILE!.DEVICEIP = LocalIP;

      try {
        if (Platform.isWindows) {
          String? devicekey = await generateHybridKey();
          loginRequestModel.xMLFILE!.FCMKEY = devicekey;
          loginRequestModel.xMLFILE!.OLDFCMKEY = strOldFcmKey;
          response = await Provider.of<LoginController>(context, listen: false)
              .getLoginDetails1(loginRequestModel);
        }
        else if (Platform.isAndroid) {
          if (await _requestStoragePermission()) {
            try {
              Directory? baseDir = await getExternalStorageDirectory();
              if (baseDir == null) {
                Navigator.pop(context);
                return;
              }
              Directory folder =
              Directory("/storage/emulated/0/Download/ERPTEXTFILE");
              File file = File("${folder.path}/FCMDetail.txt");
              if (await file.exists()) {
                String fileContent = await file.readAsString();
                List<String> split = fileContent.split("USERID");
                if (split.length >= 2) {
                  strOldFcmKey = split[1];
                  String strUserId1 = split[0];
                  List<String> split1 = strUserId1.split("LOGINID");
                  if (split1.length >= 2) {

                  } else {

                  }
                } else {

                }
              } else {

              }
            } catch (e) {

            }
          }
          else {
            print("dfggggg");
          }

          firebaseToken = await _setupFirebaseMessaging();
        //  firebaseToken="ePgIeCbLRAG_59zTgnTqOA:APA91bFDTDlTnIoKskyGMsqxPwhxECv84eXfPw1kPftCm-PWlDjlzsjwKLiTDBb712amfVHTfQS7mQ3gyo6CT4tcbEXgjMS9ek_Isr8jXUNS97bQx-3tmOI";
          loginRequestModel.xMLFILE!.FCMKEY = firebaseToken;
          loginRequestModel.xMLFILE!.OLDFCMKEY = strOldFcmKey;

          response = await Provider.of<LoginController>(context, listen: false)
              .getLoginDetails1(loginRequestModel);
        }
        else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Unsupported platform")),
          );
          return;
        }
        context.read<FinancialYearProvider>().loadTransactions();
      } catch (e, st) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login API failed, please try again")),
        );
        return;
      }

      print("Login Response *** ${response?.data}");

      if (response == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Enter Correct Userid and Password")),
        );
        return;
      }

      if (response!.data!.MESSAGE != null && response!.data!.MESSAGE != "") {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response!.data!.MESSAGE!)),
        );
        return;
      }

      if (response!.data!.status == 'false') {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response!.data!.message ?? "Login failed")),
        );
        return;
      }

      if (response!.data!.status == 'true') {
        try {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          prefs.setString("USERID", response!.data!.userid.toString());
          prefs.setString("USERNAME", response!.data!.username.toString());
          prefs.setString("TOKEN", response!.data!.token.toString());
          // prefs.setString("ORGSTRUCTID", response!.data!.orgstrucid.toString());
          prefs.setString("POSID", response!.data!.posid.toString());
          prefs.setString("LOGINRESPONSE", jsonEncode(response));
          prefs.setString('ENABLEBIOMETRIC', response!.data!.ISVERIFIED.toString());

          if (response?.data?.ISOTP != null && response!.data!.ISOTP == "false") {
            deleteFcmDetailFile();
            prefs.setBool("ISLOGGEDIN", true);

            if (Platform.isWindows) {
              try {
                connectWebSocket(response!.data!.userid);
              } catch (e, st) {

              }
            }

            try {
              Provider.of<LoginController>(context, listen: false)
                  .getUser("username", "password", response);


              if (Platform.isAndroid) {
                try {
                   firebaseToken = await _setupFirebaseMessaging();
                  prefs.setString('FCMTOKEN', firebaseToken);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Firebase messaging setup error: $e")),
                  );
                  print("Firebase messaging setup error: $e");
                }
              }

              try {
                await DatabaseService().insertDocMast(response!);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("DB insert error: $e")),
                );
                print("DB insert error: $e");
              }

              UpdateUserDeviceInfoRequestModel updateUserDeviceInfoRequestModel =
              UpdateUserDeviceInfoRequestModel();
              updateUserDeviceInfoRequestModel.xMLFILE = XMLFILEDEVICEINFO();
              updateUserDeviceInfoRequestModel.xMLFILE!.uSERID =
                  response!.data!.userid;
              updateUserDeviceInfoRequestModel.xMLFILE!.tOKEN = response!.data!.token;
              if (Platform.isAndroid) {
                updateUserDeviceInfoRequestModel.xMLFILE!.dEVICETYPE =
                "android";
              }else if(Platform.isIOS){
                updateUserDeviceInfoRequestModel.xMLFILE!.dEVICETYPE =
                "ios";
              }
              else {
                updateUserDeviceInfoRequestModel.xMLFILE!.dEVICETYPE =
                "windows";
              }
              updateUserDeviceInfoRequestModel.xMLFILE!.fLAG = "I";
              updateUserDeviceInfoRequestModel.xMLFILE!.dEVICEID = firebaseToken;

              try {
                updatedeviceinforesponse =
                await Provider.of<LoginController>(context, listen: false)
                    .UpdateUserDeviceInfoDetails(updateUserDeviceInfoRequestModel);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Update device info error: $e")),
                );
                print("Update device info error: $e");
              }
              /*  try {
              print('calling syncSLedgerModel API');
              strSLedger = prefs.getString('syncSLedgerLastSyncDate');
              SyncSLedgerModel syncSLedgerModel =
              await Provider.of<LoginController>(context, listen: false)
                  .syncSLedgerData({
                "XMLFILE": {
                  "FLAG": "1",
                  "LASTSYNCDATE": strSLedger ?? "01-Jan-1900 00:00:00",
                  "MID": "0",
                  "ORGSTRUCTID": response!.data!.orgstrucid,
                  "POSID": response!.data!.posid,
                  "TOKEN": response!.data!.token.toString(),
                  "USERID": response!.data!.userid
                }
              });
              print('Got syncSLedgerModel data--->');
              await DatabaseService().insertOrUpdateSLedger(syncSLedgerModel);
              if (syncSLedgerModel != null) {
                if (syncSLedgerModel.dATA != null) {
                  if (prefs != null) {
                    prefs.setString("syncSLedgerLastSyncDate",
                        syncSLedgerModel.dATA!.sYNCDATETIME ??
                            "01-Jan-1900 00:00:00");
                  }
                }
              }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("calling syncSLedgerModel API: $e")),
                );
                print("Update device info error: $e");
              }*/
              //  _loadBarcodeData();

              // Biometric handling - wrapped in try-catch to avoid crash
              try {
                bool canAuthenticate = await auth.isDeviceSupported() &&
                    await auth.canCheckBiometrics;

                if (response!.data!.ISVERIFIED == "true" && canAuthenticate) {
                  Navigator.pop(context); // Close loading dialog before auth
                  setState(() {
                    _isAuthenticating = true;
                    _authorized = 'Authenticating';
                  });
                  bool authenticated = false;
                  try {
                    authenticated = await auth.authenticate(
                      localizedReason: 'Scan your fingerprint to authenticate',
                      options: const AuthenticationOptions(
                        stickyAuth: true,
                        biometricOnly: true,
                      ),
                    );
                  } on PlatformException catch (e) {
                    setState(() {
                      _isAuthenticating = false;
                      _authorized = 'Error - ${e.message}';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_authorized)),
                    );
                    return;
                  }
                  setState(() {
                    _isAuthenticating = false;
                    _authorized = authenticated ? 'true' : 'false';
                  });
                  if (authenticated) {
                    _nextScrebredirect();
                  }
                } else {
                  Navigator.pop(context); // Close loading dialog if no biometric
                  _nextScrebredirect();
                }
              } catch (e, st) {
                print("Biometric error: $e\n$st");
                Navigator.pop(context);
                _nextScrebredirect();
              }
            } catch (e, st) {
              print("Post-login processing inner error: $e\n$st");
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error after login, please try again")),
              );
            }
          }
          else if (response?.data?.ISOTP != null && response!.data!.ISOTP == "true") {
            // Handle ISOTP true case
            Navigator.pop(context);
            setState(() {
              buttonText = 'Sign In';
              showOtpField = true;
              otpController.text = "";
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("OTP verification required")),
            );
          }
          else {
            deleteFcmDetailFile();
            prefs.setBool("ISLOGGEDIN", true);

            if (Platform.isWindows) {
              try {
                connectWebSocket(response!.data!.userid);
              } catch (e, st) {

              }
            }

            try {
              Provider.of<LoginController>(context, listen: false)
                  .getUser("username", "password", response);


              if (Platform.isAndroid) {
                try {
                   firebaseToken = await _setupFirebaseMessaging();
                  prefs.setString('FCMTOKEN', firebaseToken);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Firebase messaging setup error: $e")),
                  );
                  print("Firebase messaging setup error: $e");
                }
              }

              try {
                await DatabaseService().insertDocMast(response!);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("DB insert error: $e")),
                );
                print("DB insert error: $e");
              }

              UpdateUserDeviceInfoRequestModel updateUserDeviceInfoRequestModel =
              UpdateUserDeviceInfoRequestModel();
              updateUserDeviceInfoRequestModel.xMLFILE = XMLFILEDEVICEINFO();
              updateUserDeviceInfoRequestModel.xMLFILE!.uSERID =
                  response!.data!.userid;
              updateUserDeviceInfoRequestModel.xMLFILE!.tOKEN = response!.data!.token;
              updateUserDeviceInfoRequestModel.xMLFILE!.dEVICETYPE = "android";
              updateUserDeviceInfoRequestModel.xMLFILE!.fLAG = "I";
              updateUserDeviceInfoRequestModel.xMLFILE!.dEVICEID = firebaseToken;

              try {
                updatedeviceinforesponse =
                await Provider.of<LoginController>(context, listen: false)
                    .UpdateUserDeviceInfoDetails(updateUserDeviceInfoRequestModel);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Update device info error: $e")),
                );
                print("Update device info error: $e");
              }
              /* try {
               print('calling syncSLedgerModel API');
               strSLedger = prefs.getString('syncSLedgerLastSyncDate');
               SyncSLedgerModel syncSLedgerModel =
               await Provider.of<LoginController>(context, listen: false)
                   .syncSLedgerData({
                 "XMLFILE": {
                   "FLAG": "1",
                   "LASTSYNCDATE": strSLedger ?? "01-Jan-1900 00:00:00",
                   "MID": "0",
                   "ORGSTRUCTID": response!.data!.orgstrucid,
                   "POSID": response!.data!.posid,
                   "TOKEN": response!.data!.token.toString(),
                   "USERID": response!.data!.userid
                 }
               });
               print('Got syncSLedgerModel data--->');
               await DatabaseService().insertOrUpdateSLedger(syncSLedgerModel);
               if (syncSLedgerModel != null) {
                 if (syncSLedgerModel.dATA != null) {
                   if (prefs != null) {
                     prefs.setString("syncSLedgerLastSyncDate",
                         syncSLedgerModel.dATA!.sYNCDATETIME ??
                             "01-Jan-1900 00:00:00");
                   }
                 }
               }
             } catch (e) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text("calling syncSLedgerModel API: $e")),
               );
               print("Update device info error: $e");
             }*/
              // _loadBarcodeData();
              // Biometric handling - wrapped in try-catch to avoid crash
              try {
                bool canAuthenticate = await auth.isDeviceSupported() &&
                    await auth.canCheckBiometrics;

                if (response!.data!.ISVERIFIED == "true" && canAuthenticate) {
                  Navigator.pop(context); // Close loading dialog before auth
                  setState(() {
                    _isAuthenticating = true;
                    _authorized = 'Authenticating';
                  });
                  bool authenticated = false;
                  try {
                    authenticated = await auth.authenticate(
                      localizedReason: 'Scan your fingerprint to authenticate',
                      options: const AuthenticationOptions(
                        stickyAuth: true,
                        biometricOnly: true,
                      ),
                    );
                  } on PlatformException catch (e) {
                    setState(() {
                      _isAuthenticating = false;
                      _authorized = 'Error - ${e.message}';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_authorized)),
                    );
                    return;
                  }
                  setState(() {
                    _isAuthenticating = false;
                    _authorized = authenticated ? 'true' : 'false';
                  });
                  if (authenticated) {
                    _nextScrebredirect();
                  }
                } else {
                  Navigator.pop(context); // Close loading dialog if no biometric
                  _nextScrebredirect();
                }
              } catch (e, st) {
                print("Biometric error: $e\n$st");
                Navigator.pop(context);
                _nextScrebredirect();
              }
            } catch (e, st) {
              print("Post-login processing inner error: $e\n$st");
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error after login, please try again")),
              );
            }
          }
          /*  else {
            // Handle ISOTP true case
            Navigator.pop(context);
            setState(() {
              buttonText = 'Sign In';
              showOtpField = true;
              otpController.text = "";
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("OTP verification required")),
            );
          }*/

          // Windows badge update, notification count etc.
          if (Platform.isWindows) {
            getNotificationCount();
            await Future.delayed(Duration(seconds: 2));
            int readcount = Constant.unreadCount ?? 0;
            if (readcount > 0) {
              updateWindowsBadge(readcount);
            }
          }
        } catch (e, st) {
          print("Login success flow error: $e\n$st");
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Unexpected error, please try again")),
          );
        }
      }
    } catch (error, stacktrace) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter Correct Userid and Password")),
      );
    }
  }


/*  void apicall() async {
    if (loginusernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please Enter user name"),
      ));
    } else if (loginpwdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please Enter Password"),
      ));
    } else {
      try {
        AlertDialog alert = AlertDialog(
          content: Row(children: [
            CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
            Container(
                margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
          ]),
        );

        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );

        CommonUtils commonUtils = new CommonUtils();
        bool isConnectivity = await commonUtils.check();
        if (isConnectivity) {
          LoginRequestModel loginRequestModel = new LoginRequestModel();
          */ /*  loginRequestModel.xMLFILE = new XMLFILE();
          loginRequestModel.xMLFILE!.lOGINID = loginusernameController.text;
          loginRequestModel.xMLFILE!.pASSWORD = loginpwdController.text;
          loginRequestModel.xMLFILE!.uSERID = 0;
*/ /*
          loginRequestModel.xMLFILE = new XMLFILElogin();
          loginRequestModel.xMLFILE!.lOGINID = loginusernameController.text;
          loginRequestModel.xMLFILE!.pASSWORD = loginpwdController.text;
          loginRequestModel.xMLFILE!.uSERID=0;
          loginRequestModel.xMLFILE!.rFID='';
          loginRequestModel.xMLFILE!.DEVICENAME=strDeviceName;
          loginRequestModel.xMLFILE!.DEVICEIP=LocalIP;
          if(Platform.isWindows){
            String?  devicekey = await generateHybridKey();
            */ /* response =
            await _repository.getLoginOldapi(loginRequestModel); */ /*
            loginRequestModel.xMLFILE!.FCMKEY=devicekey;
            loginRequestModel.xMLFILE!.OLDFCMKEY=strOldFcmKey;
            response = await Provider.of<LoginController>(context, listen: false)
                .getLoginDetails1(loginRequestModel);
           */ /* response = await Provider.of<LoginController>(context, listen: false)
                .getLogin(loginRequestModel);*/ /*

          }
          else if(Platform.isAndroid){
            if (await _requestStoragePermission()) {
              try {
                Directory? baseDir = await getExternalStorageDirectory(); // App-specific dir
                if (baseDir == null) {
                  print("❌ Could not get external storage directory");
                  return;
                }

                Directory folder = Directory("/storage/emulated/0/Download/ERPTEXTFILE");
                File file = File("${folder.path}/FCMDetail.txt");

                if (await file.exists()) {
                  String fileContent = await file.readAsString();

                  // Split by USERID
                  List<String> split = fileContent.split("USERID");
                  if (split.length >= 2) {
                    strOldFcmKey = split[1];
                    String strUserId1 = split[0];

                    // Split by LOGINID
                    List<String> split1 = strUserId1.split("LOGINID");
                    if (split1.length >= 2) {
                      String strLoginId = split1[0];
                      String strUId = split1[1];

                      print("🔐 strLoginId: $strLoginId");
                      print("🆔 strUId: $strUId");
                      print("📦 strOldFcmKey: $strOldFcmKey");
                    } else {
                      print("⚠️ Invalid format: LOGINID split failed");
                    }
                  } else {
                    print("⚠️ Invalid format: USERID split failed");
                  }
                } else {
                  print("ℹ️ File does not exist at ${file.path}");
                }
              } catch (e) {
                print("❌ Error reading file: $e");
              }
            } else {
              print("❌ Storage permission denied");
            }
            firebaseToken = await _setupFirebaseMessaging();
            loginRequestModel.xMLFILE!.FCMKEY=firebaseToken;
            loginRequestModel.xMLFILE!.OLDFCMKEY=strOldFcmKey;
            response = await Provider.of<LoginController>(context, listen: false)
                .getLoginDetails1(loginRequestModel);

          }
          */ /*   response = await Provider.of<LoginController>(context, listen: false)
              .getLoginDetails1(loginRequestModel);
*/ /*
          print("Login Response *** ${response!.data}");

          // response = await _repository.getLoginData(loginRequestModel);
//          await Provider.of<UserProvider>(context, listen: false).login(username, password);
          if (response != null) {
            if (response!.data!.MESSAGE != null && response!.data!.MESSAGE == "") {
              if (response!.data!.status == 'false') {
                Get.focusScope?.unfocus();

                Navigator.pop(context); //for dissmiss progres dialog
                print(response!.data!.message);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response!.data!.message!),));
                */ /*    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Enter Correct Userid and Password'),
              ));*/ /* //response!.data!.message ??

              }
              else if (response!.data != null && response!.data!.status == 'true') {



                SharedPreferences prefs = await SharedPreferences.getInstance();

                prefs = await SharedPreferences.getInstance();
                if (prefs != null) {
                  print('Logged in--->');
                  */ /*  String Loginresponse=   jsonEncode(response);
                prefs.setString("Loginresponse", Loginresponse);
*/ /*
                  prefs.setString("USERID", response!.data!.userid.toString());

                  prefs.setString(
                      "USERNAME", response!.data!.username.toString());

                  prefs.setString("TOKEN", response!.data!.token.toString());
                  prefs.setString(
                      "ORGSTRUCTID", response!.data!.orgstrucid.toString());
                  prefs.setString("POSID", response!.data!.posid.toString());

                  String Loginresponse = jsonEncode(response);
                  prefs.setString("LOGINRESPONSE", Loginresponse);


                  prefs.setString('ENABLEBIOMETRIC', response!.data!.ISVERIFIED.toString());
                }
                if (response!.data!.ISOTP == "false") {
                  deleteFcmDetailFile();
                  prefs.setBool("ISLOGGEDIN", true);
                  //windows notification
                  if (Platform.isWindows) {
                    connectWebSocket(response!.data!.userid);
                  }
                  Provider.of<LoginController>(context, listen: false)
                      .getUser("username", "password", response);



                  getData();
                  if (!Platform.isWindows) {
                    firebaseToken = await _setupFirebaseMessaging();
                    prefs.setString('FCMTOKEN', firebaseToken);
                  }

                  //await compute(UpdateUserDeviceInfoapicall(), 1);

                  await DatabaseService().insertDocMast(response!);


                  print('Started calling API');

                  UpdateUserDeviceInfoRequestModel updateUserDeviceInfoRequestModel =
                  UpdateUserDeviceInfoRequestModel();
                  updateUserDeviceInfoRequestModel.xMLFILE = XMLFILEDEVICEINFO();
                  updateUserDeviceInfoRequestModel.xMLFILE!.uSERID =
                      response!.data!.userid;
                  updateUserDeviceInfoRequestModel.xMLFILE!.tOKEN = response!.data!.token;
                  updateUserDeviceInfoRequestModel.xMLFILE!.dEVICETYPE = "android";
                  updateUserDeviceInfoRequestModel.xMLFILE!.fLAG = "I";
                  updateUserDeviceInfoRequestModel.xMLFILE!.dEVICEID = firebaseToken;

                  updatedeviceinforesponse =
                  await Provider.of<LoginController>(context, listen: false)
                      .UpdateUserDeviceInfoDetails(updateUserDeviceInfoRequestModel);

                  */ /*   SyncILedgerModel syncILedgerModel =
                  await Provider.of<LoginController>(context, listen: false)
                      .syncILedgerData({
                "XMLFILE": {
                  "FLAG": "1",
                  "LASTSYNCDATE": "01-Jan-1900 00:00:00",
                  "MID": "0",
                  "ORGSTRUCTID": response!.data!.orgstrucid,
                  "POSID": response!.data!.posid,
                  "TOKEN": response!.data!.token.toString(),
                  "USERID": response!.data!.userid
                }
              });
             print('Got syncILedgerModel data--->');
                await DatabaseService().insertOrUpdateILedger(syncILedgerModel);
*/ /*

                  print('calling syncSLedgerModel API');
                  strSLedger = prefs.getString('syncSLedgerLastSyncDate');
                  SyncSLedgerModel syncSLedgerModel =
                  await Provider.of<LoginController>(context, listen: false)
                      .syncSLedgerData({
                    "XMLFILE": {
                      "FLAG": "1",
                      "LASTSYNCDATE": strSLedger ?? "01-Jan-1900 00:00:00",
                      "MID": "0",
                      "ORGSTRUCTID": response!.data!.orgstrucid,
                      "POSID": response!.data!.posid,
                      "TOKEN": response!.data!.token.toString(),
                      "USERID": response!.data!.userid
                    }
                  });
                  print('Got syncSLedgerModel data--->');
                  await DatabaseService().insertOrUpdateSLedger(syncSLedgerModel);
                  if (syncSLedgerModel != null) {
                    if (syncSLedgerModel.dATA != null) {
                      if (prefs != null) {
                        prefs.setString("syncSLedgerLastSyncDate",
                            syncSLedgerModel.dATA!.sYNCDATETIME ??
                                "01-Jan-1900 00:00:00");
                      }
                    }
                  }
                  //  print('calling syncPriceMasterModel API');

                  */ /*     SyncPriceMasterModel syncPriceMasterModel =
                  await Provider.of<LoginController>(context, listen: false)
                      .syncPriceMasterData({
                "XMLFILE": {
                  "FLAG": "1",
                  "LASTSYNCDATE": "01-Jan-1900 00:00:00",
                  "MID": "0",
                  "ORGSTRUCTID": response!.data!.orgstrucid,
                  "POSID": response!.data!.posid,
                  "TOKEN": response!.data!.token.toString(),
                  "USERID": response!.data!.userid
                }
              })*/ /*;
                  //  print('Got syncPriceMasterModel data--->');
                  // await DatabaseService().insertOrUpdatePriseMaster(syncPriceMasterModel);

                  // print('calling fillUserListModel API');

                  */ /* FillUserListModel fillUserListModel =
                  await Provider.of<LoginController>(context, listen: false)
                      .syncFillUserListModelData({
                "XMLFILE": {
                  "DESC": "",
                  "ISACTIVE": "true",
                  "SEARCHUSERID": "0",
                  "SHOWHELP": "1",
                  "UTYPEID": "0",
                  "TOKEN": response!.data!.token.toString(),
                  "USERID": response!.data!.userid
                }
              });*/ /*
                  //  print('Got fillUserListModel data--->');
                  //  await DatabaseService().insertOrUpdateUserMast(fillUserListModel);

                  //  print('calling getSOListModel API');

                  */ /*   GetSOListModel getSOListModel =
                  await Provider.of<LoginController>(context, listen: false)
                      .syncSOListData({
                "XMLFILE": {
                  "FLAG": "1",
                  "LASTSYNCDATE": "01-Jan-1900 00:00:00",
                  "MID": "0",
                  "ORGSTRUCTID": response!.data!.orgstrucid,
                  "POSID": response!.data!.posid,
                  "TOKEN": response!.data!.token.toString(),
                  "USERID": response!.data!.userid
                }
              });*/ /*
                  //  print('Got getSOListModel data--->');
                  // await DatabaseService().insertOrUpdateSO(getSOListModel);

                  //  print('calling getItemBalanceModel API');

                  */ /* GetItemBalanceModel getItemBalanceModel =
                  await Provider.of<LoginController>(context, listen: false)
                      .syncItemBalanceDetails({
                "XMLFILE": {
                  "FLAG": "1",
                  "LASTSYNCDATE": "01-Jan-1900 00:00:00",
                  "MID": "0",
                  "ORGSTRUCTID": "4",
                  "POSID": response!.data!.posid,
                  "TOKEN": response!.data!.token.toString(),
                  "USERID": response!.data!.userid
                }
              });*/ /*
                  // print('Got getItemBalanceModel data--->');
                  */ /* await DatabaseService()
                  .insertOrUpdateItemStock(getItemBalanceModel);
*/ /*
                  bool canAuthenticate = await auth.isDeviceSupported() &&
                      await auth.canCheckBiometrics;

                  if (response!.data!.ISVERIFIED != null &&
                      response!.data!.ISVERIFIED == "true") {
                    if (!canAuthenticate) {
                      setState(() {
                        _isAuthenticating = false;
                        _authorized = 'Biometric authentication not available.';
                      });
                      //return;
                      _nextScrebredirect();
                    }
                    else {
                      Navigator.pop(context);
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
                            _authorized = 'Too many failed attempts. Try again in 30 seconds.';
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
                        print(_authorized);

                        if (_authorized == "true") {
                          //call Database UI
                          _nextScrebredirect();
                        }
                      });
                      //

                    }
                  } else {
                    _nextScrebredirect();
                  }
                }
                else{

                  //isotp is true

                  print("Button label $buttonText");

               if(buttonText != null && buttonText =="Resend OTP")
                 {
                   setState(() {
                     buttonText = 'Resend OTP';
                     showOtpField = showOtpField;
                     otpController.text="";
                   });
                    fetchotp = await _apiProvider.authenticateUser(
                       context, response!.data!.MOBILENO.toString(), response!.data!.userid, "E", "");

                 }else{
                 setState(() {
                   buttonText = 'Resend OTP';
                   showOtpField = !showOtpField;
                   otpController.text="";
                 });
                  fetchotp = await _apiProvider.authenticateUser(
                     context,response!.data!.MOBILENO.toString(), response!.data!.userid, "I", "");

               }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(fetchotp!.eRRORMSG!.mSG.toString()),));
                }

                //updateWindowsBadge(15);
                if(Platform.isWindows){
                  getNotificationCount() ;
                  await Future.delayed(Duration(seconds: 2));
                  int readcount =Constant.unreadCount ?? 0;
                  print("count :$readcount");
                  if(readcount > 0){
                    updateWindowsBadge(Constant.unreadCount!);
                  }
                }

              }
            }else{
              Navigator.pop(context);
              setState(() {
                buttonText = 'Sign In';
                showOtpField = false;
                 otpController.text="";
              });
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response!.data!.MESSAGE.toString()),));
            }
            //  print("Login Response *** ${response!.data.menulist!.data}");
            Get.focusScope?.unfocus();
          }
          else {
            Navigator.pop(context); //for dissmiss progres dialog
            setState(() {
              buttonText = 'Sign In';
              showOtpField = false;
              otpController.text="";
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Enter Correct Userid and Password"),
            ));
          }
        } else {
          Navigator.pop(context); //for dissmiss progres dialog
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Please check Internet Connection"),
          ));
        }
      } catch (error, stacktrace) {
        Navigator.pop(context); //for dissmiss progres dialog
        print("Exception occured: $error stackTrace: $stacktrace");
        //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter Correct Userid and Password"),));
      }
    }
  }*/
  /*_nextScrebredirect() async
  {
    */ /*Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => Dashboard()),
          (Route<dynamic> route) => false,
    );*/ /*
    print("Navigation to Dashboard about to happen...");
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => Dashboard(),
    ));


  }*/
  UpdateUserDeviceInfoapicall() async {
    try {
      AlertDialog alert = AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(
            backgroundColor: Colors.white,
          ),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
        ]),
      );

      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );

      CommonUtils commonUtils = CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {
        UpdateUserDeviceInfoRequestModel updateUserDeviceInfoRequestModel =
        UpdateUserDeviceInfoRequestModel();
        updateUserDeviceInfoRequestModel.xMLFILE = XMLFILEDEVICEINFO();
        updateUserDeviceInfoRequestModel.xMLFILE!.uSERID =
            response!.data!.userid;
        updateUserDeviceInfoRequestModel.xMLFILE!.tOKEN = response!.data!.token;
        updateUserDeviceInfoRequestModel.xMLFILE!.dEVICETYPE = "android";
        updateUserDeviceInfoRequestModel.xMLFILE!.fLAG = "I";
        updateUserDeviceInfoRequestModel.xMLFILE!.dEVICEID = "";

        updatedeviceinforesponse =
        await Provider.of<LoginController>(context, listen: false)
            .UpdateUserDeviceInfoDetails(updateUserDeviceInfoRequestModel);
        //  _loadBarcodeData();
        if (updatedeviceinforesponse != null) {
          /*Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
          );*/
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionListScreen(),
            ),
          );
        } else {
          Navigator.pop(context); //for dissmiss progres dialog
        }
      } else {
        Navigator.pop(context); //for dissmiss progres dialog
      }
    } catch (error, stacktrace) {
      Navigator.pop(context); //for dissmiss progres dialog
      //  print("Exception occured: $error stackTrace: $stacktrace");
    }
  }

  ClientEngagementapicall() async {
    try {
      AlertDialog alert = AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(
            backgroundColor: Colors.white,
          ),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
        ]),
      );
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
      final LoginApiRepository _repository = LoginApiRepository();
      CommonUtils commonUtils = new CommonUtils();
      bool isConnectivity = await commonUtils.check();
      if (isConnectivity) {
        ClientEngagementReqestModel clientEngagementReqestModel =
        new ClientEngagementReqestModel();
        clientEngagementReqestModel.xMLFILE = new XMLFILECLIENTENG();
        clientEngagementReqestModel.xMLFILE!.uSERID = response!.data!.userid;
        clientEngagementReqestModel.xMLFILE!.tOKEN = response!.data!.token;
        clientEngagementReqestModel.xMLFILE!.mID = "0";
        clientEngagementResponseModel =
        await _repository.ClientEngagementData(clientEngagementReqestModel);
        if (clientEngagementResponseModel != null) {
          print(clientEngagementResponseModel);
          /* timer =
              Timer.periodic(const Duration(milliseconds: 500), (timer) {
                // print(timer.tick);
              });*/

          // timer?.cancel();

          // SyncCRMDataapicall();
        } else {
          Navigator.pop(context); //for dissmiss progres dialog
        }
      } else {
        Navigator.pop(context); //for dissmiss progres dialog
      }
    } catch (error, stacktrace) {
      Navigator.pop(context); //for dissmiss progres dialog
      // print("Exception occured: $error stackTrace: $stacktrace");
    }
  }

  Future<void> deleteFcmDetailFile() async {
    try {
      if (Platform.isAndroid) {
        if (await _requestStoragePermission()) {
          final file = File("/storage/emulated/0/Download/ERPTEXTFILE/FCMDetail.txt");

          if (await file.exists()) {
            await file.delete();
            print('✅ FCMDetail.txt deleted');
          } else {
            print('ℹ️ File does not exist at: ${file.path}');
          }
        } else {
          print("❌ Permission denied to delete file");
        }
      }
    } catch (e) {
      print('❌ Error deleting file: $e');
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt <= 28) {
      // Android 9 and below
      final status = await Permission.storage.request();
      return status.isGranted;
    }

    if (sdkInt == 29) {
      // Android 10 → NO permission required
      return true;
    }

    if (sdkInt >= 30) {
      // Android 11+
      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }

    return false;
  }

  Future<void> _loadBarcodeData() async {
    final provider = Provider.of<BarcodeProvider>(context, listen: false);

    try {
      await Future.wait([
        provider.fetchBarcodeDetails("1"),
        provider.fetchBarcodeDetails("2"),
      ]);
    } catch (e) {
      print("Error while loading barcode data: $e");
    }
  }

  Future<int> getVersionCode() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int versionCode = int.parse(packageInfo.buildNumber);
    print("Version Code: $versionCode");
    return versionCode % 1000;
  }

  Future<bool> apiCheckUpdateAvailable() async {
    bool isUpdated = false;

    int currentVersion = await getVersionCode();

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    String deviceName = androidInfo.manufacturer + " " + androidInfo.model;

    CheckDeviceRequestModel checkDeviceRequestModel =
    new CheckDeviceRequestModel();
    checkDeviceRequestModel.xMLFILE = new XMLFILEc();
    checkDeviceRequestModel.xMLFILE!.uSERID = 0;
    checkDeviceRequestModel.xMLFILE!.dEVICEID = deviceName;
    checkDeviceRequestModel.xMLFILE!.fLAG = "0";
    checkDeviceRequestModel.xMLFILE!.iPADDRESS = "$LocalIP";
    checkDeviceRequestModel.xMLFILE!.mAC = "";
    checkDeviceRequestModel.xMLFILE!.pORT = "";
    checkDeviceRequestModel.xMLFILE!.vERSION = currentVersion;
    final LoginApiRepository _repository = LoginApiRepository();

    try {
      {
        CheckDeviceResponseModel response =
        await _repository.getCheckDevice(checkDeviceRequestModel);
        if (response != null) if (response.dATA != null &&
            response.dATA!.lATESTVERSION != null) {
          if (int.parse(response.dATA!.lATESTVERSION!) >
              int.parse(response.dATA!.cURRENTVERSION ?? '0')) {
            isUpdated = true;
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Your app is updated!')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response.error!),
          ));
        }
      }
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unable to check latest version!'),
      ));
    }

    return isUpdated;
  }

  Future<void> requestStoragePermission() async {
    bool updateAvailable = await apiCheckUpdateAvailable();

    if (!updateAvailable) {
      return;
    }

    AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;

    if (androidInfo.version.sdkInt >= 30) {
      var manageExternalStorageStatus = await Permission.manageExternalStorage.status;
      if (!manageExternalStorageStatus.isGranted) {
        var result = await Permission.manageExternalStorage.request();
        if (!result.isGranted) {
          _showPermissionDeniedDialog();
        } else {
          downloadFile(context);
        }
      } else {
        downloadFile(context);
      }
    } else {
      var storagePermissionStatus = await Permission.storage.status;
      if (!storagePermissionStatus.isGranted) {
        var result = await Permission.storage.request();
        if (!result.isGranted) {
          _showPermissionDeniedDialog();
        } else {
          downloadFile(context);
        }
      } else {
        downloadFile(context);
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




  Future<bool> downloadFile(BuildContext context) async {
    await requestInstallPermission();

    try {
      final String url =
          '${AppConfig.RAW_BASE_URL}/DownloadAPK/DownloadApkFile';

      debugPrint('Downloading file...');
      showLoadingDialog(context, message: 'Downloading App');

      final request = http.Request('GET', Uri.parse(url));

      // ⏳ Increase timeout for large APKs
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 5),
      );

      if (streamedResponse.statusCode != 200) {
        throw Exception('Download failed');
      }

      // 📂 Use external storage (IMPORTANT for APK install)
      final Directory? directory = await getExternalStorageDirectory();
      final File file = File('${directory!.path}/app.apk');

      final IOSink sink = file.openWrite();
      await streamedResponse.stream.pipe(sink);
      await sink.close();

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!await file.exists()) {
        return false;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('App downloaded successfully!'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final installer = FlutterAppInstaller();
                await installer.installApk(filePath: file.path);
                Navigator.pop(context);
              },
              child: const Text('Install'),
            ),
          ],
        ),
      );

      return true;
    } on TimeoutException catch (e) {
      debugPrint('Download timeout: $e');

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return false;
    } catch (e, s) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      debugPrint('Error: $e');
      debugPrintStack(stackTrace: s);
      return false;
    }
  }

}
