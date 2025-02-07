import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:flutter/material.dart';

class DetectVideo extends StatefulWidget {
  const DetectVideo({super.key, required this.title});
  final String title;

  @override
  State<DetectVideo> createState() => _DetectVideoState();
}

class _DetectVideoState extends State<DetectVideo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppbar(title: "Analyze Video"), body: Container());
  }
}
