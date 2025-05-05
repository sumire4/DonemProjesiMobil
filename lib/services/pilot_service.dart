import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pilot_model.dart';
class PilotService {
  static Future<List<PilotModel>> getirSurucuSiralama() async {
    const url = 'https://f1-motorsport-data.p.rapidapi.com/standings-drivers?year=2025';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'x-rapidapi-host': 'f1-motorsport-data.p.rapidapi.com',
        'x-rapidapi-key': 'deneme', // Kendi API key'in
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // entries içinde sürücü sıralamalarını alıyoruz
      final entries = body['standings']?['entries'];
      if (entries == null || entries is! List) {
        print('Veri tipi yanlış veya eksik: ${entries.runtimeType}');
        throw Exception('Beklenen "entries" listesi gelmedi.');
      }

      return entries.map<PilotModel>((entry) {
        return PilotModel(
          isim: entry['athlete']?['name'] ?? 'Bilinmiyor',
          takim: entry['athlete']?['flag']?['alt'] ?? 'Bilinmiyor', // Bayrak altındaki ülke ismi kullanılıyor
          pozisyon: entry['stats']?[0]['value'] ?? 0,  // Rank değeri
        );
      }).toList();
    } else {
      throw Exception('RapidAPI verisi alınamadı: ${response.statusCode}');
    }
  }
}
