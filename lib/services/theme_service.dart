import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _key = 'theme_mode';

  static final notifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

  static Future<void> load() async {
    final val = await _storage.read(key: _key);
    notifier.value = val == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  static Future<void> setMode(ThemeMode mode) async {
    notifier.value = mode;
    await _storage.write(key: _key, value: mode == ThemeMode.light ? 'light' : 'dark');
  }
}
