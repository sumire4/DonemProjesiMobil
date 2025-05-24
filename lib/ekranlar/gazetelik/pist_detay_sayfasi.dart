import 'dart:async';
import 'package:donemprojesi/ekranlar/brief/brief_ekrani.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PistDetaySayfasi extends StatefulWidget {
  final Map<String, dynamic> yaris;

  const PistDetaySayfasi({super.key, required this.yaris});

  @override
  State<PistDetaySayfasi> createState() => _PistDetaySayfasiState();
}

class _PistDetaySayfasiState extends State<PistDetaySayfasi> {
  bool _favori = false;
  late Timer _timer;
  Duration _kalanSure = Duration.zero;

  @override
  void initState() {
    super.initState();
    _baslatGeriSayim();
  }

  void _baslatGeriSayim() {
    final DateTime? hedefTarih = DateTime.tryParse(widget.yaris['race_date'] ?? '');
    if (hedefTarih != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final now = DateTime.now();
        setState(() {
          _kalanSure = hedefTarih.difference(now).isNegative
              ? Duration.zero
              : hedefTarih.difference(now);
        });
      });
    }
  }


  String _sureFormatla(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '$days Gün $hours Saat $minutes Dakika $seconds Saniye';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _favoriToggle() {
    setState(() => _favori = !_favori);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_favori ? "Favorilere eklendi" : "Favorilerden çıkarıldı")),
    );
  }

  void _paylas() {
    final String mesaj = "🏁 ${widget.yaris['name']} yarışı yaklaşıyor!\n"
        "Detaylar uygulamamızda! 📱";
    Share.share(mesaj);
  }

  void _haritadaAc() async {
    final lat = widget.yaris['latitude'];
    final lng = widget.yaris['longitude'];

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Koordinatlar mevcut değil.")),
      );
      return;
    }

    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harita açılamadı.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final yaris = widget.yaris;
    final bool haritaMevcut = yaris['latitude'] != null && yaris['longitude'] != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(yaris['name'] ?? "Yarış Detayı"),
        actions: [
          if (haritaMevcut)
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: _haritadaAc,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: yaris['kusbakisiAsset'] != null
                  ? Image.asset(
                yaris['kusbakisiAsset'],
                height: 200,
                fit: BoxFit.contain,
              )
                  : const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Yeni eklenen pist bilgileri kartı
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Bayrak resmi internetten
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: yaris['flagUrl'] != null
                        ? Image.network(
                      yaris['flagUrl'],
                      width: 48,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.flag_outlined, size: 32),
                    )
                        : const Icon(Icons.flag_outlined, size: 32),
                  ),
                  const SizedBox(width: 12),
                  // Pist ve ülke adı
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        yaris['name'] ?? "Bilinmeyen Pist",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900), // Daha kalın yazı tipi
                      ),
                      Text(
                        yaris['country'] ?? "Bilinmeyen Ülke",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),



            const SizedBox(height: 24),
            Text(
              "Yarışa Kalan Süre:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _sureFormatla(_kalanSure),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Pist Bilgisi:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              yaris['description'] ?? "Pist bilgisi bulunamadı.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BriefEkrani()),
                );
              },
              icon: const Icon(
                Icons.smart_toy, // Yapay zeka ikonu (alternatif: Icons.memory)
                color: Color(0xFF006400), // Koyu yeşil ikon rengi
              ),
              label: Text(
                "Briefe İlerle",
                style: TextStyle(
                  color: Color(0xFF006400), // Koyu yeşil yazı rengi
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Color(0xFFA8E6CF), // Açık yeşil buton rengi
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 115.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),


          ],
        ),

      ),
    );
  }
}
