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

class VideoClassificationBar extends StatelessWidget {
  final List<Map<String, dynamic>> segmentResults;
  final double totalDuration;
  final double barHeight;
  final Duration currentPlaybackPosition;

  const VideoClassificationBar({
    super.key,
    required this.segmentResults,
    required this.totalDuration,
    this.barHeight = 30.0,
    required this.currentPlaybackPosition,
  });

  @override
  Widget build(BuildContext context) {
    if (segmentResults.isEmpty || totalDuration <= 0) {
      return Container();
    }

    final double effectiveTotalDuration = totalDuration;

    final double currentPositionInSeconds =
        currentPlaybackPosition.inMilliseconds / 1000.0;
    final double clampedPosition =
        currentPositionInSeconds.clamp(0.0, effectiveTotalDuration);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;

        final double indicatorPixelPosition =
            (clampedPosition / effectiveTotalDuration) * maxWidth;

        return Container(
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(color: Colors.grey[700]!),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Row(
                children: segmentResults.map((result) {
                  final start =
                      (result['start_time'] as num?)?.toDouble() ?? 0.0;
                  final end = (result['end_time'] as num?)?.toDouble() ?? start;
                  final segmentDuration = end - start;

                  Color segmentColor;
                  final label = result['label'];
                  final double confidenceScore =
                      (result['confidence_score'] as num?)?.toDouble() ?? 0.0;
                  final String status = result['status'] ?? 'unknown';

                  if (status != 'success') {
                    segmentColor = Colors.grey;
                  } else {
                    Color baseColor;
                    if (label == 'AI-generated') {
                      baseColor = Colors.red;
                    } else if (label == 'Human-made') {
                      baseColor = Colors.green;
                    } else {
                      baseColor = Colors.grey[600]!;
                    }

                    final Color neutralColor = Colors.grey[300]!;

                    final double clampedConfidence =
                        confidenceScore.clamp(0.0, 1.0);
                    segmentColor =
                        Color.lerp(neutralColor, baseColor, clampedConfidence)!;
                  }

                  final double segmentWidth =
                      (segmentDuration / effectiveTotalDuration) * maxWidth;

                  return Container(
                    width: segmentWidth.isFinite && segmentWidth >= 0
                        ? segmentWidth
                        : 0.0,
                    color: segmentColor,
                  );
                }).toList(),
              ),
              Positioned(
                left: indicatorPixelPosition.clamp(0.0, maxWidth - 2.0),
                top: 0,
                bottom: 0,
                width: 2.0,
                child: Container(
                  color: Colors.blueAccent,
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
  String _videoFileName = "";

  String _analysisStatus = "Select a video to analyze.";
  bool _isAnalyzing = false;
  String _overallLabel = "";
  String _overallConfidence = "";

  List<Map<String, dynamic>> _segmentResults = [];
  double _totalVideoDuration = 0.0;

  Duration _currentPlaybackPosition = Duration.zero;

  double maxVideoPlayerWidth = 400.0;
  double maxVideoPlayerHeight = 300.0;

  @override
  void initState() {
    super.initState();
    _initializeController(
      VideoPlayerController.networkUrl(
        Uri.parse(
            "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
      ),
    );
    _updateStatus("Select a video to analyze.");
  }

  void _initializeController(VideoPlayerController newController) {
    if (_controller != null) {
      _controller!.removeListener(_updatePlaybackPosition);
      _controller!.dispose();
    }
    _controller = newController;
    _controller!.setLooping(true);

    _controller!.addListener(_updatePlaybackPosition);

    _controller!.initialize().then((_) {
      setState(() {
        if (_videoFile == null) {
          _controller!.play();
        }
      });
    }).catchError((error) {
      print("Error initializing video player: $error");
      _updateStatus("Error initializing video player: ${error.toString()}",
          isError: true);
      _videoFile = null;
      _videoFileName = "";
      _controller = null;
      _currentPlaybackPosition = Duration.zero;
      setState(() {});
    });
  }

  void _updatePlaybackPosition() {
    if (_controller != null && _controller!.value.isInitialized) {
      if (_currentPlaybackPosition != _controller!.value.position) {
        setState(() {
          _currentPlaybackPosition = _controller!.value.position;
        });
      }
    }
  }

  void _updateStatus(String message, {bool isError = false}) {
    setState(() {
      _analysisStatus = message;
      if (!message.startsWith("Analysis Complete")) {
        _overallLabel = "";
        _overallConfidence = "";
        _segmentResults = [];
        _totalVideoDuration = 0.0;
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
        _overallLabel = "";
        _overallConfidence = "";
        _segmentResults = [];
        _totalVideoDuration = 0.0;
        _analysisStatus = "Video selected: $_videoFileName";
        _currentPlaybackPosition = Duration.zero;

        _initializeController(
          VideoPlayerController.file(
            _videoFile!,
          ),
        );
      });
    } else {
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

    _controller?.pause();

    setState(() {
      _isAnalyzing = true;
      _updateStatus("Uploading video...");
      _overallLabel = "";
      _overallConfidence = "";
      _segmentResults = [];
      _totalVideoDuration = 0.0;
      _currentPlaybackPosition = Duration.zero;
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
            _segmentResults = List<Map<String, dynamic>>.from(segmentResults);
            _totalVideoDuration = (totalDuration as num).toDouble();
            _analysisStatus = "Analysis Complete:";
          });
          print("Analysis results and segments updated.");
        } else {
          print(
              "Warning: Missing data in successful response (overall, segments, or duration).");
          _updateStatus(
              "Analysis complete, but missing data in server response.",
              isError: true);
          _overallLabel = "";
          _overallConfidence = "";
          _segmentResults = [];
          _totalVideoDuration = 0.0;
          setState(() {});
        }
      } else {
        print("Server returned error status or non-200 code.");
        final errorMessage = responseBody['message'] ?? "Unknown server error.";
        _updateStatus("Server Error: ${response.statusCode} - $errorMessage",
            isError: true);
        _overallLabel = "";
        _overallConfidence = "";
        _segmentResults = [];
        _totalVideoDuration = 0.0;
        setState(() {});
      }
    } catch (e) {
      print("Error during HTTP request or processing: $e");
      _updateStatus("Error analyzing video: ${e.toString()}", isError: true);
      _overallLabel = "";
      _overallConfidence = "";
      _segmentResults = [];
      _totalVideoDuration = 0.0;
      setState(() {});
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
      print("Analysis process finished.");
    }
  }

  @override
  void dispose() {
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
              SizedBox(height: 10),
              if (_controller != null && _controller!.value.isInitialized)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      SizedBox(width: 8),
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
                          : 0),
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
                  Text(
                    _analysisStatus,
                    style: textTheme.titleMedium?.copyWith(
                        color: _analysisStatus.startsWith("Error")
                            ? colorScheme.error
                            : textTheme.titleMedium?.color),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: enableAnalyzeButton ? _analyzeVideo : null,
                    style: elevatedButtonThemeData.style,
                    child: _isAnalyzing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const UploadVideoText(title: "Upload and Analyze"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (_overallLabel.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Overall Classification Result:",
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
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 20),
                    if (_segmentResults.isNotEmpty)
                      Text(
                        "Segment Classification:",
                        style: textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(height: _segmentResults.isNotEmpty ? 10 : 0),
                  ],
                ),
              if (_segmentResults.isNotEmpty &&
                  _controller != null &&
                  _controller!.value.isInitialized)
                VideoClassificationBar(
                  segmentResults: _segmentResults,
                  totalDuration: _totalVideoDuration,
                  currentPlaybackPosition: _currentPlaybackPosition,
                  barHeight: 30.0,
                ),
              SizedBox(height: _segmentResults.isNotEmpty ? 20 : 0),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
