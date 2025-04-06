import 'package:flutter/material.dart';
import 'package:rss_dart/dart_rss.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class HaberDetayEkrani extends StatelessWidget {
  final RssItem haber;

  const HaberDetayEkrani({Key? key, required this.haber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = haber.enclosure?.url;
    final String fullDescription = haber.description ?? 'Açıklama yok.';
    final String? haberLink = haber.link;

    return Scaffold(
      appBar: AppBar(
        title: Text(haber.title ?? 'Haber Detayı'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                Image.network(imageUrl, fit: BoxFit.cover),
              const SizedBox(height: 16),
              Text(
                haber.title ?? 'Başlık Yok',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                haber.pubDate ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Html(
                data: fullDescription,
                  onLinkTap: (url, _, __) {
                    _launchURL(url!);
                  }
              ),
              if (haberLink != null && fullDescription.contains('Okumaya devam et'))
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: InkWell(
                    onTap: () {
                      _launchURL(haberLink);
                    },
                    child: Text(
                      '',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // URL açma işlevi
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri);
  }

}