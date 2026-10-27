import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:erpflutter/Constants.dart';
import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/helpers/DeviceTokenService.dart';
import 'package:erpflutter/helpers/api_helpers.dart';
import 'package:erpflutter/models/financialyear_model.dart';
import 'package:erpflutter/models/getnotificationmodel.dart';
import 'package:erpflutter/models/login_model.dart';
import 'package:erpflutter/models/sync_s_ledger_model.dart';
import 'package:erpflutter/provider/get_notification_provider.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/companylist/model/transaction_model.dart';
import 'package:erpflutter/screens/login/login_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../barcodescanner/models/asn_scanning_response.dart';
import '../database/app_preferences.dart';
import '../database/secure_storage_service.dart';
import '../helpers/api_request.dart';
import '../models/ChangePasswordRequestModel.dart';
import '../models/ChangePasswordResponseModel.dart';
import '../models/CheckDeviceRequestModel.dart';
import '../models/CheckDeviceResponseModel.dart';
import '../models/ClientEngagementReqestModel.dart';
import '../models/ClientEngagementResponseModel.dart';
import '../models/FillDocMastRequestModel.dart';
import '../models/FillDocMastResponseModel.dart';
import '../models/FillLocationsRequestModel.dart';
import '../models/FillLocationsResponseModel.dart';
import '../models/FillStatusListRequestModel.dart';
import '../models/FillStatusListResponseModel.dart';
import '../models/GetDefaultValRequestModel.dart';
import '../models/GetDefaultValResponseModel.dart';
import '../models/GetTransDetailsForQCRequestModel.dart';
import '../models/GetTransDetailsForQCResponseModel.dart';
import '../models/LoginRequestModel.dart';
import '../models/LoginResponseModel.dart';
import '../models/ProcessNFGQualityLookupRequestModel.dart';
import '../models/ProcessNFGQualityLookupResponseModel.dart';
import '../models/RejectionReworkHelpForQCRequestModel.dart';
import '../models/RejectionReworkHelpForQCResponseModel.dart';
import '../models/SalesOrderListModel.dart';
import '../models/UpdateUserDeviceInfoRequestModel.dart';
import '../models/UpdateUserDeviceInfoResponseModel.dart';
import '../models/auth_user_otp_response_model.dart';
import '../models/edit_note_model.dart';
import '../models/forgot_password_response.dart';
import '../models/know_your_products_model.dart';
import '../models/login_response_model.dart';
import '../models/product_details_model.dart';
import '../models/projectwise_response_model.dart';
import '../models/service_engineer_regsiter_response_model.dart';
import '../models/updatenotificationstatus_model.dart';
import '../utils/deviceutils.dart';

class ApiProvider {
//create dio object
  final Dio _dio = Dio();
  SharedPreferences? prefs;
  String? strSalesOrder = "01-Jan-1900 00:00:00";
  final SecureStorageService _secureStorage = SecureStorageService();

  //Base URL

  // Local....
  // String? apibaseurl = "http://10.0.0.233:8023/Api";

  String? apibaseurl = "http://125.99.42.182:8392/ERPAPI/api";

  // Public....
  // String? apibaseurl = "http://c9crmps.cloud9ebiz.com/ERPAPI/Api";
  String login = "Authenticate/ReturnLoginInfo_V1"; //post api version 1 for biometry
  String _loginEndpoint = "Authenticate/ReturnLoginInfo_V1";

  String? companyConfig = "Authenticate/InitialConfig?"; //get
  String? loginApi = "Authenticate/ReturnLoginInfo"; //post
  String? UpdateUserDeviceInfo = "Notification/UpdateUserDeviceInfo"; //post
  String? ClientEngagement = "CRM/ClientEngagement"; //post
  String? GetDefaultVal = "CommonLibrary/GetDefaultVal"; //post
  String? FillDocMast = "CommonLibrary/FillDocMast"; //post
  String? FillStatusList = "CommonLibrary/FillStatusList"; //post
  String? ProcessNfgQualityLookup = "QualityControl/ProcessNFGQualityLookup"; //post
  String? GetTransDetailsForQC = "QualityControl/GetTransDetailsForQC"; //post
  String? FillLocations = "CommonLibrary/FillLocations"; //post
  String? RejectionReworkHelpForQC = "QualityControl/RejectionReworkHelpForQC"; //post
  String getCheckDevice = "ProdSchedule/CheckDevice";
  String? ForgotPassword = "Authenticate/ForgotPassword"; //Post
  String verifyotp = "APS_API/UserAuthOTP";

  String? EditDeleteNote = "Activities/AddActivity"; //Post
  String? GetNotification = "Notification/GetNotification"; //Post
  String? GetSoList = "SalesOrder/GetSOList"; //Post

