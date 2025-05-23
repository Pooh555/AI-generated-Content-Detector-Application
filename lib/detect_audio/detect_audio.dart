import 'dart:io';
import 'dart:convert';
import 'package:ai_generated_content_detector/keys.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:audioplayers/audioplayers.dart';

import 'package:ai_generated_content_detector/detect_audio/text.dart';
import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AudioClassificationBar extends StatelessWidget {
  final List<Map<String, dynamic>> segmentResults;
  final double totalDuration;
  final double barHeight;
  final double currentPlaybackPosition;

  const AudioClassificationBar({
    super.key,
    required this.segmentResults,
    required this.totalDuration,
    this.barHeight = 20.0,
    required this.currentPlaybackPosition,
  });

  @override
  Widget build(BuildContext context) {
    if (segmentResults.isEmpty || totalDuration <= 0) {
      return Container();
    }

    final double coveredDuration = segmentResults.fold(0.0, (sum, result) {
      final start = (result['start_time'] as num?)?.toDouble() ?? 0.0;
      final end = (result['end_time'] as num?)?.toDouble() ?? start;
      return sum + (end - start);
    });

    if (coveredDuration <= 0) {
      return Container(
        height: barHeight,
        color: Colors.grey,
        alignment: Alignment.center,
        child: Text("No valid segments to display",
            style: TextStyle(color: Colors.white, fontSize: 12)),
      );
    }

    final double clampedPosition =
        currentPlaybackPosition.clamp(0.0, totalDuration);
    final double positionAlongCoveredDuration =
        (clampedPosition / totalDuration) * coveredDuration;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;

        final double indicatorPixelPosition =
            (positionAlongCoveredDuration / coveredDuration) * maxWidth;

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
                  final duration = end - start;

                  Color segmentColor;
                  final label = result['label'];
                  final double confidenceScore =
                      (result['confidence_score'] as num?)?.toDouble() ?? 0.0;
                  final String status = result['status'] ?? 'unknown';
                  final String type = result['type'] ?? 'unknown';

                  if (status == 'vad_skipped' || type == 'no_voice') {
                    segmentColor = Colors.grey;
                  } else if (status == 'error') {
                    segmentColor = Colors.deepOrange;
                  } else {
                    Color baseColor;
                    if (label == 'AI-generated') {
                      baseColor = Colors.red;
                    } else if (label == 'Human') {
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

                  final int flex = (duration * 10000).round();
                  final int finalFlex =
                      flex > 0 ? flex : (duration > 0 ? 1 : 0);

                  return Expanded(
                    flex: finalFlex,
                    child: Container(
                      color: segmentColor,
                    ),
                  );
                }).toList(),
              ),
              Positioned(
                left: indicatorPixelPosition,
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

class DetectAudio extends StatefulWidget {
  const DetectAudio({super.key, required this.title});
  final String title;

  @override
  State<DetectAudio> createState() => _DetectAudioState();
}

class _DetectAudioState extends State<DetectAudio> {
  File? _audioFile;
  String _selectedFileName = "";

  List<Map<String, dynamic>> _segmentResults = [];
  String _overallConclusion = "";
  double _totalAudioDuration = 0.0;

  String _statusMessage = "";
  bool _isPredicting = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _playerTotalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _statusUpdate("Select an audio file to analyze.");

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _playerTotalDuration = duration;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _currentPosition = _playerTotalDuration;
      });
    });
  }

  Future<void> _pickAudio(ImageSource source) async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _currentPosition = Duration.zero;
      _playerTotalDuration = Duration.zero;
    });

    final pickedFile = await ImagePicker().pickMedia();

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      setState(() {
        _audioFile = file;
        _selectedFileName = path.basename(file.path);
        _segmentResults = [];
        _overallConclusion = "";
        _totalAudioDuration = 0.0;
        _statusUpdate("Audio file selected: $_selectedFileName");
      });

      try {
        await _audioPlayer.setSourceDeviceFile(file.path);
      } catch (e) {
        print("Error setting audio player source: $e");
      }
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
      _totalAudioDuration =
          totalDuration ?? _playerTotalDuration.inSeconds.toDouble();
    });
  }

  Future<void> _uploadAudio() async {
    if (_audioFile == null) {
      _statusUpdate("Please select an audio file first.");
      return;
    }

    await _audioPlayer.pause();

    setState(() {
      _isPredicting = true;
      _segmentResults = [];
      _overallConclusion = "";
      _statusUpdate("Analyzing audio...");
    });

    final audioServerUrl = "http://172.30.45.80:5001/classify_audio";

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
          totalDuration: (responseBody['audio_duration'] as num?)?.toDouble() ??
              _playerTotalDuration.inSeconds.toDouble(),
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

  void _seekAudio(TapDownDetails details, double barWidth) {
    if (_playerTotalDuration.inMilliseconds == 0 || barWidth == 0) return;

    final double tapPositionX = details.localPosition.dx;
    final double fraction = tapPositionX / barWidth;

    final int targetMilliseconds =
        (_playerTotalDuration.inMilliseconds * fraction).round();

    _audioPlayer.seek(Duration(milliseconds: targetMilliseconds));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ElevatedButtonThemeData elevatedButtonThemeData =
        Theme.of(context).elevatedButtonTheme;

    final double currentPositionSeconds =
        _currentPosition.inMilliseconds / 1000.0;

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
                    if (_playerTotalDuration.inMilliseconds > 0)
                      Text(
                        "Duration: ${_playerTotalDuration.inSeconds.toString()} seconds",
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
              if (_segmentResults.isNotEmpty &&
                  _playerTotalDuration.inMilliseconds > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LayoutBuilder(builder: (context, constraints) {
                      final double barWidth = constraints.maxWidth;
                      return GestureDetector(
                        onTapDown: (details) => _seekAudio(details, barWidth),
                        child: AudioClassificationBar(
                          segmentResults: _segmentResults,
                          totalDuration: _totalAudioDuration > 0
                              ? _totalAudioDuration
                              : _playerTotalDuration.inSeconds.toDouble(),
                          barHeight: 20.0,
                          currentPlaybackPosition: currentPositionSeconds,
                        ),
                      );
                    }),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 48.0,
                          onPressed: (_audioFile == null || _isPredicting)
                              ? null
                              : () {
                                  if (_isPlaying) {
                                    _audioPlayer.pause();
                                  } else {
                                    if (_currentPosition >=
                                        _playerTotalDuration) {
                                      _audioPlayer.seek(Duration.zero);
                                    }
                                    _audioPlayer.play(
                                        DeviceFileSource(_audioFile!.path));
                                  }
                                },
                          icon: Icon(
                            _isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: (_audioFile == null || _isPredicting)
                                ? Colors.grey
                                : Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          _formatDuration(_currentPosition),
                          style: textTheme.bodyMedium,
                        ),
                        Text(" / "),
                        Text(
                          _formatDuration(_playerTotalDuration),
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    _buildColorLegend(textTheme),
                  ],
                ),
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
        _buildLegendItem(Colors.grey, "No Voice / Skipped", textTheme),
        _buildLegendItem(Colors.deepOrange, "Processing Error", textTheme),
        Text(
          "\n(Color intensity indicates confidence)",
          style: textTheme.bodySmall!.copyWith(fontStyle: FontStyle.italic),
        ),
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

  List<Widget> _buildResultWidgets(TextTheme textTheme) {
    List<Widget> widgets = [];
    int voiceSegmentCount = 0;

    for (var i = 0; i < _segmentResults.length; i++) {
      final result = _segmentResults[i];
      final type = result['type'] ?? 'unknown';
      final status = result['status'] ?? 'unknown';
      final label = result['label'];
      final confidence = result['confidence'];
      final startTime = result['start_time'] as num? ?? 0.0;
      final endTime = result['end_time'] as num? ?? 0.0;

      String headerText;
      String resultDetails;

      if (type == 'voice' && status == 'success') {
        voiceSegmentCount++;
        headerText =
            'Voice Segment #$voiceSegmentCount (${startTime.toStringAsFixed(2)}s - ${endTime.toStringAsFixed(2)}s):';
        resultDetails = 'Classification: $label\nConfidence: $confidence';
      } else if (type == 'no_voice' && status == 'vad_skipped') {
        headerText =
            'Segment (${startTime.toStringAsFixed(2)}s - ${endTime.toStringAsFixed(2)}s):';
        resultDetails = result['message'] ?? "No voice detected.";
      } else if (status == 'error') {
        headerText =
            'Segment Error (${startTime.toStringAsFixed(2)}s - ${endTime.toStringAsFixed(2)}s):';
        resultDetails = result['message'] ?? "Processing failed.";
        if (label != null || confidence != null) {
          resultDetails += '\nLabel: $label, Confidence: $confidence';
        }
        if (result['confidence_score'] != null) {
          resultDetails +=
              '\nConfidence Score: ${result['confidence_score'].toStringAsFixed(2)}';
        }
      } else {
        headerText =
            'Unknown Segment Result (${startTime.toStringAsFixed(2)}s - ${endTime.toStringAsFixed(2)}s):';
        resultDetails = jsonEncode(result);
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                headerText,
                style: textTheme.titleMedium!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                resultDetails,
                style: textTheme.bodyMedium,
              ),
              if (i < _segmentResults.length - 1) const Divider(height: 15),
            ],
          ),
        ),
      );
    }
    if (_overallConclusion.isNotEmpty && !_isPredicting) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(
            _overallConclusion,
            style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return widgets;
  }
}
