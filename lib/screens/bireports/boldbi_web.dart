import 'package:flutter/material.dart';


class BoldBIDashboardWeb extends StatelessWidget {
  final String dashboardId;
  const BoldBIDashboardWeb({super.key, required this.dashboardId});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:  AppBar(title: Text("Dashboard")),
      body: Center(
        child: Text(
          "BoldBI Dashboard is only supported on Web.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
