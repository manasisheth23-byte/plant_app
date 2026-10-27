
import 'package:erpflutter/database/DatabaseHelper.dart';
import 'package:erpflutter/repository/chat_repository.dart';
import 'package:flutter/material.dart';


class ChatViewModel extends ChangeNotifier {

  final ChatRepository repository =
  ChatRepository();
  List<Map<String, dynamic>> questionList = [];
  String sessionId = "";
  final DatabaseHelper dbHelper =
  DatabaseHelper();
  bool isLoading = false;
  bool isLoadingmsg = false;
  List<Map<String, dynamic>> messages = [];
  Future<void> createSession({required String ProjectNo,}) async {

    try {

      /// CLEAR OLD CHAT
      messages.clear();

      /// CLEAR OLD QUESTIONS
      questionList.clear();

      /// DEFAULT BOT MESSAGE
      messages.add({

        "isBot": true,

        "message":
        "Welcome back! How can I help you today?",
      });

      isLoading = true;

      notifyListeners();

      final response =
      await repository.createSession(ProjectNo);

      sessionId =
      response["DATA"]["SESSIONID"];

      /// STORE QUESTION LIST
      questionList =

      List<Map<String, dynamic>>.from(

        response["DATA"]["LIST"] ?? [],
      );

      debugPrint(
        "SESSION ID : $sessionId",
      );

      debugPrint(
        "QUESTION COUNT : ${questionList.length}",
      );

    } catch (e) {

      debugPrint(e.toString());

    } finally {

      isLoading = false;

      notifyListeners();
    }
  }
  /*Future<void> createSession() async {

    try {

      /// CLEAR OLD CHAT
      messages.clear();

      /// OPTIONAL DEFAULT BOT MESSAGE
      messages.add({

        "isBot": true,

        "message":
        "Welcome back! How can I help you today?",
      });

      isLoading = true;

      notifyListeners();

      final response =
      await repository.createSession();

      sessionId =
      response["DATA"]["SESSIONID"];

      debugPrint(
        "SESSION ID : $sessionId",
      );

    } catch (e) {

      debugPrint(e.toString());

    } finally {

      isLoading = false;

      notifyListeners();
    }
  }*/
  /*Future<void> createSession() async {

    try {

      isLoading = true;

      notifyListeners();

      final response =
      await repository.createSession();

      sessionId =
      response["DATA"]["SESSIONID"];

      debugPrint(
        "SESSION ID : $sessionId",
      );

    } catch (e) {

      debugPrint(e.toString());

    } finally {

      isLoading = false;

      notifyListeners();
    }
  }*/
  Future<void> sendMessage({

    required String message,

    String code = "",
    String projectNo ="NA",
  }) async {

    if (message.trim().isEmpty) {
      return;
    }

    /// USER MESSAGE
    messages.add({

      "isBot": false,

      "message": message,
    });

    isLoadingmsg = true;

    notifyListeners();

    try {

      final response =
      await repository.sendMessage(

        sessionId: sessionId,

        message: message,

        code: code,
        projectNo: projectNo,
      );


      isLoadingmsg = false;

      messages.add({

        "isBot": true,

        "message":
        response["ROOT"]["REPLY"]
            .toString(),
      });

      notifyListeners();

    } catch (e) {

      isLoadingmsg = false;

      messages.add({

        "isBot": true,

        "message":
        "Something went wrong",
      });

      notifyListeners();
    }
  }


/*
  List<ProjectModel> projectList = [];

  bool isProjectLoading = false;

  Future<void> loadProjects() async {

    try {

      isProjectLoading = true;

      notifyListeners();

      projectList =
      await dbHelper.getUniqueProjects();

    } catch (e) {

      debugPrint("Error loading projects: $e");

    } finally {

      isProjectLoading = false;

      notifyListeners();
    }
  }*/

  /*Future<void> sendMessage(
      {

        required String message,

        String code = "",
      }
      )
  async {

    if (message.trim().isEmpty) {
      return;
    }

    /// USER MESSAGE
    messages.add({
      "isBot": false,
      "message": message,
    });

    /// SHOW LOADING
    isLoadingmsg = true;

    notifyListeners();

    try {

      final response =
      await repository.sendMessage(

        sessionId: sessionId,

        message: message,
        code: code,
      );

      /// HIDE LOADING
      isLoadingmsg = false;

      /// BOT MESSAGE
      messages.add({

        "isBot": true,

        "message":
        response["ROOT"]["Reply"]
            .toString(),
      });

      notifyListeners();

    } catch (e) {

      /// HIDE LOADING
      isLoadingmsg = false;

      messages.add({

        "isBot": true,

        "message":
        "Something went wrong",
      });

      notifyListeners();
    }
  }*/
  /*Future<void> sendMessage(
      String message)
  async {

    if (message.trim().isEmpty) {
      return;
    }

    messages.add({
      "isBot": false,
      "message": message,
    });

    notifyListeners();

    try {

      final response =
      await repository.sendMessage(
        sessionId: sessionId,
        message: message,
      );

      messages.add({

        "isBot": true,

        "message":
        response["DATA"]["RESPONSE"]
            .toString(),
      });

      notifyListeners();

    } catch (e) {

      messages.add({

        "isBot": true,

        "message":
        "Something went wrong",
      });

      notifyListeners();
    }
  }*/

}