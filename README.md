# Odin Vault

A local-first password manager and TOTP authenticator built with Flutter. All data stays on your device - no cloud sync, no accounts.

## Features

- **Password vault** - store, edit, and delete credentials (title, username, password, URL, notes)
- **TOTP / 2FA** - add authenticator codes by secret key with live countdown
- **Biometric unlock** - fingerprint / face authentication via the device's secure hardware
- **Master password** - salted SHA-256 hash, never stored in plaintext
- **Encrypted storage** - vault entries encrypted with AES-256-CBC; the key is held in Android Keystore via `flutter_secure_storage`
- **Fully offline** - SQLite database, no network permissions required

## Tech stack

| Layer | Library |
| --- | --- |
| UI | Flutter / Material 3 |
| Local DB | sqflite |
| Secure key storage | flutter_secure_storage (Android Keystore) |
| Encryption | encrypt (AES-256-CBC) |
| Biometrics | local_auth |
| TOTP | otp |
| Hashing | crypto (SHA-256) |

## Getting started

### Prerequisites

- Flutter SDK ≥ 3.11.5
- Android SDK (for Android builds)

### Run

```bash
flutter pub get
flutter run
```

> On first launch you will be prompted to create a master password. This cannot be recovered - there is no backup mechanism.

## Security notes

- Encryption keys are generated at runtime with a cryptographically secure RNG and stored in the Android Keystore.
- The master password hash uses SHA-256 + a random 32-byte salt. A future improvement would be to replace this with a slow KDF (PBKDF2 / Argon2) for stronger resistance on rooted devices.
- `android/local.properties` is excluded from version control - it is generated locally by the Flutter toolchain.

## License

MIT
