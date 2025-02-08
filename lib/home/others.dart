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
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

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
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: const Text(
          'Gemini',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
