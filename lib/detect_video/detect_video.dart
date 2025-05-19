// detect_video.dart

import 'dart:io';
import 'dart:convert';
import 'package:ai_generated_content_detector/detect_video/text.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';
import 'package:ai_generated_content_detector/keys.dart';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';

// --- Widget to display the colored video bar based on classification results ---
class VideoClassificationBar extends StatelessWidget {
  final List<Map<String, dynamic>> segmentResults;
  final double totalDuration; // Total duration of the video in seconds
  final double barHeight; // Height of the bar
  final Duration
      currentPlaybackPosition; // Current playback position from VideoPlayer

  const VideoClassificationBar({
    super.key,
    required this.segmentResults,
    required this.totalDuration,
    this.barHeight = 30.0, // Increased height slightly for better visibility
    required this.currentPlaybackPosition,
  });

  @override
  Widget build(BuildContext context) {
    if (segmentResults.isEmpty || totalDuration <= 0) {
      return Container(); // Don't show the bar if no results or zero duration
    }

    // Use the actual total duration from the video player if it's available and greater
    // This handles potential slight differences between CV2 duration and player duration
    // For accurate playback indicator positioning
    // final double effectiveTotalDuration = playerTotalDuration.inMilliseconds / 1000.0 > totalDuration
    //     ? playerTotalDuration.inMilliseconds / 1000.0
    //     : totalDuration; // Use server duration if player duration is less or unavailable

    final double effectiveTotalDuration =
        totalDuration; // Stick to server duration for bar scaling

    // Calculate the position of the playback indicator along the bar's width
    final double currentPositionInSeconds =
        currentPlaybackPosition.inMilliseconds / 1000.0;
    // Clamp position to be within duration for indicator placement
    final double clampedPosition =
        currentPositionInSeconds.clamp(0.0, effectiveTotalDuration);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;

        // Calculate indicator position in pixels relative to the bar width
        final double indicatorPixelPosition =
            (clampedPosition / effectiveTotalDuration) * maxWidth;

        return Container(
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(color: Colors.grey[700]!),
          ),
          clipBehavior: Clip.antiAlias, // Clip children like the Row and Stack
          child: Stack(
            children: [
              Row(
                // The colored segments
                children: segmentResults.map((result) {
                  final start =
                      (result['start_time'] as num?)?.toDouble() ?? 0.0;
                  final end = (result['end_time'] as num?)?.toDouble() ?? start;
                  final segmentDuration = end - start;

                  Color segmentColor;
                  final label = result['label'];
                  final double confidenceScore =
                      (result['confidence_score'] as num?)?.toDouble() ?? 0.0;
                  final String status = result['status'] ??
                      'unknown'; // e.g., 'success', 'no_frames', 'error'

                  if (status != 'success') {
                    // Handle non-successful segments (e.g., no frames extracted, error)
                    segmentColor =
                        Colors.grey; // Grey for any non-classified segment
                  } else {
                    // status is 'success' - use label and confidence
                    Color baseColor;
                    if (label == 'AI-generated') {
                      baseColor = Colors.red;
                    } else if (label == 'Human-made') {
                      // Note: Use "Human-made" from server
                      baseColor = Colors.green;
                    } else {
                      baseColor =
                          Colors.grey[600]!; // Fallback for unknown label
                    }

                    // Define a neutral color for 0 confidence
                    final Color neutralColor = Colors.grey[300]!;

                    // Interpolate color based on confidence score (clamped 0.0 to 1.0)
                    final double clampedConfidence =
                        confidenceScore.clamp(0.0, 1.0);
                    segmentColor =
                        Color.lerp(neutralColor, baseColor, clampedConfidence)!;
                  }

                  // Calculate the width for this segment in pixels
                  // Ensure the width is proportional to its duration
                  final double segmentWidth =
                      (segmentDuration / effectiveTotalDuration) * maxWidth;

                  // Use Flexible with tight fit to ensure it takes exactly the calculated width
                  // Using flex in Expanded can sometimes lead to rounding issues depending on total width and number of segments
                  // Flexible(flex: (segmentDuration * 10000).round(), ...) is an alternative
                  return Container(
                    width: segmentWidth.isFinite && segmentWidth >= 0
                        ? segmentWidth
                        : 0.0, // Handle potential NaN or negative widths
                    color: segmentColor,
                    // Optional: Add tooltip or gesture detector
                    // child: Tooltip(message: "$label (${(confidenceScore*100).toStringAsFixed(1)}%)"),
                  );
                }).toList(),
              ),
              // --- Playback Indicator ---
              Positioned(
                // Position the indicator horizontally
                // Clamp to ensure it stays within the bounds of the bar
                left: indicatorPixelPosition.clamp(
                    0.0, maxWidth - 2.0), // Adjust clamp by indicator width
                top: 0,
                bottom: 0,
                width: 2.0, // Thickness of the indicator line
                child: Container(
                  color: Colors.blueAccent, // Color of the indicator
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DetectVideo extends StatefulWidget {
  const DetectVideo({super.key, required this.title});
  final String title;

  @override
  State<DetectVideo> createState() => _DetectVideoState();
}

class _DetectVideoState extends State<DetectVideo> {
  VideoPlayerController? _controller;
  File? _videoFile;
  String _videoFileName = ""; // To display the name of the picked file

  // State variables for analysis process and results
  String _analysisStatus = "Select a video to analyze.";
  bool _isAnalyzing = false;
  String _overallLabel = ""; // Changed from _resultLabel to be clearer
  String _overallConfidence = ""; // Changed from _resultConfidence

  // State variables for segmented results and duration
  List<Map<String, dynamic>> _segmentResults = [];
  double _totalVideoDuration = 0.0; // Total duration in seconds from server

  // State variables for video player position and total duration
  Duration _currentPlaybackPosition = Duration.zero;
  // _controller!.value.duration gives total duration from player

  double maxVideoPlayerWidth = 400.0;
  double maxVideoPlayerHeight = 300.0;

  @override
  void initState() {
    super.initState();
    // Initialize with a default network video or keep empty if you prefer
    _initializeController(
      VideoPlayerController.networkUrl(
        Uri.parse(
            "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
      ),
    );
    _updateStatus("Select a video to analyze.");
  }

  void _initializeController(VideoPlayerController newController) {
    // Dispose the old controller and remove listener BEFORE initializing new one
    if (_controller != null) {
      _controller!.removeListener(_updatePlaybackPosition); // Remove listener
      _controller!.dispose();
    }
    _controller = newController;
    _controller!.setLooping(true);

    // Add listener for playback position *before* initialization completes
    // This ensures we don't miss initial events if initialize is fast
    _controller!.addListener(_updatePlaybackPosition);

    _controller!.initialize().then((_) {
      setState(() {
        // Optional: Autoplay the initial video, but maybe not the selected one
        if (_videoFile == null) {
          // Only play initial video on init
          _controller!.play();
        }
        // Ensure position listener is active - already added above
      });
    }).catchError((error) {
      print("Error initializing video player: $error");
      _updateStatus("Error initializing video player: ${error.toString()}",
          isError: true);
      _videoFile = null;
      _videoFileName = "";
      // Explicitly clear controller state on error
      _controller = null;
      _currentPlaybackPosition = Duration.zero; // Reset position state
      setState(() {}); // Trigger rebuild to show error placeholder
    });
  }

  // Listener function to update playback position
  void _updatePlaybackPosition() {
    if (_controller != null && _controller!.value.isInitialized) {
      // Only update state if the position has actually changed
      // This prevents unnecessary rebuilds
      if (_currentPlaybackPosition != _controller!.value.position) {
        setState(() {
          _currentPlaybackPosition = _controller!.value.position;
        });
      }
    }
  }

  // Helper to update analysis status and clear results/segments
  void _updateStatus(String message, {bool isError = false}) {
    setState(() {
      _analysisStatus = message;
      // Clear results and segments when status changes unless it's the final 'Analysis Complete' status
      if (!message.startsWith("Analysis Complete")) {
        _overallLabel = "";
        _overallConfidence = "";
        _segmentResults = []; // Clear segments
        _totalVideoDuration = 0.0; // Reset duration
        // Playback position is handled by the listener
      }
    });
  }

  Future<void> _pickVideo(ImageSource source) async {
    if (_isAnalyzing) return;

    final pickedFile = await ImagePicker().pickVideo(source: source);
    if (pickedFile != null) {
      final file = File(pickedFile.path);

      setState(() {
        _videoFile = file;
        _videoFileName = p.basename(file.path);
        // Clear previous analysis results, segments, and status
        _overallLabel = "";
        _overallConfidence = "";
        _segmentResults = [];
        _totalVideoDuration = 0.0;
        _analysisStatus = "Video selected: $_videoFileName";
        _currentPlaybackPosition =
            Duration.zero; // Reset playback position on new pick

        _initializeController(
          VideoPlayerController.file(
            _videoFile!,
          ),
        );
      });
    } else {
      // User cancelled picking
      _updateStatus(_videoFile == null
          ? "Select a video to analyze."
          : "Video selected: $_videoFileName");
    }
  }

  Future<void> _analyzeVideo() async {
    if (_videoFile == null) {
      _updateStatus("Please select a video first.", isError: true);
      return;
    }
    if (_isAnalyzing) return;

    // Stop video playback when analysis starts
    _controller?.pause();

    setState(() {
      _isAnalyzing = true;
      _updateStatus("Uploading video...");
      // Ensure results and segments are clear from previous analysis
      _overallLabel = "";
      _overallConfidence = "";
      _segmentResults = [];
      _totalVideoDuration = 0.0;
      _currentPlaybackPosition = Duration.zero; // Reset position display
    });

    final videoServerUrl = "$serverAddress:5003/classify_video";

    try {
      var uri = Uri.parse(videoServerUrl);
      var request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath(
        'video',
        _videoFile!.path,
      ));

      print("Sending video file to server...");
      var streamedResponse = await request.send();
      print("Request sent. Waiting for response...");

      var response = await http.Response.fromStream(streamedResponse);
      print("Response received with status code: ${response.statusCode}");

      final responseBody = json.decode(response.body);
      print("Response body decoded.");

      // Process the server response
      if (response.statusCode == 200 && responseBody['status'] == 'success') {
        final overallResult = responseBody['overall_result'];
        final segmentResults = responseBody['segment_results'];
        final totalDuration = responseBody['total_duration'];

        if (overallResult != null &&
            segmentResults != null &&
            totalDuration != null) {
          setState(() {
            _overallLabel = overallResult['label'] ?? "N/A";
            _overallConfidence = overallResult['confidence'] ?? "N/A";
            // Ensure segment results are treated as a list of maps
            _segmentResults = List<Map<String, dynamic>>.from(segmentResults);
            _totalVideoDuration =
                (totalDuration as num).toDouble(); // Ensure it's double
            _analysisStatus = "Analysis Complete:";
          });
          print("Analysis results and segments updated.");

          // Optional: Automatically play video after analysis?
          // _controller?.play();
        } else {
          print(
              "Warning: Missing data in successful response (overall, segments, or duration).");
          _updateStatus(
              "Analysis complete, but missing data in server response.",
              isError: true);
          // Clear potentially partial results
          _overallLabel = "";
          _overallConfidence = "";
          _segmentResults = [];
          _totalVideoDuration = 0.0;
          setState(() {}); // Ensure UI updates
        }
      } else {
        // Handle server error or status not success
        print("Server returned error status or non-200 code.");
        final errorMessage = responseBody['message'] ?? "Unknown server error.";
        _updateStatus("Server Error: ${response.statusCode} - $errorMessage",
            isError: true);
        // Ensure results and segments are cleared on server error
        _overallLabel = "";
        _overallConfidence = "";
        _segmentResults = [];
        _totalVideoDuration = 0.0;
        setState(() {}); // Ensure UI updates
      }
    } catch (e) {
      // Handle network or other exceptions
      print("Error during HTTP request or processing: $e");
      _updateStatus("Error analyzing video: ${e.toString()}", isError: true);
      // Ensure results and segments are cleared on exception
      _overallLabel = "";
      _overallConfidence = "";
      _segmentResults = [];
      _totalVideoDuration = 0.0;
      setState(() {}); // Ensure UI updates
    } finally {
      setState(() {
        _isAnalyzing = false; // Always set analyzing state to false
      });
      print("Analysis process finished.");
    }
  }

  @override
  void dispose() {
    // Remove listener before disposing the controller
    _controller?.removeListener(_updatePlaybackPosition);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    ElevatedButtonThemeData elevatedButtonThemeData =
        Theme.of(context).elevatedButtonTheme;

    final bool enableAnalyzeButton = _videoFile != null && !_isAnalyzing;

    return Scaffold(
      appBar: MyAppbar(title: "Analyze Video"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenBorderMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              IntroductionText(),
              SizedBox(height: 15),

              // Video Player Area
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: _controller != null &&
                            _controller!.value.isInitialized
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: maxVideoPlayerWidth,
                                maxHeight: maxVideoPlayerHeight,
                              ),
                              child: AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: VideoPlayer(_controller!),
                              ),
                            ),
                          )
                        : Container(
                            width: maxVideoPlayerWidth,
                            height: maxVideoPlayerHeight,
                            alignment: Alignment.center,
                            child:
                                _analysisStatus.startsWith("Error initializing")
                                    ? Icon(Icons.error,
                                        size: 50, color: colorScheme.error)
                                    : CircularProgressIndicator(),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 10), // Spacing below player

              // --- Play/Pause Button and Position Display ---
              // Show these only if a video controller is initialized
              if (_controller != null && _controller!.value.isInitialized)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0), // Match bar padding
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the row content
                    children: [
                      IconButton(
                        icon: Icon(
                          _controller!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller!.value.isPlaying
                                ? _controller!.pause()
                                : _controller!.play();
                          });
                        },
                      ),
                      SizedBox(width: 8), // Space between button and text
                      Text(
                        '${_currentPlaybackPosition.inMinutes}:${(_currentPlaybackPosition.inSeconds % 60).toString().padLeft(2, '0')} / '
                        '${_controller!.value.duration.inMinutes}:${(_controller!.value.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

              SizedBox(
                  height:
                      _controller != null && _controller!.value.isInitialized
                          ? 15
                          : 0), // Conditional spacing

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: _isAnalyzing
                          ? null
                          : () => _pickVideo(ImageSource.gallery),
                      style: elevatedButtonThemeData.style,
                      child:
                          const UploadVideoText(title: "Select a Video File")),
                  SizedBox(height: 15),

                  // Display selected video file name or initial status
                  Text(
                    _analysisStatus,
                    style: textTheme.titleMedium?.copyWith(
                        color: _analysisStatus.startsWith("Error")
                            ? colorScheme.error
                            : textTheme.titleMedium?.color),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),

                  // Analyze Button
                  ElevatedButton(
                    onPressed: enableAnalyzeButton ? _analyzeVideo : null,
                    style: elevatedButtonThemeData.style,
                    child: _isAnalyzing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const UploadVideoText(
                            title: "Upload and Analyze"), // Changed button text
                  ),
                ],
              ),

              SizedBox(height: 20),

              // --- Overall Analysis Results Display ---
              // Show overall results only if they are available
              if (_overallLabel.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Overall Classification Result:", // Changed title
                      style: textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      _overallLabel,
                      style: textTheme.headlineLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _overallLabel == "Human-made"
                              ? Colors.green[700]
                              : Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Confidence: $_overallConfidence",
                      style: textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20), // Space before segment bar/title
                    Divider(), // Separator
                    SizedBox(height: 20),
                    // Only show Segment Classification title if there are segments to show
                    if (_segmentResults.isNotEmpty)
                      Text(
                        "Segment Classification:",
                        style: textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(
                        height: _segmentResults.isNotEmpty
                            ? 10
                            : 0), // Conditional space
                  ],
                ),

              // --- Video Classification Bar (Segment Visualization) ---
              // Show the bar only if segment results are available AND video is initialized
              if (_segmentResults.isNotEmpty &&
                  _controller != null &&
                  _controller!.value.isInitialized)
                VideoClassificationBar(
                  segmentResults: _segmentResults,
                  totalDuration:
                      _totalVideoDuration, // Use duration from server
                  currentPlaybackPosition:
                      _currentPlaybackPosition, // Pass current player position
                  barHeight: 30.0, // Set desired bar height
                ),
              SizedBox(
                  height: _segmentResults.isNotEmpty
                      ? 20
                      : 0), // Conditional spacing after bar

              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

// Assuming UploadVideoText is defined like this somewhere (e.g., themes/template.dart or detect_video/upload_video_text.dart)
// class UploadVideoText extends StatelessWidget {
//   final String title;
//   const UploadVideoText({Key? key, required this.title}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     TextTheme textTheme = Theme.of(context).textTheme;
//     // Use titleLarge here for consistency with ElevatedButton default
//     return Text(
//       title,
//       style: textTheme.titleLarge,
//     );
//   }
// }
