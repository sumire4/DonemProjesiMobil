import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
    _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveToPrefs();
    notifyListeners();
  }

  void _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode');

    if (themeString != null) {
      if (themeString == 'light') {
        _themeMode = ThemeMode.light;
      } else if (themeString == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (themeString == 'system') {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    }
  }

  void _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = _themeMode.toString().split('.').last;
    await prefs.setString('themeMode', themeString);
  }
}
