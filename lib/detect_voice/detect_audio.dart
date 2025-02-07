import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:flutter/material.dart';

class DetectAudio extends StatefulWidget {
  const DetectAudio({super.key, required this.title});
  final String title;

  @override
  State<DetectAudio> createState() => _DetectAudioState();
}

class _DetectAudioState extends State<DetectAudio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppbar(title: "Analyze Audio"), body: Container());
  }
}
