import 'package:flutter/material.dart';
import '../../models/yaris_model.dart';
import '../../services/yaris_service.dart';
import 'package:donemprojesi/ekranlar/detaysayfasi.dart';


class GecmisYarislarSayfasi extends StatefulWidget {
  const GecmisYarislarSayfasi({super.key});

  @override
  State<GecmisYarislarSayfasi> createState() => _GecmisYarislarSayfasiState();
}

class _GecmisYarislarSayfasiState extends State<GecmisYarislarSayfasi> {
  late Future<List<YarisModel>> yarislar;

  @override
  void initState() {
    super.initState();
    yarislar = YarisService.getirGecmisYarislar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<List<YarisModel>>(
        future: yarislar,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Yarış bulunamadı.'));
          }

          final yarisList = snapshot.data!;
          return ListView.builder(
            itemCount: yarisList.length,
            itemBuilder: (context, index) {
              final yaris = yarisList[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(yaris.yarisAdi),
                    subtitle: Text('${yaris.tarih} • ${yaris.lokasyon}'),
                    trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetaySayfasi(
                              pilotlar: yaris.pilotlar, // YarisModel'in içindeki pilotlar listesi
                              yarisAdi: yaris.yarisAdi,
                            ),
                          ),
                        );
                      }

                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
