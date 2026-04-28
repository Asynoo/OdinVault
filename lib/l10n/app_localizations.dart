import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_da.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('da'),
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Odin Vault'**
  String get appTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your master password to unlock.'**
  String get loginSubtitle;

  /// No description provided for @masterPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Master Password'**
  String get masterPasswordLabel;

  /// No description provided for @unlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockButton;

  /// No description provided for @useBiometric.
  ///
  /// In en, this message translates to:
  /// **'Use Biometric'**
  String get useBiometric;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect master password.'**
  String get incorrectPassword;

  /// No description provided for @biometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed.'**
  String get biometricFailed;

  /// No description provided for @createVaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a master password to secure your vault.'**
  String get createVaultSubtitle;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength: {label}'**
  String passwordStrength(String label);

  /// No description provided for @strengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get strengthWeak;

  /// No description provided for @strengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get strengthFair;

  /// No description provided for @strengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strengthStrong;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @createVaultButton.
  ///
  /// In en, this message translates to:
  /// **'Create Vault'**
  String get createVaultButton;

  /// No description provided for @searchPasswords.
  ///
  /// In en, this message translates to:
  /// **'Search passwords...'**
  String get searchPasswords;

  /// No description provided for @noPasswordsYet.
  ///
  /// In en, this message translates to:
  /// **'No passwords yet.\nTap + to add one.'**
  String get noPasswordsYet;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noSearchResults(String query);

  /// No description provided for @lockVault.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lockVault;

  /// No description provided for @addPasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add password'**
  String get addPasswordTooltip;

  /// No description provided for @deleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get deleteEntryTitle;

  /// No description provided for @deleteEntryContent.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? This cannot be undone.'**
  String deleteEntryContent(String title);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @passwordsTab.
  ///
  /// In en, this message translates to:
  /// **'Passwords'**
  String get passwordsTab;

  /// No description provided for @twoFaTab.
  ///
  /// In en, this message translates to:
  /// **'2FA'**
  String get twoFaTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @editPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Password'**
  String get editPasswordTitle;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @titleField.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get titleField;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Gmail, Netflix'**
  String get titleHint;

  /// No description provided for @usernameField.
  ///
  /// In en, this message translates to:
  /// **'Username / Email *'**
  String get usernameField;

  /// No description provided for @passwordField.
  ///
  /// In en, this message translates to:
  /// **'Password *'**
  String get passwordField;

  /// No description provided for @urlField.
  ///
  /// In en, this message translates to:
  /// **'URL (optional)'**
  String get urlField;

  /// No description provided for @urlHint.
  ///
  /// In en, this message translates to:
  /// **'https://example.com'**
  String get urlHint;

  /// No description provided for @notesField.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesField;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @addPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Add Password'**
  String get addPasswordButton;

  /// No description provided for @toggleVisibility.
  ///
  /// In en, this message translates to:
  /// **'Toggle visibility'**
  String get toggleVisibility;

  /// No description provided for @generatePassword.
  ///
  /// In en, this message translates to:
  /// **'Generate password'**
  String get generatePassword;

  /// No description provided for @noTotpEntries.
  ///
  /// In en, this message translates to:
  /// **'No 2FA entries yet.\nTap + to add an authenticator.'**
  String get noTotpEntries;

  /// No description provided for @refreshesIn.
  ///
  /// In en, this message translates to:
  /// **'Refreshes in {seconds}s'**
  String refreshesIn(int seconds);

  /// No description provided for @removeTwoFaTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove 2FA'**
  String get removeTwoFaTitle;

  /// No description provided for @removeTwoFaContent.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\"? This cannot be undone.'**
  String removeTwoFaContent(String name);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @addTwoFaTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add 2FA'**
  String get addTwoFaTooltip;

  /// No description provided for @addTwoFaTitle.
  ///
  /// In en, this message translates to:
  /// **'Add 2FA Account'**
  String get addTwoFaTitle;

  /// No description provided for @accountNameField.
  ///
  /// In en, this message translates to:
  /// **'Account Name *'**
  String get accountNameField;

  /// No description provided for @accountNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. john@gmail.com'**
  String get accountNameHint;

  /// No description provided for @issuerField.
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get issuerField;

  /// No description provided for @issuerHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Google'**
  String get issuerHint;

  /// No description provided for @secretKeyField.
  ///
  /// In en, this message translates to:
  /// **'Secret Key *'**
  String get secretKeyField;

  /// No description provided for @secretKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Base32 secret from your app'**
  String get secretKeyHint;

  /// No description provided for @secretKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter the base32 secret key shown when setting up 2FA in your account.'**
  String get secretKeyHelp;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @biometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Biometric Unlock'**
  String get biometricUnlock;

  /// No description provided for @biometricSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint to unlock vault'**
  String get biometricSubtitle;

  /// No description provided for @changeMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Change Master Password'**
  String get changeMasterPassword;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @resetVault.
  ///
  /// In en, this message translates to:
  /// **'Reset Vault'**
  String get resetVault;

  /// No description provided for @resetVaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data and start over'**
  String get resetVaultSubtitle;

  /// No description provided for @resetVaultContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete ALL passwords, 2FA entries, and your master password. This cannot be undone.'**
  String get resetVaultContent;

  /// No description provided for @resetEverything.
  ///
  /// In en, this message translates to:
  /// **'Reset Everything'**
  String get resetEverything;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'v1.0.0 - Local password manager\nAll data stored on this device only.'**
  String get aboutSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Master Password'**
  String get changePasswordTitle;

  /// No description provided for @currentPasswordField.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPasswordField;

  /// No description provided for @newPasswordField.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordField;

  /// No description provided for @confirmNewPasswordField.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPasswordField;

  /// No description provided for @incorrectCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get incorrectCurrentPassword;

  /// No description provided for @minimumCharacters.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get minimumCharacters;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Master password updated.'**
  String get passwordUpdated;

  /// No description provided for @copyPasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy password'**
  String get copyPasswordTooltip;

  /// No description provided for @usernameCopied.
  ///
  /// In en, this message translates to:
  /// **'Username copied'**
  String get usernameCopied;

  /// No description provided for @passwordCopied.
  ///
  /// In en, this message translates to:
  /// **'Password copied'**
  String get passwordCopied;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @urlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get urlLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @togglePasswordTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle password'**
  String get togglePasswordTooltip;

  /// No description provided for @copyCodeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCodeTooltip;

  /// No description provided for @removeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeTooltip;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get codeCopied;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @exportVault.
  ///
  /// In en, this message translates to:
  /// **'Export Vault'**
  String get exportVault;

  /// No description provided for @exportVaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save an encrypted backup file'**
  String get exportVaultSubtitle;

  /// No description provided for @importVault.
  ///
  /// In en, this message translates to:
  /// **'Import Vault'**
  String get importVault;

  /// No description provided for @importVaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup file'**
  String get importVaultSubtitle;

  /// No description provided for @exportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Vault'**
  String get exportDialogTitle;

  /// No description provided for @exportDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Enter your master password to create an encrypted backup.'**
  String get exportDialogContent;

  /// No description provided for @exportButton.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportButton;

  /// No description provided for @exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Vault exported successfully'**
  String get exportSuccess;

  /// No description provided for @importDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Vault'**
  String get importDialogTitle;

  /// No description provided for @importDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Enter the master password used when this backup was created.'**
  String get importDialogContent;

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importButton;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {passwords} passwords and {totp} 2FA entries'**
  String importSuccess(int passwords, int totp);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password or corrupted backup.'**
  String get importFailed;

  /// No description provided for @importFileError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected file.'**
  String get importFileError;

  /// No description provided for @generatorTab.
  ///
  /// In en, this message translates to:
  /// **'Generator'**
  String get generatorTab;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @passwordLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get passwordLength;

  /// No description provided for @includeUppercase.
  ///
  /// In en, this message translates to:
  /// **'Uppercase (A-Z)'**
  String get includeUppercase;

  /// No description provided for @includeLowercase.
  ///
  /// In en, this message translates to:
  /// **'Lowercase (a-z)'**
  String get includeLowercase;

  /// No description provided for @includeNumbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers (0-9)'**
  String get includeNumbers;

  /// No description provided for @includeSymbols.
  ///
  /// In en, this message translates to:
  /// **'Symbols (!@#...)'**
  String get includeSymbols;

  /// No description provided for @generatorHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get generatorHistory;

  /// No description provided for @autoLock.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock'**
  String get autoLock;

  /// No description provided for @autoLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Lock vault when backgrounded'**
  String get autoLockSubtitle;

  /// No description provided for @autoLockAfter.
  ///
  /// In en, this message translates to:
  /// **'Lock after'**
  String get autoLockAfter;

  /// No description provided for @lockAfterMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String lockAfterMinutes(int n);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['da', 'en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return AppLocalizationsDa();
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
