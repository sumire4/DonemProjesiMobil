import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:donemprojesi/ekranlar/brief/chat_bubble.dart';
import 'package:donemprojesi/ekranlar/brief/chat_message.dart';

class BriefEkrani extends StatefulWidget {
  @override
  _BriefEkraniState createState() => _BriefEkraniState();
}

class _BriefEkraniState extends State<BriefEkrani> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeOpenAI();
  }

  Future<void> _initializeOpenAI() async {
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'API anahtarı bulunamadı!',
          isUser: false,
        ));
      });
      return;
    }

    OpenAI.apiKey = apiKey;
    await _getInitialF1Prediction();
  }

  Future<void> _getInitialF1Prediction() async {
    setState(() {
      _isLoading = true;
      _messages.add(ChatMessage(text: 'Analiz ediliyor...', isUser: false));
    });

    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);

      // F1 yarış takvimi JSON'u oku
      final calendarJson = await rootBundle.loadString('assets/f1_calendar.json');
      final calendar = jsonDecode(calendarJson) as List;

      final nextRace = calendar
          .map((e) => {
        "name": e["name"],
        "date": DateTime.parse(e["race_date"]),
      })
          .where((e) => e["date"].isAfter(now))
          .toList()
        ..sort((a, b) =>
            (a["date"] as DateTime).compareTo(b["date"] as DateTime));

      if (nextRace.isEmpty) {
        throw 'Gelecek yarış bulunamadı.';
      }

      final race = nextRace.first;
      final raceName = race["name"];
      final raceDate = DateFormat('yyyy-MM-dd – kk:mm').format(race["date"]);

      // Takım ve pilotları JSON'dan oku
      final teamsJson = await rootBundle.loadString('assets/f1_teams.json');
      final teamsData = jsonDecode(teamsJson) as Map<String, dynamic>;
      final teams = teamsData["teams"] as List;

      // Takım ve pilot listesini string haline getir
      String teamDriversInfo = "";
      for (var team in teams) {
        final teamName = team["name"];
        final drivers = (team["drivers"] as List).join(", ");
        teamDriversInfo += "$teamName: $drivers\n";
      }

      String greeting;
      final hour = now.hour;
      if (hour < 12) {
        greeting = 'Günaydın!';
      } else if (hour < 18) {
        greeting = 'İyi günler!';
      } else {
        greeting = 'İyi akşamlar!';
      }

      final prompt =
      '''
        $greeting Bugünün tarihi: $formattedDate
        
        Sıradaki Formula 1 yarışı: $raceName
        Yarış tarihi ve saati: $raceDate
        
        Güncel takım ve pilot kadrosu:
        $teamDriversInfo
        
        Lütfen bu yarış için bir sıralama tahmini yap. İlk 5'i yaz ve kazananı belirt.
        Tahminlerini pist yapısı, tarih, genel hava koşulları ve önceki performanslara göre açıkla.
       ''';

      final response = await OpenAI.instance.chat.create(
        model: "gpt-4",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
            ],
          ),
        ],
      );

      // content aslında List<OpenAIChatCompletionChoiceMessageContentItemModel> tipi
      final contentItems = response.choices.first.message.content;

      final contentText = contentItems
          ?.map((item) => item.text ?? '')
          .join('\n') ??
          '';

      setState(() {
        _isLoading = false;
        _messages.removeLast();
        _messages.add(ChatMessage(text: contentText, isUser: false));
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.removeLast();
        _messages.add(ChatMessage(text: 'Hata: $e', isUser: false));
      });
    } finally {
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _isLoading = true;
      _messages.add(ChatMessage(text: message, isUser: true));
      _messages.add(ChatMessage(text: 'Cevap bekleniyor...', isUser: false));
    });

    try {
      final response = await OpenAI.instance.chat.create(
        model: "gpt-4",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(message),
            ],
          ),
        ],
      );

      final contentItems = response.choices.first.message.content;
      final contentText = contentItems
          ?.map((item) => item.text ?? '')
          .join('\n') ??
          '';

      setState(() {
        _isLoading = false;
        _messages.removeWhere((m) => m.text == 'Cevap bekleniyor...');
        _messages.add(ChatMessage(text: contentText, isUser: false));
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.removeWhere((m) => m.text == 'Cevap bekleniyor...');
        _messages.add(ChatMessage(text: 'Hata oluştu: $e', isUser: false));
      });
    } finally {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
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
                return ChatBubble(message: _messages[index]);
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
                      hintText: 'ChatGPT\'ye soru sorun...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        final msg = value.trim();
                        _textController.clear();
                        _sendMessage(msg);
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final msg = _textController.text.trim();
                    if (msg.isNotEmpty) {
                      _textController.clear();
                      _sendMessage(msg);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    minimumSize: Size(64, 56),
                  ),
                  child: Text("Gönder"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
