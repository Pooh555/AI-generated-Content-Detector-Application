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
            text: 'Analyze your Image',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class UploadImageText extends StatelessWidget {
  const UploadImageText({super.key, required this.title});

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

class NoSelectedImageText extends StatelessWidget {
  const NoSelectedImageText({super.key});

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
