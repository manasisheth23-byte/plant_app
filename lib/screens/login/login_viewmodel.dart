import 'dart:io';


import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import '../../Constants.dart';
import '../../app_config.dart';
import '../../database/DatabaseHelper.dart';
import '../../database/app_preferences.dart';
import '../../database/secure_storage_service.dart';
import '../../models/ChangePasswordRequestModel.dart';
import '../../models/ChangePasswordResponseModel.dart';
import '../../models/LoginResponseModel.dart';
import '../../models/UpdateUserDeviceInfoRequestModel.dart';
import '../../services/ApiProvider.dart';
import '../../utils/CommonUtils.dart';



enum LoginStatus {
  initial,
  loading,
  success,
  error,
}
class LoginViewModel extends ChangeNotifier {
  final ApiProvider _repo = ApiProvider();
  final SecureStorageService _storage = SecureStorageService();
  final DatabaseHelper dbHelper =
  DatabaseHelper();
  bool isLoading = false;
  LoginStatus _status = LoginStatus.initial;
  LoginStatus get status => _status;
  String? _error;
  String? get error => _error;

  LoginResponseModel? _loginResponse;   // 👈 ADD THIS

  LoginResponseModel? get loginResponse => _loginResponse;  // 👈 GETTER
  String? _message;
  String? get message => _message;
  String? _code;
  String? get code => _code;
  String? _otp;
  String? get otp => _otp;
  Future<void> login(
      String userId,
      String password,
      )
  async {
    _status = LoginStatus.loading;
    notifyListeners();

    try {
      final response = await _repo.logindata(
        userId: userId,
        password: password,
      );

      print("API RESPONSE : $response");

      if (response != null) {
        _loginResponse = response;


        await SecureStorageService.saveCredentials(userId, password);
        await SecureStorageService.saveUser(response);

        _status = LoginStatus.success;
        _error = null;
        _message = response.data!.message; // <-- Save success message if available

        if (Platform.isWindows && response.data != null) {
          connectWebSocket(response.data!.userid);
        }
      } else {
        _status = LoginStatus.error;
        _message = "Invalid Login ID or Password.";
        _error = _message;
      }
    } catch (e) {
      print("LOGIN ERROR : $e");

      _status = LoginStatus.error;

      // Show API error if available
      if (e.toString().contains("Exception:")) {
        _message = e.toString().replaceFirst("Exception:", "").trim();
      } else {
        _message = "Login failed. Please try again.";
      }

      _error = _message;
    }

    notifyListeners();
  }

