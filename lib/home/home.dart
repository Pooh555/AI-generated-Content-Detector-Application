import 'package:ai_generated_content_detector/home/service_widgets.dart';
import 'package:ai_generated_content_detector/home/services_grid.dart';
import 'package:ai_generated_content_detector/themes/path.dart';
import 'package:flutter/material.dart';
import 'package:ai_generated_content_detector/home/carousel.dart';
import 'package:ai_generated_content_detector/home/text.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';

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
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenBorderMargin),
            child: Column(
              children: [
                const SizedBox(height: 50),
                const WelcomeText(),
                const SizedBox(height: 50),
                CarouselPanel(carouselImages: homeCarouselImagesPaths),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: const QuickMenuText(),
                ),
                const SizedBox(height: 15),
                ServiceWidgets(),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: const ServicesText(),
                ),
                const ServicesGridWidget(),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: const UtilitiesText(),
                ),
              ],
            ),
          ),
        ));
  }
}
