import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/takim_model.dart';

class TakimService {
  static const String _url = 'https://f1-motorsport-data.p.rapidapi.com/standings-controllers?year=2025';
  static const Map<String, String> _headers = {
    'X-RapidAPI-Key': ' ',
    'X-RapidAPI-Host': 'f1-motorsport-data.p.rapidapi.com',
  };

  static Future<List<TakimModel>> getirTakimSiralama() async {
    final response = await http.get(Uri.parse(_url), headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      final standings = data['standings'];
      final List<dynamic> entries = standings['entries'];

      return entries.map((entry) => TakimModel.fromJson(entry)).toList();
    } else {
      throw Exception('Takım verisi alınamadı: ${response.statusCode}');
    }
  }
}