  /*Future<void> login(
      String userId,
      String password,
      )
  async {

    _status = LoginStatus.loading;

    notifyListeners();

    try {
      print("LOGIN METHOD START");
      final response = await _repo.logindata(
        userId: userId,
        password: password,
      );
      print("API RESPONSE : $response");
      if (response != null) {
        final savedCreds =
        await SecureStorageService.getCredentials();

        if (savedCreds != null &&
            savedCreds["username"] == userId &&
            savedCreds["password"] == password) {

        }else{
       //   await dbHelper.deleteAllTasks();
         // await dbHelper.deleteAllIssues();
        }
        _loginResponse = response;  // 👈 SAVE RESPONSE
        await SecureStorageService.saveCredentials(userId, password);
        await SecureStorageService.saveUser(response);

        //await SecureStorageService.saveIsApiLogin(true);
        _status = LoginStatus.success;
        _error = null;
        if(Platform.isWindows) {
          if (response.data != null) {
            connectWebSocket(response.data!.userid);
          }
        }
      } else {
        _status = LoginStatus.error;
      }

    } catch (e, stackTrace) {

      print("LOGIN ERROR : $e");
      print("STACKTRACE : $stackTrace");

      _status = LoginStatus.error;
      _error = e.toString();
    }
    *//*catch (e) {
      _status = LoginStatus.error;
      _error = "Login ID/Password is not correct.";

    }*//*

    notifyListeners();
  }*/
  Future<void> connectWebSocket(String userId) async {
    print("🚀 connectWebSocket START");

    // If already connected, close old connection
    if (Constant.rawSocket != null &&
        Constant.rawSocket!.readyState == WebSocket.open) {
      print('⚠️ Closing old socket');
      await Constant.rawSocket!.close();
    }

    String wsUrl = AppConfig.RAW_BASE_URL.replaceFirst('http', 'ws');
    final fullUrl =
        '$wsUrl/ERPAPI/WebSocketHandlerUserWise_API.ashx?USERID=$userId';

    print('🌐 Connecting to: $fullUrl');

    try {
      Constant.rawSocket = await WebSocket.connect(fullUrl);
      print('✅ Socket instance created');

      Constant.channel = IOWebSocketChannel(Constant.rawSocket!);

      if (Constant.rawSocket!.readyState == WebSocket.open) {
        print('✅ WebSocket connected successfully');

        // 🔥 SEND TEST MESSAGE
        Constant.channel!.sink.add("HELLO");
        print('📤 Sent: HELLO');
      } else {
        print('❌ Socket NOT open. State: ${Constant.rawSocket!.readyState}');
      }
    } catch (e) {
      print('🔥 Connection error: $e');
      return;
    }

    // Listen to incoming messages
    print("👂 Start listening to WebSocket stream...");

    Constant.channel!.stream.listen(
          (data) async {
        print('📥 Received RAW: $data');
        print('📥 Type: ${data.runtimeType}');
        final parsed = parseSocketData(data.toString());

        print('📦 Parsed Data: $parsed');

        String msgCode = parsed['MSGCODE']?.toLowerCase() ?? "";
        String projId = parsed['PROJID'] ?? "";
        String issueId = parsed['ISSUEID'] ?? "";
        String taskId = parsed['TASKID'] ?? "";
        String subTaskId = parsed['SUBTASKID'] ?? "";
        String? token = await AppPreferences.getLoginToken();
        if (msgCode == "released" || msgCode == "updated") {

          print("👉 Calling handleReleasedNotification");

      /*    try {
            await CommonUtils.handleReleasedNotification(
              token: token!,
              userId: userId,
              projId: projId.toString(),
            );
          } catch (e) {
            print("❌ handleReleasedNotification error: $e");
          }*/
        }
        /// ✅ 2. NEW ISSUE
        else if (msgCode == "newissue") {
          print("👉 Handling NEW ISSUE notification");
          try {
          /*  await CommonUtils. handleNewIssueNotification(
              token: token!,
              userId: userId,
              issueId: issueId,
              taskId: taskId,
              subTaskId: subTaskId,
            );*/

          } catch (e) {
            print("❌ NEW ISSUE error: $e");
          }
        }
        /// ✅ 3. DELETE ISSUE
        else if (msgCode == "deleted") {
          print("🗑️ Handling DELETE ISSUE");

          if (issueId.isNotEmpty) {
            try {
              {
                await CommonUtils.deleteIssueById(issueId);
                print("🗑️ Deleted in UI ISSUEID: $issueId");
              }
            } catch (e) {
              print("❌ DELETE ISSUE error: $e");
            }
          } else {
            print("⚠️ ISSUEID is empty, cannot delete");
          }
        }
        else if (
        (msgCode == "logout") &&
            (parsed['ISLOGOUT'] == "1")) {

          print("🚪 Logout triggered");

          try {
            {
              // ✅ Foreground → UI logout
             // await CommonUtils.logoutUser();
              print("✅ UI logout done");
            }
          } catch (e) {
            print("❌ Logout error: $e");
          }
        }
        /* final context = AuthRepository.navigatorKey.currentContext;
        print('🧭 context: $context');

        if (context != null) {
          *//*showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Notification'),
                content: Text(data.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );*//*
        } else {
          print('⚠️ Context is NULL → Dialog not shown');
        }*/
      },
      onDone: () {
        print('❌ WebSocket closed (onDone called)');
      },
      onError: (error) {
        print('🔥 WebSocket error: $error');
      },
    );
  }
  Map<String, String> parseSocketData(String rawData) {
    final Map<String, String> result = {};

    // Split by comma
    final parts = rawData.split(',');

    for (var part in parts) {
      final keyValue = part.split(':');

      if (keyValue.length >= 2) {
        final key = keyValue[0].trim();
        final value = keyValue.sublist(1).join(':').trim(); // handles extra ':'

        result[key] = value;
      }
    }

    return result;
  }

/*  Future<void> startBackgroundSync(
      LoginResponseModel response,
      DashboardViewModel dashboardVM,
      )
  async {
    try {
      String? fcmtoken = await AppPreferences.getFcmToken();

      /// 🔹 1. Run FCM + Device update in parallel
      await Future.wait([
        if (fcmtoken != null && fcmtoken.isNotEmpty)
          _repo.updateFcmKey(response.data!.token, fcmtoken),

        updateDeviceInfo(response, fcmtoken),
      ]);

     *//* final repo = SubTaskRepository();
      final issueRepo = IssueRepository();*//*

      /// 🔥 2. PARALLEL API CALLS (MAIN OPTIMIZATION)
      *//*await Future.wait([
        repo.getSubTasks(
          token: response.data?.token ?? "",
          userId: response.data?.userId ?? "",
          projId: "0",
        ),

        repo.getSubTasksTypeThree(
          token: response.data?.token ?? "",
          userId: response.data?.userId ?? "",
          projId: "0",
          taskId: "0",
        ),*//*

     *//*   issueRepo.getSubTaskIssues(),
        issueRepo.fetchAndStoreUsersDio(),*//*
     // ]);
      await dashboardVM.loadSubTasksFromDb(); // reload DB
      dashboardVM.notifyListeners();
      /// 🔹 3. Save flag
      await SecureStorageService.saveIsApiLogin(false);

    } catch (e) {
      debugPrint("Background Sync Error: $e");
    }
  }*/
  Future<void> updateDeviceInfo(
      LoginResponseModel response,
      String? fcmtoken,
      ) async {
    UpdateUserDeviceInfoRequestModel request =
    UpdateUserDeviceInfoRequestModel();

    request.xMLFILE = XMLFILEDEVICEINFO()
      ..uSERID = response.data?.userid
      ..tOKEN = response.data!.token
      ..dEVICETYPE = "android"
      ..fLAG = "I"
      ..dEVICEID = fcmtoken;
      //..dEVICEID ="ePgIeCbLRAG_59zTgnTqOA:APA91bFDTDlTnIoKskyGMsqxPwhxECv84eXfPw1kPftCm-PWlDjlzsjwKLiTDBb712amfVHTfQS7mQ3gyo6CT4tcbEXgjMS9ek_Isr8jXUNS97bQx-3tmOI";
    ;

    await _repo.updateUserDeviceInfoDetails(request);
  }

