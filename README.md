# Odin Vault

A local-first password manager and TOTP authenticator built with Flutter. All data stays on your device - no cloud sync, no accounts.

## Features

- **Password vault** - store, edit, and delete credentials (title, username, password, URL, notes)
- **TOTP / 2FA** - add authenticator codes by secret key with live countdown
- **Biometric unlock** - fingerprint / face authentication via the device's secure hardware
- **Master password** - PBKDF2 (100,000 iterations, SHA-256 HMAC) with a random 32-byte salt; never stored in plaintext
- **Encrypted storage** - vault entries encrypted with AES-256-CBC; the key is held in Android Keystore via `flutter_secure_storage`
- **Light and dark mode** - toggle in Settings, preference persisted across sessions
- **Localization** - English, Danish, and Japanese
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
| Key derivation | pointycastle (PBKDF2 / SHA-256 HMAC) |
| Localization | flutter_localizations + intl |

## Getting started

### Prerequisites

- Flutter SDK >= 3.11.5
- Android SDK (for Android builds)

### Run

```bash
flutter pub get
flutter run
```

> On first launch you will be prompted to create a master password. This cannot be recovered - there is no backup mechanism.

## Security notes

- Encryption keys are generated at runtime with a cryptographically secure RNG and stored in the Android Keystore.
- The master password is hashed with PBKDF2 (100,000 iterations, SHA-256 HMAC, 32-byte random salt), making brute-force significantly harder than a plain hash - including on rooted devices.
- Existing vaults created with the old SHA-256 scheme are silently migrated to PBKDF2 on the next successful login.
- `android/local.properties` is excluded from version control - it is generated locally by the Flutter toolchain.

## License

MIT
