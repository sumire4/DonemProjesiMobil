import 'package:donemprojesi/ekranlar/profil/kaydedilen_haberler_ekrani.dart';
import 'package:donemprojesi/ekranlar/profil/profil_duzenle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; // Fotoğraf seçmek için
import 'dart:io';
import 'package:intl/intl.dart'; // Tarih formatlamak için
import 'package:donemprojesi/ekranlar/profil/giris_ekrani.dart';
import 'package:firebase_core/firebase_core.dart';


class HesabimEkrani extends StatefulWidget {
  @override
  _HesabimEkraniState createState() => _HesabimEkraniState();
}

class _HesabimEkraniState extends State<HesabimEkrani> {
  final User? user = FirebaseAuth.instance.currentUser;
  late Future<DocumentSnapshot> _kullaniciVerisi;
  File? _profilResmi; // Kullanıcı fotoğrafı

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _kullaniciVerisi = FirebaseFirestore.instance
          .collection('kullanicilar')
          .doc(user!.uid)
          .get();
    }
  }

  Future<void> _fotoSec() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profilResmi = File(pickedFile.path); // Seçilen fotoğrafı _profilResmi'ye atıyoruz
      });

      try {
        // Firebase Storage'a yükleme işlemi
        String fileName = '${user!.uid}_profile_picture.png'; // Kullanıcıya özel dosya adı
        Reference storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$fileName');

        // Fotoğrafı yükleme
        await storageRef.putFile(_profilResmi!);

        // Fotoğrafın URL'sini al
        String downloadURL = await storageRef.getDownloadURL();

        // Firestore'a kaydet
        await FirebaseFirestore.instance
            .collection('kullanicilar')
            .doc(user!.uid)
            .update({'profilResmi': downloadURL}); // URL'yi Firestore'a kaydediyoruz

        // Başarılı işlem mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil resmi başarıyla güncellendi.')),
        );
      } catch (e) {
        // Hata durumunda kullanıcıya bilgi ver
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $e')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return GirisEkrani(); // Giriş yapılmamışsa giriş ekranına dön
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _kullaniciVerisi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Kullanıcı verisi bulunamadı.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final favoriPilot = data['favoriPilot'] ?? 'Belirtilmemiş';
          final Timestamp? kayitTarihiTS = data['kayitTarihi'];
          final favoriTakim = data['favoriTakim'] ?? 'Belirtilmemiş';
          final String kayitTarihi = kayitTarihiTS != null
              ? DateFormat('dd.MM.yyyy HH:mm').format(kayitTarihiTS.toDate())
              : 'Bilinmiyor';

          String dosyaAdiDonustur(String isim) {
            return isim.toLowerCase().replaceAll(" ", "_");
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            // Profil resmi
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: _profilResmi != null
                                  ? FileImage(_profilResmi!) as ImageProvider
                                  : NetworkImage(data['profilResmi'] ?? ''),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                icon: Icon(Icons.camera_alt, color: Colors.grey),
                                onPressed: _fotoSec,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          user!.email ?? 'E-posta yok',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 16),

                        // Favori Pilot Resmi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/pilotlar/${dosyaAdiDonustur(favoriPilot)}.png',
                              width: 80,
                              height: 80,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 80),
                            ),
                            SizedBox(width: 16),
                            // Favori Takım Logosu
                            Image.asset(
                              'assets/images/takimlar/${dosyaAdiDonustur(favoriTakim)}.png',
                              width: 80,
                              height: 80,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.flag, size: 80),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ListTile(
                          leading: Icon(Icons.star),
                          title: Text('Favori Pilot'),
                          subtitle: Text(favoriPilot),
                        ),
                        ListTile(
                          leading: Icon(Icons.directions_car),
                          title: Text('Favori Takım'),
                          subtitle: Text(favoriTakim),
                        ),
                        ListTile(
                          leading: Icon(Icons.calendar_today),
                          title: Text('Katılma Tarihi'),
                          subtitle: Text(kayitTarihi),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilDuzenleEkrani(
                          favoriPilot: favoriPilot,
                          favoriTakim: favoriTakim,
                        ),
                      ),
                    ).then((_) {
                      setState(() {
                        _kullaniciVerisi = FirebaseFirestore.instance
                            .collection('kullanicilar')
                            .doc(user!.uid)
                            .get(); // Güncelleme sonrası tekrar veriyi çek
                      });
                    });
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Profili Düzenle'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => KaydedilenHaberlerEkrani()),
                    );
                  },
                  icon: Icon(Icons.bookmarks),
                  label: Text('Kaydedilenler'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HesabimEkrani()),
                    );
                  },
                  icon: Icon(Icons.logout),
                  label: Text('Çıkış Yap'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
