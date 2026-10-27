

import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _fcmTokenKey = "fcm_token";
  static const String _loginTokenKey = "login_token";
  static const String _keyUserId = "user_id";
  static const String _keyUserName = "user_name";
  static const String _pendingProjectsKey = "pending_projects";
  static const String _positionDesc = "position_description";

  static Future<void> addPendingProject(String projId) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> list = prefs.getStringList(_pendingProjectsKey) ?? [];

    if (!list.contains(projId)) {
      list.add(projId);

      await prefs.setStringList(_pendingProjectsKey, list);

      // 🔥 IMPORTANT FIX
      await Future.delayed(const Duration(milliseconds: 300));

      print("📦 Saved list: $list");
    }
  }

  static Future<List<String>> getPendingProjects() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> list = prefs.getStringList(_pendingProjectsKey) ?? [];

    print("📥 Retrieved list: $list");

    return list;
  }

  static Future<void> clearPendingProjects() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingProjectsKey);
  }
  /// Save FCM Token
  static Future<void> saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
  }

  /// Get FCM Token
  static Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fcmTokenKey);
  }

  /// Save Login Token
  static Future<void> saveLoginToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginTokenKey, token);
  }

  /// Get Login Token
  static Future<String?> getLoginToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loginTokenKey);
  }
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
  }
  static Future<void> setString(
      String key,
      String value,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(
      String key,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
  /// 🔹 Get User ID
  static Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId) ?? "";
  }
  static Future<void> saveUserName(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, userId);
  }

  /// 🔹 Get User ID
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName) ?? "";
  }
  static Future<void> savepositionDesc(String positionDesc) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_positionDesc, positionDesc);
  }

  /// 🔹 Get User ID
  static Future<String> getpositionDesce() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_positionDesc) ?? "";
  }
  /// Clear All Data (Logout)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  static Future<void> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("base_url", url);
  }

  static Future<String?> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("base_url");
  }

}