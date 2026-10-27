
import 'package:erpflutter/database/app_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

class DatabaseHelper {

  final DatabaseService _databaseService =
  DatabaseService();
  /// BULK INSERT TASK LIST


 /* Future<void> insertTaskList(
      List<Map<String, dynamic>> taskList,
      ) async {
    final Database db = await _databaseService.database;

    String userId = await AppPreferences.getUserId();

    Batch batch = db.batch();

    /// STORE API TASK IDS
    List<String> apiTaskIds = [];

    for (var task in taskList) {
      /// ADD LOCAL FIELDS
      task["USERID"] = userId;
      task["SYNCDONE"] = "0";

      /// SAVE TASKID
      apiTaskIds.add(task["TASKID"].toString());

      /// INSERT OR UPDATE
      batch.insert(
        "project_tasks",
        task,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    /// DELETE EXTRA LOCAL RECORDS
    if (apiTaskIds.isNotEmpty) {
      String placeholders =
      List.generate(apiTaskIds.length, (_) => "?").join(",");

      batch.delete(
        "project_tasks",
        where:
        "TASKID NOT IN ($placeholders) AND USERID = ?",
        whereArgs: [
          ...apiTaskIds,
          userId,
        ],
      );
    } else {
      /// IF API RETURNS EMPTY LIST
      batch.delete(
        "project_tasks",
        where: "USERID = ?",
        whereArgs: [userId],
      );
    }

    await batch.commit(noResult: true);

    print("Task list synced successfully");
  }*/
/*  Future<List<Map<String, dynamic>>> getTaskByTaskId(
      int taskId,
      ) async {

    final db =  await _databaseService.database;

    return await db.query(
      "project_tasks",
      where: "TASKID = ?",
      whereArgs: [taskId],
    );
  }*/
  Future<void> insertTaskList(
      List<Map<String, dynamic>> taskList,
      )
  async {

    final Database db =
    await _databaseService.database;

    String userId =
    await AppPreferences.getUserId();

/*    await db.transaction((txn) async {

      /// GET TABLE COLUMNS
      final tableInfo =
      await txn.rawQuery(
        "PRAGMA table_info(project_tasks)",
      );

      final validColumns =
      tableInfo
          .map(
            (e) => e["name"].toString(),
      )
          .toSet();

      final batch = txn.batch();

      /// DELETE OLD DATA
      batch.delete(
        "project_tasks",
        where: "USERID = ?",
        whereArgs: [userId],
      );

      /// INSERT NEW DATA
      for (final task in taskList) {

        final filteredTask =
        Map<String, dynamic>.from(task);

        filteredTask["USERID"] = userId;
        filteredTask["SYNCDONE"] = "0";

        /// REMOVE API COLUMNS
        /// WHICH DON'T EXIST IN SQLITE
        filteredTask.removeWhere(
              (key, value) =>
          !validColumns.contains(key),
        );

        batch.insert(
          "project_tasks",
          filteredTask,
          conflictAlgorithm:
          ConflictAlgorithm.replace,
        );
      }

      await batch.commit(
        noResult: true,
        continueOnError: true,
      );
    });*/

    print(
      "Task list synced successfully",
    );
  }
  /// INSERT TASK
/*  Future<void> insertTask(
      Map<String, dynamic> task,
      )
  async {

    final Database db =
    await _databaseService.database;

    await db.insert(

      "project_tasks",

      task,

      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }*/