  Future<RejectionReworkHelpForQcResponseModel> RejectionReworkHelpForQCDetails(
      RejectionReworkHelpForQCRequestModel data) async {
    try {
      prefs = await SharedPreferences.getInstance();
      //Return String
      String? stringValuebaseURL = prefs!.getString('URL');
      String? stringValuebaseTOKEN = prefs!.getString('TOKEN');
      String url = stringValuebaseURL! + "/" + RejectionReworkHelpForQC!;
      print(url);
      var headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      };
      var response =
          await http.post(Uri.parse(url), headers: headers, body: json.encode(data.toJson()));
      print('URL:$url');
      print(data.toJson());
      print(response.statusCode);
      if (response.statusCode == 401) {}
      return RejectionReworkHelpForQcResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print(data.toJson());
      print("Exception occured: $error stackTrace: $stacktrace");
      return RejectionReworkHelpForQcResponseModel.withError(error.toString());
    }
  }

  Future<FillLocationsResponseModel> FillLocationsDetails(FillLocationsRequestModel data) async {
    try {
      prefs = await SharedPreferences.getInstance();
      //Return String
      String? stringValuebaseURL = prefs!.getString('URL');
      String? stringValuebaseTOKEN = prefs!.getString('TOKEN');
      String url = stringValuebaseURL! + "/" + FillLocations!;
      print(url);
      var headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      };
      var response =
          await http.post(Uri.parse(url), headers: headers, body: json.encode(data.toJson()));
      print('URL:$url');
      print(data.toJson());
      print(response.statusCode);
      if (response.statusCode == 401) {}
      return FillLocationsResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print(data.toJson());
      print("Exception occured: $error stackTrace: $stacktrace");
      return FillLocationsResponseModel.withError(error.toString());
    }
  }

  Future<GetTransDetailsForQcResponseModel> GetTransDetailsForQCDetails(
      GetTransDetailsForQCRequestModel data) async {
    try {
      prefs = await SharedPreferences.getInstance();
      //Return String
      String? stringValuebaseURL = prefs!.getString('URL');
      String? stringValuebaseTOKEN = prefs!.getString('TOKEN');
      String url = stringValuebaseURL! + "/" + GetTransDetailsForQC!;
      print(url);
      var headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      };
      var response =
          await http.post(Uri.parse(url), headers: headers, body: json.encode(data.toJson()));
      print('URL:$url');
      print(data.toJson());
      print(response.statusCode);
      if (response.statusCode == 401) {}
      return GetTransDetailsForQcResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print(data.toJson());
      print("Exception occured: $error stackTrace: $stacktrace");
      return GetTransDetailsForQcResponseModel.withError(error.toString());
    }
  }

  Future<ProcessNfgQualityLookupResponseModel> ProcessNFGQualityLookupDetails(
      ProcessNFGQualityLookupRequestModel data) async {
    try {
      prefs = await SharedPreferences.getInstance();
      //Return String
      String? stringValuebaseURL = prefs!.getString('URL');
      String? stringValuebaseTOKEN = prefs!.getString('TOKEN');
      String url = stringValuebaseURL! + "/" + ProcessNfgQualityLookup!;
      print(url);
      var headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      };
      var response =
          await http.post(Uri.parse(url), headers: headers, body: json.encode(data.toJson()));
      print('URL:$url');
      print(data.toJson());
      print(response.statusCode);
      if (response.statusCode == 401) {}
      return ProcessNfgQualityLookupResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print(data.toJson());
      print("Exception occured: $error stackTrace: $stacktrace");
      return ProcessNfgQualityLookupResponseModel.withError(error.toString());
    }
  }

  Future<FillStatusListResponseModel> FillStatusListDetails(FillStatusListRequestModel data) async {
    try {
      prefs = await SharedPreferences.getInstance();
      //Return String
      String? stringValuebaseURL = prefs!.getString('URL');
      String? stringValuebaseTOKEN = prefs!.getString('TOKEN');
      String url = stringValuebaseURL! + "/" + FillStatusList!;
      print(url);
      var headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      };

      print('url fill------------> $url');
      print('body fill------------> ${json.encode(data.toJson())}');
      var response =
          await http.post(Uri.parse(url), headers: headers, body: json.encode(data.toJson()));
      print('URL:$url');
      print(data.toJson());
      print(response.statusCode);
      if (response.statusCode == 401) {}
      return FillStatusListResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print(data.toJson());
      print("Exception occured: $error stackTrace: $stacktrace");
      return FillStatusListResponseModel.withError(error.toString());
    }
  }

  Future<FillDocMastResponseModel> FillDocMastDetails(FillDocMastRequestModel data) async {
    try {
      prefs = await SharedPreferences.getInstance();
      //Return String
      String? stringValuebaseURL = prefs!.getString('URL');
      String? stringValuebaseTOKEN = prefs!.getString('TOKEN');
      String url = stringValuebaseURL! + "/" + FillDocMast!;
      print(url);
      var headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      };
      var response =
          await http.post(Uri.parse(url), headers: headers, body: json.encode(data.toJson()));
      print('URL:$url');
      print(data.toJson());
      print(response.statusCode);
      if (response.statusCode == 401) {}
      return FillDocMastResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print(data.toJson());
      print("Exception occured: $error stackTrace: $stacktrace");
      return FillDocMastResponseModel.withError(error.toString());
    }
  }

  Future<GetDefaultValResponseModel> GetDefaultValDetails(GetDefaultValRequestModel data) async {
    try {
      prefs = await SharedPreferences.getInstance();
      //Return String
      String? stringValuebaseURL = prefs!.getString('URL');
      String? stringValuebaseTOKEN = prefs!.getString('TOKEN');
      String url = stringValuebaseURL! + "/" + GetDefaultVal!;
      print(url);
      var headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      };
      var response =
          await http.post(Uri.parse(url), headers: headers, body: json.encode(data.toJson()));
      print('URL:$url');
      print(data.toJson());
      print(response.statusCode);
      if (response.statusCode == 401) {}
      return GetDefaultValResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print(data.toJson());
      print("Exception occured: $error stackTrace: $stacktrace");
      return GetDefaultValResponseModel.withError(error.toString());
    }
  }

  Future<LoginResponseModel> getLoginDetails(LoginRequestModel data) async {
    try {
      prefs = await SharedPreferences.getInstance();
      //Return String
      String? stringValuebaseURL = prefs!.getString('URL');
      String? stringValuebaseTOKEN = prefs!.getString('TOKEN');
      String url = stringValuebaseURL! + "/" + loginApi!;
      print(url);
      var headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      };
      var response =
          await http.post(Uri.parse(url), headers: headers, body: json.encode(data.toJson()));
      print('URL:$url');
      print(data.toJson());
      print(response.statusCode);
      if (response.statusCode == 401) {}
      return LoginResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print(data.toJson());
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }

  Future<ClientEngagementResponseModel> ClientEngagementDetails(
      ClientEngagementReqestModel data) async {
    try {
      prefs = await SharedPreferences.getInstance();
      //Return String
      String? stringValuebaseURL = prefs!.getString('URL');
      String? stringValuebaseTOKEN = prefs!.getString('TOKEN');

      String url = stringValuebaseURL! + "/" + ClientEngagement!;
      print(url);
      //_dio.options.contentType = Headers.jsonContentType;

      //Response response = await _dio.post(url, data: data.toJson());

      var headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      };

      var response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(data));
      print('URL:$url');
      print(data.toJson());
      return ClientEngagementResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print(data.toJson());
      print("Exception occured: $error stackTrace: $stacktrace");
      return ClientEngagementResponseModel.withError(error.toString());
    }
  }

  // ***************************************************************************************

  Future<SoListModel> fetchSoList() async {
    // const String baseUrl =
    //     // 'http://125.99.42.182:8392/ERPAPI/api/SalesOrder/GetSOList';

    String baseUrl = "${AppConfig.BASE_URL}$GetSoList";
    print("****** $baseUrl");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? UserID = prefs.getString('USERID');
    String? OrStID = prefs.getString('ORGSTRUCTID');
    String? Token = prefs.getString('TOKEN');
    String? PosID = prefs.getString('POSID');
    String? controlno = prefs.getString('CONTROLNO');
   // prefs = await SharedPreferences.getInstance();

    strSalesOrder = prefs.getString('SalesOrderData');

    final body = {
      "XMLFILE": {
        "FLAG": 1,
        // "LASTSYNCDATE": strSalesOrder ?? "01-Jan-1900 00:00:00",
        "LASTSYNCDATE": "01-Jan-1900 00:00:00",
        "MID": 0,
        "ORGSTRUCTID": OrStID,
        "POSID": PosID,
        "TOKEN": Token,
        "USERID": UserID,
        "CONTROLNO":controlno,
      },
    };
    print(body);
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print(response.body);
    // Access the SYNCDATETIME value
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    String salesorderdata = jsonResponse['DATA']['SYNCDATETIME'];

    // Print or use the SYNCDATETIME value
    print("***&&&&***&&& $salesorderdata"); // Output: "2024-10-07 12:19:18"
    if (response.statusCode == 200) {
      if (prefs != null) {
        prefs.setString("SalesOrderData", salesorderdata ?? "01-Jan-1900 00:00:00");
      }
      return SoListModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  // ***************************************************************************************

  Future<GetNotificationModel> getNotification(String nID) async {
    try {
      LoginResponseModel? user = await SecureStorageService.getUser();

      // Check login/token
      if (user?.data?.token == null ||
          (user?.data?.token?.isEmpty ?? true)) {
        return GetNotificationModel();
      }

      final body = {
        "XMLFILE": {
          "FLAG": "0",
          "NID": nID,
          "NOTIFYDATETIME": "",
          "ORGSTRUCTID": user?.data?.orgstrucid ?? "",
          "POSID": user?.data?.posid ?? "",
          "TOKEN": user?.data?.token ?? "",
          "USERID": user?.data?.userid ?? "",
          "CONTROLNO": user?.data?.controlno ?? "",
          "SearchTxtbox": "",
          "STATUSID":"0",
          "ACTIVITYID":"0",
          "DESC":""
        }
      };

      print(AppConfig.BASE_URL+ GetNotification!);
      print("Request Body: ${jsonEncode(body)}");

      final response = await _dio.post(
        AppConfig.BASE_URL+ GetNotification!,
        data: jsonEncode(body),
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },

          // Accept all status codes so Dio won't throw on 300
          validateStatus: (status) => true,
        ),
      );

      print("Status Code: ${response.statusCode}");
  //    print("Response Data: ${response.data}");

      // Handle 200 and 300
      if (response.statusCode == 200 ||
          response.statusCode == 300) {
        if (response.data is String) {
          return GetNotificationModel.fromJson(
            jsonDecode(response.data),
          );
        }

        return GetNotificationModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw Exception(
        'Failed to load data. Status Code: ${response.statusCode}',
      );
    } on DioException catch (e) {
      print("Dio Error: ${e.message}");

      // Handle 300 responses that still come through exceptions
      if (e.response != null) {
        print("Error Status Code: ${e.response?.statusCode}");
        print("Error Response: ${e.response?.data}");

        if (e.response?.statusCode == 300) {
          if (e.response!.data is String) {
            return GetNotificationModel.fromJson(
              jsonDecode(e.response!.data),
            );
          }

          return GetNotificationModel.fromJson(
            e.response!.data as Map<String, dynamic>,
          );
        }
      }

      throw Exception(
        e.response?.data?.toString() ??
            e.message ??
            'Something went wrong',
      );
    } catch (e) {
      print("getNotification Error: $e");
      rethrow;
    }
  }

  // ***************************************************************************************

  Future<EditNoteModel> EditNote(
      String content, String subject, String activityid, String flag) async {
    // const String baseUrl = 'http://125.99.42.182:8392/ERPAPI/api/Activities/AddActivity';

    String baseUrl = "${AppConfig.BASE_URL}$EditDeleteNote";
    print("****** $baseUrl");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? UserID = prefs.getString('USERID');
    String? OrStID = prefs.getString('ORGSTRUCTID');
    String? Token = prefs.getString('TOKEN');
    String? PosID = prefs.getString('POSID');

    final body = {
      "XMLFILE": {
        "ACTIVITYID": activityid,
        "ASSIGNEDTO": 0,
        "CALLPLANTYPEID": 0,
        "CALLTYPEID": 0,
        "CONTACTPERSONID": 0,
        "CONTENT": content,
        "FLAG": flag,
        "ORGSTRUCTID": OrStID,
        "POSID": PosID,
        "SUBJECT": subject,
        "TYPEID": 3,
        "TOKEN": Token,
        "USERID": UserID
      }
    };

    print(body);

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print("Edit Note Body ${response.body}");
      return EditNoteModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<ProjectWiseDetailResponse> fetchMasterProjectData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValuebaseOrgStructId = prefs.getString('ORGSTRUCTID');
    String? stringValuebaseUserId = prefs.getString('USERID');

    final url = Uri.parse(AppConfig.RAW_BASE_URL +
        '/erpapi/api/SalesOrder/GetMProjno/?Orgstrucid=$stringValuebaseOrgStructId&USERID=$stringValuebaseUserId&FLAG=13');
    print(url);

    final response = await http.get(url);
    print(response);
    if (response.statusCode == 200) {
      return ProjectWiseDetailResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<void> getNotificationCount(BuildContext context) async {
    try {
      final notificationProvider = Provider.of<GetNotificationProvider>(context, listen: false);

      // Wait for data to be fetched
      await notificationProvider.GetNotification("0");
      if (!context.mounted) return;
      // Safely access the list
      List<NitificationLIST> notifications =
          notificationProvider.getNotificationModel?.dATA?.lIST ?? [];

      // Sort unread first
      notifications.sort((a, b) {
        return (a.ISREAD == "0" ? 0 : 1).compareTo(b.ISREAD == "0" ? 0 : 1);
      });

      // Count unread
      Constant.unreadCount = notifications.where((item) => item.ISREAD == "0").length;
      final unreadProvider = Provider.of<UnreadNotificationProvider>(context, listen: false);
      unreadProvider.setUnreadCount(
        notifications.where((item) => item.ISREAD == "0").length,
      );
      print("Unread count: $Constant.unreadCount");
    } catch (e) {
      print("Error fetching notification count: $e");
    }
  }
  Future<UpdatedNotificationStatusModel?> UpdateNotificationStatus(BuildContext context,String nid,
      {
        String isread = '1',
        String dismiss = '0',
        String isview = '1',
      }) async {
    final url = "${AppConfig.RAW_BASE_URL}/ERPAPI/API/Notification/UpdateNotificationStatus";
 print("url : $url");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? UserID = prefs.getString('USERID');
    String? Token = prefs.getString('TOKEN');
    String? orStID = prefs.getString('ORGSTRUCTID');
    String? controlno = prefs.getString('CONTROLNO');


    final body = {
      "XMLFILE": {
        "NID": nid,
        "USERID": UserID,
        "TOKEN": Token,
        "ORGSTRUCTID":orStID,
        "CONTROLNO":controlno,
        "ISREAD":"1",
        "DISMISS" : "0",
        "ISVIEW":"1"
      }
    };

    print("Body==>>> $body");

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = jsonDecode(response.body);
    print("Response Of UpdateStatus==>> $data");
    try {
      if (response.statusCode == 200) {
        final status = data['DATA']['Status'];
        print("Mystatus===>>> $status");
        getNotificationCount(context);
        return UpdatedNotificationStatusModel.fromJson(data);
      } else {
        return UpdatedNotificationStatusModel.fromJson(data);
      }
    } catch (e) {
      print(e);
    }
  }
  Future<UserAuthOTPResponseModel> authenticateUser(
      BuildContext context,
      String token,
      String mobileNo,
      String userId,
      String strFlag,
      String strOtp,
      ) async {
    try {



      final String url = AppConfig.BASE_URL+"$verifyotp";

      final Map<String, dynamic> requestBody = {
        "Flag": strFlag,
        "MOBILENO": mobileNo,
        "OTP": strOtp,
        "USERID": userId,
      };

      final dio = Dio();
      print("URL: $url");
      print("Request: $requestBody");
      final response = await dio.post(
        url,
        data: requestBody,
        options: Options(
          headers: {
            'X-Auth-Token': token,
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print("URL: $url");
      print("Request: $requestBody");
      print("Response: ${response.data}");
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        return UserAuthOTPResponseModel.fromJson(response.data);
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio Error: ${e.response?.data}");
      throw Exception(e.response?.data ?? "Something went wrong");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
/*  Future<UserAuthOTPResponseModel> authenticateUser(BuildContext context,
      String mobileNo, String userId, String strFlag, String strOtp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValuebaseTOKEN = prefs.getString('TOKEN');

    //Return String
    String stringValuebaseURL = prefs.getString('baseURL')?? "";
    final String url = AppConfig.BASE_URL +'APS_API/UserAuthOTP';
   // final String url = 'http://125.99.42.182:8442/ERPAPI/api/APS_API/UserAuthOTP';

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      "Flag": strFlag,
      "MOBILENO": mobileNo,
      "OTP": strOtp, // You can modify this as needed
      "USERID": userId,
    };

    // Make the API call
    final response = await post(
      Uri.parse(url),
      body: jsonEncode(requestBody),
      headers: {
        'X-Auth-Token': stringValuebaseTOKEN!,
        'Content-type': 'application/json; charset=utf-8',
        'Accept': 'application/json; charset=UTF-8',
      },
    );
    print(url);
    print(jsonEncode(requestBody));
    print(response.body);
    print(response.statusCode);
    if (response.headers.containsKey(HttpHeaders.contentEncodingHeader) ||
        response.headers[HttpHeaders.contentEncodingHeader] == 'Gzip') {
      final List<int> gzipBytes = response.bodyBytes;
      final List<int> resultBytes = GZipCodec().decode(gzipBytes);

      final result = utf8.decode(resultBytes);

      return UserAuthOTPResponseModel.fromJson(json.decode(result));
    } else {
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        String message = jsonResponse['ERRORMSG']['MSG'];


      }

      return UserAuthOTPResponseModel.fromJson(json.decode(response.body));
    }
  }*/
  Future<ServiceEngineerRegisterResponseModel> registerServiceEngineer(
      BuildContext context,
      String mobileNo,
      String base64String1,
      String base64String2,
      String strUserId,
      String strKoelUserId) async {
    // FirebaseApi firebaseApi = FirebaseApi();
    //  String? token = await firebaseApi.getFcmToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    ServiceEngineerRegisterResponseModel _response;
   final String url = AppConfig.BASE_URL +'APS_API/UploadBiometricDetails';
    //final String url = 'http://125.99.42.182:8442/ERPAPI/api/APS_API/UploadBiometricDetails';

    String? stringValuebaseTOKEN = prefs!.getString('TOKEN');
    String? stringValuebaseFCMKey = prefs!.getString('FCMTOKEN');
    String decodedResponse;
    var url1 = Uri.parse(url);
    var request = http.MultipartRequest('POST', url1);
    var responseData;
    //String? fcmtoken="ePgIeCbLRAG_59zTgnTqOA:APA91bFDTDlTnIoKskyGMsqxPwhxECv84eXfPw1kPftCm-PWlDjlzsjwKLiTDBb712amfVHTfQS7mQ3gyo6CT4tcbEXgjMS9ek_Isr8jXUNS97bQx-3tmOI";

    // Add headers
    request.headers['X-Auth-Token'] = stringValuebaseTOKEN ?? '';
    // Add the Base64 string as text fields
    request.fields['USERID'] = strUserId;

    request.fields['PHOTO'] = base64String1;


    request.fields['FINGERPRINT1'] = "";
    request.fields['FINGERPRINT2'] = "";
    request.fields['FINGERPRINT3'] = "";
    request.fields['SERVIVEENIGMOBNO'] = mobileNo;
    String? fcmtoken = await AppPreferences.getFcmToken();
    if (Platform.isAndroid) {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          "FCM token not available. Please check internet or reinstall the app.",
        );
      }

      fcmtoken =token;
      request.fields['FCMKEY'] = fcmtoken!;

    }else
      {
        request.fields['FCMKEY'] = stringValuebaseFCMKey!;

      }
  // request.fields['FCMKEY'] = fcmtoken!;
    request.fields['AUTHLOGINID'] = strKoelUserId;
    request.fields['AUTHUSERPHOTO'] = base64String2;
    print('Sending request to: $url');
    print('Request Headers: ${request.headers}');
    print('Request Fields: ${request.fields}');
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        responseData = await http.Response.fromStream(response);
      } else {
        print('Error: ${response.statusCode}');
        return Future.error('Failed to register service engineer');
      }
    } catch (e) {
      print('Error: $e');
    }
    // Check for gzip encoding
    if (responseData.headers.containsKey(HttpHeaders.contentEncodingHeader) &&
        responseData.headers[HttpHeaders.contentEncodingHeader] == 'GZip') {
      final List<int> gzipBytes = responseData.bodyBytes;
      final List<int> resultBytes = GZipCodec().decode(gzipBytes);
      final result = utf8.decode(resultBytes);
      final List<dynamic> data = json.decode(result);
      decodedResponse = utf8.decode(resultBytes);
      // Parse the JSON response
      final dynamic jsonResponse = json.decode(decodedResponse);
      print('response body : ${jsonResponse}');
      if (jsonResponse is List<dynamic>) {
        // If the response is a list, you can handle it like this:
        return ServiceEngineerRegisterResponseModel.fromJson(jsonResponse[0]); // Adjust based on your requirements
      } else if (jsonResponse is Map<String, dynamic>) {
        // If the response is a map
        return ServiceEngineerRegisterResponseModel.fromJson(jsonResponse);
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      // Expecting a list response
      return ServiceEngineerRegisterResponseModel.fromJson(json.decode(responseData.body));
    }
  }

  Future<List<LoginModel>> getFingerprintLoginDetails(
      String userId, String password) async {

    userId = userId.trim();
    password = password.trim();

    String url =
        '${AppConfig.BASE_URL}APS_API/GetLoginDetails'
        '?UserId=${Uri.encodeQueryComponent(userId)}'
        '&Password=${Uri.encodeQueryComponent(password)}';

    print(url);

    final response = await post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      // Parse the JSON response
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((user) => LoginModel.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load login details');
    }
  }

  Future<LoginResponseModel> getLoginDetails1(LoginRequestModel data) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      //Return String
      String stringValuebaseURL = prefs.getString('baseURL')?? "";
      String url = stringValuebaseURL +  "/ERPAPI/API/" + login;
      //apibaseurl + "/" + login;



      var response = await ApiRequest.post(url: url , headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Expose-Headers": "*",
        "Access-Control-Allow-Credentials":"true",
        "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
        "Access-Control-Allow-Methods": "POST, OPTIONS,GET,HEAD"
      }, body: json.encode(data.toJson()));
      print(data.toJson());


      return LoginResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {

      print("Exception occured: $error stackTrace: $stacktrace");
      if(prefs!=null){
        prefs!.setString("ERROR", error.toString());
      }
      return LoginResponseModel.withError(error.toString());
    }
  }
  Future<KnowYourProductsModel?> getKnowYourProducts() async {

    final url = "${AppConfig.RAW_BASE_URL}/ERPAPI/api/KnowledgeBase/GetSolCategory";
    print(url);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userID = prefs.getString('USERID');
    String? orStID = prefs.getString('ORGSTRUCTID');

    String? controlno = prefs.getString('CONTROLNO');

    final body = {
      "XMLFILE": {
        "DESC": "",
        "USERID": userID,
        "ORGSTRUCTID":orStID,
        "CONTROLNO":controlno


      }
    };
    /*final queryParams = {
      "DESC": "",
      "USERID": UserID ?? "",
    };*/
    print("Body==>>> $body");
    try {
    //  final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (!kIsWeb) HttpHeaders.acceptEncodingHeader: 'gzip',
        },
        body: jsonEncode(body),
      );
     // final response = await http.get(uri, headers: headers,);
      //final data = jsonDecode(response.body);
      //print("Response Of UpdateStatus==>> $data");
      if (response.statusCode == 200) {
        if (kIsWeb) {
          // Web: http already handles gzip
          final data = jsonDecode(response.body);
          return KnowYourProductsModel.fromJson(data);
        } else {
          // Windows/Native: you can still decode manually if needed
          //  final data = jsonDecode(response.body);
          //  return KnowYourProductsModel.fromJson(data);
          if (response.headers.containsKey(HttpHeaders.contentEncodingHeader) ||
              response.headers[HttpHeaders.contentEncodingHeader] == 'gzip') {
            // Decode the Gzip-encoded response
            final List<int> gzipBytes = response.bodyBytes;
            final List<int> resultBytes = GZipCodec().decode(gzipBytes);

            final result = utf8.decode(resultBytes);
            var data = jsonDecode(result);

            return KnowYourProductsModel.fromJson(data);
          }
        }
      } else {
        print("Request failed: ${response.statusCode}");
      }
    } catch (e, t) {
      print("Error calling API: $e");
      print("Trace: $t");
    }
    return null;
  }

  Future<ProductsDetailsModel?> getProductDetails(String solId,String sOLFOLID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url =
        "${AppConfig.RAW_BASE_URL}/ERPAPI/API/KnowledgeBase/GetSolution";
  print(url);
    var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      'X-Auth-Token': "069cce18-6ad4-48ba-92c6-3f80153b0635",
      if (!kIsWeb) HttpHeaders.acceptEncodingHeader: 'gzip', // only for Windows/native
    };


    String? UserID = prefs.getString('USERID');
    String? orStID = prefs.getString('ORGSTRUCTID');

    String? controlno = prefs.getString('CONTROLNO');
    final body = {
      "XMLFILE": {
        "SOLID": solId,
        "SOLFOLID": sOLFOLID,
        "DESC": "",
        "USERID": UserID,
        "ORGSTRUCTID":orStID,
        "CONTROLNO" : controlno

      }
    };

    try {
      //final response = await http.get(Uri.parse(url), headers: headers);
      final response = await post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (!kIsWeb) HttpHeaders.acceptEncodingHeader: 'gzip',
        },
        body: jsonEncode(body),
      );
      print(jsonEncode(body));
      if (response.statusCode == 200) {
        if (kIsWeb) {
          // Web → http handles gzip, just use body
          final data = jsonDecode(response.body);
          return ProductsDetailsModel.fromJson(data);
        } else {
          // Windows/Native → still, http usually handles gzip itself
          //  final data = jsonDecode(response.body);
          //   return ProductsDetailsModel.fromJson(data);
          if (response.headers.containsKey(HttpHeaders.contentEncodingHeader) ||
              response.headers[HttpHeaders.contentEncodingHeader] == 'gzip') {
            // Decode the Gzip-encoded response
            final List<int> gzipBytes = response.bodyBytes;
            final List<int> resultBytes = GZipCodec().decode(gzipBytes);

            final result = utf8.decode(resultBytes);
            var data = jsonDecode(result);

            return ProductsDetailsModel.fromJson(data);
          }}
      }
    } catch (e, t) {
      print("Error calling API: $e");
      print("Trace: $t");
    }

    return null;
  }
  Future<List<TransactionModel>> fetchTransactions(String flag) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String apiUrl =
        "${AppConfig.RAW_BASE_URL}/ERPAPI/API/LOTDetails/GetBarCodeScanDetails";
    String? UserID = prefs.getString('USERID');
    final requestBody = {
      "XMLFILE": {
        "FLAG": flag,
        "USERID": UserID
      }
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(requestBody),
    );
    print(apiUrl);
    print(jsonEncode(requestBody));
    print(response);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final transactionResponse  =
            TransactionResponse.fromJson(decoded);
        return transactionResponse.transactions;


    } else {
      throw Exception("API Failed: ${response.statusCode}");
    }
  }
   Future<TransactionModel_FinancialYear> fetchTransactionsfinancial(String flag) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String apiUrl =
        "${AppConfig.RAW_BASE_URL}/ERPAPI/API/LOTDetails/GetBarCodeScanDetails";
    String? UserID = prefs.getString('USERID');
    final requestBody = {
      "XMLFILE": {
        "FLAG": flag,
        "USERID": UserID
      }
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(requestBody),
    );
    print(apiUrl);
    print(jsonEncode(requestBody));
    print(response);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final transactionResponse =
            TransactionModel_FinancialYear.fromJson(decoded);
        return transactionResponse;


    } else {
      throw Exception("API Failed: ${response.statusCode}");
    }
  }
  Future<List<TransactionModel>> fetchPlantLIst(String? orgstID) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var controlno= prefs.getString('CONTROLNO');
    print("controlno : $controlno");
    String apiUrl =
        "${AppConfig.RAW_BASE_URL}/ERPAPI/API/LOTDetails/GetBarCodeScanDetails";
    String? UserID = prefs.getString('USERID');

    final requestBody = {
      "XMLFILE": {
        "FLAG": "7",
        "USERID": UserID,
        "ORGSTRUCID":orgstID
      }
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(requestBody),
    );
