import 'package:ai_generated_content_detector/detect_text/text.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';
import 'package:flutter/material.dart';

class InputTextField extends StatefulWidget {
  const InputTextField({super.key, required this.controller});
  final TextEditingController controller;

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  int _currentLines = 5;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _currentLines = widget.controller.text.split('\n').length;
    if (_currentLines < 5) _currentLines = 5;
    if (_currentLines > maxTextLine) {
      _currentLines = maxTextLine;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    int newLines = widget.controller.text.split('\n').length;

    if (newLines != _currentLines) {
      if (newLines < 5) {
        setState(() {
          _currentLines = 5;
        });
      } else if (newLines > maxTextLine) {
      } else {
        setState(() {
          _currentLines = newLines;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: widget.controller,
          maxLength: maxTextLength,
          maxLines: _currentLines > maxTextLine ? maxTextLine : _currentLines,
          minLines: 5,
          expands: false,
          style: textTheme.bodySmall,
          decoration: InputDecoration(
            fillColor: colorScheme.secondary,
            filled: true,
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
      ],
    );
  }
}
