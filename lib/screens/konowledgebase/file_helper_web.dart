import 'dart:html' as html;

import 'package:erpflutter/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WebViewAll extends StatelessWidget {
  final String dashboardId;
  const WebViewAll({super.key, required this.dashboardId});
  /// Opens or downloads a file in the browser
   static Future<void> openFileweb(String fileName, String fileUrl) async {
    try {
      final anchor = html.AnchorElement(href: fileUrl)
        ..setAttribute("download", fileName)
        ..click();
      print("File download triggered for Web: $fileName");
    } catch (e) {
      print("Error opening file on Web: $e");
    }
  }
   @override
   Widget build(BuildContext context) {
     return  Scaffold(
       appBar:  AppBar(
           backgroundColor: AppColors.APPCOLOR,
           foregroundColor: Colors.white,title: Text("Dashboard")),
       body: Center(
         child: Text(
           "BoldBI Dashboard is only supported on Web.",
           style: TextStyle(fontSize: 16, color: Colors.grey),
         ),
       ),
     );
   }
}
