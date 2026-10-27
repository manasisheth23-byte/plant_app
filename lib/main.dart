import 'dart:io';

import 'package:erpflutter/Constants.dart';
import 'package:erpflutter/Dashboard.dart';
import 'package:erpflutter/barcodescanner/view_models/audit_barcode_viewmodel.dart';
import 'package:erpflutter/barcodescanner/view_models/barcoderegistration_viewmodel.dart';
import 'package:erpflutter/barcodescanner/views/barcode_audit.dart';
import 'package:erpflutter/models/getnotificationmodel.dart';
import 'package:erpflutter/provider/barcode_provider.dart';
import 'package:erpflutter/provider/chat_viewmodel.dart';
import 'package:erpflutter/provider/edit_note_provider.dart';
import 'package:erpflutter/provider/financialyear_provider.dart';
import 'package:erpflutter/provider/get_notification_provider.dart';
import 'package:erpflutter/provider/so_list_provider.dart';
import 'package:erpflutter/provider/sotable_provider.dart';
import 'package:erpflutter/provider/themecontroller.dart';
import 'package:erpflutter/screens/UnreadNotificationProvider.dart';
import 'package:erpflutter/screens/activity/activity_controller.dart';
import 'package:erpflutter/screens/alerts/alerts_list.dart';
import 'package:erpflutter/screens/aprovals/approvals_controller.dart';
import 'package:erpflutter/screens/login/login_controller.dart';
import 'package:erpflutter/screens/login/login_viewmodel.dart';
import 'package:erpflutter/screens/plantlist/plant_provider.dart';
import 'package:erpflutter/screens/so_reports/so_projectwise_controller.dart';
import 'package:erpflutter/screens/soreport/sochart_controller.dart';
import 'package:erpflutter/screens/supplier/supplier_controller.dart';

import 'package:erpflutter/splash_screen.dart';
import 'package:erpflutter/utils/global_variables.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'barcodescanner/view_models/physical_barcode_viewmodel.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isIOS){
    final prefs = await SharedPreferences.getInstance();

    bool firstLaunch = prefs.getBool('first_launch') ?? true;

    if (firstLaunch) {
      await const FlutterSecureStorage().deleteAll();

      await prefs.setBool('first_launch', false);
    }
  }else if(Platform.isWindows){
    final prefs = await SharedPreferences.getInstance();

    bool firstLaunch = prefs.getBool('first_launch') ?? true;

    if (firstLaunch) {
      await clearAppData();
    }
  }
  if (Platform.isAndroid) {
    try {
     await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    } catch (e) {
      print("Firebase not initialized: $e");
    }
  }
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final initializationSettings = InitializationSettings(
    android: Platform.isAndroid ? AndroidInitializationSettings('@mipmap/applogo') : null,
    iOS: Platform.isIOS ? DarwinInitializationSettings(onDidReceiveLocalNotification: onSelectNotificationIOS) : null,

  );

  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onSelectNotification);

  if (Platform.isAndroid) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("============= FCM Notification Received =============");

      // Notification payload
      print("Title      : ${message.notification?.title}");
      print("Body       : ${message.notification?.body}");

      // Data payload
      print("Data       : ${message.data}");

      // Individual data values
      message.data.forEach((key, value) {
        print("$key : $value");
      });

      print("Message ID : ${message.messageId}");
      print("Sent Time  : ${message.sentTime}");

      print("=====================================================");
      if (message.data.isNotEmpty) {
        handleNotificationData(message.data);
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message?.data.isNotEmpty ?? false) {
        handleNotificationData(message!.data);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.data.isNotEmpty) {
        handleNotificationData(message.data);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('open_notification_screen', true);
      }
    });
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? stringValuebaseTOKEN = prefs.getString('TOKEN');
  String? stringValuebaseUserId = prefs.getString('USERID');



  print('token------------>$stringValuebaseTOKEN');
  print('ID------------>$stringValuebaseUserId');
  print('pos------------>$posId');
  print('org------------>$orgStructId');
  print('controlno..........>$controlno');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginController()),
        ChangeNotifierProvider(create: (context) => SupplierController()),
        ChangeNotifierProvider(create: (context) => ApprovalsController()),
        ChangeNotifierProvider(create: (context) => ActivityController()),
        ChangeNotifierProvider(create: (context) => SoListProvider()),
        ChangeNotifierProvider(create: (context) => GetNotificationProvider()),
        ChangeNotifierProvider(create: (context) => EditNoteProvider()),
        ChangeNotifierProvider(create: (context) => SoChatService()),
        ChangeNotifierProvider(create: (context) => SoReportProvider()),
        ChangeNotifierProvider(create: (context) => ProjectWiseDetailtProvider()),
        ChangeNotifierProvider(create: (_) => UnreadNotificationProvider()),
        ChangeNotifierProvider(create: (context) => BarcodeProvider()),
        ChangeNotifierProvider(create: (context) => AuditProvider()),
        ChangeNotifierProvider(create: (context) => ProductionBarcodeViewModel()),
        ChangeNotifierProvider(create: (_) => PlantProvider()),
        ChangeNotifierProvider(create: (_) => FinancialYearProvider()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => BarcodeProviderAns()),

      ],
      child: MyApp(),
    ),
  );
}


