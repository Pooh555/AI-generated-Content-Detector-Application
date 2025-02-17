import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:flutter/material.dart';

class Help extends StatefulWidget {
  const Help({super.key, required this.title});
  final String title;

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppbar(title: "Help"),
        body: ApologyText(
            title:
                "This feature is being developed.\n\nWe apologize for the inconvenience."));
  }
}
