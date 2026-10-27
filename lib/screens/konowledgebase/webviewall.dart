import 'package:erpflutter/app_colors.dart';
import 'package:flutter/material.dart';


class WebViewAll extends StatelessWidget {
  final String dashboardId;
  const WebViewAll({super.key, required this.dashboardId});
  static Future<void> openFileweb(String fileName, String fileUrl) async {

  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:  AppBar(
          backgroundColor: AppColors.APPCOLOR,
          foregroundColor: Colors.white,
          title: Text("Dashboard")),
      body: Center(
        child: Text(
          "BoldBI Dashboard is only supported on Web.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
