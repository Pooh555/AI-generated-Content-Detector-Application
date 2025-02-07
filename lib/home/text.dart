import 'package:flutter/material.dart';

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the custom TextTheme from the app's theme
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: 'Beyond the illusion\n',
            style: textTheme.headlineLarge,
          ),
          TextSpan(
            text: 'AI or Human',
            style: textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic, color: colorScheme.onSecondary),
          ),
        ],
      ),
    );
  }
}

class QuickMenuText extends StatelessWidget {
  const QuickMenuText({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the custom TextTheme from the app's theme
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(
          Icons.dashboard_customize,
          color: colorScheme.onSurface,
          size: textTheme.bodyMedium?.fontSize,
        ),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: " Quick Menu",
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ServicesText extends StatelessWidget {
  const ServicesText({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the custom TextTheme from the app's theme
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(
          Icons.dashboard,
          color: colorScheme.onSurface,
          size: textTheme.bodyMedium?.fontSize,
        ),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: " Services",
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UtilitiesText extends StatelessWidget {
  const UtilitiesText({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the custom TextTheme from the app's theme
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(
          Icons.menu,
          color: colorScheme.onSurface,
          size: textTheme.bodyMedium?.fontSize,
        ),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: " Others",
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
