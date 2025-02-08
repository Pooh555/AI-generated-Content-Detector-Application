import 'package:flutter/material.dart';

class OthersGrid extends StatelessWidget {
  const OthersGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true, // Prevents infinite height issues
      physics:
          const NeverScrollableScrollPhysics(), // Prevents scroll conflicts
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: [
        GeminiButton(),
      ],
    );
  }
}

class GeminiButton extends StatelessWidget {
  const GeminiButton({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/gemini',
          arguments: {
            'title': "Chatbot",
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(11.75),
        decoration: BoxDecoration(
          color: colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(11.75),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.forum,
                color: colorScheme.onSurface,
                size: textTheme.bodyMedium?.fontSize,
              ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: " Chatbot",
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
