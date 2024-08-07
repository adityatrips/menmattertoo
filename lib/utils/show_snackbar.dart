import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum TypeOfSnackbar { success, error, warning }

void showSnackbar(String text, {TypeOfSnackbar type = TypeOfSnackbar.success}) {
  Color? backgroundColor;
  Color? foregroundColor;

  switch (type) {
    case TypeOfSnackbar.success:
      backgroundColor = Colors.green.shade100;
      foregroundColor = Colors.green.shade900;
      break;
    case TypeOfSnackbar.warning:
      backgroundColor = Colors.amber.shade100;
      foregroundColor = Colors.amber.shade900;
      break;
    case TypeOfSnackbar.error:
      backgroundColor = Colors.red.shade100;
      foregroundColor = Colors.red.shade900;
      break;
  }

  Get.showSnackbar(GetSnackBar(
    duration: const Duration(seconds: 2),
    snackPosition: SnackPosition.BOTTOM,
    animationDuration: const Duration(milliseconds: 500),
    forwardAnimationCurve: Curves.fastEaseInToSlowEaseOut,
    reverseAnimationCurve: Curves.fastEaseInToSlowEaseOut,
    barBlur: 100,
    icon: Icon(
      type == TypeOfSnackbar.success
          ? Icons.check_circle_rounded
          : type == TypeOfSnackbar.warning
              ? Icons.warning_rounded
              : Icons.error_rounded,
      color: foregroundColor,
    ),
    backgroundColor: backgroundColor,
    titleText: Text(
      type.toString().split('.').last.toUpperCase(),
      style: TextStyle(
        color: foregroundColor,
        fontWeight: FontWeight.bold,
        fontFamily: "BN",
        fontSize: 20,
      ),
    ),
    messageText: Text(
      text,
      style: TextStyle(color: foregroundColor),
    ),
  ));
}
