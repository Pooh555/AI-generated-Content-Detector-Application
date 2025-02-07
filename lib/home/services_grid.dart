import 'package:flutter/material.dart';

class ServicesGridWidget extends StatelessWidget {
  const ServicesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Define service icons
    Map<String, Icon> servicesIconPath = {
      "Audio": Icon(
        Icons.music_note,
        color: colorScheme.onSurface,
        size: textTheme.bodySmall?.fontSize,
      ),
      "About": Icon(
        Icons.info,
        color: colorScheme.onSurface,
        size: textTheme.bodySmall?.fontSize,
      ),
      "Help": Icon(
        Icons.help,
        color: colorScheme.onSurface,
        size: textTheme.bodySmall?.fontSize,
      ),
      "Image": Icon(
        Icons.image,
        color: colorScheme.onSurface,
        size: textTheme.bodySmall?.fontSize,
      ),
      "Profile": Icon(
        Icons.person,
        color: colorScheme.onSurface,
        size: textTheme.bodySmall?.fontSize,
      ),
      "Settings": Icon(
        Icons.settings,
        color: colorScheme.onSurface,
        size: textTheme.bodySmall?.fontSize,
      ),
      "Text": Icon(
        Icons.description,
        color: colorScheme.onSurface,
        size: textTheme.bodySmall?.fontSize,
      ),
      "Video": Icon(
        Icons.play_circle,
        color: colorScheme.onSurface,
        size: textTheme.bodySmall?.fontSize,
      ),
    };

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: GridView.count(
        shrinkWrap: true, // Prevents infinite height issues
        physics:
            const NeverScrollableScrollPhysics(), // Prevents scroll conflicts
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 4,
        children: servicesIconPath.entries.map((entry) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/${entry.key.toLowerCase()}');
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                entry.value, // Icon widget
                const SizedBox(height: 5),
                Text(
                  entry.key,
                  style: textTheme.labelSmall,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
