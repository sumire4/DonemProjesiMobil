import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pilot_model.dart';

class PilotService {
  static List<PilotModel>? _cache;

  static const String _url = 'https://f1-motorsport-data.p.rapidapi.com/standings-drivers?year=2025';
  static const Map<String, String> _headers = {
    'X-RapidAPI-Key': ' ',
    'X-RapidAPI-Host': 'f1-motorsport-data.p.rapidapi.com',
  };

  static Future<List<PilotModel>> getirPilotSiralama() async {
    if (_cache != null) return _cache!;

    final response = await http.get(Uri.parse(_url), headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final standings = data['standings'] as Map<String, dynamic>?;

      if (standings == null) {
        throw Exception('API yanıtı beklenmedik formatta: standings null');
      }

      final List<dynamic>? entries = standings['entries'] as List<dynamic>?;

      if (entries == null) {
        throw Exception('API yanıtı beklenmedik formatta: entries null');
      }

      _cache = entries.map((entry) => PilotModel.fromJson(entry)).toList();
      return _cache!;
    } else {
      throw Exception('Pilot verisi alınamadı: ${response.statusCode}');
    }
  }
}
