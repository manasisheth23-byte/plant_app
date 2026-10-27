
import 'package:erpflutter/database/app_preferences.dart';

class ConfigService {
//static String baseUrl = "http://10.0.0.223:8567/ERPAPI/API/";
//static String baseUrl = "http://10.0.0.245:8217/ERPAPI/API/";
//static String baseUrl = "http://c9businesssuite.cloud9ebiz.com/ERPAPI/API/";
//static String baseUrl = "http://c9businesssuite.cloud9ebiz.com/ERPAPI/API/";
//static String baseUrl = "http://10.0.0.223:8532/ERPAPI/API/";
//static String baseUrl = "http://125.99.42.182:8532/ERPAPI/API/";
//static String baseUrl = "http://10.0.0.223:8565/ERPAPI/API/";
  //static String baseUrl = "https://c9erpitek.cloud9ebiz.com/ERPAPI/API/";
static String baseUrl = "https://erp.itekrfid.com/ERPAPI/API/";
//static String baseUrl = "http://125.99.42.184:8217/ERPAPI/API/";

//static String baseUrl = "http://125.99.42.182:8567/ERPAPI/API/";
  static Future<void> loadBaseUrl() async {
    final savedUrl = await AppPreferences.getBaseUrl();
    if (savedUrl != null) {
      baseUrl = savedUrl;
    }
  }
  static const String apiSuffix = "/ERPAPI/API/";
  static String getBaseOnlyUrl() {
    String url = baseUrl;

    if (url.contains(apiSuffix)) {
      return url.replaceAll(apiSuffix, "");
    }

    return url;
  }
  static String formatUrl(String input) {
    String url = input.trim();

    /// ✅ Remove trailing slash
    if (url.endsWith("/")) {
      url = url.substring(0, url.length - 1);
    }

    /// ✅ Case 1: already full correct
    if (url.endsWith("/ERPAPI/API")) {
      return "$url/";
    }

    /// ✅ Case 2: user typed ERPAPI only
    if (url.endsWith("/ERPAPI")) {
      return "$url/API/";
    }

    /// ✅ Case 3: user typed full with slash
    if (url.contains("/ERPAPI/API/")) {
      return url;
    }

    /// ✅ Default: append full suffix
    return url + apiSuffix;
  }

  static Future<void> updateBaseUrl(String newUrl) async {
    if (!newUrl.endsWith("/")) {
      newUrl = "$newUrl/";
    }
    baseUrl = newUrl;
    await AppPreferences.saveBaseUrl(newUrl);
  }
}