import 'package:flutter/material.dart';
import 'storage.dart';

class ThemeService {
  static const _key = 'theme_mode';

  static final notifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

  static Future<void> load() async {
    final val = await secureStorage.read(key: _key);
    notifier.value = val == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  static Future<void> setMode(ThemeMode mode) async {
    notifier.value = mode;
    await secureStorage.write(key: _key, value: mode == ThemeMode.light ? 'light' : 'dark');
  }
}
