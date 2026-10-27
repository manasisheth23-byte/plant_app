import 'dart:convert';

import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../helpers/api_helpers.dart';
import '../../helpers/api_request.dart';
import '../../models/approve_reject_request_model.dart';
import '../../models/approve_reject_response_model.dart';
import '../../models/get_approval_history_request_model.dart';
import '../../models/get_approval_history_response_model.dart';
import '../../models/get_approval_list_request_model.dart';
import '../../models/get_approval_list_response_model.dart';
class ApprovalsController with ChangeNotifier {
  Future<GetApprovalListResponseModel> GetApprovalListDetails(
      GetApprovalListRequestModel data,BuildContext context) async {
    try {
      String url = AppConfig.BASE_URL + GetApprovalList!;

      print("url: $url ");
      print(json.encode(data.toJson()));
      var response = await ApiRequest.post(url : url, body: json.encode(data.toJson()));


      if (response.statusCode == 401) {

      }

      return GetApprovalListResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }
  Future<ApproveRejectResponseModel> GetApproveReject(
      ApproveRejectRequestModel data,BuildContext context) async {
    try {
      String url = AppConfig.BASE_URL + ApproveReject!;
      var response = await ApiRequest.post(url : url, body: json.encode(data.toJson()));
      if (response.statusCode == 401) {

      }

      return ApproveRejectResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }
  Future<GetApproveHistoryResponseModel> GetApprovalHistory(
      GetApproveHistoryRequestModel data,BuildContext context) async {
    try {
      String url = AppConfig.BASE_URL + GetApproveHistory!;
     print("url: $url");
     print(data.toJson());
      var response = await ApiRequest.post(url : url,
          body: json.encode(data.toJson()),
      ).timeout(const Duration(seconds: 60));
      if (response.statusCode == 401) {

      }

      return GetApproveHistoryResponseModel.fromJson(jsonDecode(response.body));
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      rethrow;
    }
  }
}