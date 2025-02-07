import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:flutter/material.dart';

class DetectImage extends StatefulWidget {
  const DetectImage({super.key, required this.title});
  final String title;

  @override
  State<DetectImage> createState() => _DetectImageState();
}

class _DetectImageState extends State<DetectImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppbar(title: "Analyze Your Image"), body: Container());
  }
}
