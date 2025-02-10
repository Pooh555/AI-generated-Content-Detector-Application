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
              text: "Real or Fake?\n",
              style: textTheme.headlineMedium,
            ),
            TextSpan(
              text: "Reveal the reality!",
              style: textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic, color: colorScheme.onSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class UploadAudioText extends StatelessWidget {
  const UploadAudioText({super.key, required this.title});

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

class NoSelectedAudioText extends StatelessWidget {
  const NoSelectedAudioText({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    // Accessing the custom TextTheme from the app's theme
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: title,
            style: textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic, color: colorScheme.onSecondary),
          ),
        ],
      ),
    );
  }
}
