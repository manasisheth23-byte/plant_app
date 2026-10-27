import 'package:connectivity_wrapper/connectivity_wrapper.dart';

import '../database/database_service.dart';
import '../database/secure_storage_service.dart';
import '../services/ApiProvider.dart';

class CommonUtils{


        //check internet connection 04-07-2019
         Future<bool> check() async {
       // var connectivityResult =await ConnectivityWrapper.instance.isConnected ;
        if (await ConnectivityWrapper.instance.isConnected) {
          return true;
        }
        return false;
      }

         static final ApiProvider _repository = ApiProvider();
         static final Set<String> _processingProjects = {};
     /*    static Future<void> handleReleasedNotification({
           required String token,
           required String userId,
           required String projId,
         })
         async {

           /// 🔹 Prevent duplicate execution
           if (_processingProjects.contains(projId)) {
             print("Project $projId is already processing. Skipping duplicate call.");
             return;
           }

           _processingProjects.add(projId);

           try {
             final TaskRepository repository =
             TaskRepository();

             /// 🔹 Fetch subtasks
             repository.getTasks();

             final repo = SubTaskRepository();

             await repo.getSubTasks(
               token: token,
               userId: userId,
               projId: projId,
             );


             await repo.getSubTasksTypeThree(
               token: token ?? "",
               userId: userId ?? "",
               projId: projId,
               taskId: "0",
             );
             print("Released notification handled successfully");

           } catch (e) {
             print("Error handling Released notification: $e");
           } finally {
             /// 🔹 Remove lock after completion
             _processingProjects.remove(projId);
             final context =AuthRepository.navigatorKey.currentContext;

             if (context != null) {
               Provider.of<DashboardViewModel>(context, listen: false).refreshDashboard();
             }
           }
         }*/
         static Set<String> _processingIssues = {};
/*  static Future<void> deleteIssueById(String issueId) async {
    final db = await DatabaseService().database;

    try {
      int count = await db.delete(
        "subtask_issues",
        where: "ISSUEID = ?",
        whereArgs: [issueId],
      );

      print("🗑️ Deleted rows: $count for ISSUEID: $issueId");
    } catch (e) {
      print("❌ Delete error: $e");
    }
  }*/
  static Future<void> deleteIssueById(
      String issueId,
      ) async {

    final db =
    await DatabaseService().database;

    try {

      int count =
      await db.delete(

        "project_issues",

        where: "ISSUEID = ?",

        whereArgs: [issueId],
      );

      print(

        "🗑️ Deleted rows: $count for ISSUEID: $issueId",
      );

    } catch (e) {

      print("❌ Delete error: $e");
    }
  }
/*  static Future<void> handleNewIssueNotification({
    required String token,
    required String userId,
    String? issueId,
    String? taskId,
    String? subTaskId,
  }) async {

    /// 🔒 Prevent duplicate execution
    String uniqueKey = issueId ?? "0";

    if (_processingIssues.contains(uniqueKey)) {
      print("⚠️ Issue already processing. Skipping duplicate call.");
      return;
    }

    _processingIssues.add(uniqueKey);

    try {
      final repo = TaskRepository();

      print("📥 Calling getSubTaskIssues API...");
      await repo.getTasks(
        taskId: (taskId != null && taskId.isNotEmpty)
            ? taskId
            : "0",
        issueId: (issueId != null && issueId.isNotEmpty)
            ? issueId
            : "0",
      );
      /// ✅ ONLY THIS API
      *//* await repo.getSubTaskIssues(issueId:  (issueId != null && issueId.isNotEmpty) ? issueId : "0",
        taskId:(taskId != null && taskId.isNotEmpty) ? taskId : "0",
        subTaskId: (subTaskId != null && subTaskId.isNotEmpty) ? subTaskId : "0");
*//*
      print("✅ New Issue API handled successfully");

    } catch (e) {
      print("❌ Error handling New Issue notification: $e");
    } finally {
      /// 🔓 Remove lock
      _processingIssues.remove(uniqueKey);

      /// ❌ NO dashboard refresh here
    }
  }*/
  /// 🔹 Check Notification Code
  /*static Future<void> checkNotificationAction({
    required Map<String, dynamic> data,
    required String token,
    required String userId,
  }) async {
    String msgCode = "";
    String msgBody = data["MSGBODY"] ?? "";
    if (msgBody.contains("MSGCODE:")) {
      msgCode = msgBody.split("MSGCODE:")[1].split(",")[0].trim().toLowerCase();
    }
    int projId = 0;

    if (msgBody.contains("PROJID:")) {
      projId = int.tryParse(
        msgBody.split("PROJID:")[1].split(",")[0].trim(),
      ) ??
          0;
    }
   // String msgCode = (data["MSGBODY"]?["MSGCODE"] ?? "").toString().toLowerCase();
    //String projId = (data["MSGBODY"]?["PROJID"] ?? "").toString();

    if (msgCode == "released") {

      await handleReleasedNotification(
        token: token,
        userId: userId,
        projId: projId.toString(),
      );

    }else if(msgCode == "updated"){
      await handleReleasedNotification(
        token: token,
        userId: userId,
        projId: projId.toString(),
      );
    }else if(data["messagecode"] == "Logout" && data['IsLogout'] == "1"){
      CommonUtil.logoutUser();
    }
  }
*/
/*  static Future<void> checkNotificationAction({
    required Map<String, dynamic> data,
    required String token,
    required String userId,
    bool isFromBackground = false,
  }) async {
    print("👉 checkNotificationAction called");

    String msgCode = "";
    String msgBody = data["MSGBODY"] ?? "";

    /// ✅ Extract MSGCODE safely
    if (msgBody.contains("MSGCODE:")) {
      try {
        msgCode = msgBody
            .split("MSGCODE:")[1]
            .split(",")[0]
            .trim()
            .toLowerCase();
      } catch (e) {
        print("❌ MSGCODE parsing error: $e");
      }
    }

    /// ✅ Extract PROJID safely
    int projId = 0;
    if (msgBody.contains("PROJID:")) {
      try {
        projId = int.tryParse(
          msgBody.split("PROJID:")[1].split(",")[0].trim(),
        ) ??
            0;
      } catch (e) {
        print("❌ PROJID parsing error: $e");
      }
    }

    print("👉 msgCode: $msgCode");
    print("👉 projId: $projId");

    /// ✅ Handle Released / Updated
    if (msgCode == "released" || msgCode == "updated") {
      print("👉 Calling handleReleasedNotification");

      try {
        if (isFromBackground) {
          print("📦 Storing project for later: $projId");
          await PendingNotificationService.addPendingProject(projId.toString());
          //await AppPreferences.addPendingProject(projId.toString());
        } else {
          await handleReleasedNotification(
            token: token,
            userId: userId,
            projId: projId.toString(),
          );
        }
        *//*await handleReleasedNotification(
          token: token,
          userId: userId,
          projId: projId.toString(),
        );*//*
      } catch (e) {
        print("❌ handleReleasedNotification error: $e");
      }
    }
    if (msgCode == "newissue") {
      print("👉 Handling NEW ISSUE notification");

      String msgBody = data["MSGBODY"] ?? "";

      String issueId = "";
      String taskId = "";
      String subTaskId = "";

      List<String> parts = msgBody.split(",");

      for (String part in parts) {
        part = part.trim();

        if (part.startsWith("ISSUEID")) {
          issueId = part.split(":")[1].trim();
        } else if (part.startsWith("TASKID")) {
          taskId = part.split(":")[1].trim();
        } else if (part.startsWith("SUBTASKID")) {
          subTaskId = part.split(":")[1].trim();
        }
      }

      print("ISSUEID: $issueId");
      print("TASKID: $taskId");
      print("SUBTASKID: $subTaskId");

      try {
        if (isFromBackground) {
          /// 📦 BACKGROUND → store for later
          print("📦 Storing NEW ISSUE for later");

          await PendingNotificationService.addPendingIssue(
            issueId: issueId,
            taskId: taskId,
            subTaskId: subTaskId,
          );

        } else {
          /// 🚀 FOREGROUND → call API directly
          await handleNewIssueNotification(
            token: token,
            userId: userId,
            issueId: issueId,
            taskId: taskId,
            subTaskId: subTaskId,
          );
        }
      } catch (e) {
        print("❌ NEW ISSUE error: $e");
      }
    }
    if(msgCode == "deleted"){
      String msgBody = data["MSGBODY"] ?? "";

      String issueId = "";
      String taskId = "";
      String subTaskId = "";

      List<String> parts = msgBody.split(",");

      for (String part in parts) {
        part = part.trim();

        if (part.startsWith("ISSUEID")) {
          issueId = part.split(":")[1].trim();
        } else if (part.startsWith("TASKID")) {
          taskId = part.split(":")[1].trim();
        } else if (part.startsWith("SUBTASKID")) {
          subTaskId = part.split(":")[1].trim();
        }
      }
      if (issueId != null) {
        if (isFromBackground) {
          if (issueId != null) {
            final db = await DatabaseService().database;

            *//* await db.delete(
              "subtask_issues",
              where: "ISSUEID = ?",
              whereArgs: [issueId],
            );*//*
            await db.delete(

              "project_issues",

              where: "ISSUEID = ?",

              whereArgs: [issueId],
            );
            print("🗑️ Deleted in background ISSUEID: $issueId");
          }
        }else{
          await deleteIssueById(issueId);
        }

      }
    }

    /// ✅ Handle Logout
    if (data["messagecode"] == "Logout" &&
        data['IsLogout'] == "1") {
      print("👉 Logout triggered");

      try {
        if (isFromBackground) {
          // ✅ Background → NO UI
          await SecureStorageService.setLoggedIn(false);
          print("✅ Background logout done");
        } else {
          // ✅ Foreground / Click → UI logout
          await CommonUtil.logoutUser();
          print("✅ UI logout done");
        }
      } catch (e) {
        print("❌ Logout error: $e");
      }
    }
  }*/
/*  static Future<void> insertSubTasks(List<TaskDetailsModel> subtasks) async {
    try {
      final db = await DatabaseService().database;

      Batch batch = db.batch();

      for (var e in subtasks) {
        batch.insert(
          "project_tasks",
          {
            "projId": e.projId,
            "projNo": e.projNo ?? "",
            "projDesc": e.projDesc ?? "",
            "taskId": e.taskId,
            "taskNo": e.taskNo ?? "",
            "taskDesc": e.taskDesc ?? "",
            "subTaskId": e.subTaskId,
            "subTaskDesc": e.subTaskDesc ?? "",
            "skillId": e.skillId,
            "skillDesc": e.skillDesc ?? "",
            "deptId": e.deptId,
            "deptDesc": e.deptDesc ?? "",
            "taskTypeId": e.taskTypeId,
            "taskTypeDesc": e.taskTypeDesc ?? "",
            "isCompleted": e.isCompleted ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);

      print("Subtasks inserted successfully");

    } catch (e, stackTrace) {
      print("SQLite Insert Error: $e");
      print(stackTrace);
    }
  }
  /// 🔹 Check Internet and Sync Edited Subtasks
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// 🔹 Start listening for internet connection
  static void startAutoSync() {

    _subscription = Connectivity().onConnectivityChanged.listen((result) async {

      if (!result.contains(ConnectivityResult.none)) {

        print("Internet detected → Running background sync");

        final repo = SubTaskRepository();

        // Run sync in background
        await repo.syncEditedSubtasks();

      } else {
        print("No internet connection");
      }

    });

  }*/

  /// 🔹 Stop listener (optional)
/*  static void stopAutoSync() {
    _subscription?.cancel();
  }*/
 /* static Future<void> logoutUser() async {

    await SecureStorageService.setLoggedIn(false);

    AuthRepository.navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
    );
  }*/
  static Future<void> logoutUserBackground() async {
    print("👉 Background logout (no UI)");

    await SecureStorageService.setLoggedIn(false);

    // Optional: clear prefs
    // await AppPreferences.clearAll();
  }
    }
    
    