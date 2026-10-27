import 'package:flutter/material.dart';

bool isShowingSnackbar = false;

void showCustomSnackBar({
  required BuildContext context,
  required String message,
  Duration duration = const Duration(seconds: 3),
  required Color backgroundColor,
}) {
  if (isShowingSnackbar) {
    return;
  }

  isShowingSnackbar = true;

  final snackBar = SnackBar(
    duration: duration,
    backgroundColor: backgroundColor,
    content: Center(child: Text(message)),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((reason) {
    isShowingSnackbar = false;
  });
}
