import 'package:ai_generated_content_detector/home/service_widgets.dart';
import 'package:flutter/material.dart';
import 'package:ai_generated_content_detector/home/carousel.dart';
import 'package:ai_generated_content_detector/home/text.dart';
import 'package:ai_generated_content_detector/Themes/varaibles.dart';

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
        body: Padding(
          padding: EdgeInsets.all(screenBorderMargin),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(top: 50)),
              const WelcomeText(),
              const Padding(padding: EdgeInsets.only(top: 50)),
              const CarouselPanel(),
              const Padding(padding: EdgeInsets.only(top: 25)),
              Align(
                alignment: Alignment.centerLeft,
                child: const QuickMenuText(),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: CarouselView(
                  itemExtent: 330,
                  shrinkExtent: 200,
                  children:
                      List<Widget>.generate(quickMenuList.length, (int index) {
                    return UncontainedLayoutCard(
                        index: index, label: quickMenuList[index]);
                  }),
                ),
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
