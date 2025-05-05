import 'package:flutter/material.dart';
import '../../../models/pilot_model.dart';
import '../../../services/pilot_service.dart';
import '../../../models/takim_model.dart'; // Takım sıralamaları için model
import '../../../services/takim_service.dart'; // TakımService

class StandingEkrani extends StatefulWidget {
  const StandingEkrani({super.key});

  @override
  State<StandingEkrani> createState() => _StandingEkraniState();
}

class _StandingEkraniState extends State<StandingEkrani> {
  late Future<List<PilotModel>> pilotSiralama;
  late Future<List<TakimModel>> takimSiralama;
  String errorMessage = ''; // Hata mesajı için bir değişken

  @override
  void initState() {
    super.initState();
    pilotSiralama = fetchPilotSiralama();
    takimSiralama = fetchTakimSiralama();
  }

  // Pilot sıralamaları verisini alırken hata mesajı ekle
  Future<List<PilotModel>> fetchPilotSiralama() async {
    try {
      return await PilotService.getirSurucuSiralama();
    } catch (e) {
      setState(() {
        errorMessage = 'API kotası doldu veya çok fazla istek gönderildi. Lütfen daha sonra tekrar deneyin.';
      });
      rethrow;
    }
  }

  // Takım sıralamaları verisini alırken hata mesajı ekle
  Future<List<TakimModel>> fetchTakimSiralama() async {
    try {
      return await TakimService.getirTakimSiralama();
    } catch (e) {
      setState(() {
        errorMessage = 'API kotası doldu veya çok fazla istek gönderildi. Lütfen daha sonra tekrar deneyin.';
      });
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Butonlar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        pilotSiralama = fetchPilotSiralama();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.white38,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Pilot Sıralamaları',
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        takimSiralama = fetchTakimSiralama();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.white38,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Takım Sıralamaları',
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Hata mesajını ekranın ortasında göstermek için Center widget'ı kullandık
          if (errorMessage.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          // Diğer içerik burada yer alacak (pilot ve takım sıralama listeleri vb.)
        ],
      ),
    );
  }
}
