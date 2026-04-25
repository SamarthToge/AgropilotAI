import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app locale and persists the user's language choice.
class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  /// Full list of languages the app supports.
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English',   'native': 'English'},
    {'code': 'hi', 'name': 'Hindi',     'native': 'हिन्दी'},
    {'code': 'mr', 'name': 'Marathi',   'native': 'मराठी'},
    {'code': 'kn', 'name': 'Kannada',   'native': 'ಕನ್ನಡ'},
    {'code': 'te', 'name': 'Telugu',    'native': 'తెలుగు'},
    {'code': 'ml', 'name': 'Malayalam', 'native': 'മലയാളം'},
    {'code': 'ta', 'name': 'Tamil',     'native': 'தமிழ்'},
  ];

  /// Load the previously-saved language code from SharedPreferences.
  /// Call this once during app startup (before [runApp]).
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code') ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  /// Switch to [languageCode] and persist the choice.
  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    notifyListeners();
  }
}
