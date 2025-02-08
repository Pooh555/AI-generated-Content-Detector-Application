import 'package:ai_generated_content_detector/detect_text/input_form.dart';
import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:flutter/material.dart';

class DetectText extends StatefulWidget {
  const DetectText({super.key, required this.title});
  final String title;

  @override
  State<DetectText> createState() => _DetectTextState();
}

class _DetectTextState extends State<DetectText> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppbar(title: "Analyze Text"),
        body: SingleChildScrollView(child: InputTextField()));
  }
}