Future<void> clearAppData() async {
  final appData = Platform.environment['APPDATA'];

  if (appData == null) {
    print("APPDATA not found");
    return;
  }

  final directory = Directory(
    '$appData\\com.c9BusinessSuite',
  );

  if (await directory.exists()) {
    await directory.delete(recursive: true);
    print("Deleted: ${directory.path}");
  } else {
    print("Directory does not exist");
  }
}
void onSelectNotificationIOS(int a, String? b, String? c, String? d) async {
  Get.to(AlertsList(showAppBar: true,));
}

void onSelectNotification(NotificationResponse? payload) async {
  Get.to(AlertsList(showAppBar: true,));
}

Future<void> handleNotificationData(Map<String, dynamic> data) async {
  String? rawMessage = data['data'];
  print(rawMessage);
  if (rawMessage != null) {
    //final parsedMap = parseCustomDataString(rawMessage);

    String notifyBy =data['NOTIFYBYNAME'];
        //parsedMap['NOTIFYBYNAME'] ?? '';
   // String notifyTo = parsedMap['NOTIFYTONAME'] ?? '';
   // String date = parsedMap['NOTIFYDATETIME'] ?? '';
    //String time = parsedMap['Notifytime'] ?? '';
    String msg = data['MSGBODY'] ?? '';
    String subject = data['SUBJECT'] ?? '';

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'your channel id', 'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    int notificationId = (DateTime.now().millisecondsSinceEpoch % 2147483647).abs();
    if (notificationId == 0) notificationId = 1;

    await flutterLocalNotificationsPlugin.show(
        notificationId, notifyBy, msg, notificationDetails,
        payload: 'item x');
  }
}

Map<String, String> parseCustomDataString(String input) {
  final Map<String, String> result = {};
  input = input.replaceAll('{', '').replaceAll('}', '');
  final pairs = input.split(',');

  for (var pair in pairs) {
    final keyValue = pair.split('=');
    if (keyValue.length == 2) {
      final key = keyValue[0].trim();
      final value = keyValue[1].trim();
      result[key] = value;
    }
  }
  return result;
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handler logic if needed
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyApp();
}
class _MyApp extends State<MyApp>  {
  Future<void> getNotificationCount() async {
    try {

      final notificationProvider = Provider.of<GetNotificationProvider>(context, listen: false);

      // Wait for data to be fetched
      await notificationProvider.GetNotification("0");

      // Safely access the list
      List<NitificationLIST> notifications =
          notificationProvider.getNotificationModel?.dATA?.lIST ?? [];

      // Sort unread first
      notifications.sort((a, b) {
        return (a.ISREAD == "0" ? 0 : 1).compareTo(b.ISREAD == "0" ? 0 : 1);
      });

      // Count unread
      Constant.unreadCount = notifications.where((item) => item.ISREAD == "0").length;
      final unreadProvider = Provider.of<UnreadNotificationProvider>(context, listen: false);
      unreadProvider.setUnreadCount(
        notifications.where((item) => item.ISREAD == "0").length,
      );
      print("Unread count: $Constant.unreadCount");
    } catch (e) {
      print("Error fetching notification count: $e");
    }
  }
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      getNotificationCount();
    });

    if(Platform.isWindows){

      /*_channel.stream.listen((data) {
        print('Received data: $data');
        setState(() {
          _message = data;
        });
      }, onDone: () => print("WebSocket closed."),
          onError: (e) {
        print("WebSocket error: $e");
      });*/
    }

  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      /*theme: ThemeData(
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue, foregroundColor: Colors.white),
        primaryColor: Colors.blue,
        tabBarTheme: TabBarTheme(
            labelColor: Colors.blue, indicatorColor: Colors.blue),
        cardTheme: CardTheme(elevation: 0),
      ),*/

      title: 'C9Erp',
      initialRoute: 'splash',
      routes: {
        'splash': (context) => SplashScreen(),
        '/dashbored': (context) => Dashboard(),
        '/AlertsList': (context) => AlertsList(showAppBar: true,),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
