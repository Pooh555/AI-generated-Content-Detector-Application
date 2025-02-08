import 'dart:convert';
import 'dart:io';
import 'package:ai_generated_content_detector/detect_image/text.dart';
import 'package:ai_generated_content_detector/home/carousel.dart';
import 'package:ai_generated_content_detector/themes/path.dart';
import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class DetectImage extends StatefulWidget {
  const DetectImage({super.key, required this.title});
  final String title;

  @override
  State<DetectImage> createState() => _DetectImageState();
}

class _DetectImageState extends State<DetectImage> {
  File? _image; // Store the picked image file
  String _predictionResult = ""; // Store the prediction result (label)
  String _predictionConfidence = ""; // Store the prediction confidence
  bool _isPredicting = false; // Track prediction state

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _predictionResult = ""; // Clear previous result
        _predictionConfidence = ""; // Clear previous confidence
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isPredicting = true; // Set predicting state to true
      _predictionResult = "Predicting..."; // Show "Predicting..." message
      _predictionConfidence = ""; // Clear confidence while predicting
    });

    try {
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'http://172.30.45.80:5000/classify_image')); // Server IP address
      request.files.add(await http.MultipartFile.fromPath(
          'image', _image!.path)); // 'image' key must match Flask endpoint

      var streamedResponse =
          await request.send(); // Send the request as a stream
      var response = await http.Response.fromStream(
          streamedResponse); // Convert streamed response to Response

      if (response.statusCode == 200) {
        final responseData =
            json.decode(response.body)['result']; // Extract 'result' dictionary
        setState(() {
          _predictionResult = responseData['label']; // Get label
          _predictionConfidence = responseData['confidence']; // Get confidence
          _isPredicting = false; // Set predicting state to false
        });
      } else {
        setState(() {
          _predictionResult = "Error: ${response.statusCode}";
          _predictionConfidence = ""; // Clear confidence on error
          _isPredicting = false; // Set predicting state to false
        });
      }
    } catch (e) {
      setState(() {
        _predictionResult = "Error: ${e.toString()}";
        _predictionConfidence = ""; // Clear confidence on exception
        _isPredicting = false; // Set predicting state to false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ElevatedButtonThemeData elevatedButtonThemeData =
        Theme.of(context).elevatedButtonTheme;

    return Scaffold(
        appBar: MyAppbar(title: "Analyze Image"),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(screenBorderMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IntroductionText(),
              SizedBox(height: 15),
              CarouselPanel(
                carouselImages: detectImageCarouselImagesPaths,
              ),
              SizedBox(height: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      style: elevatedButtonThemeData.style,
                      child: UploadImageText(title: "Upload an Image")),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    child: UploadImageText(title: "Take a Photo"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _image == null ? NoSelectedImageText() : Image.file(_image!),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed:
                      _image == null || _isPredicting ? null : _uploadImage,
                  child: _isPredicting
                      ? const CircularProgressIndicator()
                      : UploadImageText(title: "Analyze Image")),
              const SizedBox(height: 20),
              Text(
                _predictionResult.isNotEmpty
                    ? "This image is generated by"
                    : '',
                style: textTheme.headlineMedium,
              ),
              Text(
                _predictionResult.isNotEmpty
                    ? _predictionResult
                    : _predictionResult,
                style: textTheme.headlineLarge,
              ),
              Text(
                _predictionResult.isNotEmpty
                    ? "(Confidence: $_predictionConfidence)"
                    : _predictionResult,
                style: textTheme.headlineSmall,
              ),
            ],
          ),
        ));
  }
}
