import 'dart:convert';
import 'package:donemprojesi/ekranlar/gazetelik/pist_detay_sayfasi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rss_dart/dart_rss.dart';
import 'package:donemprojesi/ekranlar/gazetelik/haber_detay_ekrani.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../main.dart';


class HaberEkrani extends StatefulWidget {
  const HaberEkrani({Key? key}) : super(key: key);

  @override
  State<HaberEkrani> createState() => _HaberEkraniState();
}


class _HaberEkraniState extends State<HaberEkrani> {
  late Future<List<RssItem>> _haberler;
  Set<String> _kaydedilenHaberLinkleri = {};
  String? _sicaklik;
  String? _havaDurumu;
  String? _sehir;
  String? _kullaniciAdi;
  String? _havaDurumuMain;
  bool _notificationEnabled = false;


  void _checkAndNotify() {
    // Örnek kalan süreyi dakika cinsinden alıyoruz
    final remainingDuration = _enYakinYaris != null ? _enYakinYaris!['remainingMinutes'] as int? ?? 0 : 0;

    if (_notificationEnabled && remainingDuration <= 60) {
      _showNotification();
    }
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Yarış bildirimi',
      'Kalan süre 1 saate ulaştı!',
      platformDetails,
    );
  }


  Future<void> _bildirimGonder() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'yarış_kalani', // Kanal ID
      'Yarış Bildirimleri', // Kanal Adı
      channelDescription: 'Yarış zamanı bildirimi',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Yarış Zamanı',
      '${_enYakinYaris?['name']} başladı!',
      platformChannelSpecifics,
      payload: 'Yarış bildirimi',
    );
  }


  List<Map<String, dynamic>> _f1Calendar = [];
  Map<String, dynamic>? _enYakinYaris;

  @override
  void initState() {
    super.initState();
    _haberler = fetchHaberler();
    _kaydedilenleriYukle();
    _havaDurumuGetir();
    _kullaniciBilgisiGetir();
    _loadF1Calendar();
  }

  Future<void> _loadF1Calendar() async {
    final jsonString = await rootBundle.loadString('assets/f1_calendar.json');
    final List<dynamic> jsonData = jsonDecode(jsonString);

    setState(() {
      _f1Calendar = jsonData.cast<Map<String, dynamic>>();
      _enYakinYarisiBul();
    });
  }
  void _enYakinYarisiBul() {
    final now = DateTime.now();

    _f1Calendar.sort((a, b) {
      final dateA = DateTime.parse(a['race_date']);
      final dateB = DateTime.parse(b['race_date']);
      return dateA.compareTo(dateB);
    });

    for (var race in _f1Calendar) {
      final raceDate = DateTime.parse(race['race_date']);
      if (raceDate.isAfter(now)) {
        _enYakinYaris = race;
        break;
      }
    }

    // Eğer hiç sonraki yarış yoksa son yarış olabilir
    if (_enYakinYaris == null && _f1Calendar.isNotEmpty) {
      _enYakinYaris = _f1Calendar.last;
    }
  }
  Future<void> _kullaniciBilgisiGetir() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('kullanicilar')
          .doc(user.uid)
          .get();
      setState(() {
        _kullaniciAdi = doc.data()?['ad'] ?? 'Kullanıcı';
      });
    }
  }

  Future<void> _kaydedilenleriYukle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('kullanicilar')
          .doc(user.uid)
          .collection('kaydedilenHaberler')
          .get();

      setState(() {
        _kaydedilenHaberLinkleri =
            snapshot.docs.map((doc) => doc['link'] as String).toSet();
      });
    }
  }

  Widget _havaDurumuIkonu(String? durum) {
    switch (durum) {
      case 'Clear':
        return const Icon(Icons.wb_sunny, color: Colors.orange, size: 32);
      case 'Clouds':
        return const Icon(Icons.cloud, color: Colors.grey, size: 32);
      case 'Rain':
      case 'Drizzle':
        return const Icon(Icons.grain, color: Colors.blue, size: 32); // Yağmur simgesi gibi
      case 'Thunderstorm':
        return const Icon(Icons.flash_on, color: Colors.yellow, size: 32);
      case 'Snow':
        return const Icon(Icons.ac_unit, color: Colors.lightBlue, size: 32);
      case 'Mist':
      case 'Fog':
        return const Icon(Icons.blur_on, color: Colors.grey, size: 32);
      default:
        return const Icon(Icons.wb_cloudy, color: Colors.grey, size: 32);
    }
  }


  Future<void> _havaDurumuGetir() async {
    const apiKey = ' '; // Weather

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Konum servisleri kapalı.");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Konum izni reddedildi.");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Konum izni kalıcı olarak reddedildi.");
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);

      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric&lang=tr');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final main = data['main'];
        final weather = data['weather'][0];
        setState(() {
          _sicaklik = "${main['temp'].round()}°C";
          _havaDurumu = weather['description'];
          _havaDurumuMain = weather['main'];
          _sehir = data['name'];
        });
      } else {
        throw Exception("Hava durumu alınamadı.");
      }
    } catch (e) {
      debugPrint("Hava durumu hatası: $e");
      setState(() {
        _sicaklik = null;
        _havaDurumu = "Konum alınamadı";
      });
    }
  }


  Future<List<RssItem>> fetchHaberler() async {
    final url = Uri.parse('https://tr.motorsport.com/rss/f1/news/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final feed = RssFeed.parse(response.body);
        if (feed.items == null || feed.items.isEmpty) {
          throw Exception('Haberler boş veya geçerli değil');
        }
        return feed.items;
      } else {
        throw Exception('Haber verisi alınamadı.');
      }
    } catch (e) {
      throw Exception('Bir hata oluştu: $e');
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'URL açılamıyor: $url';
    }
  }

  String _selamla() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Günaydın";
    } else if (hour >= 12 && hour < 18) {
      return "İyi günler";
    } else if (hour >= 18 && hour < 22) {
      return "İyi akşamlar";
    } else {
      return "İyi geceler";
    }
  }

  Widget _havaDurumuIconuGetir(String? durum) {
    switch (durum) {
      case 'Clear':
        return const Icon(Icons.wb_sunny, color: Colors.orange, size: 24);
      case 'Clouds':
        return const Icon(Icons.cloud, color: Colors.grey, size: 24);
      case 'Rain':
        return const Icon(Icons.beach_access, color: Colors.blue, size: 24);
      case 'Snow':
        return const Icon(Icons.ac_unit, color: Colors.lightBlue, size: 24);
      case 'Thunderstorm':
        return const Icon(Icons.flash_on, color: Colors.yellow, size: 24);
      case 'Drizzle':
        return const Icon(Icons.grain, color: Colors.blueGrey, size: 24);
      case 'Mist':
      case 'Fog':
        return const Icon(Icons.blur_on, color: Colors.grey, size: 24);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey, size: 24);
    }
  }
  final DateTime _enYakinYarisTarihi = DateTime(2025, 5, 25, 15, 0); // 25 Mayıs 2025, 15:00
  String _kalanSureMetni() {
    if (_enYakinYaris == null) return "";

    final simdi = DateTime.now();
    final yarismTarihi = DateTime.parse(_enYakinYaris!['race_date']);
    final fark = yarismTarihi.difference(simdi);

    if (fark.isNegative) {
      return "Yarış başladı";
    }

    final gun = fark.inDays;
    final saat = fark.inHours % 24;

    return "$gun gün $saat saat";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<RssItem>>(
        future: _haberler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Hiç haber bulunamadı."));
          }

          final haberler = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: haberler.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,  // Ortada toplayalım
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Sol taraf: Selamlama ve hava durumu
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${_selamla()} 👋",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(height: 8),
                            if (_sicaklik != null && _havaDurumu != null && _sehir != null)
                              Row(
                                children: [
                                  Text(
                                    "$_sehir: $_sicaklik, $_havaDurumu",
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                  const SizedBox(width: 8),
                                  _havaDurumuIconuGetir(_havaDurumuMain),
                                ],
                              )
                            else
                              Text(
                                "Konum veya hava durumu yükleniyor...",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.start,
                              ),
                          ],
                        ),
                      ),

                      // İnce dikey çizgi
                      Container(
                        width: 1,
                        height: 50, // Çizginin yüksekliği ihtiyaca göre ayarlanabilir
                        color: Colors.grey[400],
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),

                      // Sağ taraf: Yarış ve kalan süre
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_enYakinYaris != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PistDetaySayfasi(yaris: _enYakinYaris!),
                                ),
                              );
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.network(
                                'https://upload.wikimedia.org/wikipedia/commons/3/33/F1.svg',
                                width: 20,
                                height: 20,
                                placeholderBuilder: (context) => const CircularProgressIndicator(),
                              ),
                              const SizedBox(height: 4),
                              if (_enYakinYaris != null) ...[
                                Text(
                                  _enYakinYaris!['name'] ?? "Yarış",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _kalanSureMetni(),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ] else
                                const Text("Yarış bilgisi yok"),
                            ],
                          ),
                        ),
                      ),


                    ],
                  ),
                );

              }


              final haber = haberler[index - 1];
              final imageUrl = haber.enclosure?.url;
              final link = haber.link ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HaberDetayEkrani(haber: haber),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrl != null && imageUrl.isNotEmpty)
                            Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 180,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  haber.title ?? 'Başlık Yok',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      haber.pubDate ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.ios_share),
                                          onPressed: () {
                                            final url = haber.link;
                                            if (url != null && url.isNotEmpty) {
                                              Share.share(url);
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            _kaydedilenHaberLinkleri.contains(link)
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
                                          ),
                                          onPressed: () async {
                                            final user =
                                                FirebaseAuth.instance.currentUser;
                                            if (user == null || link.isEmpty) {
                                              return;
                                            }

                                            final docRef = FirebaseFirestore.instance
                                                .collection('kullanicilar')
                                                .doc(user.uid)
                                                .collection('kaydedilenHaberler');

                                            if (_kaydedilenHaberLinkleri.contains(link)) {
                                              final query = await docRef
                                                  .where('link', isEqualTo: link)
                                                  .get();
                                              for (var doc in query.docs) {
                                                await doc.reference.delete();
                                              }
                                              setState(() {
                                                _kaydedilenHaberLinkleri.remove(link);
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                    content: Text('Haber kayıtlardan çıkarıldı')),
                                              );
                                            } else {
                                              await docRef.add({
                                                'title': haber.title,
                                                'link': link,
                                                'pubDate': haber.pubDate,
                                                'imageUrl': imageUrl,
                                                'savedAt': Timestamp.now(),
                                              });
                                              setState(() {
                                                _kaydedilenHaberLinkleri.add(link);
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Haber kaydedildi')),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
