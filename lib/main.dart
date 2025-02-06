import 'package:ai_generated_content_detector/Themes/font.dart';
import 'package:ai_generated_content_detector/Themes/themes.dart';
import 'package:flutter/material.dart';
import 'home/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI detector',
      theme: ThemeData(
        colorScheme: darkDefault(context),
        textTheme: defaultTextTheme(context),
        useMaterial3: true,
      ),
      home: const HomePage(title: "Home"),
    );
  }
}
