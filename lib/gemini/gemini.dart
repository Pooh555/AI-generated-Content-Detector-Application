import 'dart:async';

import 'package:ai_generated_content_detector/keys.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart' as ai;

class GeminiPanel extends StatefulWidget {
  const GeminiPanel({super.key, required String title});

  @override
  State<GeminiPanel> createState() => _GeminiPanelState();
}

class _GeminiPanelState extends State<GeminiPanel> {
  List<ai.Content> history = [];
  late final ai.GenerativeModel _model;
  late final ai.ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  bool _loading = false;

  bool _showWarning = true;
  late Timer _timer;

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _model = ai.GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
    _chat = _model.startChat();

    _timer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _showWarning = false;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Medical Friend'),
      ),
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 90),
            itemCount: history.reversed.length,
            controller: _scrollController,
            reverse: true,
            itemBuilder: (context, index) {
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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        history.add(ai.Content(
                            'user', [ai.TextPart(_textController.text)]));
                      });
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
        ],
      ),
    );
  }

  Future<void> _sendChatMessage(String message, int historyIndex) async {
    setState(() {
      _loading = true;
      _textController.clear();
      _textFieldFocus.unfocus();
      _scrollDown();
    });

    List<ai.Part> parts = [];

    try {
      var response = _chat.sendMessageStream(
        ai.Content.text(message),
      );
      await for (var item in response) {
        var text = item.text;
        if (text == null) {
          _showError('No response from API.');
          return;
        } else {
          setState(() {
            _loading = false;
            parts.add(ai.TextPart(text));
            if ((history.length - 1) == historyIndex) {
              history.removeAt(historyIndex);
            }
            history.insert(historyIndex, ai.Content('model', parts));
          });
        }
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

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
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
}

class MessageTile extends StatelessWidget {
  final bool sendByMe;
  final String message;

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
