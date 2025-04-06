import 'package:donemprojesi/ekranlar/ekranlar/gecmisYarislarSayfasi.dart';
import 'package:flutter/material.dart';
import 'ekranlar/ekranlar/hesabimEkrani.dart';
import 'ekranlar/girişEkrani.dart';
import 'ekranlar/haberEkrani.dart';
import 'ekranlar/ekranlar/briefEkrani.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HaberEkrani(), // Haberler (index 0)
    GecmisYarislarSayfasi(),
    Briefekrani(),

    Center(child: Text('Hesap')), // Hesap (index 3) - Giriş ekranına yönlendiriliyor
  ];

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 3) {
      final user = FirebaseAuth.instance.currentUser;

      // Oturum açık mı kontrol et
      if (user == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GirisEkrani()),
        ).then((_) {
          setState(() {
            _selectedIndex = 0; // Girişten geri gelince "Haber" sekmesine dön
          });
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HesabimEkrani()),
        ).then((_) {
          setState(() {
            _selectedIndex = 0; // Profil ekranından çıkınca da ana sayfaya dön
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            _selectedIndex == 0
                ? "Haberler"
                : _selectedIndex == 1
                ? "Skorlar"
                : _selectedIndex == 2
                ? "AI"
                : "Hesap",
          ),
        ),
        elevation: 0,
      ),
      body: _selectedIndex < _widgetOptions.length - 1
          ? _widgetOptions[_selectedIndex]
          : Center(child: Text("Hesap")), // Hesap için geçici placeholder
      bottomNavigationBar: NavigationBar(
        height: 60,
        backgroundColor: Colors.white,
        destinations: [
          NavigationDestination(icon: Icon(Icons.article), label: "Haber"),
          NavigationDestination(icon: Icon(Icons.sports_score), label: "Skor"),
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: "AI"),
          NavigationDestination(icon: Icon(Icons.person), label: "Hesap"),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}