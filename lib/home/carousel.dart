import 'package:ai_generated_content_detector/themes/themes.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../themes/path.dart';

class CarouselPanel extends StatefulWidget {
  const CarouselPanel({super.key});

  @override
  State<CarouselPanel> createState() => _CarouselPanelState();
}

class _CarouselPanelState extends State<CarouselPanel> {
  final CarouselController controller = CarouselController(initialItem: 1);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return CarouselSlider(
      options: CarouselOptions(
        height: 300.0,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 1000),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        enlargeFactor: 0.25,
        scrollDirection: Axis.horizontal,
      ),
      items: homeCarouselImagesPaths.map((imageMap) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 0.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widgetBorderRadius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(imageMap["path"]!, fit: BoxFit.cover),
                    Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 225.0),
                          ),
                          Text(
                            imageMap["label"]!,
                            style: textTheme.displaySmall,
                            textAlign: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                          ),
                          Text(
                            imageMap["description"]!,
                            style: textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
