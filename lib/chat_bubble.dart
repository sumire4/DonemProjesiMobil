import 'package:flutter/material.dart';
import 'chat_message.dart'; // ChatMessage'ı import edin

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(message.text),
      ),
    );
  }
}