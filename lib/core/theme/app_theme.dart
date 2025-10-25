import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    colorSchemeSeed: Colors.red,
    useMaterial3: true,
    snackBarTheme:
    const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
