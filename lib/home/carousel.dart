import 'package:ai_generated_content_detector/Themes/varaibles.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../Themes/path.dart';

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
      items: homeCarouselImagesPaths.map((imagePath) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 0.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widgetBorderRadius),
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
