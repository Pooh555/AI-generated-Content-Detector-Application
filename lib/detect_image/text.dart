import 'package:flutter/material.dart';

class AppbarText extends StatelessWidget {
  const AppbarText({super.key});

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
