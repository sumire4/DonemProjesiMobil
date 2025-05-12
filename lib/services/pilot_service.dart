import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pilot_model.dart';

class PilotService {
  static List<PilotModel>? _cache;

  static const String _url = 'https://f1-motorsport-data.p.rapidapi.com/standings-drivers?year=2025';
  static const Map<String, String> _headers = {
    'X-RapidAPI-Key': 'deneme',
    'X-RapidAPI-Host': 'f1-motorsport-data.p.rapidapi.com',
  };

  static Future<List<PilotModel>> getirPilotSiralama() async {
    // Bellekte varsa tekrar istek atma
    if (_cache != null) return _cache!;

    final response = await http.get(Uri.parse(_url), headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      // Null kontrolü
      if (data['standings'] == null || data['standings']['entries'] == null) {
        throw Exception('API yanıtı beklenmedik formatta: standings null');
      }

      final standings = data['standings'];
      final List<dynamic> entries = standings['entries'];

      _cache = entries.map((entry) => PilotModel.fromJson(entry)).toList();
      return _cache!;
    } else {
      throw Exception('Pilot verisi alınamadı: ${response.statusCode}');
    }
  }
}
