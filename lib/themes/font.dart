import 'package:ai_generated_content_detector/themes/themes.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';
import 'package:flutter/material.dart';

TextTheme defaultTextTheme(context) {
  return TextTheme(
    headlineLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily,
      color: darkDefault(context).surfaceBright,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily,
      color: darkDefault(context).surfaceBright,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily,
      color: darkDefault(context).surfaceBright,
    ),
    bodyLarge: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamily,
      color: darkDefault(context).onSurface,
    ),
    bodyMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily,
      color: darkDefault(context).onSurface,
    ),
    bodySmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamily,
      color: darkDefault(context).onSurface,
    ),
    displayLarge: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily,
      color: darkDefault(context).onSurface,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily,
      color: darkDefault(context).onSurface,
    ),
    displaySmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.normal,
      fontFamily: fontFamily,
      color: darkDefault(context).onSurface,
    ),
    labelLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily,
      color: darkDefault(context).onSurface,
    ),
    labelMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily,
      color: darkDefault(context).onSurface,
    ),
    labelSmall: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      fontFamily: fontFamily,
      color: darkDefault(context).onSurface,
    ),
  );
}
