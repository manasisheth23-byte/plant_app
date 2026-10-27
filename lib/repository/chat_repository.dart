
import 'package:dio/dio.dart';
import 'package:erpflutter/database/app_preferences.dart';
import 'package:erpflutter/repository/api_service.dart';

class ChatRepository {

  final Dio _dio = DioClient().dio;

  /// CREATE SESSION
  Future<dynamic> createSession(String projectNo) async {

    try {
      String userId = await AppPreferences.getUserId();
      final body = {

        "XMLFILE": {

          "USERID":userId,

          "PROJNO": projectNo,
        }
      };

      final response = await _dio.post(

        "Chat/CreateSession",

        data: body,

        options: Options(
          headers: {
            "Content-Type":
            "application/json",
          },
        ),
      );

      return response.data;

    } on DioException catch (e) {

      throw Exception(
        e.response?.data ??
            "Create Session Failed",
      );
    }
  }

  /// SEND MESSAGE
  Future<dynamic> sendMessage({

    required String sessionId,

    required String message,
    required String code,
    required String projectNo,

  })
  async {

    try {
      if(projectNo == ""){
        projectNo ="NA";
      }
      String userId = await AppPreferences.getUserId();
      final body = {

        "XMLFILE": {

          "SessionId": sessionId,

          "Message": message,

          "USERID": userId,
          "CODE": code,

          "PROJNO": projectNo,
        }
      };

      final response = await _dio.post(

        "Chat/SendMessage",

        data: body,

        options: Options(
          headers: {
            "Content-Type":
            "application/json",
          },
        ),
      );

      return response.data;

    } on DioException catch (e) {

      throw Exception(
        e.response?.data ??
            "Send Message Failed",
      );
    }
  }
}