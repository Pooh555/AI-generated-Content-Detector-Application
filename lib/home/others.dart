import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OthersGrid extends StatelessWidget {
  const OthersGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      children: [
        const GeminiButton(),
        Column(
          children: const [
            Expanded(
              child: PlaceholderButton(
                icon: Icons.volunteer_activism,
                text: "Support us",
                url: "https://my.fsf.org/donate",
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: PlaceholderButton(
                icon: Icons.code,
                text: "Source Code",
                url:
                    "https://github.com/Pooh555/AI-generated-Content-Detector-Application", // Add the URL
              ),
            ),
          ],
        ),
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
          arguments: {'title': "Chatbot"},
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
                size: textTheme.headlineLarge?.fontSize,
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

class PlaceholderButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? url;

  const PlaceholderButton(
      {super.key, required this.icon, required this.text, this.url});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: url != null
          ? () async {
              if (await canLaunchUrl(Uri.parse(url!))) {
                await launchUrl(Uri.parse(url!));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Unable to launch the URL",
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.error),
                    ),
                    backgroundColor: colorScheme.errorContainer,
                  ),
                );
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(8),
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
                icon,
                color: colorScheme.onSurface,
                size: textTheme.headlineMedium?.fontSize,
              ),
              const SizedBox(height: 5),
              Text(
                text,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
