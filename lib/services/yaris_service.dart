import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pilot_model.dart';
import '../models/yaris_model.dart';

class YarisService {
  static Future<List<Pilot>> getirYarisSonucu(String sezon, String round) async {
    final url = Uri.parse('https://ergast.com/api/f1/$sezon/$round/results.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['MRData']['RaceTable']['Races'][0]['Results'] as List;

      return results.map((json) {
        final driver = json['Driver'];
        final constructor = json['Constructor'];
        return Pilot(
          isim: '${driver['givenName']} ${driver['familyName']}',
          siralama: int.parse(json['position']),
          takim: constructor['name'],
          puan: json['points'],
        );
      }).toList();
    } else {
      throw Exception('Yarış sonucu alınamadı');
    }
  }

  static Future<List<YarisModel>> getirGecmisYarislar() async {
    final url = Uri.parse('https://ergast.com/api/f1/2024/results.json?limit=100');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final races = data['MRData']['RaceTable']['Races'] as List;

      return races.map((raceJson) => YarisModel.fromJson(raceJson)).toList();
    } else {
      throw Exception('Yarış verileri alınamadı!');
    }
  }
}
