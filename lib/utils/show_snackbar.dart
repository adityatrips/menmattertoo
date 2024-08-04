import 'package:flutter/material.dart';

enum TypeOfSnackbar { success, error, warning }

void showSnackbar(BuildContext context, String text,
    {TypeOfSnackbar type = TypeOfSnackbar.success}) {
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

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 750),
      content: Text(
        text,
        style: TextStyle(color: foregroundColor),
      ),
      backgroundColor: backgroundColor,
    ),
  );
}
