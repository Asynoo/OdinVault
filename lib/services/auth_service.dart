import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/export.dart';
import 'database_service.dart';
import 'encryption_service.dart';
import 'storage.dart';

class AuthService {
  static const _keyHash = 'master_hash';
  static const _keySalt = 'master_salt';
  static const _keyAes = 'aes_key';
  static const _keyBioEnabled = 'biometric_enabled';
  static const _keyHashVersion = 'hash_version';
  static const _keyGcmMigrated = 'gcm_migrated';
  static const _keyFailedAttempts = 'login_failed_attempts';
  static const _keyLockoutUntil = 'login_lockout_until';

  static const _pbkdf2Iterations = 100000;

  static String? _sessionKey;
  static final _localAuth = LocalAuthentication();

  static String? get sessionKey => _sessionKey;

  static String decrypt(String encrypted) {
    if (_sessionKey == null) return '';
    return EncryptionService.decrypt(encrypted, _sessionKey!);
  }

  static Future<bool> isSetUp() async {
    final hash = await secureStorage.read(key: _keyHash);
    return hash != null;
  }

  static Future<void> setup(String masterPassword) async {
    final salt = _generateSalt();
    final hash = _pbkdf2Hash(masterPassword, salt);
    final aesKey = EncryptionService.generateKey();
    await secureStorage.write(key: _keySalt, value: salt);
    await secureStorage.write(key: _keyHash, value: hash);
    await secureStorage.write(key: _keyHashVersion, value: '2');
    await secureStorage.write(key: _keyAes, value: aesKey);
    _sessionKey = aesKey;
  }

