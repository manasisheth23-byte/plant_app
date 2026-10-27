/*
import 'dart:convert';

import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/models/getnotificationmodel.dart';
import 'package:erpflutter/models/notification_detail_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http; // ✅ Add this import
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ApiProvider.dart';

class GetNotificationProvider extends ChangeNotifier{
  GetNotificationModel? _getNotificationModel;
  bool _loading = false;
  String _errorMessage = '';
  NotificationDetailResponse? _response;
  bool _loadingDetail = false;
  String? _error;
  GetNotificationModel? get getNotificationModel => _getNotificationModel;
  bool get loading => _loading;
  String get errorMessage => _errorMessage;

  final ApiProvider _apiService = ApiProvider();

  NotificationDetailResponse? get response => _response;
  bool get loadingDetail => _loadingDetail;
  String? get error => _error;
  Future<void> GetNotification() async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _getNotificationModel = await _apiService.getNotification();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
  /// 🔹 Fetch Notification Details
  Future<void> fetchNotifications(String strNID) async {
    _loadingDetail = true;
    _error = null;
    _response = null; // ✅ reset previous data
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? UserID = prefs.getString('USERID');

    String url =
        "${AppConfig.BASE_URL}/Notification/GetNotificationDetails";
    print(url);
    try {
      final body = {
        "XMLFILE": {"FLAG": "0", "NID": strNID, "USERID": UserID}
        //   "XMLFILE": {"FLAG": "0", "NID": "2598", "USERID": "2857"}
      };

      print("Request URL: $url");
      print("Request Body: ${jsonEncode(body)}");

      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _response = NotificationDetailResponse.fromJson(data);
      } else {
        _error = "Server error: ${res.statusCode}";
      }
    } catch (e) {
      _error = "Failed: $e";
    }

    _loadingDetail = false;
    notifyListeners();
  }
}*/
import 'dart:convert';
import 'package:erpflutter/app_config.dart';
import 'package:erpflutter/models/getnotificationmodel.dart';
import 'package:erpflutter/models/notification_detail_response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ApiProvider.dart';

class GetNotificationProvider extends ChangeNotifier {
  final ApiProvider _apiService = ApiProvider();

  GetNotificationModel? _getNotificationModel;
  GetNotificationModel? _getNotificationModelDetail;
  bool _loading = false;
  String _errorMessage = '';

  NotificationDetailResponse? _response;
  bool _loadingDetail = false;
  String? _error;

  /// Cache for Notification details by NID
  final Map<String, NotificationDetailResponse> _cache = {};

  GetNotificationModel? get getNotificationModel => _getNotificationModel;
  GetNotificationModel? get getNotificationModelDetail => _getNotificationModelDetail;
  bool get loading => _loading;
  String get errorMessage => _errorMessage;

  NotificationDetailResponse? get response => _response;
  bool get loadingDetail => _loadingDetail;
  String? get error => _error;

  /// ------------------ Fetch Notification List -----------------
  Future<void> GetNotification(String nID) async {

    // ✅ Refresh UI ONLY when nID == "0"
    final bool shouldNotifyUI = nID == "0";

    if (shouldNotifyUI) {
      _loading = true;
      _errorMessage = '';
      notifyListeners();
    }

    try {
      if (nID == "0") {
        _getNotificationModel =
        await _apiService.getNotification(nID);
      } else {
        _getNotificationModelDetail =
        await _apiService.getNotification(nID);
      }
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      if (shouldNotifyUI) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  /* Future<void> GetNotification( String nID) async {
    _loading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      if(nID == "0"){
        _getNotificationModel = await _apiService.getNotification(nID);
      }else{
        _getNotificationModelDetail = await _apiService.getNotification(nID);
      }

    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }*/

  /// ------------------ Fetch Notification Details (Optimized) ------------------
  Future<void> fetchNotifications(String nid) async {
    _loadingDetail = true;
    _error = null;
    _response = null;
    notifyListeners();
    print("🔹 Fetching: 1");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('USERID');
    String? controlno = prefs.getString('CONTROLNO');
    String? orStID = prefs.getString('ORGSTRUCTID');

    // Return cache instantly
    if (_cache.containsKey(nid)) {
      print("🔹 Fetching: 2");
      _response = _cache[nid];
      _loadingDetail = false;
      notifyListeners();
      return;
    }

    final url = "${AppConfig.BASE_URL}Notification/GetNotificationDetails";
    print("🔹 Fetching: $url");

    try {
      final body = {
        "XMLFILE": {
          "FLAG": "0",
          "NID": nid,
          "USERID": userId,
          "CONTROLNO":controlno,
          "ORGSTRUCTID":orStID
        }
      };
      print("🔹 : "+jsonEncode(body));
      final res = await http
          .post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 60)); // ⏳ Timeout added

      if (res.statusCode == 200) {
        // Parse JSON on background thread → SUPER FAST
        final data = await compute(jsonDecode, res.body);
        _response = NotificationDetailResponse.fromJson(data);

        // Cache response
        _cache[nid] = _response!;
      } else {
        _error = "Server Error: ${res.statusCode}";
      }
    } catch (e) {
      _error = "Failed: $e";
    }

    _loadingDetail = false;
    notifyListeners();
  }

  //set notification count
  int _unreadCount = 0;
  bool _isLoading = false;

  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  Future<void> loadNotificationCount(String nID) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.getNotification(nID);


      final list = response.dATA?.lIST ?? [];

      _unreadCount = list
          .where((item) => item.ISREAD == "0")
          .length;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateCount(int count) {
    if (_unreadCount != count) {
      _unreadCount = count;
      notifyListeners();
    }
  }

  void incrementCount() {
    _unreadCount++;
    notifyListeners();
  }

  void resetCount() {
    _unreadCount = 0;
    notifyListeners();
  }
}