  Future<ChangePasswordResponseModel> ChanagePasswordapicall(
      String oldPwd, String newPwd, String confirmPwd,
      String token, String userId, String activity
      ) async {
    ChangePasswordRequestModel req = ChangePasswordRequestModel();
    req.xMLFILE = XMLFILECHANGEPASSWORD();
    req.xMLFILE!.uSERID = userId;
    req.xMLFILE!.tOKEN = token;
    req.xMLFILE!.oLDPASSWORD = oldPwd;
    req.xMLFILE!.nEWPASSWORD = newPwd;
    req.xMLFILE!.cONFIRMPASSWORD = confirmPwd;

    if(activity != null && activity =="FORGOTPASSWORD")
      {
        req.xMLFILE!.FLAG = "F";
      }else{
      req.xMLFILE!.FLAG = "C";
    }


    final response = await _repo.ChangePasswordDetails(req);
    return response;
  }
  bool _showPassword = false;
  bool get showPassword => _showPassword;

  void togglePassword() {
    _showPassword = !_showPassword;
    notifyListeners();
  }
  void setOfflineSuccess() {
    _status = LoginStatus.success;
    notifyListeners();
  }

  void setOfflineError(String message) {
    _status = LoginStatus.error;
    _error = message;
    notifyListeners();
  }
  // =========================
  // 🔹 OTP VERIFY METHOD
  // =========================
  Future<void> authenticateUserOtp({
    required BuildContext context,
    required String token,
    required String mobileNo,
    required String userId,
    required String strFlag,
    required String strOtp,
  }) async {
    _setLoading();


      final response = await _repo.authenticateUser(
        context,
        token,
        mobileNo,
        userId,
        strFlag,
        strOtp,
      );

      if (response != null) {
        _status = LoginStatus.success;
        _error = null;
        _message = response.eRRORMSG!.mSG!.toString();
        _code= response.eRRORMSG!.cODE!.toString();
        _otp= response.eRRORMSG!.OTP.toString();


      } else {
        _setError("OTP Verification Failed");
      }

  }
  // =========================
  // 🔹 LOADING HANDLER
  // =========================
  void _setLoading() {
    _status = LoginStatus.loading;
    _error = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = LoginStatus.error;
    _error = message;
    notifyListeners();
  }
}