import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.title});
  final String title;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: MyAppbar(title: "Profile"), body: Container());
  }
}
