import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:ai_generated_content_detector/detect_image/text.dart';
import 'package:ai_generated_content_detector/home/carousel.dart';
import 'package:ai_generated_content_detector/keys.dart';
import 'package:ai_generated_content_detector/themes/path.dart';
import 'package:ai_generated_content_detector/themes/template.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class FaceBoxPainter extends CustomPainter {
  final ui.Image? image;
  final List<Map<String, dynamic>>? results;
  final BoxFit fit;
  final Size widgetSize;

  FaceBoxPainter({
    required this.image,
    required this.results,
    required this.fit,
    required this.widgetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null || results == null || results!.isEmpty) {
      return;
    }

    final imageSize = Size(image!.width.toDouble(), image!.height.toDouble());
    final FittedSizes fittedSizes = applyBoxFit(fit, imageSize, widgetSize);
    final Size sourceSize = fittedSizes.source;
    final Size destinationSize = fittedSizes.destination;

    if (destinationSize.width <= 0 || destinationSize.height <= 0) {
      return;
    }

    final double scale = destinationSize.width / sourceSize.width;
    final double offsetX = (widgetSize.width - destinationSize.width) / 2;
    final double offsetY = (widgetSize.height - destinationSize.height) / 2;

    final Paint boxPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    int faceCount = 0;

    for (var i = 0; i < results!.length; i++) {
      final result = results![i];
      final type = result['type'] ?? 'unknown';

      if (type == 'face') {
        final box = result['box'];
        if (box != null && box is List && box.length == 4) {
          try {
            final double x1 = (box[0] as num).toDouble();
            final double y1 = (box[1] as num).toDouble();
            final double x2 = (box[2] as num).toDouble();
            final double y2 = (box[3] as num).toDouble();

            final double displayX1 = offsetX + x1 * scale;
            final double displayY1 = offsetY + y1 * scale;
            final double displayX2 = offsetX + x2 * scale;
            final double displayY2 = offsetY + y2 * scale;

            canvas.drawRect(
              Rect.fromLTRB(displayX1, displayY1, displayX2, displayY2),
              boxPaint,
            );

            faceCount++;
            final textSpan = TextSpan(
              text: '$faceCount',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black54,
              ),
            );
            final textPainter = TextPainter(
              text: textSpan,
              textDirection: TextDirection.ltr,
            );
            textPainter.layout();

            final textX = displayX1 + 5;
            final textY = displayY1 + 5;

            final adjustedTextX =
                textX < widgetSize.width - textPainter.width - 5
                    ? textX
                    : widgetSize.width - textPainter.width - 5;
            final adjustedTextY =
                textY < widgetSize.height - textPainter.height - 5
                    ? textY
                    : widgetSize.height - textPainter.height - 5;

            final finalTextX = adjustedTextX > 0 ? adjustedTextX : 0.0;
            final finalTextY = adjustedTextY > 0 ? adjustedTextY : 0.0;

            canvas.save();
            canvas.translate(finalTextX, finalTextY);
            textPainter.paint(canvas, Offset.zero);
            canvas.restore();
          } catch (e) {
            print("Error drawing box or text for a face: $e");
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is FaceBoxPainter &&
        (oldDelegate.results != results ||
            oldDelegate.image != image ||
            oldDelegate.widgetSize != widgetSize ||
            oldDelegate.fit != fit);
  }
}

class DetectImage extends StatefulWidget {
  const DetectImage({super.key, required this.title});
  final String title;

  @override
  State<DetectImage> createState() => _DetectImageState();
}

class _DetectImageState extends State<DetectImage> {
  File? _imageFile;
  ui.Image? _originalImage;
  Size _imageSize = Size.zero;

  List<Map<String, dynamic>> _predictionResults = [];
  String _statusMessage = "";
  bool _isPredicting = false;

  final BoxFit _imageFit = BoxFit.contain;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final ByteData bytes = await imageFile
          .readAsBytes()
          .then((byteList) => ByteData.view(byteList.buffer));
      final ui.Codec codec =
          await ui.instantiateImageCodec(bytes.buffer.asUint8List());
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image originalImage = frameInfo.image;

      setState(() {
        _imageFile = imageFile;
        _originalImage = originalImage;
        _imageSize = Size(
            originalImage.width.toDouble(), originalImage.height.toDouble());
        _predictionResults = [];
        _statusMessage = "";
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isPredicting = true;
      _predictionResults = [];
      _statusMessage = "Analyzing image...";
    });

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse("$serverAddress:5000/classify_image"));
      request.files
          .add(await http.MultipartFile.fromPath('image', _imageFile!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final responseBody = json.decode(response.body);

      if (responseBody['status'] == 'success') {
        setState(() {
          _predictionResults = (responseBody['results'] as List<dynamic>?)
                  ?.map((item) => item as Map<String, dynamic>)
                  .toList() ??
              [];

          _statusMessage = responseBody['message'] ?? "Analysis complete.";
          _isPredicting = false;
        });
      } else {
        setState(() {
          _statusMessage =
              "Error: ${responseBody['message'] ?? 'Unknown error'}";
          _predictionResults = [];
          _isPredicting = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Error: ${e.toString()}";
        _predictionResults = [];
        _isPredicting = false;
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IntroductionText(),
              SizedBox(height: 15),
              CarouselPanel(
                carouselImages: detectImageCarouselImagesPaths,
              ),
              SizedBox(height: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
              if (_imageFile != null && _originalImage != null)
                LayoutBuilder(builder: (context, constraints) {
                  final FittedSizes fittedSizes = applyBoxFit(
                    _imageFit,
                    _imageSize,
                    Size(constraints.maxWidth, constraints.maxHeight),
                  );
                  final Size renderedSize = fittedSizes.destination;

                  return Container(
                    width: constraints.maxWidth,
                    height:
                        renderedSize.height > 0 ? renderedSize.height : null,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.file(
                          _imageFile!,
                          fit: _imageFit,
                          width: constraints.maxWidth,
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: FaceBoxPainter(
                              image: _originalImage,
                              results: _predictionResults,
                              fit: _imageFit,
                              widgetSize: Size(
                                  constraints.maxWidth, renderedSize.height),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                })
              else
                NoSelectedImageText(),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed:
                      _imageFile == null || _isPredicting ? null : _uploadImage,
                  child: _isPredicting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : UploadImageText(title: "Analyze Image")),
              const SizedBox(height: 20),
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    _statusMessage,
                    style: textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_predictionResults.isNotEmpty && !_isPredicting)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _predictionResults.length == 1 &&
                                _predictionResults[0]['type'] == 'entire_image'
                            ? "Analysis Result:"
                            : "Analysis Results:",
                        style: textTheme.titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ..._buildResultWidgets(textTheme),
                  ],
                ),
              if (!_isPredicting &&
                  _imageFile == null &&
                  _predictionResults.isEmpty &&
                  _statusMessage.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Select an image to analyze AI-generated content.',
                    style: textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ));
  }

  List<Widget> _buildResultWidgets(TextTheme textTheme) {
    List<Widget> widgets = [];
    int faceCount = 0;

    for (var i = 0; i < _predictionResults.length; i++) {
      final result = _predictionResults[i];
      final type = result['type'] ?? 'unknown';
      final label = result['label'] ?? 'N/A';
      final confidence = result['confidence'] ?? 'N/A';

      String headerText;
      String resultDetails;

      if (type == 'face') {
        faceCount++;
        headerText = 'Face #$faceCount:';
        resultDetails = 'Classification: $label\nConfidence: $confidence';
      } else if (type == 'entire_image') {
        headerText = 'Entire Image Analysis:';
        resultDetails = 'Classification: $label\nConfidence: $confidence';
      } else {
        String status = result['status'] ?? 'unknown';
        String message = result['message'] ?? 'No message';
        headerText = '$type Result ($status):';
        resultDetails = 'Message: $message';
        if (label != 'N/A' || confidence != 'N/A') {
          resultDetails += '\nLabel: $label, Confidence: $confidence';
        }
        if (result['box'] != null) {
          resultDetails += '\nBox: ${result['box']}';
        }
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                headerText,
                style: textTheme.titleMedium!
                    .copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              Text(
                resultDetails,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (i < _predictionResults.length - 1) const Divider(height: 15),
            ],
          ),
        ),
      );
    }
    return widgets;
  }
}
