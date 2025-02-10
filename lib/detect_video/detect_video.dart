import 'dart:io';

import 'package:ai_generated_content_detector/detect_video/text.dart';
import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';

class DetectVideo extends StatefulWidget {
  const DetectVideo({super.key, required this.title});
  final String title;

  @override
  State<DetectVideo> createState() => _DetectVideoState();
}

class _DetectVideoState extends State<DetectVideo> {
  VideoPlayerController? _controller; // Make controller nullable
  File? _videoFile;

  @override
  void initState() {
    super.initState();
    // Initialize with a direct video URL instead of YouTube
    _initializeController(
      VideoPlayerController.networkUrl(
        Uri.parse(
            "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
      ),
    );
  }

  void _initializeController(VideoPlayerController newController) {
    if (_controller != null) {
      _controller!.dispose(); // Dispose old controller
    }
    _controller = newController;
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
        // Initialize controller with local file
        _initializeController(
          VideoPlayerController.file(_videoFile!),
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
      appBar: MyAppbar(title: "Analyze Video"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: _controller != null && _controller!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : const CircularProgressIndicator(),
            ),
            ElevatedButton(
              onPressed: () => _pickVideo(ImageSource.gallery),
              style: elevatedButtonThemeData.style,
              child: const UploadVideoText(title: "Upload a Video"),
            ),
            if (_videoFile != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Video Path: ${_videoFile!.path}",
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
