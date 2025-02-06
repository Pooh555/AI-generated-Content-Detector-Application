import 'package:flutter/material.dart';

TextTheme defaultTextTheme(context) {
  return TextTheme(
    headlineLarge: const TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: const TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.normal,
    ),
    bodyMedium: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
    ),
    bodySmall: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );
}
