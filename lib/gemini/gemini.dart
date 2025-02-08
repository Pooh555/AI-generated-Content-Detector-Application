import 'dart:async';

import 'package:ai_generated_content_detector/keys.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as ai;

class GeminiPanel extends StatefulWidget {
  const GeminiPanel({super.key, required String title});

  @override
  State<GeminiPanel> createState() => _GeminiPanelState();
}

// Define the State class for GeminiPanel
class _GeminiPanelState extends State<GeminiPanel> {
  // Declare necessary variables
  List<ai.Content> history = []; // List to store chat history
  late final ai.GenerativeModel _model; // Instance of GenerativeModel
  late final ai.ChatSession _chat; // Instance of ChatSession
  final ScrollController _scrollController =
      ScrollController(); // Controller for scrolling
  final TextEditingController _textController =
      TextEditingController(); // Controller for text input field
  final FocusNode _textFieldFocus =
      FocusNode(); // Focus node for text input field
  bool _loading = false; // Flag to indicate if chat is loading

  // State variables for warning message visibility and timer
  bool _showWarning = true;
  late Timer _timer;

  // Function to scroll to the bottom of the chat history
  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  // Initialization method for the state
  @override
  void initState() {
    super.initState();
    // Initialize GenerativeModel with specified model and API key
    _model = ai.GenerativeModel(
      model: 'gemini-pro', // model name
      apiKey: apiKey,
    );
    // Start a new chat session using the initialized model
    _chat = _model.startChat();

    // Start timer to hide warning after 5 seconds
    _timer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _showWarning = false;
      });
    });
  }

  // Dispose method to cancel timer
  @override
  void dispose() {
    _timer.cancel(); // Cancel timer to avoid memory leaks
    super.dispose();
  }

  // Build method to create the UI for the GeminiPanel
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Medical Friend'), // App bar title
      ),
      body: Stack(
        children: [
          // Widget to display chat history in a scrollable list
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 90),
            itemCount: history.reversed.length,
            controller: _scrollController,
            reverse: true,
            itemBuilder: (context, index) {
              // Build each chat message tile based on history
              var content = history.reversed.toList()[index];
              var text = content.parts
                  .whereType<ai.TextPart>()
                  .map<String>((e) => e.text)
                  .join('');
              return MessageTile(
                sendByMe: content.role == 'user',
                message: text,
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 15,
              );
            },
          ),
          // Widget for the input area at the bottom of the screen
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                  color: colorScheme.error,
                  border: Border(top: BorderSide(color: colorScheme.error))),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: TextField(
                        controller: _textController,
                        autofocus: true,
                        focusNode: _textFieldFocus,
                        decoration: InputDecoration(
                            hintText: 'Ask me anything...',
                            hintStyle: TextStyle(color: colorScheme.error),
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10.0))),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  // Send button to send chat message
                  GestureDetector(
                    onTap: () {
                      // Update UI state to add user message to history
                      setState(() {
                        history.add(ai.Content(
                            'user', [ai.TextPart(_textController.text)]));
                      });
                      // Call method to send user message and handle response
                      _sendChatMessage(_textController.text, history.length);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, boxShadow: [
                        BoxShadow(
                            offset: const Offset(1, 1),
                            blurRadius: 0,
                            spreadRadius: 5,
                            color: colorScheme.error)
                      ]),
                      child: _loading
                          ? const Center(
                              child: CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.send_rounded,
                              color: colorScheme.error,
                            ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // Positioned widget for warning message
          Positioned(
            top: 5,
            left: 18,
            child: Visibility(
              visible: _showWarning,
              // child: buildWarningChatUsage(375.0, 75.0), // Commented out undefined method call
              child:
                  Container(), // Replaced with an empty Container to avoid error, consider implementing or removing this section completely
            ),
          ),
        ],
      ),
    );
  }

  // Function to send user message and process response
  Future<void> _sendChatMessage(String message, int historyIndex) async {
    // Update UI state to indicate loading state
    setState(() {
      _loading = true;
      _textController.clear(); // Clear text input field
      _textFieldFocus.unfocus(); // Unfocus text input field
      _scrollDown(); // Scroll to bottom of chat history
    });

    List<ai.Part> parts = []; // List to store parts of chat response

    try {
      // Send user message to chat session and await response
      var response = _chat.sendMessageStream(
        ai.Content.text(message),
      );
      await for (var item in response) {
        var text = item.text;
        if (text == null) {
          _showError('No response from API.'); // Show error if no response
          return;
        } else {
          // Update UI state to add model response to chat history
          setState(() {
            _loading = false;
            parts.add(ai.TextPart(text)); // Add text part to response parts
            if ((history.length - 1) == historyIndex) {
              history.removeAt(historyIndex); // Remove old history entry
            }
            history.insert(historyIndex,
                ai.Content('model', parts)); // Insert updated history entry
          });
        }
      }
    } catch (e) {
      _showError(e.toString()); // Show error if exception occurs
      setState(() {
        _loading = false;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Function to show error dialog
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
}

// Widget class for displaying chat message tile
class MessageTile extends StatelessWidget {
  final bool sendByMe; // Flag to indicate if message is sent by user
  final String message; // Content of the message

  const MessageTile({super.key, required this.sendByMe, required this.message});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: sendByMe ? colorScheme.error : colorScheme.error,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: sendByMe ? Colors.white : Colors.black,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }
}
