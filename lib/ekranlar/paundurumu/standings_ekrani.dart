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

  @override
  void initState() {
    super.initState();
    takimSiralama = TakimService.getirTakimSiralama();
    pilotSiralama = PilotService.getirPilotSiralama();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Standings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Takım Sıralaması", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            FutureBuilder<List<TakimModel>>(
              future: takimSiralama,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Hata: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Veri bulunamadı');
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final takim = snapshot.data![index];
                      return ListTile(
                        title: Text(takim.displayName),
                        subtitle: Text('Rank: ${takim.rank} | Points: ${takim.points}'),
                      );
                    },
                  );
                }
              },
            ),
            SizedBox(height: 20),
            Text("Pilot Sıralaması", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            FutureBuilder<List<PilotModel>>(
              future: pilotSiralama,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Hata: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Veri bulunamadı');
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final pilot = snapshot.data![index];
                      return ListTile(
                        title: Text(pilot.driverName),
                        subtitle: Text('Team: ${pilot.teamName} | Position: ${pilot.points}'),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
