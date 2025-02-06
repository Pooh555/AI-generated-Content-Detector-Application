import 'package:ai_generated_content_detector/Themes/themes.dart';
import 'package:flutter/material.dart';

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

class ServicesText extends StatelessWidget {
  const ServicesText({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the custom TextTheme from the app's theme
    TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(
          Icons.horizontal_split,
          color: darkDefault(context).onSurface,
          size: 24.0,
          semanticLabel: 'Text to announce in accessibility modes',
        ),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: 'Services',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
