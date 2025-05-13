import 'package:ai_generated_content_detector/detect_text/text.dart';
import 'package:ai_generated_content_detector/themes/varaibles.dart';
import 'package:flutter/material.dart';

class InputTextField extends StatefulWidget {
  // --- Corrected Constructor ---
  // Make 'controller' a required named parameter using {} and 'this.'
  const InputTextField({super.key, required this.controller});

  // --- Add the controller as an instance variable ---
  final TextEditingController controller;

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  // Remove the declaration here, we will use widget.controller
  // late TextEditingController _controller;

  int _currentLines = 5;

  @override
  void initState() {
    super.initState();
    // Use the controller passed from the parent via widget.controller
    // Remove: _controller = TextEditingController();
    widget.controller.addListener(_onTextChanged);
    // Initialize _currentLines based on the initial text in the controller
    _currentLines = widget.controller.text.split('\n').length;
    if (_currentLines < 5) _currentLines = 5; // Ensure minimum 5 lines
    if (_currentLines > maxTextLine)
      _currentLines = maxTextLine; // Ensure max lines
  }

  @override
  void dispose() {
    // Remove listener from the parent's controller
    widget.controller.removeListener(_onTextChanged);
    // Do NOT dispose the controller here, the parent (DetectTextState) owns it.
    // Remove: _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Use the controller passed from the parent via widget.controller
    int newLines = widget.controller.text.split('\n').length;

    // Only call setState if the number of lines changes and is within bounds
    if (newLines != _currentLines) {
      if (newLines < 5) {
        setState(() {
          _currentLines = 5;
        });
      } else if (newLines > maxTextLine) {
        // Stay at maxTextLine, no setState needed if already there
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
          // --- Use the controller passed from the parent ---
          controller: widget.controller,
          // ------------------------------------------------
          maxLength: maxTextLength,
          // maxLines should react to _currentLines, but also respect the overall limit
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
        // --- Remove the redundant button from here ---
        // SizedBox(height: 5),
        // Align(
        //   alignment: Alignment.center,
        //   child: ElevatedButton(
        //     onPressed: () {
        //       String text = _controller.text;
        //       // TODO: Send th message the the server
        //       // print('Submitted: $text');
        //     },
        //     child: UploadTextText(title: "See the result"),
        //   ),
        // ),
        // --------------------------------------------
      ],
    );
  }
}
