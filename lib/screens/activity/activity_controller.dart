import 'dart:convert';

import 'package:erpflutter/models/fill_status_list_model.dart';
import 'package:erpflutter/models/sync_s_ledger_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_config.dart';
import '../../helpers/api_helpers.dart';
import '../../helpers/api_request.dart';
import '../../models/activity_response_model.dart';
import '../../models/activity_task_request_model.dart';
import '../../models/add_activity_request_model.dart';
import '../../models/add_activity_response_model.dart';
import '../../models/add_event_request_model.dart';
import '../../models/add_event_response_model.dart';
import '../../models/add_task_request_model.dart';
import '../../models/add_task_response_model.dart';
import '../../models/fill_user_list_model.dart';
import '../../utils/global_variables.dart';

class ActivityController with ChangeNotifier {
  SyncSLedgerModel? syncSLedgerModel;
  FillStatusListModel? typeList;
  FillStatusListModel? callPurposeList;
  FillStatusListModel? callTypeList;
  FillStatusListModel? priorityList;
  // SyncSLedgerModel? businessPartners;
  String? strAssignedTo;
  String? strSubject;
  String? strDueDate;
  String? strBusinessprtner;
  String? strStatus;
  String? strPriority;
  String? strRemark;

  bool dataLoaded = false;

  FillUserListModel? fillUserListModel;


  void printLargeString(String text) {
    const int chunkSize = 800; // Adjust chunk size based on your needs
    int startIndex = 0;
    while (startIndex < text.length) {
      int endIndex = startIndex + chunkSize;
      if (endIndex > text.length) {
        endIndex = text.length;
      }
      print(text.substring(startIndex, endIndex));
      startIndex = endIndex;
    }
  }

  Future<ActivityResponseModel> GetActivityListDetails(
      ActivityTaskRequestModel data, BuildContext context) async {
    try {
      String url = AppConfig.BASE_URL + GetActivities!;
      print(url);
      print(json.encode(data.toJson()));
      var response =
      await ApiRequest.post(url: url, body: json.encode(data.toJson()));
      if (response.statusCode == 401) {}


      printLargeString(
          'activity details----------> ${jsonDecode(response.body)}');
      return ActivityResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }

  Future<AddActivityResponseModel> AddActivityDetails(
      AddActivityRequestModel data, BuildContext context) async {
    try {
      String url = AppConfig.BASE_URL + AddActivity!;
      var response =
      await ApiRequest.post(url: url, body: json.encode(data.toJson()));
      if (response.statusCode == 401) {}

      return AddActivityResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }

  void fetchData() async {
    if(dataLoaded){
      return;
    }

    var response = await ApiRequest.post(
        url: AppConfig.BASE_URL + fillUserList,
        body: json.encode({
          "XMLFILE": {
            "DESC": "",
            "ISACTIVE": "true",
            "SEARCHUSERID": "0",
            "SHOWHELP": "1",
            "UTYPEID": "0",
            "TOKEN": token,
            "USERID": userId,
            "ORGSTRUCTID" : orgStructId,
            "CONTROLNO" : controlno
          }
        }));

    fillUserListModel = FillUserListModel.fromJson(json.decode(response.body));

    response = await ApiRequest.post(
        url: AppConfig.BASE_URL + fillStatusList,
        body: json.encode({
          "XMLFILE": {
            "DESC": "",
            "FLAG": "0",
            "STATUSID": "0",
            "TYPEID": "122",
            "TOKEN": token,
            "USERID": userId,
            "ORGSTRUCTID" : orgStructId,
            "CONTROLNO" : controlno
          }
        }));
    priorityList = FillStatusListModel.fromJson(json.decode(response.body));

    response = await ApiRequest.post(
        url: AppConfig.BASE_URL + fillStatusList,
        body: json.encode({
          "XMLFILE": {
            "DESC": "",
            "FLAG": "0",
            "STATUSID": "0",
            "TYPEID": "124",
            "TOKEN": token,
            "USERID": userId,
            "ORGSTRUCTID" : orgStructId,
            "CONTROLNO" : controlno
          }
        }));

    typeList = FillStatusListModel.fromJson(json.decode(response.body));

    response = await ApiRequest.post(
        url: AppConfig.BASE_URL + fillStatusList,
        body: json.encode({
          "XMLFILE": {
            "DESC": "",
            "FLAG": "0",
            "STATUSID": "0",
            "TYPEID": "125",
            "TOKEN": token,
            "USERID": userId,
            "ORGSTRUCTID" : orgStructId,
            "CONTROLNO" : controlno
          }
        }));
    callPurposeList = FillStatusListModel.fromJson(json.decode(response.body));

    response = await ApiRequest.post(
        url: AppConfig.BASE_URL + fillStatusList,
        body: json.encode({
          "XMLFILE": {
            "DESC": "",
            "FLAG": "0",
            "STATUSID": "0",
            "TYPEID": "126",
            "TOKEN": token,
            "USERID": userId,
            "ORGSTRUCTID" : orgStructId,
            "CONTROLNO" : controlno
          }
        }));
    callTypeList = FillStatusListModel.fromJson(json.decode(response.body));

     //compute(fetchSyncSLedgerData, 0);
     response = await ApiRequest.post(
         url: AppConfig.BASE_URL + syncSLedger,
         body: json.encode({
          "XMLFILE": {
            "FLAG": "1",
             "LASTSYNCDATE": "01-Jan-1900 00:00:00",
             "MID": "0",
            "ORGSTRUCTID" : orgStructId,
            "CONTROLNO" : controlno,
             "POSID": posId,
             "TOKEN": token,
             "USERID": userId
           }
         }));

     syncSLedgerModel = SyncSLedgerModel.fromJson(json.decode(response.body));

    dataLoaded = true;

    notifyListeners();

  }

  void getActivity( String? strAssignedTo,
      String? strSubject,
      String? strDueDate,
      String? strBusinessprtner,
      String? strStatus,
      String? strPriority,
      String? strRemark){
    this.strAssignedTo=strAssignedTo;
    this.strSubject=strSubject;
    this.strDueDate=strDueDate;
    this.strBusinessprtner=strBusinessprtner;
    this.strStatus=strStatus;
    this.strPriority=strPriority;
    this.strRemark=strRemark;
    notifyListeners();
  }
  void _showSnackBar(String message) {
    Get.rawSnackbar(
      message: message,
      backgroundColor: Colors.red,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }
  Future<AddActivityTaskResponseModel> AddActivityTaskDetails(
      AddTaskRequestModel data, BuildContext context) async {
    try {
      String url = AppConfig.BASE_URL + AddActivity!;
      var response =
      await ApiRequest.post(url: url, body: json.encode(data.toJson()));
      print("url ----> $url");
      print("data ----> ${data.toJson()}");
      print("response ----> $response");
      if (response.statusCode == 401) {

      }else if(response.statusCode == 400){
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final data = jsonResponse["Data"];

        final String status = data["Status"];
        final String message = data["Message"];
        _showSnackBar(message);
      }

      return AddActivityTaskResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }
  Future<AddEventResponseModel> AddActivityEventDetails(
      AddEventRequestModel data, BuildContext context) async {
    try {
      String url = AppConfig.BASE_URL + AddActivity!;
      var response =
      await ApiRequest.post(url: url, body: json.encode(data.toJson()));
      print("url ----> $url");
      print("data ----> ${data.toJson()}");
      print("response ----> $response");
      if (response.statusCode == 401) {}

      return AddEventResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }

}
