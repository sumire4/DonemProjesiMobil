import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Ana Sayfa",
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
          ),
        ),

        elevation: 0,
      ),
      body: Center(

      ),
      bottomNavigationBar: NavigationBar(
        height: 60,
        backgroundColor: Colors.white,
        indicatorColor: Colors.blueAccent.withOpacity(0.2),
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
