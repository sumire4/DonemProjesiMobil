import 'package:donemprojesi/ekranlar/profil/sifre_degisim_ekrani.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilDuzenleEkrani extends StatefulWidget {
  final String favoriPilot;
  final String favoriTakim;
  final _mevcutSifreController = TextEditingController();
  final _yeniSifreController = TextEditingController();
  final _yeniSifreTekrarController = TextEditingController();

  ProfilDuzenleEkrani({required this.favoriPilot, required this.favoriTakim});

  @override
  _ProfilDuzenleEkraniState createState() => _ProfilDuzenleEkraniState();
}

class _ProfilDuzenleEkraniState extends State<ProfilDuzenleEkrani> {
  final _formKey = GlobalKey<FormState>();

  String? _secilenPilot;
  String? _secilenTakim;

  final List<String> _pilotlar = [
    'Max Verstappen',
    'Lewis Hamilton',
    'Charles Leclerc',
    'Fernando Alonso',
    'Lando Norris',
    'Sergio Perez',
    'George Russell',
    'Carlos Sainz',
    'Valtteri Bottas',
    'Esteban Ocon',
    'Sebastian Vettel',
    'Michael Schumacher',
    'Aryton Senna',
    'Mika Hakkinen',
    'Kimi Raikonen',
    'Nico Rosberg',
    'Felipe Massa',
  ];

  final List<String> _takimlar = [
    'Red Bull Racing',
    'Mercedes',
    'Ferrari',
    'McLaren',
    'Aston Martin',
    'Alpine',
    'AlphaTauri',
    'Alfa Romeo',
    'Haas',
    'Williams',
  ];

  @override
  void initState() {
    super.initState();
    _secilenPilot = widget.favoriPilot;
    _secilenTakim = widget.favoriTakim;
  }

  Future<void> _kaydet() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('kullanicilar').doc(user.uid).update({
          'favoriPilot': _secilenPilot,
          'favoriTakim': _secilenTakim,
        });
        Navigator.pop(context); // Geri dön
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profili Düzenle')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Favori Takımı Değiştir  ',
                  border: OutlineInputBorder(),
                ),
                value: _secilenPilot,
                items: _pilotlar
                    .map((pilot) => DropdownMenuItem(
                  value: pilot,
                  child: Text(pilot),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _secilenPilot = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Lütfen bir pilot seçin' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Favori Takımı Değiştir  ',
                  border: OutlineInputBorder(),
                ),
                value: _secilenTakim,
                items: _takimlar
                    .map((takim) => DropdownMenuItem(
                  value: takim,
                  child: Text(takim),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _secilenTakim = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Lütfen bir takım seçin' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SifreDegistirEkrani()),
                  );
                },
                icon: Icon(Icons.lock),
                label: Text('Şifreyi Değiştir'),
              ),

              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _kaydet,
                icon: Icon(Icons.save),
                label: Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
