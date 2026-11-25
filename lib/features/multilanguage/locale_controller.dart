import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const String _key = 'app_language';

  final SharedPreferences prefs;
  late Locale _locale;

  LocaleController({
    required this.prefs,
    required Locale deviceLocale,
  }) {
    final language = prefs.getString(_key);

    if (language == 'en' || language == 'de') {
      _locale = Locale(language!);
    } else {
      _locale = Locale(deviceLocale.languageCode == 'de' ? 'de' : 'en');
    }
  }

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'en' && locale.languageCode != 'de') {
      return;
    }

    if (_locale == locale) {
      return;
    }

    _locale = locale;
    notifyListeners();

    await prefs.setString(_key, locale.languageCode);
  }
}