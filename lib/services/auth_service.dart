import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/export.dart';
import 'encryption_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keyHash = 'master_hash';
  static const _keySalt = 'master_salt';
  static const _keyAes = 'aes_key';
  static const _keyBioEnabled = 'biometric_enabled';
  static const _keyHashVersion = 'hash_version';

  static const _pbkdf2Iterations = 100000;

  static String? _sessionKey;
  static final _localAuth = LocalAuthentication();

  static String? get sessionKey => _sessionKey;

  static Future<bool> isSetUp() async {
    final hash = await _storage.read(key: _keyHash);
    return hash != null;
  }

  static Future<void> setup(String masterPassword) async {
    final salt = _generateSalt();
    final hash = _pbkdf2Hash(masterPassword, salt);
    final aesKey = EncryptionService.generateKey();
    await _storage.write(key: _keySalt, value: salt);
    await _storage.write(key: _keyHash, value: hash);
    await _storage.write(key: _keyHashVersion, value: '2');
    await _storage.write(key: _keyAes, value: aesKey);
    _sessionKey = aesKey;
  }

  static Future<bool> loginWithPassword(String masterPassword) async {
    final salt = await _storage.read(key: _keySalt);
    final storedHash = await _storage.read(key: _keyHash);
    final version = await _storage.read(key: _keyHashVersion) ?? '1';
    if (salt == null || storedHash == null) return false;

    final bool matches;
    if (version == '1') {
      matches = _sha256Hash(masterPassword, salt) == storedHash;
    } else {
      matches = _pbkdf2Hash(masterPassword, salt) == storedHash;
    }

    if (!matches) return false;

    // Silently upgrade legacy SHA-256 hash to PBKDF2 on successful login
    if (version == '1') {
      final newSalt = _generateSalt();
      await _storage.write(key: _keySalt, value: newSalt);
      await _storage.write(key: _keyHash, value: _pbkdf2Hash(masterPassword, newSalt));
      await _storage.write(key: _keyHashVersion, value: '2');
    }

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
    final version = await _storage.read(key: _keyHashVersion) ?? '1';
    if (salt == null || storedHash == null) return false;
    if (version == '1') return _sha256Hash(password, salt) == storedHash;
    return _pbkdf2Hash(password, salt) == storedHash;
  }

  static Future<void> changeMasterPassword(String newPassword) async {
    final salt = _generateSalt();
    await _storage.write(key: _keySalt, value: salt);
    await _storage.write(key: _keyHash, value: _pbkdf2Hash(newPassword, salt));
    await _storage.write(key: _keyHashVersion, value: '2');
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

  static String _pbkdf2Hash(String password, String salt) {
    final saltBytes = Uint8List.fromList(base64Decode(salt));
    final passwordBytes = Uint8List.fromList(utf8.encode(password));
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(saltBytes, _pbkdf2Iterations, 32));
    return base64Encode(pbkdf2.process(passwordBytes));
  }

  // Retained only for migrating existing SHA-256 hashes (hash_version = '1')
  static String _sha256Hash(String password, String salt) {
    return sha256.convert(utf8.encode(password + salt)).toString();
  }
}
