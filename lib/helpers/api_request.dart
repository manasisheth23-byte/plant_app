import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_preferences.dart';
import '../database/secure_storage_service.dart';
import '../models/LoginResponseModel.dart';
import '../models/service_engineer_regsiter_response_model.dart';

import '../screens/login/login.dart';
import 'api_helpers.dart';

class ApiRequest {
  static Future<http.Response> get(
      {required String url, Map<String, String>? headers}) async {
    print('url----> $url');
    Uri uri = Uri.parse(url);
    Map<String, String>? headerMap = commonHeader;

    if (headers != null) {
      headerMap.addAll(headers);
    }

    var response;
    try{
      response = await http.get(uri, headers: headerMap).timeout(Duration(seconds: 40));
    }catch(e){
      Get.snackbar(
        'Info',
        'Connection error!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      rethrow;
    }

    switch (response.statusCode) {
      case 200:

        print('Success: ${response.statusCode}');
        break;
      case 201:
        print('Created: ${response.statusCode}');
        break;
      case 400:
        Get.snackbar(
          'Info',
          'Bad Request: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Bad Request: ${response.statusCode}');
        break;
      case 401:
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLogout", false);
          prefs!.setString("TOKEN", '');

          Get.offAll(LoginScreen());
        }

        Get.snackbar(
          'Info',
          'Unauthorized: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Unauthorized: ${response.statusCode}');
        break;
      case 403:
        Get.snackbar(
          'Info',
          'Forbidden: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Forbidden: ${response.statusCode}');
        break;
      case 404:
        Get.snackbar(
          'Info',
          'Not Found: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Not Found: ${response.statusCode}');
        break;
      case 500:
       /* Get.snackbar(
          'Info',
          'Internal Server Error: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );*/

        print('Internal Server Error: ${response.statusCode}');
        break;
      case 502:
        Get.snackbar(
          'Info',
          'Bad Gateway: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Bad Gateway: ${response.statusCode}');
        break;
      case 503:
        Get.snackbar(
          'Info',
          'Service Unavailable: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Service Unavailable: ${response.statusCode}');
        break;
      case 504:
        Get.snackbar(
          'Info',
          'Gateway Timeout: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Gateway Timeout: ${response.statusCode}');
        break;
      default:
        Get.snackbar(
          'Info',
          'Unexpected status code: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Unexpected status code: ${response.statusCode}');
    }

    return response;
  }

  static Future<http.Response> post(
      {required String url,
        Map<String, String>? headers,
        required String body}) async {

    print('url---> $url');
    print('body---> $body');

    Uri uri = Uri.parse(url);
    Map<String, String>? headerMap = commonHeader;

    if (headers != null) {
      headerMap.addAll(headers);
    }

    var response;
    try{
      response = await http.post(uri, headers: headerMap, body: body).timeout(const Duration(minutes: 2));
    }catch(e){
      Get.snackbar(
        'Info',
        'Connection error!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      rethrow;
    }

    switch (response.statusCode) {
      case 200:
        break;
      case 201:

        break;
      case 300:
        break;
      case 400:
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        String message = jsonResponse['DATA'] != null && jsonResponse['DATA']['Message'] != null
            ? jsonResponse['DATA']['Message'].toString()
            : 'Something went wrong.';

       /* Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );*/
        break;
      case 401:
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs!.setBool("ISLOGGEDIN", false);
          prefs!.setString("TOKEN", '');
          Get.closeAllSnackbars();
          Get.back();
          Get.offAll(LoginScreen());
        }

        Get.snackbar(
          'Info',
          'Unauthorized: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Unauthorized: ${response.statusCode}');
        break;
      case 403:
        Get.snackbar(
          'Info',
          'Forbidden: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Forbidden: ${response.statusCode}');
        break;
      case 404:
        Get.snackbar(
          'Info',
          'Not Found: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Not Found: ${response.statusCode}');
        break;
      case 500:
        Get.snackbar(
          'Info',
          'Internal Server Error: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Internal Server Error: ${response.statusCode}');
        break;
      case 502:
        Get.snackbar(
          'Info',
          'Bad Gateway: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Bad Gateway: ${response.statusCode}');
        break;
      case 503:
        Get.snackbar(
          'Info',
          'Service Unavailable: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Service Unavailable: ${response.statusCode}');
        break;
      case 504:
        Get.snackbar(
          'Info',
          'Gateway Timeout: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Gateway Timeout: ${response.statusCode}');
        break;
      default:
        Get.snackbar(
          'Info',
          'Unexpected status code: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print('Unexpected status code: ${response.statusCode}');
    }

    return response;
  }

  static Future<http.Response> delete(
      {required String url, Map<String, String>? headers}) async {
    Uri uri = Uri.parse(url);
    Map<String, String>? headerMap = commonHeader;

    if (headers != null) {
      headerMap.addAll(headers);
    }

    var response = await http.delete(uri, headers: headerMap);
    return response;
  }


  static Future<bool> handleStatus(http.Response response,
      {bool showSnack = true}) async {
    switch (response.statusCode) {
      case 200:
      case 201:
        return true;

      case 300:
        _showSnack(showSnack, "Redirect", "Multiple Choices (300)");
        return false;

      case 400:
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        String message =
            jsonResponse['DATA']?['Message'] ?? 'Something went wrong.';
        _showSnack(showSnack, "Error", message);
        return false;

      case 401:
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("ISLOGGEDIN", false);
        prefs.setString("TOKEN", "");

        _showSnack(showSnack, "Unauthorized",
            "Session expired, login required.");

        Get.offAll(() => LoginScreen());
        return false;

      case 403:
        _showSnack(showSnack, "Forbidden", "Access denied (403)");
        return false;

      case 404:
        _showSnack(showSnack, "Not Found", "API not found (404)");
        return false;

      case 500:
        _showSnack(showSnack, "Server Error", "Internal Server Error (500)");
        return false;

      case 502:
        _showSnack(showSnack, "Bad Gateway", "Bad Gateway (502)");
        return false;

      case 503:
        _showSnack(showSnack, "Service Unavailable",
            "Service temporarily unavailable (503)");
        return false;

      case 504:
        _showSnack(showSnack, "Timeout", "Gateway Timeout (504)");
        return false;

      default:
        _showSnack(showSnack, "Unknown",
            "Unexpected status code: ${response.statusCode}");
        return false;
    }
  }

  static void _showSnack(bool show, String title, String message) {
    if (!show) return;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }


}
