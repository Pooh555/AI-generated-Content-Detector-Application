import 'package:ai_generated_content_detector/home/service_widgets.dart';
import 'package:flutter/material.dart';
import 'package:ai_generated_content_detector/home/text.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';

class DetectVoice extends StatefulWidget {
  const DetectVoice({super.key, required this.title});
  final String title;

  @override
  State<DetectVoice> createState() => _DetectVoiceState();
}

class _DetectVoiceState extends State<DetectVoice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(screenBorderMargin),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(top: 50)),
              const WelcomeText(),
              Align(
                alignment: Alignment.centerLeft,
                child: const QuickMenuText(),
              ),
              ServiceWidgets(),
              Align(
                alignment: Alignment.centerLeft,
                child: const ServicesText(),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: const UtilitiesText(),
              ),
            ],
          ),
        ));
  }
}
