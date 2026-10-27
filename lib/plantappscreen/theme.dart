import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


/// Cloud 9 brand palette (mirrors the HTML prototype CSS variables).
class C {
  static const deep = Color(0xFF12426E);
  static const blue = Color(0xFF1C6FB5);
  static const sky = Color(0xFF4FA3DD);
  static const amber = Color(0xFFE0922F);
  static const teal = Color(0xFF1796A3);
  static const green = Color(0xFF3E8E5A);
  static const red = Color(0xFFC0504D);
  static const slate = Color(0xFF5A6B82);
  static const ink = Color(0xFF1A2740);
  static const mut = Color(0xFF6B7886);
  static const panel = Color(0xFFF2F6FB);
  static const panel2 = Color(0xFFE1ECF7);
  static const line = Color(0xFFDCE6F1);
  static const redp = Color(0xFFFBEAEA);
  static const amberp = Color(0xFFFCF1E1);
  static const greenp = Color(0xFFE8F3EC);
  static const bluep = Color(0xFFE6F0FA);
  static const bg = Color(0xFFF6F9FC);
  static const List<Color> colors = [
    deep,
    blue,
    sky,
    amber,
    teal,
    green,
    red,
    slate,
  ];
  /// Severity / status helpers.
  static Color sev(String s) => {
        'red': red,
        'amber': amber,
        'green': green,
        'blue': blue,
        'slate': slate,
      }[s] ??
      slate;

  static Color barColor(num v) =>
      v >= 90 ? amber : (v >= 70 ? blue : slate);

  static Color status(String s) => {
        'running': green,
        'setup': amber,
        'idle': slate,
        'down': red,
        'pm': blue,
        'noplan': const Color(0xFF9AA7B6),
      }[s] ??
      slate;

  static String statusLabel(String s) => {
        'running': 'Running',
        'setup': 'Setup',
        'idle': 'Idle',
        'down': 'DOWN',
        'pm': 'Maintenance',
        'noplan': 'No plan',
      }[s] ??
      s;
}

/// Typography (Sora display, IBM Plex Sans body, IBM Plex Mono for numbers).
TextStyle sora(double size, {FontWeight w = FontWeight.w700, Color? c}) =>
    GoogleFonts.sora(fontSize: size, fontWeight: w, color: c ?? C.ink);

TextStyle body(double size, {FontWeight w = FontWeight.w400, Color? c}) =>
    GoogleFonts.ibmPlexSans(fontSize: size, fontWeight: w, color: c ?? C.ink);

TextStyle mono(double size, {Color? c, FontWeight w = FontWeight.w600}) =>
    GoogleFonts.ibmPlexMono(fontSize: size, fontWeight: w, color: c ?? C.ink);

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: C.bg,
      colorScheme: ColorScheme.fromSeed(
          seedColor: C.blue, primary: C.blue, surface: Colors.white),
      textTheme: GoogleFonts.ibmPlexSansTextTheme(),
    );
