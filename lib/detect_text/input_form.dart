import 'package:ai_generated_content_detector/themes/varaibles.dart';
import 'package:flutter/material.dart';

class InputTextField extends StatefulWidget {
  const InputTextField({super.key});

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  late TextEditingController _controller;
  int _currentLines = 5;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    int newLines = _controller.text.split('\n').length;

    if (newLines > _currentLines && newLines <= maxTextLine) {
      setState(() {
        _currentLines = newLines;
      });
    } else if (newLines < 5) {
      setState(() {
        _currentLines = 5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accessing the custom TextTheme from the app's theme
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(screenBorderMargin),
          child: TextField(
            controller: _controller,
            maxLength: maxTextLength,
            maxLines: _currentLines,
            minLines: 5,
            expands: false,
            style: textTheme.bodySmall,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1.25,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: colorScheme.outline,
                ),
              ),
              hintText: "Enter your text here...",
              hintStyle: textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic, color: colorScheme.onSecondary),
              alignLabelWithHint: true,
            ),
          ),
        ),
      ],
    );
  }
}
