import 'package:shared_preferences/shared_preferences.dart';

String? userId;
String? token;
String? orgStructId;
String? posId;
String? controlno;

Future<void> getData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  userId = prefs.getString('USERID') ?? '';
  token = prefs.getString('TOKEN') ?? '';
  orgStructId = prefs.getString('ORGSTRUCTID') ?? '';
  posId = prefs.getString('POSID') ?? '';
  controlno = prefs.getString('CONTROLNO')??'';
}