  // Returns remaining lockout duration, or null if not locked out.
  static Future<Duration?> getLockoutRemaining() async {
    final s = await secureStorage.read(key: _keyLockoutUntil);
    if (s == null) return null;
    final until = DateTime.parse(s);
    final remaining = until.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  static Future<bool> loginWithPassword(String masterPassword) async {
    if (await getLockoutRemaining() != null) return false;

    final salt = await secureStorage.read(key: _keySalt);
    final storedHash = await secureStorage.read(key: _keyHash);
    final version = await secureStorage.read(key: _keyHashVersion) ?? '1';
    if (salt == null || storedHash == null) return false;

    final bool matches;
    if (version == '1') {
      matches = _constantEquals(_sha256Hash(masterPassword, salt), storedHash);
    } else {
      matches = _constantEquals(_pbkdf2Hash(masterPassword, salt), storedHash);
    }

    if (!matches) {
      await _recordFailedAttempt();
      return false;
    }

    if (version == '1') {
      final newSalt = _generateSalt();
      await secureStorage.write(key: _keySalt, value: newSalt);
      await secureStorage.write(key: _keyHash, value: _pbkdf2Hash(masterPassword, newSalt));
      await secureStorage.write(key: _keyHashVersion, value: '2');
    }

    _sessionKey = await secureStorage.read(key: _keyAes);
    if (_sessionKey != null) {
      await _clearFailedAttempts();
      unawaited(_migrateToGcm());
    }
    return _sessionKey != null;
  }

  static Future<bool> loginWithBiometric() async {
    final bioEnabled = await secureStorage.read(key: _keyBioEnabled);
    if (bioEnabled != 'true') return false;
    final canAuth =
        await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    if (!canAuth) return false;
    final didAuth = await _localAuth.authenticate(
      localizedReason: 'Unlock Odin Vault',
      options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
    );
    if (!didAuth) return false;
    _sessionKey = await secureStorage.read(key: _keyAes);
    if (_sessionKey != null) unawaited(_migrateToGcm());
    return _sessionKey != null;
  }

  static Future<bool> isBiometricEnabled() async {
    final val = await secureStorage.read(key: _keyBioEnabled);
    return val == 'true';
  }

  static Future<bool> isBiometricAvailable() async {
    return await _localAuth.canCheckBiometrics ||
        await _localAuth.isDeviceSupported();
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await secureStorage.write(key: _keyBioEnabled, value: enabled ? 'true' : 'false');
  }

  static Future<bool> verifyPassword(String password) async {
    final salt = await secureStorage.read(key: _keySalt);
    final storedHash = await secureStorage.read(key: _keyHash);
    final version = await secureStorage.read(key: _keyHashVersion) ?? '1';
    if (salt == null || storedHash == null) return false;
    if (version == '1') return _constantEquals(_sha256Hash(password, salt), storedHash);
    return _constantEquals(_pbkdf2Hash(password, salt), storedHash);
  }

  static Future<void> changeMasterPassword(String newPassword) async {
    final salt = _generateSalt();
    await secureStorage.write(key: _keySalt, value: salt);
    await secureStorage.write(key: _keyHash, value: _pbkdf2Hash(newPassword, salt));
    await secureStorage.write(key: _keyHashVersion, value: '2');
  }

  static void logout() {
    _sessionKey = null;
    DatabaseService.close().ignore();
  }

  static Future<void> deleteAll() async {
    await secureStorage.deleteAll();
    _sessionKey = null;
    await DatabaseService.close();
  }

  static Future<void> _recordFailedAttempt() async {
    final current =
        int.tryParse(await secureStorage.read(key: _keyFailedAttempts) ?? '0') ?? 0;
    final count = current + 1;
    await secureStorage.write(key: _keyFailedAttempts, value: count.toString());
    if (count >= 5) {
      final lockMinutes = count >= 10 ? 24 * 60 : pow(2, count - 5).toInt();
      final until = DateTime.now().add(Duration(minutes: lockMinutes));
      await secureStorage.write(key: _keyLockoutUntil, value: until.toIso8601String());
    }
  }

  static Future<void> _clearFailedAttempts() async {
    await secureStorage.delete(key: _keyFailedAttempts);
    await secureStorage.delete(key: _keyLockoutUntil);
  }

  static Future<void> _migrateToGcm() async {
    try {
      final done = await secureStorage.read(key: _keyGcmMigrated);
      if (done == 'true') return;
      final passwords = await DatabaseService.getPasswords();
      for (final e in passwords) {
        if (!e.encryptedPassword.startsWith('gcm:')) {
          final plain = EncryptionService.decrypt(e.encryptedPassword, _sessionKey!);
          await DatabaseService.updatePassword(e.copyWith(
            encryptedPassword: EncryptionService.encrypt(plain, _sessionKey!),
            updatedAt: e.updatedAt,
          ));
        }
      }
      final totps = await DatabaseService.getTotpEntries();
      for (final e in totps) {
        if (!e.encryptedSecret.startsWith('gcm:')) {
          final plain = EncryptionService.decrypt(e.encryptedSecret, _sessionKey!);
          await DatabaseService.updateTotp(e.copyWithSecret(
            EncryptionService.encrypt(plain, _sessionKey!),
          ));
        }
      }
      await secureStorage.write(key: _keyGcmMigrated, value: 'true');
    } catch (_) {
      // Will retry on next login since gcm_migrated flag won't be set
    }
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  // Constant-time string comparison to prevent timing side-channels.
  static bool _constantEquals(String a, String b) {
    final ab = utf8.encode(a);
    final bb = utf8.encode(b);
    if (ab.length != bb.length) return false;
    var diff = 0;
    for (var i = 0; i < ab.length; i++) {
      diff |= ab[i] ^ bb[i];
    }
    return diff == 0;
  }

  static String _pbkdf2Hash(String password, String salt) {
    final saltBytes = Uint8List.fromList(base64Decode(salt));
    final passwordBytes = Uint8List.fromList(utf8.encode(password));
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(saltBytes, _pbkdf2Iterations, 32));
    return base64Encode(pbkdf2.process(passwordBytes));
  }

  // Kept for migrating existing SHA-256 hashes (hash_version = '1')
  static String _sha256Hash(String password, String salt) {
    return sha256.convert(utf8.encode(password + salt)).toString();
  }
}
