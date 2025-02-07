import 'package:flutter/material.dart';
import 'package:ai_generated_content_detector/themes/path.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';

List<String> quickMenuList = [
  "Image",
  "Text",
  "Video",
  "Audio",
];

class ServiceWidgets extends StatelessWidget {
  const ServiceWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List<Widget>.generate(quickMenuList.length, (int index) {
          return Padding(
            padding: EdgeInsets.only(right: inbetweenWidgetpadding),
            child: SizedBox(
              width: 259,
              height: 175,
              child: UncontainedLayoutCard(
                  index: index, label: quickMenuList[index]),
            ),
          );
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
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        if (index < pages.length) {
          Navigator.of(context).pushNamed(quickMenuPages[index]);
        } else {
          throw "The desired page does not exist.";
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widgetBorderRadius),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.onSecondary,
            borderRadius: BorderRadius.circular(widgetBorderRadius),
            image: DecorationImage(
              opacity: 1.0,
              image: AssetImage(
                quickMenuImagesPath[index % quickMenuImagesPath.length],
              ),
              fit: BoxFit.cover,
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
      ),
    );
  }
}
