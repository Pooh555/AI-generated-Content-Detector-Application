import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.title});
  final String title;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: MyAppbar(title: "Settings"), body: Container());
  }
}
