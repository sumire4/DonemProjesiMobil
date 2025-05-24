import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/yaris_model.dart';

class YarisService {
  static Future<List<YarisModel>> getirGecmisYarislar() async {
    final url = Uri.parse('https://f1-motorsport-data.p.rapidapi.com/current-scoreboard');
    final response = await http.get(
      url,
      headers: {
        'X-RapidAPI-Key': ' ',
        'X-RapidAPI-Host': 'f1-motorsport-data.p.rapidapi.coms',
      },
    );

    if (response.statusCode == 200) {
      final List races = jsonDecode(response.body)['response'];
      return races.map((race) => YarisModel.fromJson(race)).toList();
    } else {
      throw Exception('API bağlantı hatası: ${response.statusCode}');
    }
  }
}
