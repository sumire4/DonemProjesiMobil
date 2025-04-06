import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../girişEkrani.dart';

class HesabimEkrani extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return GirisEkrani(); // Giriş yapılmamışsa giriş ekranı
    } else {
      return Scaffold(
        appBar: AppBar(title: Text('Profil')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle, size: 100),
              SizedBox(height: 20),
              Text('Hoş geldiniz, ${user.email}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // Sayfayı yeniden yükle
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HesabimEkrani()),
                  );
                },
                child: Text('Çıkış Yap'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
