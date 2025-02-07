import 'package:flutter/material.dart';
import 'package:ai_generated_content_detector/themes/path.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';

List<String> servicesList = [
  "About",
  "Audio",
  "Image",
  "Profile",
  "Settings",
  "Text",
  "Video",
];

class ServicesGridWidget extends StatelessWidget {
  const ServicesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        shrinkWrap: true, // Prevents infinite height issues
        physics: NeverScrollableScrollPhysics(), // Prevents scroll conflicts
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        children: List.generate(
          6,
          (index) => Container(
            padding: const EdgeInsets.all(8),
            color: Colors.green[(index + 1) * 100],
            child: Text(servicesList[index]),
          ),
        ),
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
          Navigator.of(context).pushNamed(pages[index]);
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
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5.0, right: 15.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                servicesList[index],
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