print(apiUrl);
print(jsonEncode(requestBody));
print(response);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final transactionResponse =
      TransactionResponse.fromJson(decoded);

      return transactionResponse.transactions;
    } else {
      throw Exception("API Failed: ${response.statusCode}");
    }
  }
  Future<CheckDeviceResponseModel> getCheckDeviceDetails(CheckDeviceRequestModel data) async {
    String url="";
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
//Return String


      //   url = "${AppConfig.BASE_URL}/" + getCheckDevice;
      url = "${AppConfig.BASE_URL}" + getCheckDevice;
      final headers = <String, String>{
        'Content-Type': 'application/json'

      };

      var response = await ApiRequest.post(url: url, headers: headers, body: json.encode(data.toJson()));
      print('URL1:$url');
      print(data.toJson());
      return CheckDeviceResponseModel.fromJson(json.decode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
//print('URL:$url');
//print(data.toJson());
      return CheckDeviceResponseModel.withError(error.toString());
    }
  }

  Future<UserAuthOTPResponseModel> authenticateUserBiometry(BuildContext context,
      String mobileNo, String userId, String strFlag, String strOtp) async {
    LoginResponseModel? user = await SecureStorageService.getUser();
    // Check login/token
    if (user?.data?.token == null ||
        (user?.data?.token?.isEmpty ?? true)) {
      return UserAuthOTPResponseModel();
    }
    final String url = '${AppConfig.BASE_URL}APS_API/UserAuthOTP';
    // final String url = 'http://125.99.42.182:8442/ERPAPI/api/APS_API/UserAuthOTP';

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      "Flag": strFlag,
      "MOBILENO": mobileNo,
      "OTP": strOtp, // You can modify this as needed
      "USERID": userId,
    };

    // Make the API call
    final responsebiometry = await post(
      Uri.parse(url),
      body: jsonEncode(requestBody),
      headers: {
        'X-Auth-Token': user!.data!.token!,
        'Content-type': 'application/json; charset=utf-8',
        'Accept': 'application/json; charset=UTF-8',
      },
    );
    print(url);
    print(jsonEncode(requestBody));

    print(responsebiometry.statusCode);
    if (responsebiometry.headers.containsKey(HttpHeaders.contentEncodingHeader) ||
        responsebiometry.headers[HttpHeaders.contentEncodingHeader] == 'Gzip') {
      final List<int> gzipBytes = responsebiometry.bodyBytes;
      final List<int> resultBytes = GZipCodec().decode(gzipBytes);

      final result = utf8.decode(resultBytes);

      return UserAuthOTPResponseModel.fromJson(json.decode(result));
    } else {
      if (responsebiometry.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responsebiometry.body);
        String message = jsonResponse['ERRORMSG']['MSG'];


      }

      return UserAuthOTPResponseModel.fromJson(json.decode(responsebiometry.body));
    }
  }

  Future<ChangePasswordResponseModel> ChangePasswordDetails(
      ChangePasswordRequestModel data) async {
    try {
      String url = AppConfig.BASE_URL+"Authenticate/ChangePassword";
      print("Response: ${url}");
      final response = await _dio.post(
        url,
        data: data.toJson(),
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      print("Response: ${url}");
      print("Response: ${data.toJson()}");

      // Parse response safely
      return ChangePasswordResponseModel.fromJson(response.data);
    } catch (error, stacktrace) {
      print("Exception occurred: $error stackTrace: $stacktrace");
      print("Response: ${data.toJson()}");
      // Return a model with error info instead of empty
      return ChangePasswordResponseModel.withError(error.toString());
    }
  }
  Future<ForgotPasswordResponse> forgotpassword(
      BuildContext context,
      String strFlag,
      String stremailid,
      ) async {
    try {



      final String url = AppConfig.BASE_URL+"$ForgotPassword";

      final Map<String, dynamic> requestBody = {
        "XMLFILE": {
          "FLAG": strFlag,
          "EMAILID": stremailid,
        }
      };
      print("URL: $url");
      print("Request: $requestBody");
      final dio = Dio();

      final response = await dio.post(
        url,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );


      print("Response: ${response.data}");
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        return ForgotPasswordResponse.fromJson(response.data);
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio Error: ${e.response?.data}");
      throw Exception(e.response?.data ?? "Something went wrong");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  Future<LoginResponseModel?> logindata({
    required String userId,
    required String password,
  })
  async {
    try {
      String deviceIp = await DeviceUtils.getLocalIp();
      //String? fcmtoken="ePgIeCbLRAG_59zTgnTqOA:APA91bFDTDlTnIoKskyGMsqxPwhxECv84eXfPw1kPftCm-PWlDjlzsjwKLiTDBb712amfVHTfQS7mQ3gyo6CT4tcbEXgjMS9ek_Isr8jXUNS97bQx-3tmOI";
       String? fcmtoken = await AppPreferences.getFcmToken();
      if (Platform.isAndroid) {
        String? token = await FirebaseMessaging.instance.getToken();
        if (token == null || token.isEmpty) {
          throw Exception(
            "FCM token not available. Please check internet or reinstall the app.",
          );
        }

        fcmtoken =token;
        //token;
      } else {
        String token = await DeviceTokenService.getOrCreateToken();
        // ✅ Windows fallback
        fcmtoken = token;
      }
      // ✅ CHECK FCM TOKEN FIRST
      /*  if (fcmtoken == null || fcmtoken.isEmpty) {
        throw Exception(
          "FCM token not available. Please check internet or reinstall the app.",
        );
      }*/
      print(AppConfig.BASE_URL+ _loginEndpoint);
      final requestData = {
        "XMLFILE": {
          "FLAG": "1",
          "LOGINID": userId,
          "PASSWORD": password,
          "RFID": "",
          "USERID": 0,
          "DEVICENAME": "",
          "DEVICEIP": deviceIp,
          "FCMKEY": fcmtoken,
          "OLDFCMKEY": ""
        }
      };

      print("=========== LOGIN API REQUEST ===========");
      print("URL      : ${AppConfig.BASE_URL + _loginEndpoint}");
      print("Request  : $requestData");
      print("=========================================");
      final response = await _dio.post(
        AppConfig.BASE_URL+ _loginEndpoint,
        data: requestData,
      );


      print(response);
      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data is Map<String, dynamic>) {
          final loginModel = LoginResponseModel.fromJson(data);
          final loginData = loginModel.data;

          await AppPreferences.saveLoginToken(loginData!.token ?? "");
          await AppPreferences.saveUserId(loginData.userid ?? "");
          await AppPreferences.saveUserName(loginData.username ?? "");
          await AppPreferences.savepositionDesc(loginData.posdesc ?? "");

          if (loginData == null) {
            throw Exception("Invalid response from server");
          }

        /*  if (loginData.status.isEmpty ||
              loginData.status.toLowerCase() != "true") {
            throw Exception(
              loginData.message.toString().isNotEmpty
                  ? loginData.message .toString()
                  : "Login failed",
            );
          }*/
          if ((loginData.status ?? "").toLowerCase() != "true") {
            throw Exception(
              loginData.message?.isNotEmpty == true
                  ? loginData.message
                  : "  Login failed",
            );
          }
          final token = loginData.token;

          if (token.isEmpty) {
            throw Exception("Token missing in response");
          }

          await _secureStorage.saveToken(token);

          return loginModel;
        }
      } else {
        throw Exception(
            "Login failed. Status Code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("Dio Error: $e");
      throw Exception("Network error. Please try again.");
    }
  }
  Future<UpdateUserDeviceInfoResponseModel> updateUserDeviceInfoDetails(
      UpdateUserDeviceInfoRequestModel data) async {
    try {
      //String url = AppConfig.BASE_URL + UpdateUserDeviceInfo!;
      print(AppConfig.BASE_URL+ "Notification/UpdateUserDeviceInfo");
     print(json.encode(data.toJson()));



      final response = await _dio.post(
        AppConfig.BASE_URL+ "Notification/UpdateUserDeviceInfo",
        data: data.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      print(response.data);
      if (response.statusCode == 401) {
        /*var prefs = await SharedPreferences.getInstance();
        prefs.setBool("ISLogout", false);
        prefs.setString("TOKEN", '');*/
        //Get.offAll(LoginPage());
      }

      return UpdateUserDeviceInfoResponseModel.fromJson(response.data);
    } catch (error, stacktrace) {
      print(data.toJson());
      print("Exception occured: $error stackTrace: $stacktrace");

      return UpdateUserDeviceInfoResponseModel.withError(error.toString());
    }
  }

/*  Future<List<TRANSACTIONSASN>> fetchASNList() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    var controlno = prefs.getString('CONTROLNO');
    String? userID = prefs.getString('USERID');
    String? orgstID = prefs.getString('ORGSTRUCTID');


    String apiUrl =
        "${AppConfig.BASE_URL}ERPAPI/API/LOTDetails/GetBarCodeScanDetails";


    final requestBody = {
      "XMLFILE": {
        "FLAG": "14",
        "USERID": userID,
        *//*"ORGSTRUCID": "4",*//*
        "ORGSTRUCID": orgstID,
        "CONTROLNO": controlno,
        "MID": "0",
        "DOCID": "0",
      }
    };


    debugPrint(apiUrl);
    debugPrint(jsonEncode(requestBody));


    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(requestBody),
    );


    debugPrint("Response : ${response.body}");


    if (response.statusCode == 200) {

      final decoded = jsonDecode(response.body);


      ASNScanningReaponse result =
      ASNScanningReaponse.fromJson(decoded);


      return result
          .tRANSACTIONDETAILS
          ?.tRANSACTIONS ??
          [];

    } else {

      throw Exception(
        "API Failed : ${response.statusCode}",
      );
    }
  }*/
  Future<List<TRANSACTIONSASN>> fetchASNList({
    required String mid,
    required String docId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var controlno = prefs.getString('CONTROLNO');
    String? userID = prefs.getString('USERID');
    String? orgstID = prefs.getString('ORGSTRUCTID');
   // String url ="http://10.0.0.223:8532/ERPAPI/API/";
    String apiUrl =
        "${AppConfig.BASE_URL}LOTDetails/GetBarCodeScanDetails";
   /* String apiUrl =
        "${AppConfig.BASE_URL}LOTDetails/GetBarCodeScanDetails";
*/
    print(apiUrl);
    final requestBody = {
      "XMLFILE": {
        "FLAG": "14",
        "USERID": userID,
        "ORGSTRUCID": orgstID,
        "CONTROLNO": controlno,
        "MID": mid,
        "DOCID": docId,
      }
    };
    print(requestBody);
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      ASNScanningReaponse result =
      ASNScanningReaponse.fromJson(decoded);

      return result.tRANSACTIONDETAILS?.tRANSACTIONS ?? [];
    } else {
      throw Exception("API Failed : ${response.statusCode}");
    }
  }
}


