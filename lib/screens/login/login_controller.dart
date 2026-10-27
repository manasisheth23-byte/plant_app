    import 'dart:convert';

import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/helpers/api_request.dart';
import 'package:erpflutter/models/get_item_balance_model.dart';
import 'package:erpflutter/models/sync_i_ledger_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/secure_storage_service.dart';
import '../../helpers/api_helpers.dart';
import '../../models/ChangePasswordRequestModel.dart';
import '../../models/ChangePasswordResponseModel.dart';
import '../../models/GetDefaultValResponseModel.dart';
import '../../models/LoginRequestModel.dart';
import '../../models/LoginResponseModel.dart';
import '../../models/ProcessNFGQualityLookupResponseModel.dart';
import '../../models/UpdateUserDeviceInfoRequestModel.dart';
import '../../models/UpdateUserDeviceInfoResponseModel.dart';
import '../../models/add_so_request_model.dart';
import '../../models/add_so_response_model.dart';
import '../../models/approve_reject_response_model.dart';
import '../../models/fill_user_list_model.dart';
import '../../models/get_approval_history_request_model.dart';
import '../../models/get_approval_history_response_model.dart';
import '../../models/get_approval_list_request_model.dart';
import '../../models/get_approval_list_response_model.dart';
import '../../models/get_page_sheet_request_model.dart';
import '../../models/get_page_sheet_response_model.dart';
import '../../models/get_so_list_model.dart';
import '../../models/sync_price_master_model.dart';
import '../../models/sync_s_ledger_model.dart';
import '../../models/approve_reject_request_model.dart';
import '../../services/ApiProvider.dart';

import 'login.dart';

class LoginController with ChangeNotifier{
  String username="";
  String password="";
  LoginResponseModel? loginResponseModel;
  GetDefaultValResponseModel? getdefaultvalresponsemodel;
  String strDefaultStatus="";
  String strDefaltDocTyp="";
  String strDefaultType="";
  String menuid="" ;
  String mid="" ;
  String itemdesc="" ;
  String itemtype="" ;
  String plant="" ;
  String unitprice="" ;
  String maninGroup="" ;
  String subGroup="" ;

  String itemCode="" ;
  String inStockQuantity="" ;
  String UserId="";
  String Token="";
  String PagesheetId="";
  ApiProvider _repo = ApiProvider();

