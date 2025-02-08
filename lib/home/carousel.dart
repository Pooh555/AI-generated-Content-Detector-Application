import 'package:ai_generated_content_detector/themes/varaibles.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselPanel extends StatefulWidget {
  const CarouselPanel({super.key, required this.carouselImages});

  final List carouselImages;

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

    List carouselImages = widget.carouselImages;

    return CarouselSlider(
      options: CarouselOptions(
        height: 300.0,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
        initialPage: 0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 1000),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        enlargeFactor: 0.25,
        scrollDirection: Axis.horizontal,
      ),
      items: carouselImages.map((imageMap) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(widgetBorderRadius),
                shadowColor: colorScheme.shadow,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widgetBorderRadius),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(imageMap["path"]!, fit: BoxFit.cover),
                      Center(
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 225.0),
                            ),
                            Text(
                              imageMap["label"]!,
                              style: textTheme.displayMedium,
                              textAlign: TextAlign.center,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 0.0),
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
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
