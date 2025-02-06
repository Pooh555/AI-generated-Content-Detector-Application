import 'package:flutter/material.dart';

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the custom TextTheme from the app's theme
    TextTheme textTheme = Theme.of(context).textTheme;

    return RichText(
      text: TextSpan(
        style: textTheme.headlineLarge,
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

    return RichText(
      text: TextSpan(
        style: textTheme.headlineLarge,
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
