import 'dart:io';
import 'dart:convert';
import 'package:ai_generated_content_detector/keys.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:ai_generated_content_detector/detect_audio/text.dart'; // Assuming this contains widgets like UploadAudioText, NoSelectedAudioText, IntroductionText
import 'package:ai_generated_content_detector/themes/template.dart'; // Assuming this contains MyAppbar
import 'package:ai_generated_content_detector/themes/varaibles.dart'; // Assuming this contains screenBorderMargin
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// --- Widget to display the colored audio bar based on confidence ---
class AudioClassificationBar extends StatelessWidget {
  final List<Map<String, dynamic>> segmentResults;
  final double totalDuration; // Total duration of the audio in seconds

  const AudioClassificationBar({
    Key? key,
    required this.segmentResults,
    required this.totalDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (segmentResults.isEmpty || totalDuration <= 0) {
      return Container(); // Don't show the bar if no results or zero duration
    }

    // Calculate the total duration covered by segments
    final double coveredDuration = segmentResults.fold(0.0, (sum, result) {
      final start = (result['start_time'] as num?)?.toDouble() ?? 0.0;
      final end = (result['end_time'] as num?)?.toDouble() ?? start;
      return sum + (end - start);
    });

    // Handle case where coveredDuration is zero to prevent division by zero
    if (coveredDuration <= 0) {
      return Container(
        height: 20.0,
        color: Colors.grey, // Indicate an issue or no valid segments
        alignment: Alignment.center,
        child: Text("No valid segments to display",
            style: TextStyle(color: Colors.white, fontSize: 12)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth =
            constraints.maxWidth; // Max width available for the bar

        return Container(
          height: 20.0, // Fixed height for the bar
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0), // Rounded corners
            border: Border.all(color: Colors.grey[700]!),
          ),
          clipBehavior: Clip.antiAlias, // Clip content to border radius
          child: Row(
            children: segmentResults.map((result) {
              final start = (result['start_time'] as num?)?.toDouble() ?? 0.0;
              final end = (result['end_time'] as num?)?.toDouble() ?? start;
              final duration = end - start;

              // Calculate the width of this segment proportional to the total covered duration
              final double segmentWidth =
                  (duration / coveredDuration) * maxWidth;

              Color segmentColor;
              final label = result['label'];
              // Get the confidence score (float between 0.0 and 1.0)
              final double confidenceScore =
                  (result['confidence_score'] as num?)?.toDouble() ?? 0.0;

              // Determine base color based on label
              Color baseColor;
              if (label == 'AI-generated') {
                baseColor = Colors.red;
              } else if (label == 'Human') {
                baseColor = Colors.green;
              } else {
                baseColor = Colors.grey; // Default for errors or unknown labels
              }

              // Define a neutral color for 0 confidence (e.g., a light grey)
              final Color neutralColor = Colors.grey[300]!;

              // Interpolate color based on confidence score
              // Clamp confidenceScore between 0.0 and 1.0 just in case
              final double clampedConfidence = confidenceScore.clamp(0.0, 1.0);

              // Use Color.lerp to blend from neutralColor to baseColor based on confidence
              segmentColor =
                  Color.lerp(neutralColor, baseColor, clampedConfidence)!;

              // Use Expanded with flex based on duration for accurate proportionality
              // Use a sufficient multiplier (e.g., 1000 or 10000) for good integer flex granularity
              final int flex = (duration * 10000).round();
              // Ensure flex is at least 1 if duration > 0, to make tiny segments visible
              final int finalFlex = flex > 0 ? flex : (duration > 0 ? 1 : 0);

              return Expanded(
                flex: finalFlex,
                child: Container(
                  color: segmentColor,
                  // Optional: Add a tooltip or gesture detector to show label/confidence on tap
                  // child: Tooltip(
                  //   message: "${result['label'] ?? 'N/A'}\nConfidence: ${result['confidence'] ?? 'N/A'}",
                  //   child: Container(color: segmentColor),
                  // ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class DetectAudio extends StatefulWidget {
  const DetectAudio({super.key, required this.title});
  final String title;

  @override
  State<DetectAudio> createState() => _DetectAudioState();
}

class _DetectAudioState extends State<DetectAudio> {
  // Corrected State type
  File? _audioFile;
  String _selectedFileName = "";

  List<Map<String, dynamic>> _segmentResults = [];
  String _overallConclusion = "";
  double _totalAudioDuration = 0.0;

  String _statusMessage = "";
  bool _isPredicting = false;

  @override
  void initState() {
    super.initState();
    _statusUpdate("Select an audio file to analyze.");
  }

  Future<void> _pickAudio(ImageSource source) async {
    final pickedFile = await ImagePicker().pickMedia(
        // Adding mediaType hint can guide the picker, but 'any' is flexible
        // mediaType: ImageSource.gallery == source ? MediaSourceType.audio : MediaSourceType.any,
        );

    if (pickedFile != null) {
      setState(() {
        _audioFile = File(pickedFile.path);
        _selectedFileName = path.basename(pickedFile.path);
        _segmentResults = [];
        _overallConclusion = "";
        _totalAudioDuration = 0.0;
        _statusUpdate("Audio file selected: $_selectedFileName");
      });
    } else {
      setState(() {
        _statusUpdate("Audio file selection cancelled.");
      });
    }
  }

  void _statusUpdate(String message,
      {List<Map<String, dynamic>>? segmentResults,
      String? overallConclusion,
      double? totalDuration}) {
    setState(() {
      _statusMessage = message;
      _segmentResults = segmentResults ?? [];
      _overallConclusion = overallConclusion ?? "";
      _totalAudioDuration = totalDuration ?? 0.0;
    });
  }

  Future<void> _uploadAudio() async {
    if (_audioFile == null) {
      _statusUpdate("Please select an audio file first.");
      return;
    }

    setState(() {
      _isPredicting = true;
      _segmentResults = [];
      _overallConclusion = "";
      _totalAudioDuration = 0.0;
      _statusUpdate("Analyzing audio...");
    });

    final audioServerUrl = "$serverAddress/classify_audio";

    try {
      var request = http.MultipartRequest('POST', Uri.parse(audioServerUrl));
      request.files.add(await http.MultipartFile.fromPath(
          'audio', _audioFile!.path,
          filename: _selectedFileName));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['status'] != 'error') {
        _statusUpdate(
          responseBody['message'] ?? "Analysis complete.",
          segmentResults: (responseBody['segment_results'] as List<dynamic>?)
                  ?.map((item) => item as Map<String, dynamic>)
                  .toList() ??
              [],
          overallConclusion: responseBody['overall_conclusion'] ??
              "No overall conclusion provided.",
          totalDuration:
              (responseBody['audio_duration'] as num?)?.toDouble() ?? 0.0,
        );
      } else {
        _statusUpdate(
          "Server Error: ${response.statusCode} - ${responseBody['message'] ?? 'Unknown server error.'}",
        );
      }
    } catch (e) {
      _statusUpdate("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isPredicting = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ElevatedButtonThemeData elevatedButtonThemeData =
        Theme.of(context).elevatedButtonTheme;

    return Scaffold(
      appBar: MyAppbar(title: "Analyze Audio"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenBorderMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IntroductionText(),
              SizedBox(height: 15),

              if (_audioFile != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Selected Audio File:",
                      style: textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      _selectedFileName,
                      style: textTheme.bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    if (_totalAudioDuration > 0)
                      Text(
                        "Duration: ${_totalAudioDuration.toStringAsFixed(2)} seconds",
                        style: textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                  ],
                )
              else
                NoSelectedAudioText(title: "No Audio Selected"),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () => _pickAudio(ImageSource.gallery),
                style: elevatedButtonThemeData.style,
                child: const UploadAudioText(title: "Select an Audio File"),
              ),

              SizedBox(height: 15),

              ElevatedButton(
                onPressed:
                    (_audioFile == null || _isPredicting) ? null : _uploadAudio,
                style: elevatedButtonThemeData.style,
                child: _isPredicting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : UploadAudioText(title: "Analyze Audio"),
              ),

              SizedBox(height: 20),

              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _statusMessage,
                    style: _statusMessage.startsWith("Error:")
                        ? textTheme.titleMedium!.copyWith(color: Colors.red)
                        : textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),

              // --- Colored Audio Bar Display (Confidence based) ---
              if (_segmentResults.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: AudioClassificationBar(
                    segmentResults: _segmentResults,
                    totalDuration: _totalAudioDuration,
                  ),
                ),

              // --- Overall Conclusion Display ---
              if (_overallConclusion.isNotEmpty && !_isPredicting)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    _overallConclusion,
                    style: textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

              if (!_isPredicting &&
                  _audioFile == null &&
                  _statusMessage.isEmpty &&
                  _segmentResults.isEmpty &&
                  _overallConclusion.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Pick an audio file to begin analysis.',
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
