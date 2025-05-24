import 'package:flutter/material.dart';
import '../../../models/pilot_model.dart';
import '../../../models/takim_model.dart';
import '../../../services/pilot_service.dart';
import '../../../services/takim_service.dart';

class StandingsEkrani extends StatefulWidget {
  @override
  _StandingsEkraniState createState() => _StandingsEkraniState();
}

class _StandingsEkraniState extends State<StandingsEkrani> {
  late Future<List<TakimModel>> takimSiralama;
  late Future<List<PilotModel>> pilotSiralama;

  String secilenSayfa = 'pilot'; // 'pilot' veya 'takim'

  @override
  void initState() {
    super.initState();
    takimSiralama = TakimService.getirTakimSiralama();
    pilotSiralama = PilotService.getirPilotSiralama();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: secilenSayfa == 'pilot'
                ? _buildPilotSiralama()
                : _buildTakimSiralama(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      secilenSayfa = 'pilot';
                    });
                  },
                  child: Text("Pilot Sıralaması"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secilenSayfa == 'pilot' ? Colors.white60: null,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      secilenSayfa = 'takim';
                    });
                  },
                  child: Text("Takım Sıralaması"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secilenSayfa == 'takim' ? Colors.white60 : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPilotSiralama() {
    return FutureBuilder<List<PilotModel>>(
      future: pilotSiralama,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Veri bulunamadı'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final pilot = snapshot.data![index];
              return ListTile(
                leading: Image.asset(
                  getPilotAssetImage(pilot.driverName),
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.person),
                ),
                title: Text(pilot.driverName),
                subtitle: Text('Takım: ${pilot.teamName} | Puan: ${pilot.points}'),
              );

            },
          );
        }
      },
    );
  }

  Widget _buildTakimSiralama() {
    return FutureBuilder<List<TakimModel>>(
      future: takimSiralama,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Veri bulunamadı'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final takim = snapshot.data![index];

              // Logo dosya adını takım ismine göre oluştur
              final logoDosyaAdi = '${takim.displayName
                  .toLowerCase()
                  .replaceAll(' ', '_')
                  .replaceAll('.', '')}.png';

              return ListTile(
                leading: Image.asset(
                  'assets/images/takimlar/$logoDosyaAdi',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
                ),
                title: Text(takim.displayName),
                subtitle: Text('Sıra: ${takim.rank} | Puan: ${takim.points}'),
              );
            },
          );
        }
      },
    );
  }

}
