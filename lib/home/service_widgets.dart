import 'package:flutter/material.dart';

List<String> quickServicesList = [
  "Image",
  "Text",
  "Video",
  "Voice",
];

class UncontainedLayoutCard extends StatelessWidget {
  UncontainedLayoutCard({
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

    return ColoredBox(
      color: colorScheme.onSecondary,
      child: Center(
        child: Text(
          quickServicesList[index],
          style: textTheme.labelLarge,
          overflow: TextOverflow.clip,
          softWrap: false,
        ),
      ),
    );
  }
}
