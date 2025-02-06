import 'package:flutter/material.dart';
import 'package:ai_generated_content_detector/Themes/themes.dart';

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the custom TextTheme from the app's theme
    TextTheme textTheme = Theme.of(context).textTheme;

    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: 'Hello',
            style: textTheme.bodyLarge,
          ),
          TextSpan(
            text: ' Pooh555!',
            style: textTheme.headlineLarge,
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
    TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(
          Icons.dashboard_customize,
          color: darkDefault(context).onSurface,
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
    TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(
          Icons.dashboard,
          color: darkDefault(context).onSurface,
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
    TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(
          Icons.menu,
          color: darkDefault(context).onSurface,
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
