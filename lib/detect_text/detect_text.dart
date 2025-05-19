// text.dart

import 'dart:convert'; // Import for json encoding/decoding
import 'package:ai_generated_content_detector/detect_text/text.dart';
import 'package:http/http.dart' as http; // Import for making HTTP requests
import 'package:ai_generated_content_detector/detect_text/input_form.dart'; // Assuming InputTextField is here
import 'package:ai_generated_content_detector/home/carousel.dart'; // Assuming CarouselPanel is here
import 'package:ai_generated_content_detector/themes/path.dart'; // Assuming detectTextCarouselImagesPaths are here
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
  String _predictionLabel = ""; // Overall label
  String _predictionConfidence = ""; // Overall confidence string
  String _pplValue = ""; // Overall PPL string

  // State variables for status and loading
  String _statusMessage = "";
  bool _isAnalyzing = false;

  // --- New state variable for segment results ---
  List<Map<String, dynamic>> _segmentResults = [];
  // Each map will contain: {'text': '...', 'label': '...', 'confidence': '...'}
  // We use dynamic for confidence and ppl just in case, though server sends strings/floats now.

  @override
  void initState() {
    super.initState();
    _updateStatus("Enter text to analyze.");
    _textController.addListener(_onTextChanged);
  }

  // Callback for text controller listener
  void _onTextChanged() {
    // Clear previous results and status when text changes significantly (optional, but good UX)
    // setState will rebuild the widget and update button state automatically
    // You might want a debounce here for performance on large texts
    setState(() {
      if (_predictionLabel.isNotEmpty || _segmentResults.isNotEmpty) {
        _updateStatus("Enter text to analyze."); // Reset status
        _segmentResults = []; // Clear previous segment results
      }
    });
  }

  // Helper to update status message and clear results
  void _updateStatus(String message,
      {String? label, String? confidence, String? ppl}) {
    setState(() {
      _statusMessage = message;
      _predictionLabel = label ?? "";
      _predictionConfidence = confidence ?? "";
      _pplValue = ppl ?? "";
      // Note: Segment results are cleared in _analyzeText before the request
      // or in _onTextChanged if you uncomment that part.
    });
  }

  Future<void> _analyzeText() async {
    final text = _textController.text.trim();

    // The server now handles the min word check and returns an error response.
    // We rely on the server's check, but the button is disabled if text is empty.
    final minWordsOverall = 30;
    if (text.split(RegExp(r'\s+')).length < minWordsOverall) {
      _updateStatus("Please enter at least $minWordsOverall words to analyze.");
      return;
    }

    if (_isAnalyzing) return;

    // --- Clear previous results and status when starting analysis ---
    setState(() {
      _isAnalyzing = true;
      _segmentResults = []; // Clear segment results
      _updateStatus("Analyzing text..."); // Show analyzing status
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
        // --- Parse Overall Result ---
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

        // --- Parse Segment Results ---
        final segmentResults = responseBody['segment_results'];
        if (segmentResults != null && segmentResults is List) {
          // Ensure segmentResults is a List of Maps
          try {
            _segmentResults = List<Map<String, dynamic>>.from(segmentResults);
          } catch (e) {
            print("Error casting segment results: $e");
            _updateStatus(
                "Analysis complete, but failed to parse segment results.");
            _segmentResults = []; // Clear potentially malformed data
          }
        } else {
          print("No segment results received or format incorrect.");
          // Keep _segmentResults empty
        }
      } else {
        // Handle server errors or status not success
        // Server now sends a specific message for min word count validation failure (status 400)
        final errorMessage = responseBody['message'] ?? "Unknown server error.";
        _updateStatus(
          "Server Error: ${response.statusCode}",
          label: errorMessage, // Use message for error
        );
        _segmentResults = []; // Clear segment results on error
      }
    } catch (e) {
      // Handle network or other exceptions
      _updateStatus("Error: ${e.toString()}");
      _segmentResults = []; // Clear segment results on exception
    } finally {
      setState(() {
        _isAnalyzing = false; // Always set analyzing state to false
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
    ColorScheme colorScheme = Theme.of(context).colorScheme; // Get color scheme
    ElevatedButtonThemeData elevatedButtonThemeData =
        Theme.of(context).elevatedButtonTheme;

    final currentText = _textController.text.trim();
    // Check minimum word count for enabling the button
    final minWordsOverall = 30;
    final bool isTextLongEnough =
        currentText.split(RegExp(r'\s+')).length >= minWordsOverall;
    final bool enableAnalyzeButton = !_isAnalyzing && isTextLongEnough;

    // Determine the color for the highlighted text based on theme or specific colors
    final Color humanColor = Colors.green[700]!; // Darker green
    final Color aiColor = Colors.red[700]!; // Darker red
    final Color errorColor =
        colorScheme.error; // Use theme error color for errors

    return Scaffold(
      appBar: MyAppbar(title: "Analyze Text"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenBorderMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children
            children: [
              IntroductionText(),
              SizedBox(height: 15),
              CarouselPanel(
                carouselImages: detectTextCarouselImagesPaths,
              ),
              SizedBox(height: 15),

              // Input text field
              InputTextField(controller: _textController),

              Padding(
                padding: const EdgeInsets.only(
                    top: 10.0, bottom: 15.0), // Adjusted padding
                child: Text(
                  'The text must be at least $minWordsOverall words long.', // Use variable
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              // Analyze Button
              ElevatedButton(
                onPressed: enableAnalyzeButton ? _analyzeText : null,
                style: elevatedButtonThemeData.style,
                child: _isAnalyzing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Analyze Text"),
              ),

              SizedBox(height: 20), // Space before status/results

              // --- Status and Result Display ---
              // Display status message
              if (_statusMessage
                  .isNotEmpty) // Display status message regardless of analysis state
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 15.0), // Added bottom padding
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
                        ? textTheme.titleMedium!
                            .copyWith(color: errorColor) // Use error color
                        : textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),

              // Display Overall Classification Results only if Analysis Complete status is shown
              if (_predictionLabel.isNotEmpty &&
                  _statusMessage == "Analysis Complete:")
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text(
                    //   "Overall Classification:", // Changed title
                    //   style: textTheme.titleLarge,
                    //   textAlign: TextAlign.center,
                    // ),
                    // SizedBox(height: 5),
                    // Text(
                    //   _predictionLabel,
                    //   style: textTheme.headlineLarge!.copyWith(
                    //       fontWeight: FontWeight.bold,
                    //       color: _predictionLabel == "Human-written"
                    //           ? humanColor
                    //           : aiColor), // Color overall label
                    //   textAlign: TextAlign.center,
                    // ),
                    // SizedBox(height: 10),
                    // Text(
                    //   "Confidence: $_predictionConfidence",
                    //   style: textTheme.titleMedium,
                    //   textAlign: TextAlign.center,
                    // ),
                    // SizedBox(height: 10),
                    // Text(
                    //   "GPT-2 PPL: $_pplValue",
                    //   style: textTheme.titleMedium,
                    //   textAlign: TextAlign.center,
                    // ),
                    _buildColorLegend(textTheme),
                    SizedBox(height: 20), // Space before segmented text
                    Divider(), // Add a divider for clarity
                    SizedBox(height: 20),
                    Text(
                      "Segment Classification:", // Title for segmented output
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                  ],
                ),

              // --- Display Highlighted Segmented Text ---
              if (_segmentResults.isNotEmpty)
                Container(
                  // Wrap in Container for potential styling/background if needed
                  padding: const EdgeInsets.all(8.0), // Inner padding
                  decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant, // Subtle background
                      borderRadius: BorderRadius.circular(8.0)),
                  child: RichText(
                    textAlign: TextAlign.justify, // Or TextAlign.left
                    text: TextSpan(
                      // Base style for the RichText, applied unless overridden by TextSpan
                      style: textTheme.bodySmall, // Default style
                      children: _segmentResults.map((segment) {
                        final String text = segment['text'] ?? '';
                        final String label = segment['label'] ?? 'Error';
                        final String confidence = segment['confidence'] ??
                            'N/A'; // Could display confidence as tooltip/gesture
                        final String errorMsg = segment['error'] ??
                            ''; // Get error message if present

                        Color color;
                        String tooltipText;

                        if (label == "Human-written") {
                          color = humanColor;
                          tooltipText = "Human ($confidence)";
                        } else if (label == "AI-generated") {
                          color = aiColor;
                          tooltipText = "AI ($confidence)";
                        } else {
                          // Handle 'Error' label
                          color = errorColor;
                          tooltipText = "Error ($errorMsg)";
                        }

                        // Add a space after each segment for readability
                        return TextSpan(
                          text: text + ' ', // Add space
                          style: TextStyle(color: color),
                          // Optional: Add tooltip or gesture recognizer for confidence
                          // recognizer: TapGestureRecognizer()..onTap = () {
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //         SnackBar(content: Text(tooltipText))
                          //     );
                          // },
                        );
                      }).toList(), // Convert the map result to a List
                    ),
                  ),
                ),
              SizedBox(height: 20), // Space after highlighted text

              // Add more space at the bottom if needed
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorLegend(TextTheme textTheme) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align legend items to the start
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

  // Helper to build a single legend item (color box + text)
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
