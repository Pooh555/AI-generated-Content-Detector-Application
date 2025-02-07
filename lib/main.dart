import 'package:ai_generated_content_detector/about/about.dart';
import 'package:ai_generated_content_detector/help/help.dart';
import 'package:ai_generated_content_detector/profile/profile.dart';
import 'package:ai_generated_content_detector/settings/settings.dart';
import 'package:ai_generated_content_detector/themes/font.dart';
import 'package:ai_generated_content_detector/themes/themes.dart';
import 'package:ai_generated_content_detector/detect_image/detect_image.dart';
import 'package:ai_generated_content_detector/detect_text/detect_text.dart';
import 'package:ai_generated_content_detector/detect_video/detect_video.dart';
import 'package:ai_generated_content_detector/detect_voice/detect_audio.dart';
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
        elevatedButtonTheme: defaultElevatedButtonTheme(context),
      ),
      home: const HomePage(title: "Home"),
      initialRoute: '/',
      routes: {
        '/about': (context) => About(title: "About this application"),
        '/audio': (context) => DetectAudio(title: "Detect AI-generated Voice"),
        '/help': (context) => Help(title: "Help"),
        '/image': (context) => DetectImage(title: "Detect AI-generated Image"),
        '/profile': (context) => Profile(title: "Profile"),
        '/settings': (context) => Settings(title: "Settings"),
        '/text': (context) => DetectText(title: "Detect AI-generated Text"),
        '/video': (context) => DetectVideo(title: "Detect AI-generated Video"),
      },
    );
  }
}
