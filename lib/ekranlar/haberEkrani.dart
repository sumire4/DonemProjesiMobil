import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rss_dart/dart_rss.dart';
import 'ekranlar/haberDetayEkrani.dart';
import 'package:url_launcher/url_launcher.dart';

class HaberEkrani extends StatefulWidget {
  const HaberEkrani({Key? key}) : super(key: key);

  @override
  State<HaberEkrani> createState() => _HaberEkraniState();
}

class _HaberEkraniState extends State<HaberEkrani> {
  late Future<List<RssItem>> _haberler;

  @override
  void initState() {
    super.initState();
    _haberler = fetchHaberler();
  }

  Future<List<RssItem>> fetchHaberler() async {
    final url = Uri.parse('https://tr.motorsport.com/rss/f1/news/'); // RSS URL

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final feed = RssFeed.parse(response.body);

        // Check if feed.items is not null or empty
        if (feed.items == null || feed.items!.isEmpty) {
          throw Exception('Haberler boş veya geçerli değil');
        }

        return feed.items!;
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
            itemCount: haberler.length,
            itemBuilder: (context, index) {
              final haber = haberler[index];
              final imageUrl = haber.enclosure?.url;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {    // Haber detaylarına git
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
                          errorBuilder: (context, error, stackTrace) => Container(),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              haber.title ?? 'Başlık Yok',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              haber.pubDate ?? '',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
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
