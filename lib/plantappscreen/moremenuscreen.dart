
import 'package:erpflutter/plantappscreen/copilot.dart';
import 'package:erpflutter/screens/report/report.dart';
import 'package:flutter/material.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          menuItem(
            context,
            icon: Icons.bar_chart,
            color: Colors.blue,
            title: "Reports",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Report(),
                ),
              );
            },
          ),

          menuItem(
            context,
            icon: Icons.chat,
            color: Colors.green,
            title: "Plant Copilot",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CopilotScreen(role: '',),
                ),
              );
            },
          ),

          menuItem(
            context,
            icon: Icons.approval,
            color: Colors.orange,
            title: "Approvals",
            onTap: () {},
          ),

          menuItem(
            context,
            icon: Icons.task_alt,
            color: Colors.purple,
            title: "Tasks",
            onTap: () {},
          ),

          menuItem(
            context,
            icon: Icons.settings,
            color: Colors.red,
            title: "Settings",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget menuItem(
      BuildContext context, {
        required IconData icon,
        required Color color,
        required String title,
        required VoidCallback onTap,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}