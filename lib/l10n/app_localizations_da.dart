// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appTitle => 'Odin Vault';

  @override
  String get loginSubtitle => 'Indtast din hovedadgangskode for at låse op.';

  @override
  String get masterPasswordLabel => 'Hovedadgangskode';

  @override
  String get unlockButton => 'Lås op';

  @override
  String get useBiometric => 'Brug biometri';

  @override
  String get enterYourPassword => 'Indtast din adgangskode';

  @override
  String get incorrectPassword => 'Forkert hovedadgangskode.';

  @override
  String get biometricFailed => 'Biometrisk godkendelse mislykkedes.';

  @override
  String get createVaultSubtitle =>
      'Opret en hovedadgangskode for at sikre din boks.';

  @override
  String get confirmPasswordLabel => 'Bekræft adgangskode';

  @override
  String passwordStrength(String label) {
    return 'Styrke: $label';
  }

  @override
  String get strengthWeak => 'Svag';

  @override
  String get strengthFair => 'Middel';

  @override
  String get strengthStrong => 'Stærk';

  @override
  String get passwordTooShort => 'Adgangskoden skal være mindst 8 tegn';

  @override
  String get passwordsDoNotMatch => 'Adgangskoderne er ikke ens';

  @override
  String get createVaultButton => 'Opret boks';

  @override
  String get searchPasswords => 'Søg adgangskoder...';

  @override
  String get noPasswordsYet =>
      'Ingen adgangskoder endnu.\nTryk på + for at tilføje.';

  @override
  String noSearchResults(String query) {
    return 'Ingen resultater for \"$query\"';
  }

  @override
  String get lockVault => 'Lås';

  @override
  String get addPasswordTooltip => 'Tilføj adgangskode';

  @override
  String get deleteEntryTitle => 'Slet post';

  @override
  String deleteEntryContent(String title) {
    return 'Slet \"$title\"? Dette kan ikke fortrydes.';
  }

  @override
  String get cancel => 'Annuller';

  @override
  String get delete => 'Slet';

  @override
  String get passwordsTab => 'Adgangskoder';

  @override
  String get twoFaTab => '2FA';

  @override
  String get settingsTab => 'Indstillinger';

  @override
  String get editPasswordTitle => 'Rediger adgangskode';

  @override
  String get newPasswordTitle => 'Ny adgangskode';

  @override
  String get save => 'Gem';

  @override
  String get titleField => 'Titel *';

  @override
  String get titleHint => 'f.eks. Gmail, Netflix';

  @override
  String get usernameField => 'Brugernavn / E-mail *';

  @override
  String get passwordField => 'Adgangskode *';

  @override
  String get urlField => 'URL (valgfri)';

  @override
  String get urlHint => 'https://eksempel.dk';

  @override
  String get notesField => 'Noter (valgfri)';

  @override
  String get titleRequired => 'Titel er påkrævet';

  @override
  String get usernameRequired => 'Brugernavn er påkrævet';

  @override
  String get passwordRequired => 'Adgangskode er påkrævet';

  @override
  String get saveChanges => 'Gem ændringer';

  @override
  String get addPasswordButton => 'Tilføj adgangskode';

  @override
  String get toggleVisibility => 'Skift synlighed';

  @override
  String get generatePassword => 'Generer adgangskode';

  @override
  String get noTotpEntries =>
      'Ingen 2FA-poster endnu.\nTryk på + for at tilføje en.';

  @override
  String refreshesIn(int seconds) {
    return 'Opdateres om ${seconds}s';
  }

  @override
  String get removeTwoFaTitle => 'Fjern 2FA';

  @override
  String removeTwoFaContent(String name) {
    return 'Fjern \"$name\"? Dette kan ikke fortrydes.';
  }

  @override
  String get remove => 'Fjern';

  @override
  String get addTwoFaTooltip => 'Tilføj 2FA';

  @override
  String get addTwoFaTitle => 'Tilføj 2FA-konto';

  @override
  String get accountNameField => 'Kontonavn *';

  @override
  String get accountNameHint => 'f.eks. john@gmail.com';

  @override
  String get issuerField => 'Udsteder';

  @override
  String get issuerHint => 'f.eks. Google';

  @override
  String get secretKeyField => 'Hemmelig nøgle *';

  @override
  String get secretKeyHint => 'Base32-hemmelighed fra din app';

  @override
  String get secretKeyHelp =>
      'Indtast den base32-hemmelige nøgle, der vises ved opsætning af 2FA i din konto.';

  @override
  String get required => 'Påkrævet';

  @override
  String get add => 'Tilføj';

  @override
  String get appearance => 'Udseende';

  @override
  String get darkMode => 'Mørk tilstand';

  @override
  String get security => 'Sikkerhed';

  @override
  String get biometricUnlock => 'Biometrisk oplåsning';

  @override
  String get biometricSubtitle => 'Brug fingeraftryk til at låse boksen op';

  @override
  String get changeMasterPassword => 'Skift hovedadgangskode';

  @override
  String get dangerZone => 'Farezonen';

  @override
  String get resetVault => 'Nulstil boks';

  @override
  String get resetVaultSubtitle => 'Slet alle data og start forfra';

  @override
  String get resetVaultContent =>
      'Dette vil permanent slette ALLE adgangskoder, 2FA-poster og din hovedadgangskode. Dette kan ikke fortrydes.';

  @override
  String get resetEverything => 'Nulstil alt';

  @override
  String get about => 'Om';

  @override
  String get aboutSubtitle =>
      'v1.0.0 - Lokal adgangskodehåndtering\nAlle data gemmes kun på denne enhed.';

  @override
  String get language => 'Sprog';

  @override
  String get changePasswordTitle => 'Skift hovedadgangskode';

  @override
  String get currentPasswordField => 'Nuværende adgangskode';

  @override
  String get newPasswordField => 'Ny adgangskode';

  @override
  String get confirmNewPasswordField => 'Bekræft ny adgangskode';

  @override
  String get incorrectCurrentPassword => 'Nuværende adgangskode er forkert.';

  @override
  String get minimumCharacters => 'Mindst 8 tegn';

  @override
  String get update => 'Opdater';

  @override
  String get passwordUpdated => 'Hovedadgangskoden er opdateret.';

  @override
  String get copyPasswordTooltip => 'Kopiér adgangskode';

  @override
  String get usernameCopied => 'Brugernavn kopieret';

  @override
  String get passwordCopied => 'Adgangskode kopieret';

  @override
  String get usernameLabel => 'Brugernavn';

  @override
  String get passwordLabel => 'Adgangskode';

  @override
  String get urlLabel => 'URL';

  @override
  String get notesLabel => 'Noter';

  @override
  String get edit => 'Rediger';

  @override
  String get deleteButton => 'Slet';

  @override
  String get togglePasswordTooltip => 'Skift adgangskodevisning';

  @override
  String get copyCodeTooltip => 'Kopiér kode';

  @override
  String get removeTooltip => 'Fjern';

  @override
  String get codeCopied => 'Kode kopieret';

  @override
  String get data => 'Data';

  @override
  String get exportVault => 'Eksporter boks';

  @override
  String get exportVaultSubtitle => 'Gem en krypteret sikkerhedskopifil';

  @override
  String get importVault => 'Importer boks';

  @override
  String get importVaultSubtitle => 'Gendan fra en sikkerhedskopifil';

  @override
  String get exportDialogTitle => 'Eksporter boks';

  @override
  String get exportDialogContent =>
      'Indtast din hovedadgangskode for at oprette en krypteret sikkerhedskopi.';

  @override
  String get exportButton => 'Eksporter';

  @override
  String get exportSuccess => 'Boks eksporteret';

  @override
  String get importDialogTitle => 'Importer boks';

  @override
  String get importDialogContent =>
      'Indtast den hovedadgangskode, der blev brugt til at oprette denne sikkerhedskopi.';

  @override
  String get importButton => 'Importer';

  @override
  String importSuccess(int passwords, int totp) {
    return 'Importerede $passwords adgangskoder og $totp 2FA-poster';
  }

  @override
  String get importFailed =>
      'Forkert adgangskode eller beskadiget sikkerhedskopi.';

  @override
  String get importFileError => 'Kunne ikke læse den valgte fil.';

  @override
  String get generatorTab => 'Generator';

  @override
  String get regenerate => 'Generer';

  @override
  String get copy => 'Kopiér';

  @override
  String get passwordLength => 'Længde';

  @override
  String get includeUppercase => 'Store bogstaver (A-Z)';

  @override
  String get includeLowercase => 'Små bogstaver (a-z)';

  @override
  String get includeNumbers => 'Tal (0-9)';

  @override
  String get includeSymbols => 'Symboler (!@#...)';

  @override
  String get generatorHistory => 'Historik';

  @override
  String get autoLock => 'Automatisk lås';

  @override
  String get autoLockSubtitle => 'Lås boksen, når appen er i baggrunden';

  @override
  String get autoLockAfter => 'Lås efter';

  @override
  String lockAfterMinutes(int n) {
    return '$n min';
  }

  @override
  String get scanQrCode => 'Scan QR-kode';

  @override
  String get scanQrButton => 'Scan QR';

  @override
  String get scanQrHint => 'Ret kameraet mod en autentificeringskode';

  @override
  String weakPasswordsCount(int n) {
    return '$n svage';
  }

  @override
  String reusedPasswordsCount(int n) {
    return '$n genbrugte';
  }

  @override
  String get weakPasswordWarning => 'Svag adgangskode';

  @override
  String get reusedPasswordWarning => 'Adgangskode genbrugt';
}
