import 'storage.dart';

class AutoLockService {
  static const _keyEnabled = 'auto_lock_enabled';
  static const _keyMinutes = 'auto_lock_minutes';

  static Future<bool> isEnabled() async {
    final val = await secureStorage.read(key: _keyEnabled);
    return val == 'true';
  }

  static Future<void> setEnabled(bool enabled) async {
    await secureStorage.write(
        key: _keyEnabled, value: enabled ? 'true' : 'false');
  }

  static Future<int> getMinutes() async {
    final val = await secureStorage.read(key: _keyMinutes);
    return int.tryParse(val ?? '') ?? 5;
  }

  static Future<void> setMinutes(int minutes) async {
    await secureStorage.write(key: _keyMinutes, value: minutes.toString());
  }
}
