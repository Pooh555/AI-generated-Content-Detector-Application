import 'dart:convert';
import 'package:ai_generated_content_detector/detect_text/text.dart';
import 'package:http/http.dart' as http;
import 'package:ai_generated_content_detector/detect_text/input_form.dart';
import 'package:ai_generated_content_detector/home/carousel.dart';
import 'package:ai_generated_content_detector/themes/path.dart';
import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';
import 'package:ai_generated_content_detector/keys.dart';

import 'package:flutter/material.dart';

class DetectText extends StatefulWidget {
  const DetectText({super.key, required this.title});
  final String title;

  @override
  State<DetectText> createState() => _DetectTextState();
}

class _DetectTextState extends State<DetectText> {
  final TextEditingController _textController = TextEditingController();

  String _predictionLabel = "";
  String _predictionConfidence = "";
  String _pplValue = "";

  String _statusMessage = "";
  bool _isAnalyzing = false;

  List<Map<String, dynamic>> _segmentResults = [];

  @override
  void initState() {
    super.initState();
    _updateStatus("Enter text to analyze.");
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      if (_predictionLabel.isNotEmpty || _segmentResults.isNotEmpty) {
        _updateStatus("Enter text to analyze.");
        _segmentResults = [];
      }
    });
  }

  void _updateStatus(String message,
      {String? label, String? confidence, String? ppl}) {
    setState(() {
      _statusMessage = message;
      _predictionLabel = label ?? "";
      _predictionConfidence = confidence ?? "";
      _pplValue = ppl ?? "";
    });
  }

  Future<void> _analyzeText() async {
    final text = _textController.text.trim();

    final minWordsOverall = 30;
    if (text.split(RegExp(r'\s+')).length < minWordsOverall) {
      _updateStatus("Please enter at least $minWordsOverall words to analyze.");
      return;
    }

    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      _segmentResults = [];
      _updateStatus("Analyzing text...");
    });

    final textServerUrl = "$serverAddress:5002/classify_text";

    try {
      final response = await http.post(
        Uri.parse(textServerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['status'] == 'success') {
        final overallResult = responseBody['overall_result'];
        if (overallResult != null) {
          _updateStatus(
            "Analysis Complete:",
            label: overallResult['label'] ?? "N/A",
            confidence: overallResult['confidence'] ?? "N/A",
            ppl: (overallResult['ppl'] as num?)?.toStringAsFixed(2) ?? "N/A",
          );
        } else {
          _updateStatus(
              "Analysis completed, but no overall result data received.");
        }

        final segmentResults = responseBody['segment_results'];
        if (segmentResults != null && segmentResults is List) {
          try {
            _segmentResults = List<Map<String, dynamic>>.from(segmentResults);
          } catch (e) {
            print("Error casting segment results: $e");
            _updateStatus(
                "Analysis complete, but failed to parse segment results.");
            _segmentResults = [];
          }
        } else {
          print("No segment results received or format incorrect.");
        }
      } else {
        final errorMessage = responseBody['message'] ?? "Unknown server error.";
        _updateStatus(
          "Server Error: ${response.statusCode}",
          label: errorMessage,
        );
        _segmentResults = [];
      }
    } catch (e) {
      _updateStatus("Error: ${e.toString()}");
      _segmentResults = [];
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    ElevatedButtonThemeData elevatedButtonThemeData =
        Theme.of(context).elevatedButtonTheme;

    final currentText = _textController.text.trim();
    final minWordsOverall = 30;
    final bool isTextLongEnough =
        currentText.split(RegExp(r'\s+')).length >= minWordsOverall;
    final bool enableAnalyzeButton = !_isAnalyzing && isTextLongEnough;

    final Color humanColor = Colors.green[700]!;
    final Color aiColor = Colors.red[700]!;
    final Color errorColor = colorScheme.error;

    return Scaffold(
      appBar: MyAppbar(title: "Analyze Text"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenBorderMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntroductionText(),
              SizedBox(height: 15),
              CarouselPanel(
                carouselImages: detectTextCarouselImagesPaths,
              ),
              SizedBox(height: 15),
              InputTextField(controller: _textController),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 15.0),
                child: Text(
                  'The text must be at least $minWordsOverall words long.',
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: enableAnalyzeButton ? _analyzeText : null,
                style: elevatedButtonThemeData.style,
                child: _isAnalyzing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Analyze Text"),
              ),
              SizedBox(height: 20),
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    _statusMessage,
                    style: _statusMessage.startsWith("Error:") ||
                            _statusMessage.startsWith("Server Error:") ||
                            _statusMessage ==
                                "Please enter some text to analyze." ||
                            _statusMessage
                                .startsWith("Please enter at least") ||
                            _statusMessage
                                .startsWith("Analysis complete, but failed")
                        ? textTheme.titleMedium!.copyWith(color: errorColor)
                        : textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_predictionLabel.isNotEmpty &&
                  _statusMessage == "Analysis Complete:")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildColorLegend(textTheme),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 20),
                    Text(
                      "Segment Classification:",
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              if (_segmentResults.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8.0)),
                  child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: textTheme.bodySmall,
                      children: _segmentResults.map((segment) {
                        final String text = segment['text'] ?? '';
                        final String label = segment['label'] ?? 'Error';
                        final String confidence =
                            segment['confidence'] ?? 'N/A';
                        final String errorMsg = segment['error'] ?? '';

                        Color color;
                        String tooltipText;

                        if (label == "Human-written") {
                          color = humanColor;
                          tooltipText = "Human ($confidence)";
                        } else if (label == "AI-generated") {
                          color = aiColor;
                          tooltipText = "AI ($confidence)";
                        } else {
                          color = errorColor;
                          tooltipText = "Error ($errorMsg)";
                        }

                        return TextSpan(
                          text: text + ' ',
                          style: TextStyle(color: color),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorLegend(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Legend:",
            style: textTheme.headlineMedium!
                .copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        _buildLegendItem(Colors.green, "Human", textTheme),
        _buildLegendItem(Colors.red, "AI-generated", textTheme),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            color: color,
            margin: EdgeInsets.only(right: 8),
          ),
          Text(label, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
