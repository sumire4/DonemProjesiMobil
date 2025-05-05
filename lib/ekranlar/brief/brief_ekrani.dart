import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:donemprojesi/ekranlar/brief/chat_bubble.dart';
import 'package:donemprojesi/ekranlar/brief/chat_message.dart';

class BriefEkrani extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<BriefEkrani> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  late GenerativeModel _model;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  // Uygulamanın başlatılması için gerekli işlemler
  Future<void> _setup() async {
    await _initializeModel();
    _getInitialF1Prediction();
  }

  // Modeli başlatma
  Future<void> _initializeModel() async {
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey != null) {
      try {
        _model = GenerativeModel(model: 'gemini-2.5-pro-exp-03-25', apiKey: apiKey);
        print("Gemini API başarıyla başlatıldı!");
      } catch (e) {
        print("Gemini API başlatılamadı: $e");
        setState(() {
          _messages.add(ChatMessage(text: 'API başlatılamadı: $e', isUser: false));
        });
      }
    } else {
      print("API anahtarı bulunamadı.");
      setState(() {
        _messages.add(ChatMessage(text: 'API anahtarı bulunamadı!', isUser: false));
      });
    }
  }

  // F1 tahmini almak için yapılan başlangıç fonksiyonu
  Future<void> _getInitialF1Prediction() async {
    if (_model == null) return;

    setState(() {
      _isLoading = true;
      _messages.add(ChatMessage(text: 'Analiz Ediliyor...', isUser: false));
    });

    try {
      final response = await _model.generateContent([
        Content.text(
            'Önümüzdeki Formula 1 yarışı için bir sıralama tahmini yapar mısın? '
                'Nedenlerini hava durumu pist zemin sıcaklığı ve yapısını dikkate alarak ve gelecek yarışı npistinin adını anarak '
                'kısaca açıkla. Satırın başında günün saatine göre günaydın iyi günler iyi akşamlar vs ekle'
                '(Uygulama açılınca ilk prompt olacak harika soru vs şeyler yazma, '
                'kısaca ilk 5e kim girer ve sence kim kazanır onu söyle.)')
      ]);

      setState(() {
        _isLoading = false;
        _messages.removeLast(); // "Tahminler alınıyor..." mesajını sil
        String? receivedText;

        if (response?.candidates != null &&
            response!.candidates!.isNotEmpty &&
            response.candidates!.first.content.parts.isNotEmpty &&
            response.candidates!.first.content.parts.first is TextPart) {
          receivedText =
              (response.candidates!.first.content.parts.first as TextPart).text;
        }

        if (receivedText != null) {
          _messages.add(ChatMessage(text: receivedText, isUser: false));
        } else {
          _messages.add(ChatMessage(
              text: 'Tahmin alınırken bir hata oluştu veya cevap boş geldi.',
              isUser: false));
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.removeLast(); // "Tahminler alınıyor..." mesajını sil
        _messages.add(ChatMessage(text: 'Hata: $e', isUser: false));
      });
    } finally {
      _scrollToBottom();
    }
  }

  // Kullanıcıdan gelen mesajı işlemek
  Future<void> _sendMessage(String message) async {
    if (_model == null || message.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
      _messages.add(ChatMessage(text: 'Cevap bekleniyor...', isUser: false));
      _textController.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await _model.generateContent([Content.text(message)]);
      setState(() {
        _isLoading = false;
        _messages.removeLast(); // "Cevap bekleniyor..." mesajını sil

        // İlk olarak parts listesindeki öğeyi kontrol et
        final firstPart = response.candidates?.first.content.parts.first;

        // Eğer firstPart bir TextPart ise, text özelliğine ulaşabiliriz
        String? text;
        if (firstPart is TextPart) {
          text = firstPart.text;
        }

        if (text != null) {
          _messages.add(ChatMessage(text: text, isUser: false));
        } else {
          _messages.add(ChatMessage(
              text: 'Cevap alınırken bir hata oluştu.', isUser: false));
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.removeLast(); // "Cevap bekleniyor..." mesajını sil
        _messages.add(ChatMessage(text: 'Hata: $e', isUser: false));
      });
    } finally {
      _scrollToBottom();
    }
  }

  // Sayfanın en altına kaydırma işlemi
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),
          if (_isLoading) LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      filled: true, // Arka plan rengini belirler
                      fillColor: Colors.white, // Arka plan rengi
                      hintText: 'Gemini\'ye soru sorun...',
                      hintStyle: TextStyle(color: Colors.grey[500]), // Hint text rengi
                      labelStyle: TextStyle(color: Colors.black), // Etiket rengi
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16), // Köşe yuvarlama
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2), // Focused border
                        borderRadius: BorderRadius.circular(16), // Köşe yuvarlama
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1), // Varsayılan border
                        borderRadius: BorderRadius.circular(16), // Köşe yuvarlama
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _sendMessage(value.trim());
                      }
                    },
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onPressed: () {
                    if (_textController.text.trim().isNotEmpty) {
                      _sendMessage(_textController.text.trim());
                    }
                  },
                  child: Text('Gönder'),
                ),
              ],
            ),
          )

        ],
      ),
    );
  }
}
