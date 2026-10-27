import 'package:flutter/material.dart';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/themecontroller.dart';


class ColorScreen extends StatefulWidget {
  const ColorScreen({super.key});

  @override
  State<ColorScreen> createState() => _ColorScreenState();
}

class _ColorScreenState extends State<ColorScreen> {
  String selectedColor = "navy";
  bool isLoading = false;

  final List<String> colors = [
    "navy",
    "blue",
    "primaryBlue",
    "indigo",
    "teal",
    "cyan",
    "emerald",
    "skyBlue",
    "slate",
    "coolGray",
    "steelBlue",
    "softPurple",
  ];

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB), // default for mobile
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 900;

            return Container(
              color: isDesktop ?  themeController.primaryColor : null, // Windows background
              child: isDesktop
                  ? Center(
                child: Container(
                  width: 650,
                  margin: const EdgeInsets.symmetric(
                    vertical: 25,
                    horizontal: 20,
                  ),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FB), // Screen/card background
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: buildBody(themeController, isDesktop),
                ),
              )
                  : buildBody(themeController, isDesktop), // Mobile full screen
            );
          },
        ),
      ),
    );
  }

  Widget buildBody(ThemeController themeController, bool isDesktop) {
    return ListView(
      padding: EdgeInsets.all(isDesktop ? 0 : 20),
      shrinkWrap: true,
      children: [
        // Header
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                "App Settings",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 22 : 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            SizedBox(width: 40),
          ],
        ),
        SizedBox(height: 25),

        // Dropdown for colors
        Material(
          color: Colors.transparent,
          child: DropdownSearch<String>(
            items: colors,
            selectedItem: selectedColor,
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: "Select App Color",
                border: OutlineInputBorder(),
              ),
            ),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
            ),
            itemAsString: (color) => color.toUpperCase(),
            onChanged: (value) {
              setState(() {
                selectedColor = value!;
              });
            },
          ),
        ),
        SizedBox(height: 30),

        // Apply button
        SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeController.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: isLoading
                ? null
                : () async {
              setState(() {
                isLoading = true;
              });

              Color color = getColorFromName(selectedColor);
              themeController.updateColors(
                primary: color,
                dark: getDarkShade(color),
              );

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString("app_color", selectedColor);

              await Future.delayed(const Duration(seconds: 1));

              setState(() {
                isLoading = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Settings Applied")),
              );
            },
            child: isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              "Apply",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color getDarkShade(Color color) {
    return Color.fromRGBO(
      (color.red * 0.7).round(),
      (color.green * 0.7).round(),
      (color.blue * 0.7).round(),
      1,
    );
  }

  Color getColorFromName(String name) {
    switch (name) {
      case "navy":
        return const Color(0xFF1A2744);
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
        return const Color(0xFF1A2744);
    }
  }
}