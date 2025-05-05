import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/takim_model.dart';

class TakimService {
  static Future<List<TakimModel>> getirTakimSiralama() async {
    final url = Uri.parse('https://f1-motorsport-data.p.rapidapi.com/standings-controllers?year=2025');
    final response = await http.get(
      url,
      headers: {
        'x-rapidapi-host': 'f1-motorsport-data.p.rapidapi.com',
        'x-rapidapi-key': 'deneme', // Buraya kendi API anahtarınızı eklemelisiniz
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final standingsData = jsonBody['standings']['entries'];

      // JSON'dan gelen veriyi listeye dönüştür
      return standingsData
          .map<TakimModel>((entry) => TakimModel.fromJson(entry))
          .toList();
    } else {
      throw Exception('Takım sıralamaları alınırken hata oluştu');
    }
  }
}