  ProcessNfgQualityLookupResponseModel?  processfgqualityresponsemodel;
  Future<GetSOListModel> getSOListData(Map<String, dynamic> data) async {
    try {
      String url = AppConfig.BASE_URL +  getSOList!;
      var response = await ApiRequest.post(url : url, body: json.encode(data));
      if (response.statusCode == 401) {
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLogout", false);
          prefs!.setString("TOKEN", '');
          Get.offAll(LoginScreen());
        }
      }
      return GetSOListModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      throw error;
    }
  }

  void getUser(String username,String password,LoginResponseModel? loginResponseModel){
    this.username=username;
    this.password=password;
    this.loginResponseModel=loginResponseModel;

    notifyListeners();

  }

  Future<AddSoResponseModel> AddSODetails(
      BuildContext context,AddSORequestModel data) async {
    try {
      String url = AppConfig.BASE_URL + AddSO!;
      var response = await ApiRequest.post(url : url, body: json.encode(data.toJson()));
      if (response.statusCode == 401) {
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLogout", false);
          prefs!.setString("TOKEN", '');
          Get.offAll(LoginScreen());
        }
      }

      print(' data----------->${response.body.toString()}');
      return AddSoResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }

  Future<LoginResponseModel> getLoginDetails(
      LoginRequestModel data) async {
    try {
      String url = AppConfig.BASE_URL + loginApi!;

      var response = await ApiRequest.post(url : url, body: json.encode(data.toJson()));
      print( "Login Response Body *** ${response.body}");
      if (response.statusCode == 401) {
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLogout", false);
          prefs!.setString("TOKEN", '');
          Get.offAll(LoginScreen());
        }
      }

      return LoginResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }

  Future<GetItemBalanceModel> syncItemBalanceDetails(Map<String, dynamic> data) async {
    try {
      String url = AppConfig.BASE_URL +  GetItemBalance!;
      var response = await ApiRequest.post(url : url, body: json.encode(data));
      if (response.statusCode == 401) {
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLogout", false);
          prefs!.setString("TOKEN", '');
          Get.offAll(LoginScreen());
        }
      }
      return GetItemBalanceModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }

  Future<UpdateUserDeviceInfoResponseModel> UpdateUserDeviceInfoDetails(
      UpdateUserDeviceInfoRequestModel data) async
  {
    try {
      String url = AppConfig.BASE_URL +  UpdateUserDeviceInfo!;
      print(url);
      print(json.encode(data.toJson()));
      var response = await ApiRequest.post(url : url, body: json.encode(data.toJson()));

      if (response.statusCode == 401) {
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLogout", false);
          prefs!.setString("TOKEN", '');
          Get.offAll(LoginScreen());
        }
      }
      return UpdateUserDeviceInfoResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print(data.toJson());
      print("Exception occured: $error stackTrace: $stacktrace");
      return UpdateUserDeviceInfoResponseModel.withError(error.toString());
    }
  }
  Future<SyncPriceMasterModel> syncPriceMasterData(Map<String, dynamic> data,BuildContext context) async {
    try {
      String url = AppConfig.BASE_URL + syncPriceMaster!;
      print(url);
      print(json.encode(data));
      var response = await ApiRequest.post(url : url, body: json.encode(data));
      if (response.statusCode == 401) {
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLogout", false);
          prefs!.setString("TOKEN", '');
          Get.offAll(LoginScreen());
        }
      }

      return SyncPriceMasterModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
     Navigator.pop(context);
      rethrow;
    }
  }

  Future<FillUserListModel> syncFillUserListModelData(Map<String, dynamic> data) async {
    try {
      String url = AppConfig.BASE_URL + fillUserList!;
      print(url);
      print(json.encode(data));
      var response = await ApiRequest.post(url : url, body: json.encode(data));
      if (response.statusCode == 401) {
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLogout", false);
          prefs!.setString("TOKEN", '');
          Get.offAll(LoginScreen());
        }
      }
      return FillUserListModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }

  Future<SyncILedgerModel> syncILedgerData(Map<String, dynamic> data,BuildContext context) async {
    try {
      String url = AppConfig.BASE_URL  + syncILedger!;
      print(url);
      print(json.encode(data));
      var response = await ApiRequest.post(url : url, body: json.encode(data));


      if (response.statusCode == 401) {
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLogout", false);
          prefs!.setString("TOKEN", '');
          Get.offAll(LoginScreen());
        }
      }
      return SyncILedgerModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      Navigator.pop(context);
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }

  Future<SyncSLedgerModel> syncSLedgerData(Map<String, dynamic> data) async {
    try {
      String url = AppConfig.BASE_URL + syncSLedger!;
      print(url);
      print(json.encode(data));
      var response = await ApiRequest.post(url : url, body: json.encode(data));
      if (response.statusCode == 401) {
        var prefs = await SharedPreferences.getInstance();
       // SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("ISLOGGEDIN", true);
        bool rememberMe = await SecureStorageService.isRememberMe();
        print(rememberMe);
        await SecureStorageService.setLoggedIn(false);
        await SecureStorageService.setIsVerifiedn(false);
        if (prefs != null) {
          prefs!.setBool("ISLogout", false);
          prefs!.setString("TOKEN", '');
          Get.offAll(LoginScreen());
        }
      }
      return SyncSLedgerModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }

  Future<GetSOListModel> syncSOListData(Map<String, dynamic> data) async {
    try {
      String url = AppConfig.BASE_URL +  getSOList!;
      print(url);
      print(json.encode(data));
      var response = await ApiRequest.post(url : url, body: json.encode(data));
      if (response.statusCode == 401) {
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLogout", false);
          prefs!.setString("TOKEN", '');
          Get.offAll(LoginScreen());
        }
      }
      return GetSOListModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }



  void getDefaultVal(String menuid,String strDefaltDocType,String strDefaultStatus, String strDefaultType,GetDefaultValResponseModel? getdefaultvalresponsemodel, LoginResponseModel? loginResponseModel){
    this.menuid=menuid;
    this.menuid=strDefaltDocType;
    this.menuid=strDefaultStatus;
    this.menuid=strDefaultType;
    this.menuid=menuid;
    this.getdefaultvalresponsemodel=getdefaultvalresponsemodel;
    this.loginResponseModel=  loginResponseModel;

    notifyListeners();

  }
  void fgQualityDetailsData(ProcessNfgQualityLookupResponseModel?  processfgqualityresponsemodelModel,String mid){
    this.processfgqualityresponsemodel=processfgqualityresponsemodel;

    this.mid=mid;
    notifyListeners();

  }
  Future<ChangePasswordResponseModel> ChangePasswordDetails(
      ChangePasswordRequestModel data) async {
    try {
      String url = AppConfig.BASE_URL + ChangePassword!;
      print(url);
      print(json.encode(data.toJson()));
      var response = await ApiRequest.post(url : url, body: json.encode(data.toJson()));
      if (response.statusCode == 401) {

      }
      return ChangePasswordResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return ChangePasswordResponseModel.withError(error.toString());
    }
  }
  void getItemMaster(String itemdesc,String itemtype,String plant, String unitprice,String maninGroup,String subGroup,String itemCode,String inStockQuantity) {
     this.itemdesc=itemdesc;
     this.itemtype=itemtype ;
     this.plant=plant ;
     this.unitprice=unitprice ;
     this.maninGroup=maninGroup ;
     this.subGroup=subGroup ;
     this.itemCode=itemCode ;
     this.inStockQuantity=inStockQuantity ;

  }

  Future<GetBiPageSheetResponseModel> GetBIPageSheetDetails(
      BuildContext context,GetBIPageSheetRequestModel data) async {
    try {
      String url = AppConfig.BASE_URL + GetBIPageSheet!;
      print(url);
      print(json.encode(data.toJson()));
      var response = await ApiRequest.post(url : url, body: json.encode(data.toJson()));
      if (response.statusCode == 401) {


      }

      return GetBiPageSheetResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return GetBiPageSheetResponseModel.withError(error.toString());
    }
  }
  void getReportView(String UserId,String Token,String PagesheetId) {
    this.UserId=UserId;
    this.Token=Token ;
    this.PagesheetId=PagesheetId ;


  }

  Future<LoginResponseModel> getLoginDetails1(LoginRequestModel data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
// commented for testing by komal barcode
    String login = "Authenticate/ReturnLoginInfo_V1"; //post api version 1 for biometry
    //String login = "Authenticate/ReturnLoginInfo";

    try {
      //Return String
      String stringValuebaseURL = prefs.getString('baseURL')?? "";
      String url = AppConfig.BASE_URL + login;



      print(url);
      print(data.toJson());
      var response = await ApiRequest.post(url: url , headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Expose-Headers": "*",
        "Access-Control-Allow-Credentials":"true",
        "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
        "Access-Control-Allow-Methods": "POST, OPTIONS,GET,HEAD"
      }, body: json.encode(data.toJson()));
      print(data.toJson());

      print(response.body);
      return LoginResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {

      print("Exception occured: $error stackTrace: $stacktrace");
      if(prefs!=null){
        prefs!.setString("ERROR", error.toString());
      }
      return LoginResponseModel.withError(error.toString());
    }
  }
  Future<LoginResponseModel> getLogin(LoginRequestModel data) async {
    String loginold = "Authenticate/ReturnLoginInfo"; //post
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      //Return String
      String stringValuebaseURL = prefs.getString('baseURL')?? "";
      String url = AppConfig.BASE_URL +  loginold;
      //apibaseurl + "/" + login;

      print(url);
      print(json.encode(data.toJson()));

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
}