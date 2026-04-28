import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'encryption_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keyHash = 'master_hash';
  static const _keySalt = 'master_salt';
  static const _keyAes = 'aes_key';
  static const _keyBioEnabled = 'biometric_enabled';

  static String? _sessionKey;
  static final _localAuth = LocalAuthentication();

  static String? get sessionKey => _sessionKey;

  static Future<bool> isSetUp() async {
    final hash = await _storage.read(key: _keyHash);
    return hash != null;
  }

  static Future<void> setup(String masterPassword) async {
    final salt = _generateSalt();
    final hash = _hashPassword(masterPassword, salt);
    final aesKey = EncryptionService.generateKey();
    await _storage.write(key: _keySalt, value: salt);
    await _storage.write(key: _keyHash, value: hash);
    await _storage.write(key: _keyAes, value: aesKey);
    _sessionKey = aesKey;
  }

  static Future<bool> loginWithPassword(String masterPassword) async {
    final salt = await _storage.read(key: _keySalt);
    final storedHash = await _storage.read(key: _keyHash);
    if (salt == null || storedHash == null) return false;
    if (_hashPassword(masterPassword, salt) != storedHash) return false;
    _sessionKey = await _storage.read(key: _keyAes);
    return _sessionKey != null;
  }

  static Future<bool> loginWithBiometric() async {
    final bioEnabled = await _storage.read(key: _keyBioEnabled);
    if (bioEnabled != 'true') return false;
    final canAuth =
        await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    if (!canAuth) return false;
    final didAuth = await _localAuth.authenticate(
      localizedReason: 'Unlock VaultPass',
      options: const AuthenticationOptions(stickyAuth: true),
    );
    if (!didAuth) return false;
    _sessionKey = await _storage.read(key: _keyAes);
    return _sessionKey != null;
  }

  static Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _keyBioEnabled);
    return val == 'true';
  }

  static Future<bool> isBiometricAvailable() async {
    return await _localAuth.canCheckBiometrics ||
        await _localAuth.isDeviceSupported();
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _keyBioEnabled, value: enabled ? 'true' : 'false');
  }

  static Future<bool> verifyPassword(String password) async {
    final salt = await _storage.read(key: _keySalt);
    final storedHash = await _storage.read(key: _keyHash);
    if (salt == null || storedHash == null) return false;
    return _hashPassword(password, salt) == storedHash;
  }

  static Future<void> changeMasterPassword(String newPassword) async {
    final salt = _generateSalt();
    final hash = _hashPassword(newPassword, salt);
    await _storage.write(key: _keySalt, value: salt);
    await _storage.write(key: _keyHash, value: hash);
  }

  static void logout() {
    _sessionKey = null;
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
    _sessionKey = null;
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  static String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }
}