 /* /// GET ALL TASKS
  Future<List<Map<String, dynamic>>>
  getAllTasks() async {

    final Database db =
    await _databaseService.database;

    return await db.query(
      "project_tasks",
    );
  }*/
  /*Future<List<ProjectModel>> getUniqueProjects() async {

    final Database db =
    await _databaseService.database;

    final result = await db.rawQuery('''
    
    SELECT DISTINCT 
      PROJID,
      PROJNO,
      PROJDESC
    FROM project_tasks
    ORDER BY PROJNO

  ''');

    return result.map((item) {

      return ProjectModel(
        projId: item['PROJID'] != null
            ? int.parse(item['PROJID'].toString())
            : 0,

        projNo: item['PROJNO']?.toString() ?? "",

        projDesc: item['PROJDESC']?.toString() ?? "",
      );

    }).toList();
  }*/
  /// GET ALL TASKS
/*  Future<List<Map<String, dynamic>>>
  getAllTasks() async {

    final Database db =
    await _databaseService.database;

    String userId =
    await AppPreferences.getUserId();

    print(
      "Reading project_tasks table...",
    );

    List<Map<String, dynamic>> result =
    await db.query(

      "project_tasks",

      where: "USERID = ?",

      whereArgs: [userId],
    );

    print(
      "TOTAL TASKS FROM DB = ${result.length}",
    );

    if(result.isNotEmpty){

      print(
        "FIRST TASK = ${result.first}",
      );

    } else {

      print(
        "project_tasks table is EMPTY",
      );
    }

    return result;
  }*/
  /*Future<List<Map<String, dynamic>>>
  getAllTasks() async {

    final Database db =
    await _databaseService.database;

    print("Reading project_tasks table...");

    List<Map<String, dynamic>> result =
    await db.query(
      "project_tasks",
    );

    print(
      "TOTAL TASKS FROM DB = ${result.length}",
    );

    if(result.isNotEmpty){

      print(
        "FIRST TASK = ${result.first}",
      );
    } else {

      print(
        "project_tasks table is EMPTY",
      );
    }

    return result;
  }*/
 /* Future<List<Map<String, dynamic>>>
  getUniqueProjectsList() async {
    final Database db =
    await _databaseService.database;

    final result = await db.rawQuery('''

SELECT DISTINCT

  PROJID,
  PROJDESC

FROM project_tasks

WHERE PROJID IS NOT NULL
AND PROJID != ''

ORDER BY PROJDESC ASC

''');

    print("DB PROJECT LIST = $result");

    return result;
  }*/
/*  Future<List<Map<String, dynamic>>>
  getUniqueProjectsList() async {

    final Database db =
    await _databaseService.database;

    String userId =
    await AppPreferences.getUserId();

    final result =
    await db.rawQuery('''

SELECT DISTINCT

  PROJID,
  PROJDESC

FROM project_tasks

WHERE PROJID IS NOT NULL
AND PROJID != ''
AND USERID = ?

ORDER BY PROJDESC ASC

''', [userId]);

    print(
      "DB PROJECT LIST = $result",
    );

    return result;
  }*/
/*  Future<List<Map<String, dynamic>>> getAllSubTasks() async {

    final db =
    await DatabaseService().database;

    return await db.query(
      "subtask_details",
    );
  }*/
  Future<List<Map<String, dynamic>>>
  getAllSubTasks() async {

    final db =
    await DatabaseService().database;

    String userId =
    await AppPreferences.getUserId();

    return await db.query(

      "subtask_details",

      where: "USERID = ?",

      whereArgs: [userId],
    );
  }
 /* Future<List<Map<String, dynamic>>> getSubTaskList({
    required int taskId,
    required int projId,
  }) async {

    final Database db =
    await _databaseService.database;

    final List<Map<String, dynamic>> result =
    await db.query(
      "subtask_details",
      where: "TASKID = ? AND PROJID = ?",
      whereArgs: [taskId, projId],
      orderBy: "SEQNO ASC",
    );

    return result;
  }*/
  Future<List<Map<String, dynamic>>> getSubTaskList({
    required int taskId,
    required int projId,
  }) async {

    final Database db =
    await _databaseService.database;

    /// QUERY
    String query = '''
    SELECT *
    FROM subtask_details
    WHERE TASKID = ?
    AND PROJID = ?
    ORDER BY SEQNO ASC
  ''';

    /// PRINT QUERY
    print("QUERY = $query");

    print("TASKID = $taskId");

    print("PROJID = $projId");

    final List<Map<String, dynamic>> result =
    await db.rawQuery(
      query,
      [taskId, projId],
    );

    print("SUBTASK COUNT = ${result.length}");

    return result;
  }
  /// DELETE TASKS
/*  Future<void> deleteAllTasks() async {

    final Database db =
    await _databaseService.database;

    await db.delete(
      "project_tasks",
    );
  }*/
  /// INSERT SINGLE ISSUE
  Future<void> insertIssue(
      Map<String, dynamic> issue,
      ) async {

    final Database db =
    await _databaseService.database;

    await db.insert(

      "project_issues",

      issue,

      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }


  Future<void> insertIssueList(
      List<Map<String, dynamic>> issues,
      ) async {

    try {

      final db =
      await _databaseService.database;

      String userId =
      await AppPreferences.getUserId();

      await db.transaction((txn) async {

        final batch = txn.batch();

        /// DELETE OLD DATA
        batch.delete(
          "project_issues",
          where: "USERID = ?",
          whereArgs: [userId],
        );

        /// INSERT NEW DATA
        for (final issue in issues) {

          batch.insert(
            "project_issues",
            {
              "ISSUEID":
              int.tryParse(
                issue["ISSUEID"]
                    .toString(),
              ) ??
                  0,

              "TASKID":
              int.tryParse(
                issue["TASKID"]
                    .toString(),
              ) ??
                  0,

              "SUBTASKID":
              int.tryParse(
                issue["SUBTASKID"]
                    .toString(),
              ) ??
                  0,

              "PROJID":
              int.tryParse(
                issue["PROJID"]
                    .toString(),
              ) ??
                  0,

              "IssueDesc":
              issue["IssueDesc"]
                  ?.toString() ??
                  "",

              "RaisedBy":
              int.tryParse(
                issue["RaisedBy"]
                    .toString(),
              ) ??
                  0,

              "IssueOwner":
              int.tryParse(
                issue["IssueOwner"]
                    .toString(),
              ) ??
                  0,

              "RaisedOn":
              issue["RaisedOn"]
                  ?.toString() ??
                  "",

              "ISSUEOWNERNAME":
              issue["ISSUEOWNERNAME"]
                  ?.toString() ??
                  "",

              "ResolvedOn":
              issue["ResolvedOn"]
                  ?.toString() ??
                  "",

              "IssueState":
              int.tryParse(
                issue["IssueState"]
                    .toString(),
              ) ??
                  0,

              "REMARK":
              issue["REMARK"]
                  ?.toString() ??
                  "",

              "IsCompleted":
              int.tryParse(
                issue["IsCompleted"]
                    .toString(),
              ) ??
                  0,

              "NeedBYDate":
              issue["NeedBYDate"]
                  ?.toString() ??
                  "",

              "RAISEDBYNAME":
              issue["RAISEDBYNAME"]
                  ?.toString() ??
                  "",

              "STATUS":
              issue["STATUS"]
                  ?.toString() ??
                  "",

              "PROJNO":
              issue["PROJNO"]
                  ?.toString() ??
                  "",

              "PROJNAME":
              issue["PROJNAME"]
                  ?.toString() ??
                  "",

              "SUBTASKNAME":
              issue["SUBTASKDESC"]
                  ?.toString() ??
                  "",
              "TASKNAME":
              issue["TASKDESC"]
                  ?.toString() ??
                  "",
              "ElapsedDays":
              issue["ElapsedDays"]
                  ?.toString() ??
                  "",
              "USERID": userId,

              "SYNCDONE": "0",
            },
          );
        }

        await batch.commit(
          noResult: true,
          continueOnError: true,
        );
      });

      print(
        "Inserted ${issues.length} issues",
      );

    } catch (e) {

      print(
        "Issue Insert Error = $e",
      );
    }
  }
  /*Future<void> insertIssueList(
      List<Map<String, dynamic>> issues,
      )
  async {

    try {

      final Database db =
      await _databaseService.database;

      String userId =
      await AppPreferences.getUserId();

      print("=========== ISSUE INSERT START ===========");

      print("TOTAL ISSUES RECEIVED = ${issues.length}");

      if (issues.isEmpty) {

        print("NO ISSUES FOUND TO INSERT");

        return;
      }

      Batch batch = db.batch();

      for (int i = 0; i < issues.length; i++) {

        final issue = issues[i];

        int issueId =
            int.tryParse(
                issue["ISSUEID"].toString()
            ) ?? 0;

        int taskId =
            int.tryParse(
                issue["TASKID"].toString()
            ) ?? 0;

        int projId =
            int.tryParse(
                issue["PROJID"].toString()
            ) ?? 0;

        Map<String, dynamic> issueMap = {

          "ISSUEID": issueId,

          "TASKID": taskId,

          "SUBTASKID":
          int.tryParse(
              issue["SUBTASKID"].toString()
          ) ?? 0,

          "PROJID": projId,

          "IssueDesc":
          issue["IssueDesc"]?.toString() ?? "",

          "RaisedBy":
          int.tryParse(
              issue["RaisedBy"].toString()
          ) ?? 0,

          "IssueOwner":
          int.tryParse(
              issue["IssueOwner"].toString()
          ) ?? 0,

          "RaisedOn":
          issue["RaisedOn"]?.toString() ?? "",

          "ISSUEOWNERNAME":
          issue["ISSUEOWNERNAME"]?.toString() ?? "",

          "ResolvedOn":
          issue["ResolvedOn"]?.toString() ?? "",

          "IssueState":
          int.tryParse(
              issue["IssueState"].toString()
          ) ?? 0,

          "REMARK":
          issue["REMARK"]?.toString() ?? "",

          "IsCompleted":
          int.tryParse(
              issue["IsCompleted"].toString()
          ) ?? 0,

          "NeedBYDate":
          issue["NeedBYDate"]?.toString() ?? "",

          "RAISEDBYNAME":
          issue["RAISEDBYNAME"]?.toString() ?? "",

          "STATUS":
          issue["STATUS"]?.toString() ?? "",

          "PROJNO":
          issue["PROJNO"]?.toString() ?? "",

          "PROJNAME":
          issue["PROJNAME"]?.toString() ?? "",

          "ElapsedDays":
          issue["ElapsedDays"]?.toString() ?? "",

          "USERID": userId,

          "SYNCDONE": "0",
        };

        final existing = await db.query(

          "project_issues",

          where:
          "ISSUEID = ? AND TASKID = ? AND PROJID = ?",

          whereArgs: [
            issueId,
            taskId,
            projId,
          ],
        );

        if (existing.isNotEmpty && issueId != 0) {

          batch.update(

            "project_issues",

            issueMap,

            where:
            "ISSUEID = ? AND TASKID = ? AND PROJID = ?",

            whereArgs: [
              issueId,
              taskId,
              projId,
            ],
          );

        } else {

          batch.insert(
            "project_issues",
            issueMap,
          );
        }
      }

      print("BATCH COMMIT STARTED");

      await batch.commit(
        noResult: true,
        continueOnError: true,
      );

      print("BATCH COMMIT SUCCESS");

      final result =
      await db.query("project_issues");

      print(
        "TOTAL RECORDS IN project_issues TABLE = ${result.length}",
      );

      print("=========== ISSUE INSERT END ===========");

    } catch (e, stackTrace) {

      print("=========== ISSUE INSERT ERROR ===========");

      print("ERROR = $e");

      print("STACKTRACE = $stackTrace");
    }
  }*/
  /// GET ALL ISSUES
  /*Future<List<Map<String, dynamic>>>
  getAllIssues() async {

    final Database db =
    await _databaseService.database;

    return await db.query(
      "project_issues",
      orderBy: "RaisedOn DESC",
    );
  }*/
 /* Future<List<Map<String, dynamic>>>
  getAllIssues() async {

    final Database db =
    await _databaseService.database;

    return await db.rawQuery("""

    SELECT

      pi.*,

      sd.TASKDESC AS TASKNAME,

      sd.SUBTASKDESC AS SUBTASKNAME

    FROM project_issues pi

    LEFT JOIN subtask_details sd

    ON pi.SUBTASKID = sd.SUBTASKID

    ORDER BY pi.RaisedOn DESC

  """);
  }*/
  Future<List<Map<String, dynamic>>>
  getAllIssues() async {

    final Database db =
    await _databaseService.database;

    String userId =
    await AppPreferences.getUserId();
    return await db.rawQuery(
      '''
  SELECT
    *
  FROM project_issues
  WHERE USERID = ?
  ORDER BY RaisedOn DESC
  ''',
      [userId],
    );
    /*return await db.rawQuery("""

    SELECT

      pi.*,

      sd.TASKDESC AS TASKNAME,

      sd.SUBTASKDESC AS SUBTASKNAME

    FROM project_issues pi

    LEFT JOIN subtask_details sd

    ON pi.SUBTASKID = sd.SUBTASKID

    WHERE pi.USERID = ?

    
    ORDER BY pi.RaisedOn DESC

  """, [userId]);*/
  }
  /// GET ISSUES BY TASK ID
 /* Future<List<Map<String, dynamic>>>
  getIssuesByTaskId(
      String taskId,
      ) async {

    final Database db =
    await _databaseService.database;

    return await db.query(

      "project_issues",

      where: "TASKID = ?",

      whereArgs: [taskId],
    );
  }*/
  Future<List<Map<String, dynamic>>>
  getIssuesByTaskId(
      String taskId,
      ) async {

    final Database db =
    await _databaseService.database;

    String userId =
    await AppPreferences.getUserId();

    return await db.query(

      "project_issues",

      where:
      "TASKID = ? AND USERID = ?",

      whereArgs: [
        taskId,
        userId,
      ],
    );
  }
  /// GET ISSUES BY PROJECT ID
 /* Future<List<Map<String, dynamic>>>
  getIssuesByProjectId(
      String projId,
      ) async {

    final Database db =
    await _databaseService.database;

    return await db.query(

      "project_issues",

      where: "PROJID = ?",

      whereArgs: [projId],
    );
  }
*/
  Future<List<Map<String, dynamic>>>
  getIssuesByProjectId(
      String projId,
      ) async {

    final Database db =
    await _databaseService.database;

    String userId =
    await AppPreferences.getUserId();

    return await db.query(

      "project_issues",

      where:
      "PROJID = ? AND USERID = ?",

      whereArgs: [
        projId,
        userId,
      ],
    );
  }
  /// DELETE ALL ISSUES
  /*Future<void> deleteAllIssues() async {

    final Database db =
    await _databaseService.database;

    await db.delete(
      "project_issues",
    );
  }*/
  Future<void> deleteAllIssues() async {

    final Database db =
    await _databaseService.database;

    String userId =
    await AppPreferences.getUserId();

    await db.delete(

      "project_issues",

      where: "USERID = ?",

      whereArgs: [userId],
    );
  }
  /// DELETE ISSUE BY ISSUEID
  /*Future<void> deleteIssue(
      String issueId,
      ) async {

    final Database db =
    await _databaseService.database;

    await db.delete(

      "project_issues",

      where: "ISSUEID = ?",

      whereArgs: [issueId],
    );
  }*/
  Future<void> deleteIssue(
      String issueId,
      ) async {

    final Database db =
    await _databaseService.database;

    String userId =
    await AppPreferences.getUserId();

    await db.delete(

      "project_issues",

      where:
      "ISSUEID = ? AND USERID = ?",

      whereArgs: [
        issueId,
        userId,
      ],
    );
  }
/*  Future<List<ProjectModel>> getProjects() async {
    final Database db =
    await _databaseService.database;
    final result = await db.rawQuery('''
      SELECT DISTINCT
             PROJID,
             PROJNO,
             PROJDESC
      FROM project_tasks
      ORDER BY PROJDESC
    ''');

    return result.map((e) => ProjectModel(
      projId: int.tryParse(e['PROJID'].toString()) ?? 0,
      projNo: e['PROJNO'].toString(),
      projDesc: e['PROJDESC'].toString(),
    )).toList();
  }

  Future<List<UserModel>> getProjectManagers() async {
    final Database db =
    await _databaseService.database;
    final result = await db.rawQuery('''
      SELECT USERID,
             USERNAME
      FROM users
      WHERE ISACTIVE = 1
      ORDER BY USERNAME
    ''');

    return result.map((e) => UserModel(
      id: int.tryParse(e['USERID'].toString()) ?? 0,
      userName: e['USERNAME'].toString(),
    )).toList();
  }*/
}
