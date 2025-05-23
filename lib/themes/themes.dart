import 'package:flutter/material.dart';

ColorScheme darkDefault(context) {
  return const ColorScheme(
    brightness: Brightness.dark,
    primary: Color.fromRGBO(17, 17, 17, 1),
    error: Color.fromARGB(255, 255, 147, 147),
    errorContainer: Color.fromRGBO(54, 54, 54, 0.502),
    inversePrimary: Color.fromARGB(255, 219, 54, 54),
    inverseSurface: Color.fromARGB(255, 210, 235, 255),
    onError: Color.fromARGB(255, 255, 107, 107),
    onErrorContainer: Color.fromARGB(255, 87, 43, 43),
    onInverseSurface: Color.fromARGB(255, 255, 147, 147),
    onPrimary: Color.fromRGBO(226, 226, 226, 1),
    onPrimaryContainer: Color.fromRGBO(255, 255, 255, 1),
    onPrimaryFixed: Color.fromRGBO(63, 63, 63, 1),
    onSecondary: Color.fromRGBO(163, 163, 163, 1),
    onSurface: Color.fromRGBO(216, 216, 216, 1),
    onTertiaryContainer: Color.fromARGB(255, 210, 235, 255),
    outline: Color.fromRGBO(255, 193, 193, 1),
    outlineVariant: Color.fromRGBO(255, 161, 161, 1),
    scrim: Color.fromRGBO(56, 56, 56, 1),
    shadow: Color.fromRGBO(0, 0, 0, 1),
    secondary: Color.fromRGBO(32, 32, 32, 1),
    surface: Color.fromRGBO(22, 22, 22, 1),
    surfaceContainer: Color.fromRGBO(255, 132, 132, 1),
    surfaceContainerHigh: Color.fromRGBO(100, 30, 30, 1),
    surfaceTint: Color.fromRGBO(0, 0, 0, 1),
    surfaceBright: Color.fromRGBO(255, 236, 236, 1),
    tertiary: Color.fromRGBO(207, 61, 61, 1),
    tertiaryContainer: Color.fromRGBO(255, 255, 255, 0.1),
    tertiaryFixed: Color.fromRGBO(255, 193, 193, 1),
    tertiaryFixedDim: Color.fromRGBO(63, 157, 245, 1),
  );
}

ColorScheme lightDefault(context) {
  return const ColorScheme(
    brightness: Brightness.light,
    // TODO: Modify colors
    primary: Color.fromRGBO(32, 32, 32, 1),
    error: Color.fromARGB(255, 255, 147, 147),
    errorContainer: Color.fromARGB(255, 255, 216, 86),
    inversePrimary: Color.fromARGB(255, 12, 12, 12),
    inverseSurface: Color.fromARGB(255, 210, 235, 255),
    onError: Color.fromARGB(255, 255, 147, 147),
    onErrorContainer: Color.fromARGB(255, 255, 124, 124),
    onInverseSurface: Color.fromARGB(255, 255, 147, 147),
    onPrimary: Color.fromRGBO(226, 226, 226, 1),
    onPrimaryContainer: Color.fromRGBO(255, 255, 255, 1),
    onPrimaryFixed: Color.fromRGBO(63, 63, 63, 1),
    onSecondary: Color.fromRGBO(12, 4, 4, 1),
    onSurface: Color.fromRGBO(216, 216, 216, 1),
    scrim: Color.fromRGBO(56, 56, 56, 1),
    shadow: Color.fromRGBO(51, 51, 51, 1),
    secondary: Color.fromRGBO(41, 41, 41, 1),
    surface: Color.fromRGBO(31, 31, 31, 1),
    surfaceTint: Color.fromRGBO(171, 242, 255, 1),
    surfaceBright: Color.fromRGBO(255, 255, 255, 1),
    tertiary: Color.fromRGBO(163, 163, 163, 1),
    tertiaryContainer: Color.fromRGBO(139, 139, 139, 1),
    tertiaryFixed: Color.fromRGBO(163, 163, 163, 1),
    tertiaryFixedDim: Color.fromRGBO(179, 179, 179, 1),
  );
}

ElevatedButtonThemeData defaultElevatedButtonTheme(context) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: darkDefault(context).tertiaryFixed,
      backgroundColor: darkDefault(context).tertiary,
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 50, right: 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11.75), // Rounded corners
      ),
      elevation: 4,
    ),
  );
}
