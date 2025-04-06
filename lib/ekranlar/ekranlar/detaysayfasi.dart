import 'package:flutter/material.dart';
import '../../models/pilot_model.dart';
import '../../models/yaris_model.dart';
import '../../utils/pilot_resimleri.dart';
import '../../utils/takim_logolari.dart';
import 'package:flutter/material.dart';
import '../../models/yaris_model.dart'; // PilotSonuc buradan geliyor

class DetaySayfasi extends StatelessWidget {
  final List<PilotSonuc> pilotlar;
  final String yarisAdi;

  const DetaySayfasi({
    super.key,
    required this.pilotlar,
    required this.yarisAdi,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(yarisAdi),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: pilotlar.length,
        itemBuilder: (context, index) {
          final pilot = pilotlar[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  // Bu kısımda isme göre bir resim haritası tanımlayabilirsin
                  'https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png',
                ),
              ),
              title: Text('${pilot.sira}. ${pilot.isim}'),
              subtitle: Text('Sıralama: ${pilot.sira}'),
            ),
          );
        },
      ),
    );
  }
}
