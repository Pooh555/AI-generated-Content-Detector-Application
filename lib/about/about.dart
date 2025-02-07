import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:flutter/material.dart';

class About extends StatefulWidget {
  const About({super.key, required this.title});
  final String title;

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppbar(title: "About this application"), body: Container());
  }
}
