import 'package:flutter/material.dart';
import 'package:ai_generated_content_detector/Themes/path.dart';
import 'package:ai_generated_content_detector/Themes/varaibles.dart';

List<String> quickMenuList = [
  "Image",
  "Text",
  "Video",
  "Voice",
];

class ServiceWidgets extends StatelessWidget {
  const ServiceWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 175),
      child: CarouselView(
        itemExtent: 259,
        shrinkExtent: 75,
        padding: EdgeInsets.only(right: inbetweenWidgetpadding),
        children: List<Widget>.generate(quickMenuList.length, (int index) {
          return UncontainedLayoutCard(
              index: index, label: quickMenuList[index]);
        }),
      ),
    );
  }
}

class UncontainedLayoutCard extends StatelessWidget {
  const UncontainedLayoutCard({
    super.key,
    required this.index,
    required this.label,
  });

  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    // Accessing the custom TextTheme from the app's theme
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widgetBorderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.onSecondary,
          borderRadius: BorderRadius.circular(widgetBorderRadius),
          image: DecorationImage(
            opacity: 1.0,
            image: AssetImage(
              quickMenuImagesPath[index % homeCarouselImagesPaths.length],
            ),
            fit: BoxFit.cover, // Adjust how the image is displayed
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5.0, right: 15.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Text(
              quickMenuList[index],
              style: textTheme.labelLarge,
              overflow: TextOverflow.clip,
              softWrap: false,
            ),
          ),
        ),
      ),
    );
  }
}
