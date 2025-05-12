class PilotModel {
  final String driverName;
  final String teamName;
  final int rank;
  final int points;

  PilotModel({
    required this.driverName,
    required this.teamName,
    required this.rank,
    required this.points,
  });

  factory PilotModel.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'];
    final team = json['team'];
    final stats = json['stats'] as List<dynamic>? ?? [];

    int rank = 0;
    int points = 0;

    for (var stat in stats) {
      if (stat['name'] == 'rank') {
        rank = stat['value'] ?? 0;
      } else if (stat['name'] == 'points') {
        points = stat['value'] ?? 0;
      }
    }

    return PilotModel(
      driverName: driver != null ? driver['name'] ?? 'Bilinmiyor' : 'Bilinmiyor',
      teamName: team != null ? team['name'] ?? 'Bilinmiyor' : 'Bilinmiyor',
      rank: rank,
      points: points,
    );
  }

}
