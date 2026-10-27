import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceTokenService {
  static const _key = "WINDOWS_DEVICE_TOKEN";

  static Future<String> getOrCreateToken() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString(_key);

    if (token != null && token.isNotEmpty) {
      return token; // ✅ reuse existing
    }

    // ✅ create new token
    token = const Uuid().v4();

    await prefs.setString(_key, token);

    return token;
  }
}