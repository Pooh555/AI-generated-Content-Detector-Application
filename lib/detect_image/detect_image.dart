import 'package:flutter/material.dart';
import 'package:ai_generated_content_detector/home/text.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';

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
