import 'package:ai_generated_content_detector/home/text.dart';
import 'package:flutter/material.dart';
import 'package:ai_generated_content_detector/home/carousel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        body: Center(
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(top: 50)),
              const WelcomeText(),
              const Padding(padding: EdgeInsets.only(top: 50)),
              const CarouselPanel(),
            ],
          ),
        ));
  }
}
