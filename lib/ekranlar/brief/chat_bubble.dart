import 'package:flutter/material.dart';
import 'package:donemprojesi/ekranlar/brief/chat_message.dart';// ChatMessage'ı import edin

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        decoration: BoxDecoration(
          color: message.isUser
              ? Colors.blue[100] // Kullanıcı mesajları için açık mavi
              : Colors.grey[200], // Sistem mesajları için açık gri
          borderRadius: BorderRadius.circular(16), // Yuvarlak köşeler
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 14,
            color: message.isUser ? Colors.black : Colors.black87, // Metin rengi
          ),
        ),
      ),
    );
  }
}
