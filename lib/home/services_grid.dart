import 'package:flutter/material.dart';

class ServicesGridWidget extends StatelessWidget {
  const ServicesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Define service icons
    Map<String, Icon> servicesIconPath = {
      "Text": Icon(
        Icons.description,
        color: colorScheme.onSurface,
        size: textTheme.headlineMedium?.fontSize,
      ),
      "Image": Icon(
        Icons.image,
        color: colorScheme.onSurface,
        size: textTheme.headlineMedium?.fontSize,
      ),
      "Audio": Icon(
        Icons.music_note,
        color: colorScheme.onSurface,
        size: textTheme.headlineMedium?.fontSize,
      ),
      "Video": Icon(
        Icons.play_circle,
        color: colorScheme.onSurface,
        size: textTheme.headlineMedium?.fontSize,
      ),
      "Profile": Icon(
        Icons.person,
        color: colorScheme.onSurface,
        size: textTheme.headlineMedium?.fontSize,
      ),
      "Settings": Icon(
        Icons.settings,
        color: colorScheme.onSurface,
        size: textTheme.headlineMedium?.fontSize,
      ),
      "About": Icon(
        Icons.info,
        color: colorScheme.onSurface,
        size: textTheme.headlineMedium?.fontSize,
      ),
      "Help": Icon(
        Icons.help,
        color: colorScheme.onSurface,
        size: textTheme.headlineMedium?.fontSize,
      ),
    };

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 4,
        children: servicesIconPath.entries.map((entry) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/${entry.key.toLowerCase()}');
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.onSurface, width: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  entry.value,
                  const SizedBox(height: 5),
                  Text(
                    entry.key,
                    style: textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
