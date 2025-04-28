import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'hesabimEkrani.dart';

class GirisEkrani extends StatefulWidget {
  @override
  _GirisEkraniState createState() => _GirisEkraniState();
}
// Boş Sayfa Widget'ı
class HesapBilgi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Başarılı Giriş'),
        automaticallyImplyLeading: false, // Geri butonunu kaldırır
      ),
      body: Center(
        child: Text('Giriş başarılı! Hoş geldiniz!'),
      ),
    );
  }
}

class _GirisEkraniState extends State<GirisEkrani> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _girisYap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Giriş başarılı olduğunda direkt olarak Profil sayfasına yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HesabimEkrani()), // Hesap ekranına yönlendir
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _handleFirebaseAuthError(e.code);
      });
      print('Giriş hatası: ${e.message}');
    } catch (e) {
      setState(() {
        _errorMessage = 'Beklenmedik bir hata oluştu.';
      });
      print('Beklenmedik hata: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  String _handleFirebaseAuthError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Bu e-posta adresine kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Yanlış şifre girdiniz.';
      case 'invalid-email':
        return 'Geçersiz bir e-posta adresi girdiniz.';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
      default:
        return 'Bilinmeyen bir giriş hatası oluştu.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş Yap'),
        elevation: 0, // AppBar'ın altındaki gölgeyi kaldırır (isteğe bağlı)
      ),
      body: Center(
        child: SingleChildScrollView( // Klavye açıldığında taşmayı önler
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // E-posta TextField
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-posta',
                  border: OutlineInputBorder(), // Çerçeveli görünüm
                  prefixIcon: Icon(Icons.email), // E-posta ikonu
                ),
              ),
              SizedBox(height: 16.0),

              // Şifre TextField
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock), // Kilit ikonu
                ),
              ),
              SizedBox(height: 24.0),

              // Giriş Yap Butonu
              ElevatedButton(
                onPressed: _isLoading ? null : _girisYap, // Yüklenirken devre dışı
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: _isLoading
                    ? CircularProgressIndicator() // Yüklenirken animasyon
                    : Text('Giriş Yap'),
              ),
              SizedBox(height: 16.0),

              // Hata Mesajı
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Theme.of(context).colorScheme.error), // Tema'dan hata rengini alır
                ),
              SizedBox(height: 16.0),

              // Kayıt Ol Butonu (isteğe bağlı)
              TextButton(
                onPressed: () {
                  // Kayıt ekranına yönlendirme (isteğe bağlı)
                  print('Kayıt ekranına git');
                  // Navigator.push(...);
                },
                child: Text('Hesabınız yok mu? Kayıt olun'),
              ),

              // Şifremi Unuttum Butonu (isteğe bağlı)
              TextButton(
                onPressed: () {
                  // Şifremi unuttum ekranına yönlendirme (isteğe bağlı)
                  print('Şifremi unuttum');
                  // Navigator.push(...);
                },
                child: Text('Şifremi unuttum'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}