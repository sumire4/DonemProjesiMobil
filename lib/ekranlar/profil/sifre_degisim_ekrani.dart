import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SifreDegistirEkrani extends StatefulWidget {
  @override
  _SifreDegistirEkraniState createState() => _SifreDegistirEkraniState();
}

class _SifreDegistirEkraniState extends State<SifreDegistirEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _mevcutSifreController = TextEditingController();
  final _yeniSifreController = TextEditingController();
  final _yeniSifreTekrarController = TextEditingController();

  bool _isLoading = false;

  Future<void> _sifreDegistir() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: _mevcutSifreController.text,
      );

      // Kimliği yeniden doğrula
      await user.reauthenticateWithCredential(credential);

      // Şifreyi güncelle
      await user.updatePassword(_yeniSifreController.text);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Şifre başarıyla güncellendi'),
        backgroundColor: Colors.green,
      ));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Hata: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Şifreyi Değiştir')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _mevcutSifreController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mevcut Şifre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Mevcut şifreyi girin' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _yeniSifreController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.length < 6 ? 'En az 6 karakter olmalı' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _yeniSifreTekrarController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre (Tekrar)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value != _yeniSifreController.text
                    ? 'Şifreler uyuşmuyor'
                    : null,
              ),
              SizedBox(height: 24),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton.icon(
                onPressed: _sifreDegistir,
                icon: Icon(Icons.save),
                label: Text('Şifreyi Güncelle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
