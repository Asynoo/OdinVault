import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _key = 'locale';

  static const supported = [
    Locale('en'),
    Locale('da'),
    Locale('ja'),
  ];

  static const names = {
    'en': 'English',
    'da': 'Dansk',
    'ja': '日本語',
  };

  static final notifier = ValueNotifier<Locale>(const Locale('en'));

  static Future<void> load() async {
    final code = await _storage.read(key: _key);
    if (code != null && supported.any((l) => l.languageCode == code)) {
      notifier.value = Locale(code);
    }
  }

  static Future<void> setLocale(Locale locale) async {
    notifier.value = locale;
    await _storage.write(key: _key, value: locale.languageCode);
  }
}
