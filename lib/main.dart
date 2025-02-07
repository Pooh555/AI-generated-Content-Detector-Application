import 'package:ai_generated_content_detector/themes/font.dart';
import 'package:ai_generated_content_detector/themes/themes.dart';
import 'package:ai_generated_content_detector/detect_image/detect_image.dart';
import 'package:ai_generated_content_detector/detect_text/detect_text.dart';
import 'package:ai_generated_content_detector/detect_video/detect_video.dart';
import 'package:ai_generated_content_detector/detect_voice/detect_voice.dart';
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
      initialRoute: '/',
      routes: {
        '/image': (context) => DetectImage(title: "Detect AI-generated Image"),
        '/text': (context) => DetectText(title: "Detect AI-generated Text"),
        '/video': (context) => DetectVideo(title: "Detect AI-generated Video"),
        '/voice': (context) => DetectVoice(title: "Detect AI-generated Voice"),
      },
    );
  }
}
