import 'dart:io';

import 'package:ai_generated_content_detector/detect_audio/text.dart';
import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class DetectAudio extends StatefulWidget {
  const DetectAudio({super.key, required this.title});
  final String title;

  @override
  State<DetectAudio> createState() => _DetectAudioState();
}

class _DetectAudioState extends State<DetectAudio> {
  VideoPlayerController? _controller;
  File? _videoFile;
  String videoTitle = "Big Bunny Tells a Story";
  String videoDesc = "Human-generated audio";
  String noVideoSelectedText = "No Audio selected";
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
  }

  void _initializeController(VideoPlayerController newController) {
    if (_controller != null) {
      _controller!.dispose();
    }
    _controller = newController;
    _controller!.setLooping(true);
    _controller!.initialize().then((_) {
      setState(() {
        _controller!.play();
      });
    });
  }

  Future<void> _pickVideo(ImageSource source) async {
    final pickedFile = await ImagePicker().pickVideo(source: source);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
        videoTitle = '';
        videoDesc = '';
        noVideoSelectedText = "A video is uploaded.";

        _initializeController(
          VideoPlayerController.file(
            _videoFile!,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
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
            children: [
              IntroductionText(),
              SizedBox(height: 15),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Center(
                  child: _controller != null && _controller!.value.isInitialized
                      ? Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
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
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 11.75),
                              child: Column(
                                children: [
                                  Text(
                                    videoTitle,
                                    style: textTheme.displayMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    videoDesc,
                                    style: textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => _pickVideo(ImageSource.gallery),
                style: elevatedButtonThemeData.style,
                child: const UploadAudioText(title: "Upload an Audio"),
              ),
              SizedBox(height: 15),
              NoSelectedAudioText(title: noVideoSelectedText),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  // TODO: Send the video the the server
                  // print('Submitted: $video');
                },
                child: UploadAudioText(title: "Check your Audio"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
