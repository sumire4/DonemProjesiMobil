class PilotModel {
  final String isim;
  final String takim;
  final int pozisyon;

  PilotModel({
    required this.isim,
    required this.takim,
    required this.pozisyon,
  });

  factory PilotModel.fromJson(Map<String, dynamic> json) {
    try {
      return PilotModel(
        isim: json['driver']?['name'] ?? 'Bilinmiyor',  // Driver ismi güvenli kontrol
        takim: json['team']?['name'] ?? 'Bilinmiyor',  // Team ismi güvenli kontrol
        pozisyon: int.tryParse(json['position']?.toString() ?? '') ?? 0,  // Pozisyon sayısal dönüşüm
      );
    } catch (e) {
      // Eğer JSON'dan herhangi bir veri düzgün çekilemezse default değerler kullan
      return PilotModel(
        isim: 'Bilinmiyor',
        takim: 'Bilinmiyor',
        pozisyon: 0,
      );
    }
  }
}
