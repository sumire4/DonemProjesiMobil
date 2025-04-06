class YarisModel {
  final String yarisAdi;
  final String tarih;
  final String lokasyon;
  final List<PilotSonuc> pilotlar;

  YarisModel({
    required this.yarisAdi,
    required this.tarih,
    required this.lokasyon,
    required this.pilotlar,
  });

  factory YarisModel.fromJson(Map<String, dynamic> json) {
    final raceName = json['raceName'];
    final date = json['date'];
    final location = json['Circuit']['Location']['locality'];
    final results = json['Results'] as List;

    List<PilotSonuc> pilotList = results.map((pilotJson) {
      return PilotSonuc(
        isim: "${pilotJson['Driver']['givenName']} ${pilotJson['Driver']['familyName']}",
        sira: int.parse(pilotJson['position']),
      );
    }).toList();

    return YarisModel(
      yarisAdi: raceName,
      tarih: date,
      lokasyon: location,
      pilotlar: pilotList,
    );
  }
}

class PilotSonuc {
  final String isim;
  final int sira;

  PilotSonuc({required this.isim, required this.sira});
}
