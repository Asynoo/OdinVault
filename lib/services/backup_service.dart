import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'encryption_service.dart';

class BackupService {
  static const _iterations = 100000;

  static String createExport({
    required List<Map<String, dynamic>> passwords,
    required List<Map<String, dynamic>> totp,
    required String masterPassword,
  }) {
    final salt = _generateSalt();
    final derivedKey = _deriveKey(masterPassword, salt);
    final payload = jsonEncode({'passwords': passwords, 'totp': totp});
    final encryptedPayload = EncryptionService.encrypt(payload, derivedKey);
    return jsonEncode({
      'v': 1,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'salt': salt,
      'data': encryptedPayload,
    });
  }

  static Map<String, dynamic>? parseImport(
      String fileContent, String masterPassword) {
    try {
      final outer = jsonDecode(fileContent) as Map<String, dynamic>;
      if ((outer['v'] as int?) != 1) return null;
      final salt = outer['salt'] as String;
      final data = outer['data'] as String;
      final derivedKey = _deriveKey(masterPassword, salt);
      final payload = EncryptionService.decrypt(data, derivedKey);
      return jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static String _generateSalt() {
    final bytes =
        List<int>.generate(32, (_) => Random.secure().nextInt(256));
    return base64Encode(bytes);
  }

  static String _deriveKey(String password, String base64Salt) {
    final saltBytes = Uint8List.fromList(base64Decode(base64Salt));
    final passwordBytes = Uint8List.fromList(utf8.encode(password));
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(saltBytes, _iterations, 32));
    return base64Encode(pbkdf2.process(passwordBytes));
  }
}
