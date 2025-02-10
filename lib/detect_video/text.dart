import 'package:flutter/material.dart';

class IntroductionText extends StatelessWidget {
  const IntroductionText({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the custom TextTheme from the app's theme
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.topLeft,
      child: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: "Genuine or Generated?\n",
              style: textTheme.headlineMedium,
            ),
            TextSpan(
              text: "Let's find out!",
              style: textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic, color: colorScheme.onSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class UploadVideoText extends StatelessWidget {
  const UploadVideoText({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    // Accessing the custom TextTheme from the app's theme
    TextTheme textTheme = Theme.of(context).textTheme;

    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: title,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class NoSelectedVideoText extends StatelessWidget {
  const NoSelectedVideoText({super.key});

  @override
  Widget build(BuildContext context) {
    // Accessing the custom TextTheme from the app's theme
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: "No image selected",
            style: textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic, color: colorScheme.onSecondary),
          ),
        ],
      ),
    );
  }
}
