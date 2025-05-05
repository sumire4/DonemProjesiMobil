import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KayitEkrani extends StatefulWidget {
  @override
  _KayitEkraniState createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String _errorMessage = '';
  bool _isLoading = false;

  // Seçim listeleri
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

  Future<void> _kayitOl() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (_secilenPilot == null || _secilenTakim == null) {
      setState(() {
        _errorMessage = 'Lütfen favori pilotunuzu ve takımınızı seçin.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Firebase Authentication'da kullanıcı oluştur
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Kullanıcı başarıyla oluşturulduktan sonra Firestore'a ek veri yaz
      await _firestore.collection('kullanicilar').doc(userCredential.user!.uid).set({
        'email': _emailController.text.trim(),
        'favoriPilot': _secilenPilot,
        'favoriTakim': _secilenTakim,
        'kayitTarihi': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); // Başarılıysa geri dön
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _handleFirebaseAuthError(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Beklenmedik bir hata oluştu.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _handleFirebaseAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu e-posta zaten kullanımda.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'weak-password':
        return 'Şifre çok zayıf.';
      default:
        return 'Bir hata oluştu.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),

            // Favori Pilot Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Favori Pilot',
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
            ),
            SizedBox(height: 16),

            // Favori Takım Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Favori Takım',
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
            ),
            SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _kayitOl,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Kayıt Ol'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
