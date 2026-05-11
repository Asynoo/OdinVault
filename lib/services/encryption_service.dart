import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;

class EncryptionService {
  static const _gcmPrefix = 'gcm:';

  static String generateKey() {
    final key = enc.Key.fromSecureRandom(32);
    return key.base64;
  }

  static String encrypt(String plaintext, String base64Key) {
    final key = enc.Key.fromBase64(base64Key);
    final iv = enc.IV.fromSecureRandom(12);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    final combined = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
    return _gcmPrefix + base64Encode(combined);
  }

  static String decrypt(String ciphertext, String base64Key) {
    return ciphertext.startsWith(_gcmPrefix)
        ? _decryptGcm(ciphertext.substring(_gcmPrefix.length), base64Key)
        : _decryptCbc(ciphertext, base64Key);
  }

  static String _decryptGcm(String ciphertext, String base64Key) {
    final key = enc.Key.fromBase64(base64Key);
    final bytes = base64Decode(ciphertext);
    final iv = enc.IV(Uint8List.fromList(bytes.sublist(0, 12)));
    final encryptedBytes =
        enc.Encrypted(Uint8List.fromList(bytes.sublist(12)));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.gcm));
    return encrypter.decrypt(encryptedBytes, iv: iv);
  }

  // Legacy CBC - retained for migrating existing data
  static String _decryptCbc(String ciphertext, String base64Key) {
    final key = enc.Key.fromBase64(base64Key);
    final bytes = base64Decode(ciphertext);
    final iv = enc.IV(Uint8List.fromList(bytes.sublist(0, 16)));
    final encryptedBytes =
        enc.Encrypted(Uint8List.fromList(bytes.sublist(16)));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return encrypter.decrypt(encryptedBytes, iv: iv);
  }
}
