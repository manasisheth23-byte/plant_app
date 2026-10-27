import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ThemeController extends ChangeNotifier {

  Color primaryColor = const Color(0xFF12426E);
  Color darkColor = const Color(0xFF0F3460);

  void updateColors({
    required Color primary,
    required Color dark,
  }) {
    primaryColor = primary;
    darkColor = dark;
    notifyListeners();
  }

  Future<void> loadSavedColor() async {
    final prefs = await SharedPreferences.getInstance();
    String? colorName = prefs.getString("app_color");

    final colors = getThemeColors(colorName ?? "navy");

    primaryColor = colors['primary']!;
    darkColor = colors['dark']!;

    notifyListeners();
  }

  Map<String, Color> getThemeColors(String name) {
    switch (name) {
      case "navy":
        return {
          "primary": const Color(0xFF1A2744),
          "dark": const Color(0xFF0F3460),
        };

      case "blue":
        return {
          "primary": const Color(0xFF1976D2),
          "dark": const Color(0xFF0D47A1),
        };

      case "teal":
        return {
          "primary": const Color(0xFF009688),
          "dark": const Color(0xFF00695C),
        };

      case "emerald":
        return {
          "primary": const Color(0xFF2E7D32),
          "dark": const Color(0xFF1B5E20),
        };

      default:
        return {
          "primary": const Color(0xFF1A2744),
          "dark": const Color(0xFF0F3460),
        };
    }
  }
}
/*
class ThemeController extends ChangeNotifier {
  Color primaryColor = const Color(0xFF1A2744);
  //const Color(0xFF2789E4);

  void updateColor(Color newColor) {
    primaryColor = newColor;
    notifyListeners();
  }
  Future<void> loadSavedColor() async {
    final prefs = await SharedPreferences.getInstance();
    String? colorName = prefs.getString("app_color");

    if (colorName != null && colorName.isNotEmpty) {
      primaryColor = getColorFromName(colorName);
    } else {
      primaryColor =  Color(0xFF1A2744);
          //Colors.blue; // ✅ default color
    }

    notifyListeners();
  }
  Color getColorFromName(String name) {
    switch (name) {
      case "primaryBlue":
        return const Color(0xFF1976D2);
      case "indigo":
        return const Color(0xFF3F51B5);
      case "teal":
        return const Color(0xFF009688);
      case "cyan":
        return const Color(0xFF00ACC1);
      case "emerald":
        return const Color(0xFF2E7D32);
      case "skyBlue":
        return const Color(0xFF0288D1);
      case "slate":
        return const Color(0xFF455A64);
      case "coolGray":
        return const Color(0xFF607D8B);
      case "steelBlue":
        return const Color(0xFF4682B4);
      case "blue":
        return Colors.blue;
      case "softPurple":
        return const Color(0xFF7E57C2);
      default:
        return Colors.blue;
    }
  }
}*/
