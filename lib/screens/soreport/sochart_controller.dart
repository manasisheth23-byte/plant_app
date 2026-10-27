import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../app_config.dart';
import '../../models/sochart_response.dart';
import '../login/login.dart';


class SoChatService with ChangeNotifier {
  static const String _apiUrl = AppConfig.RAW_BASE_URL +'/erpapi/api/SalesOrder/SODashboard/';

  SoChartData? _dashboardData;

  SoChartData? get dashboardData => _dashboardData;

  Future<void> fetchDashboardData(BuildContext mcontext,String strReportion,String strRpttype,String strFlag) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? stringValuebaseOrgStructId = prefs.getString('ORGSTRUCTID');
    String? stringValuebaseUserId = prefs.getString('USERID');


    final response = await http.get(Uri.parse(
        '$_apiUrl?REPORTON=$strReportion&RPTTYPE=$strRpttype&Orgstrucid=$stringValuebaseOrgStructId&USERID=$stringValuebaseUserId&FLAG=$strFlag'));
    print('$_apiUrl?REPORTON=$strReportion&RPTTYPE=$strRpttype&Orgstrucid=$stringValuebaseOrgStructId&USERID=$stringValuebaseUserId&FLAG=$strFlag');

   print(response.statusCode);
print(response);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _dashboardData = SoChartData.fromJson(data);
      notifyListeners();
    } else {
      String errorMessage = 'An error occurred';
      Color snackBarColor = Colors.red;

      if (response.statusCode == 400) {
        errorMessage = 'Bad Request: ${response.statusCode}';
      } else if (response.statusCode == 401) {
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLogout", false);
          prefs!.setString("TOKEN", '');

          Get.offAll(LoginScreen());
        }
        errorMessage = 'Unauthorized: ${response.statusCode}';
      } else if (response.statusCode == 500) {
        errorMessage =  'Internal Server Error: ${response.statusCode}';
      }else if (response.statusCode == 502) {
        errorMessage =  'Bad Gateway: ${response.statusCode}';
      }else if (response.statusCode == 503) {
        errorMessage =   'Service Unavailable: ${response.statusCode}';
      }else if (response.statusCode == 504) {
        errorMessage =   'Gateway Timeout: ${response.statusCode}';
      }else
      {
        errorMessage =   'Unexpected status code: ${response.statusCode}';
      }


      // Show SnackBar with the error message
      ScaffoldMessenger.of(mcontext).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: snackBarColor,
        ),
      );
      throw Exception('Failed to load dashboard data');
    }
  }
}
