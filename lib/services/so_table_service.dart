import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../app_config.dart';
import '../models/so_table_model.dart';
import '../screens/login/login.dart';


class SoReportService {
  static const String _baseUrl = '${AppConfig.RAW_BASE_URL}/erpapi/api/SalesOrder/FilterExportData';


  static Future<SoTableModel> fetchSoData({required BuildContext context,

    int pageNo = 1,
    bool applyFilter = false,
    Map<String, String>? filterParams
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? UserID = prefs.getString('USERID');
    final filterParamsWithDefaults = filterParams ?? {};

    final payload = {
      "XMLFILE": {
        "SPXML": {
          "SPDETAILS": {
            "FLAG": "1",
            "REPORTON": "1",
            "SEARCHTEXT": "",
            "SONO": filterParamsWithDefaults['SONO'] ?? "",
            "CUSTOMER": filterParamsWithDefaults['CUSTOMER'] ?? "",
            "ALERTSID": filterParamsWithDefaults['ALERTSID'] ?? "0",
            "ITEMCODE": filterParamsWithDefaults['ITEMCODE'] ?? "",
            "PONO": " ",
            "COLORID": filterParamsWithDefaults['COLORID'] ?? "0",
            "USERID": UserID,
            "PAGENO": pageNo,
            "PROJID": filterParamsWithDefaults['PROJID'] ?? "0",
            "SHOWSPIKE": "false",
            "ITEMSUBGRPID": filterParamsWithDefaults['ITEMSUBGRPID'] ?? "0",
            "SELORGSTRUCTID": filterParamsWithDefaults['SELORGSTRUCTID'] ?? "4",
            "STATUSID": "0",
            "DATEVAL": "1900-01-01T00:00:00",
            "ProdtCategoryID": "",
            "ProdnlineID": "",
            "SOTYPE": "0",
            "CDDCOLORID": filterParamsWithDefaults['CDDCOLORID'] ?? "0"
          }
        }
      }
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print("So Table Call Successfully***********");
      final jsonData = jsonDecode(response.body);
      return SoTableModel.fromJson(jsonData);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: snackBarColor,
        ),
      );
      throw Exception('Failed to load SO Table data');
    }
  }

  static Future<SoTableModel> fetchSoData1({

    int pageNo = 1,
    bool applyFilter = false,
    Map<String, String>? filterParams
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? UserID = prefs.getString('USERID');
    final filterParamsWithDefaults = filterParams ?? {};

    final payload = {
      "XMLFILE": {
        "SPXML": {
          "SPDETAILS": {
            "FLAG": "1",
            "REPORTON": "1",
            "SEARCHTEXT": "",
            "SONO": filterParamsWithDefaults['SONO'] ?? "",
            "CUSTOMER": filterParamsWithDefaults['CUSTOMER'] ?? "",
            "ALERTSID": filterParamsWithDefaults['ALERTSID'] ?? "0",
            "ITEMCODE": filterParamsWithDefaults['ITEMCODE'] ?? "",
            "PONO": " ",
            "COLORID": filterParamsWithDefaults['COLORID'] ?? "0",
            "USERID": UserID,
            "PAGENO": pageNo,
            "PROJID": filterParamsWithDefaults['PROJID'] ?? "0",
            "SHOWSPIKE": "false",
            "ITEMSUBGRPID": filterParamsWithDefaults['ITEMSUBGRPID'] ?? "0",
            "SELORGSTRUCTID": filterParamsWithDefaults['SELORGSTRUCTID'] ?? "4",
            "STATUSID": "0",
            "DATEVAL": "1900-01-01T00:00:00",
            "ProdtCategoryID": "",
            "ProdnlineID": "",
            "SOTYPE": "0",
            "CDDCOLORID": filterParamsWithDefaults['CDDCOLORID'] ?? "0"
          }
        }
      }
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print("So Table Call Successfully***********");
      final jsonData = jsonDecode(response.body);
      return SoTableModel.fromJson(jsonData);
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


      throw Exception('Failed to load SO Table data');
    }
  }
}