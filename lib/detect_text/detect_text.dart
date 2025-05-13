import 'dart:convert'; // Import for json encoding/decoding
import 'package:http/http.dart' as http; // Import for making HTTP requests

import 'package:ai_generated_content_detector/detect_text/text.dart'; // Assuming IntroductionText is here
import 'package:ai_generated_content_detector/detect_text/input_form.dart'; // Assuming InputTextField is here
import 'package:ai_generated_content_detector/home/carousel.dart'; // Assuming CarouselPanel is here
import 'package:ai_generated_content_detector/themes/path.dart'; // Assuming detectTextCarouselImagesPaths is here
import 'package:ai_generated_content_detector/themes/template.dart'; // Assuming MyAppbar is here
import 'package:ai_generated_content_detector/themes/varaibles.dart'; // Assuming screenBorderMargin is here
import 'package:ai_generated_content_detector/keys.dart'; // Assuming serverAddress is here

import 'package:flutter/material.dart';

class DetectText extends StatefulWidget {
  const DetectText({super.key, required this.title});
  final String title;

  @override
  State<DetectText> createState() => _DetectTextState();
}

class _DetectTextState extends State<DetectText> {
  // Controller to manage the text input field's content
  final TextEditingController _textController = TextEditingController();

  // State variables for classification results
  String _predictionLabel = "";
  String _predictionConfidence = "";
  String _pplValue = "";

  // State variables for status and loading
  String _statusMessage = "";
  bool _isAnalyzing = false;

  // --- Removed Minimum word count constant ---
  // final int _minimumWordCount = 30;

  @override
  void initState() {
    super.initState();
    // --- Updated initial status message ---
    _updateStatus("Enter text to analyze.");
  }

  // Helper to update status message and clear results
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
    final text = _textController.text
        .trim(); // Get text and remove leading/trailing whitespace

    // --- Removed Minimum word count check ---
    // final wordCount = text
    //     .split(RegExp(r'\s+'))
    //     .where((w) => w.isNotEmpty)
    //     .length;
    // if (wordCount < _minimumWordCount) {
    //   _updateStatus(
    //       "Please enter at least $_minimumWordCount words. You have $wordCount words.");
    //   return;
    // }

    // Basic check if text is empty after trimming
    if (text.isEmpty) {
      _updateStatus("Please enter some text to analyze.");
      return;
    }

    // Pause if already analyzing
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      _updateStatus("Analyzing text..."); // Show analyzing status
    });

    // Ensure you use the correct URL and port for your text server (e.g., 5002)
    final textServerUrl = "$serverAddress:5002/classify_text"; // Update port

    try {
      final response = await http.post(
        Uri.parse(textServerUrl),
        headers: {'Content-Type': 'application/json'}, // Specify JSON content
        body: jsonEncode({'text': text}), // Send text in JSON format
      );

      final responseBody = json.decode(response.body);

      // Parse the response from the text server
      if (response.statusCode == 200 && responseBody['status'] == 'success') {
        final resultData = responseBody['result'];

        if (resultData != null) {
          _updateStatus(
            "Analysis Complete:", // Status message after success
            label: resultData['label'] ?? "N/A", // Get label
            confidence:
                resultData['confidence'] ?? "N/A", // Get confidence string
            ppl: (resultData['ppl'] as num?)?.toStringAsFixed(2) ??
                "N/A", // Get PPL as number, format it
          );
        } else {
          _updateStatus("Analysis completed, but no result data received.");
        }
      } else {
        // Handle server errors or status not success
        _updateStatus(
          "Server Error: ${response.statusCode}",
          label: responseBody['message'] ??
              "Unknown server error.", // Use message for error
        );
      }
    } catch (e) {
      // Handle network or other exceptions
      _updateStatus("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isAnalyzing = false; // Always set analyzing state to false
      });
    }
  }

  @override
  void dispose() {
    // Dispose the controller when the widget is removed
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ElevatedButtonThemeData elevatedButtonThemeData =
        Theme.of(context).elevatedButtonTheme;

    // Get the current text from the controller to check if it's empty
    final currentText = _textController.text.trim();
    final bool isTextEmpty = currentText.isEmpty;

    return Scaffold(
      appBar: MyAppbar(title: "Analyze Text"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenBorderMargin),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center column content horizontally
            children: [
              IntroductionText(), // Assuming IntroductionText is defined
              SizedBox(height: 15),
              CarouselPanel(
                // Assuming CarouselPanel and detectTextCarouselImagesPaths are defined
                carouselImages: detectTextCarouselImagesPaths,
              ),
              SizedBox(height: 15),

              // Input text field, linked to _textController
              InputTextField(
                  controller: _textController), // Pass the controller

              SizedBox(height: 20), // Space before button

              // Analyze Button
              ElevatedButton(
                // Disable if analyzing or text is empty
                onPressed: (_isAnalyzing || isTextEmpty) ? null : _analyzeText,
                style: elevatedButtonThemeData.style,
                child: _isAnalyzing
                    ? const CircularProgressIndicator(
                        color: Colors.white) // Show loading indicator
                    : Text("Analyze Text"), // Button text
              ),

              SizedBox(height: 20), // Space before results

              // --- Status and Result Display ---
              // Display status message always when not empty, style errors/warnings
              if (_statusMessage.isNotEmpty && !_isAnalyzing)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _statusMessage,
                    style: _statusMessage.startsWith("Error:") ||
                            _statusMessage.startsWith(
                                "Please enter some text") // Added empty text check
                        ? textTheme.titleMedium!.copyWith(
                            color:
                                Colors.red) // Style errors/warnings differently
                        : textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),

              // Display Classification Results only if Analysis Complete status is shown
              if (_predictionLabel.isNotEmpty &&
                  _statusMessage == "Analysis Complete:")
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center results text column
                  children: [
                    Text(
                      "Classification:",
                      style: textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      _predictionLabel,
                      style: textTheme.headlineLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Confidence: $_predictionConfidence",
                      style: textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "GPT-2 PPL: $_pplValue",
                      style: textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

              // Optional: Display initial prompt when nothing is happening and text is empty
              if (!_isAnalyzing &&
                  currentText.isEmpty &&
                  _statusMessage.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Enter text above to begin analysis.',
                    style: textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
