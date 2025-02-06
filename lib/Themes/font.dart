import 'package:ai_generated_content_detector/Themes/themes.dart';
import 'package:flutter/material.dart';

TextTheme defaultTextTheme(context) {
  return TextTheme(
    headlineLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: darkDefault(context).surfaceBright,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: darkDefault(context).surfaceBright,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: darkDefault(context).surfaceBright,
    ),
    bodyLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.normal,
      color: darkDefault(context).onSurface,
    ),
    bodyMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: darkDefault(context).onSurface,
    ),
    bodySmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: darkDefault(context).onSurface,
    ),
  );
}
