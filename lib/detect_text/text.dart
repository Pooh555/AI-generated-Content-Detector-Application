import 'package:flutter/material.dart';

class UploadTextText extends StatelessWidget {
  const UploadTextText({super.key, required this.title});

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
