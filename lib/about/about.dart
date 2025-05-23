import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  const About({super.key, required this.title});
  final String title;

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: MyAppbar(title: "About this application"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenBorderMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: "AI vs Human", style: textTheme.headlineMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset("res/assets/github/kita_AI.jpg",
                    width: MediaQuery.of(context).size.width * 0.45),
                Image.asset("res/assets/github/kita_human.jpg",
                    width: MediaQuery.of(context).size.width * 0.45),
              ],
            ),
            const SizedBox(height: 15),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      text: "About This Project",
                      style: textTheme.headlineMedium),
                ],
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final Uri url = Uri.parse("https://www.infomatrix.ro/");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "This project is competing in Infomatrix 2025.",
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.tertiaryFixedDim),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      text: "Deep Learning", style: textTheme.headlineMedium),
                ],
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      text:
                          "The models used for identifying AI-generated content are located in the listed repository.",
                      style: textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final Uri url = Uri.parse(
                    "https://github.com/Pooh555/AI_vs_human_generated_content_models");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: " - All models source code",
                      style: textTheme.bodySmall
                          ?.copyWith(color: colorScheme.tertiaryFixedDim),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: "We are from Kamneotvidya Science Academy.",
                        style: textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () async {
                  final Uri url = Uri.parse("https://www.kvis.ac.th");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: Text(
                  "KVIS",
                  style: textTheme.headlineMedium
                      ?.copyWith(color: colorScheme.tertiaryFixedDim),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
