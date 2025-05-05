class TakimModel {
  final String takimAdi;
  final int pozisyon;
  final int puan;

  TakimModel({
    required this.takimAdi,
    required this.pozisyon,
    required this.puan,
  });

  factory TakimModel.fromJson(Map<String, dynamic> json) {
    return TakimModel(
      takimAdi: json['team']['name'] ?? 'Bilinmiyor', // Takım adı
      pozisyon: json['position'] ?? 0, // Takım sıralama pozisyonu
      puan: json['stats'][0]['value'] ?? 0, // Takımın puanı
    );
  }
}
