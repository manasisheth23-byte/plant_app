
import 'package:dio/dio.dart';
import 'package:erpflutter/repository/ConfigService.dart';
import 'package:erpflutter/repository/snackbar_service.dart';

import 'package:shared_preferences/shared_preferences.dart';


class DioClient {
  final Dio dio = Dio();


  DioClient() {
    dio.options = BaseOptions(
      //baseUrl: "http://10.0.0.245:8501/api",q
   // baseUrl: "http://125.99.42.184:8501/api",
    // baseUrl: "http://10.0.0.223:8567/ERPAPI/API/",
       // baseUrl: "http://10.0.0.223:8573/ERPAPI/API/",
baseUrl: ConfigService.baseUrl,
      //baseUrl: "http://125.99.42.182:8567/ERPAPI/API/",

      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(seconds: 60),
      headers: {
        "Content-Type": "application/json",
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
       /* onRequest: (options, handler) async {
          final token = await SecureStorageService.getToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          print("========= API REQUEST =========");
          print("URL: ${options.baseUrl}${options.path}");
          print("METHOD: ${options.method}");
          print("HEADERS: ${options.headers}");
          print("QUERY PARAMETERS: ${options.queryParameters}");
          print("BODY: ${options.data}");
          print("================================");

          return handler.next(options);
        },*/
        onRequest: (options, handler) async {
          // ✅ Always take latest base URL
          options.baseUrl = ConfigService.baseUrl;

          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? stringValuebaseTOKEN = prefs.getString('TOKEN');
          final token = stringValuebaseTOKEN;
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          print("========= API REQUEST =========");
          print("URL: ${options.baseUrl}${options.path}");
          print("METHOD: ${options.method}");
          print("HEADERS: ${options.headers}");
          print("QUERY PARAMETERS: ${options.queryParameters}");
          print("BODY: ${options.data}");
          print("================================");

          return handler.next(options);
        },
        onError: (DioException e, handler) {

          String errorMessage = "Something went wrong";

          switch (e.type) {

            case DioExceptionType.connectionTimeout:
              errorMessage = "Connection timeout. Please check internet.";
              break;

            case DioExceptionType.receiveTimeout:
              errorMessage = "Server not responding.";
              break;

            case DioExceptionType.connectionError:
              errorMessage = "No internet connection.";
              break;

            case DioExceptionType.badResponse:

              if (e.response?.statusCode == 401) {

             /*   AuthRepository.logout();
                errorMessage = "Session expired. Please login again.";
*/
              } else if (e.response?.statusCode == 500) {

                errorMessage = "Server error. Please try again later.";

              } else {

                errorMessage = "API error occurred";

              }

              break;

            default:
              errorMessage = "Unexpected error occurred";
          }

          /// 🔹 Show Snackbar globally
          SnackbarService.showError(errorMessage);

          return handler.reject(e);
        },
      ),
    );
  }

}