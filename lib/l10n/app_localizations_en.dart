// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Odin Vault';

  @override
  String get loginSubtitle => 'Enter your master password to unlock.';

  @override
  String get masterPasswordLabel => 'Master Password';

  @override
  String get unlockButton => 'Unlock';

  @override
  String get useBiometric => 'Use Biometric';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get incorrectPassword => 'Incorrect master password.';

  @override
  String get biometricFailed => 'Biometric authentication failed.';

  @override
  String get createVaultSubtitle =>
      'Create a master password to secure your vault.';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String passwordStrength(String label) {
    return 'Strength: $label';
  }

  @override
  String get strengthWeak => 'Weak';

  @override
  String get strengthFair => 'Fair';

  @override
  String get strengthStrong => 'Strong';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get createVaultButton => 'Create Vault';

  @override
  String get searchPasswords => 'Search passwords...';

  @override
  String get noPasswordsYet => 'No passwords yet.\nTap + to add one.';

  @override
  String noSearchResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get lockVault => 'Lock';

  @override
  String get addPasswordTooltip => 'Add password';

  @override
  String get deleteEntryTitle => 'Delete Entry';

  @override
  String deleteEntryContent(String title) {
    return 'Delete \"$title\"? This cannot be undone.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get passwordsTab => 'Passwords';

  @override
  String get twoFaTab => '2FA';

  @override
  String get settingsTab => 'Settings';

  @override
  String get editPasswordTitle => 'Edit Password';

  @override
  String get newPasswordTitle => 'New Password';

  @override
  String get save => 'Save';

  @override
  String get titleField => 'Title *';

  @override
  String get titleHint => 'e.g. Gmail, Netflix';

  @override
  String get usernameField => 'Username / Email *';

  @override
  String get passwordField => 'Password *';

  @override
  String get urlField => 'URL (optional)';

  @override
  String get urlHint => 'https://example.com';

  @override
  String get notesField => 'Notes (optional)';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get addPasswordButton => 'Add Password';

  @override
  String get toggleVisibility => 'Toggle visibility';

  @override
  String get generatePassword => 'Generate password';

  @override
  String get noTotpEntries =>
      'No 2FA entries yet.\nTap + to add an authenticator.';

  @override
  String refreshesIn(int seconds) {
    return 'Refreshes in ${seconds}s';
  }

  @override
  String get removeTwoFaTitle => 'Remove 2FA';

  @override
  String removeTwoFaContent(String name) {
    return 'Remove \"$name\"? This cannot be undone.';
  }

  @override
  String get remove => 'Remove';

  @override
  String get addTwoFaTooltip => 'Add 2FA';

  @override
  String get addTwoFaTitle => 'Add 2FA Account';

  @override
  String get accountNameField => 'Account Name *';

  @override
  String get accountNameHint => 'e.g. john@gmail.com';

  @override
  String get issuerField => 'Issuer';

  @override
  String get issuerHint => 'e.g. Google';

  @override
  String get secretKeyField => 'Secret Key *';

  @override
  String get secretKeyHint => 'Base32 secret from your app';

  @override
  String get secretKeyHelp =>
      'Enter the base32 secret key shown when setting up 2FA in your account.';

  @override
  String get required => 'Required';

  @override
  String get add => 'Add';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get security => 'Security';

  @override
  String get biometricUnlock => 'Biometric Unlock';

  @override
  String get biometricSubtitle => 'Use fingerprint to unlock vault';

  @override
  String get changeMasterPassword => 'Change Master Password';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get resetVault => 'Reset Vault';

  @override
  String get resetVaultSubtitle => 'Delete all data and start over';

  @override
  String get resetVaultContent =>
      'This will permanently delete ALL passwords, 2FA entries, and your master password. This cannot be undone.';

  @override
  String get resetEverything => 'Reset Everything';

  @override
  String get about => 'About';

  @override
  String get aboutSubtitle =>
      'v1.0.0 - Local password manager\nAll data stored on this device only.';

  @override
  String get language => 'Language';

  @override
  String get changePasswordTitle => 'Change Master Password';

  @override
  String get currentPasswordField => 'Current Password';

  @override
  String get newPasswordField => 'New Password';

  @override
  String get confirmNewPasswordField => 'Confirm New Password';

  @override
  String get incorrectCurrentPassword => 'Current password is incorrect.';

  @override
  String get minimumCharacters => 'Minimum 8 characters';

  @override
  String get update => 'Update';

  @override
  String get passwordUpdated => 'Master password updated.';

  @override
  String get copyPasswordTooltip => 'Copy password';

  @override
  String get usernameCopied => 'Username copied';

  @override
  String get passwordCopied => 'Password copied';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get urlLabel => 'URL';

  @override
  String get notesLabel => 'Notes';

  @override
  String get edit => 'Edit';

  @override
  String get deleteButton => 'Delete';

  @override
  String get togglePasswordTooltip => 'Toggle password';

  @override
  String get copyCodeTooltip => 'Copy code';

  @override
  String get removeTooltip => 'Remove';

  @override
  String get codeCopied => 'Code copied';

  @override
  String get data => 'Data';

  @override
  String get exportVault => 'Export Vault';

  @override
  String get exportVaultSubtitle => 'Save an encrypted backup file';

  @override
  String get importVault => 'Import Vault';

  @override
  String get importVaultSubtitle => 'Restore from a backup file';

  @override
  String get exportDialogTitle => 'Export Vault';

  @override
  String get exportDialogContent =>
      'Enter your master password to create an encrypted backup.';

  @override
  String get exportButton => 'Export';

  @override
  String get exportSuccess => 'Vault exported successfully';

  @override
  String get importDialogTitle => 'Import Vault';

  @override
  String get importDialogContent =>
      'Enter the master password used when this backup was created.';

  @override
  String get importButton => 'Import';

  @override
  String importSuccess(int passwords, int totp) {
    return 'Imported $passwords passwords and $totp 2FA entries';
  }

  @override
  String get importFailed => 'Incorrect password or corrupted backup.';

  @override
  String get importFileError => 'Could not read the selected file.';

  @override
  String get generatorTab => 'Generator';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get copy => 'Copy';

  @override
  String get passwordLength => 'Length';

  @override
  String get includeUppercase => 'Uppercase (A-Z)';

  @override
  String get includeLowercase => 'Lowercase (a-z)';

  @override
  String get includeNumbers => 'Numbers (0-9)';

  @override
  String get includeSymbols => 'Symbols (!@#...)';

  @override
  String get generatorHistory => 'History';

  @override
  String get autoLock => 'Auto-lock';

  @override
  String get autoLockSubtitle => 'Lock vault when backgrounded';

  @override
  String get autoLockAfter => 'Lock after';

  @override
  String lockAfterMinutes(int n) {
    return '$n min';
  }

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get scanQrButton => 'Scan QR';

  @override
  String get scanQrHint => 'Point the camera at an authenticator QR code';
}
