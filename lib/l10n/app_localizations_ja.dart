// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Odin Vault';

  @override
  String get loginSubtitle => 'マスターパスワードを入力してロックを解除してください。';

  @override
  String get masterPasswordLabel => 'マスターパスワード';

  @override
  String get unlockButton => 'ロック解除';

  @override
  String get useBiometric => '生体認証を使用';

  @override
  String get enterYourPassword => 'パスワードを入力してください';

  @override
  String get incorrectPassword => 'マスターパスワードが違います。';

  @override
  String get biometricFailed => '生体認証に失敗しました。';

  @override
  String get createVaultSubtitle => 'ボルトを保護するためのマスターパスワードを作成してください。';

  @override
  String get confirmPasswordLabel => 'パスワードの確認';

  @override
  String passwordStrength(String label) {
    return '強度: $label';
  }

  @override
  String get strengthWeak => '弱い';

  @override
  String get strengthFair => '普通';

  @override
  String get strengthStrong => '強い';

  @override
  String get passwordTooShort => 'パスワードは8文字以上必要です';

  @override
  String get passwordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get createVaultButton => 'ボルトを作成';

  @override
  String get searchPasswords => 'パスワードを検索...';

  @override
  String get noPasswordsYet => 'パスワードがありません。\n＋をタップして追加してください。';

  @override
  String noSearchResults(String query) {
    return '「$query」の結果はありません';
  }

  @override
  String get lockVault => 'ロック';

  @override
  String get addPasswordTooltip => 'パスワードを追加';

  @override
  String get deleteEntryTitle => 'エントリを削除';

  @override
  String deleteEntryContent(String title) {
    return '「$title」を削除しますか？この操作は元に戻せません。';
  }

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get passwordsTab => 'パスワード';

  @override
  String get twoFaTab => '2FA';

  @override
  String get settingsTab => '設定';

  @override
  String get editPasswordTitle => 'パスワードを編集';

  @override
  String get newPasswordTitle => '新しいパスワード';

  @override
  String get save => '保存';

  @override
  String get titleField => 'タイトル *';

  @override
  String get titleHint => '例：Gmail、Netflix';

  @override
  String get usernameField => 'ユーザー名 / メール *';

  @override
  String get passwordField => 'パスワード *';

  @override
  String get urlField => 'URL（任意）';

  @override
  String get urlHint => 'https://example.com';

  @override
  String get notesField => 'メモ（任意）';

  @override
  String get titleRequired => 'タイトルは必須です';

  @override
  String get usernameRequired => 'ユーザー名は必須です';

  @override
  String get passwordRequired => 'パスワードは必須です';

  @override
  String get saveChanges => '変更を保存';

  @override
  String get addPasswordButton => 'パスワードを追加';

  @override
  String get toggleVisibility => '表示切替';

  @override
  String get generatePassword => 'パスワードを生成';

  @override
  String get noTotpEntries => '2FAエントリがありません。\n＋をタップして認証アプリを追加してください。';

  @override
  String refreshesIn(int seconds) {
    return '$seconds秒後に更新';
  }

  @override
  String get removeTwoFaTitle => '2FAを削除';

  @override
  String removeTwoFaContent(String name) {
    return '「$name」を削除しますか？この操作は元に戻せません。';
  }

  @override
  String get remove => '削除';

  @override
  String get addTwoFaTooltip => '2FAを追加';

  @override
  String get addTwoFaTitle => '2FAアカウントを追加';

  @override
  String get accountNameField => 'アカウント名 *';

  @override
  String get accountNameHint => '例：john@gmail.com';

  @override
  String get issuerField => '発行者';

  @override
  String get issuerHint => '例：Google';

  @override
  String get secretKeyField => 'シークレットキー *';

  @override
  String get secretKeyHint => 'アプリのBase32シークレット';

  @override
  String get secretKeyHelp => 'アカウントで2FAを設定する際に表示されるBase32シークレットキーを入力してください。';

  @override
  String get required => '必須';

  @override
  String get add => '追加';

  @override
  String get appearance => '外観';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get security => 'セキュリティ';

  @override
  String get biometricUnlock => '生体認証でロック解除';

  @override
  String get biometricSubtitle => '指紋でボルトをロック解除';

  @override
  String get changeMasterPassword => 'マスターパスワードを変更';

  @override
  String get dangerZone => '危険な操作';

  @override
  String get resetVault => 'ボルトをリセット';

  @override
  String get resetVaultSubtitle => 'すべてのデータを削除して最初からやり直す';

  @override
  String get resetVaultContent =>
      'すべてのパスワード、2FAエントリ、マスターパスワードが完全に削除されます。この操作は元に戻せません。';

  @override
  String get resetEverything => 'すべてをリセット';

  @override
  String get about => 'このアプリについて';

  @override
  String get aboutSubtitle =>
      'v1.0.0 - ローカルパスワードマネージャー\nすべてのデータはこのデバイスにのみ保存されます。';

  @override
  String get language => '言語';

  @override
  String get changePasswordTitle => 'マスターパスワードを変更';

  @override
  String get currentPasswordField => '現在のパスワード';

  @override
  String get newPasswordField => '新しいパスワード';

  @override
  String get confirmNewPasswordField => '新しいパスワードの確認';

  @override
  String get incorrectCurrentPassword => '現在のパスワードが違います。';

  @override
  String get minimumCharacters => '最低8文字';

  @override
  String get update => '更新';

  @override
  String get passwordUpdated => 'マスターパスワードが更新されました。';

  @override
  String get copyPasswordTooltip => 'パスワードをコピー';

  @override
  String get usernameCopied => 'ユーザー名をコピーしました';

  @override
  String get passwordCopied => 'パスワードをコピーしました';

  @override
  String get usernameLabel => 'ユーザー名';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get urlLabel => 'URL';

  @override
  String get notesLabel => 'メモ';

  @override
  String get edit => '編集';

  @override
  String get deleteButton => '削除';

  @override
  String get togglePasswordTooltip => 'パスワードの表示切替';

  @override
  String get copyCodeTooltip => 'コードをコピー';

  @override
  String get removeTooltip => '削除';

  @override
  String get codeCopied => 'コードをコピーしました';

  @override
  String get data => 'データ';

  @override
  String get exportVault => 'ボルトをエクスポート';

  @override
  String get exportVaultSubtitle => '暗号化されたバックアップファイルを保存';

  @override
  String get importVault => 'ボルトをインポート';

  @override
  String get importVaultSubtitle => 'バックアップファイルから復元';

  @override
  String get exportDialogTitle => 'ボルトをエクスポート';

  @override
  String get exportDialogContent => '暗号化されたバックアップを作成するにはマスターパスワードを入力してください。';

  @override
  String get exportButton => 'エクスポート';

  @override
  String get exportSuccess => 'ボルトをエクスポートしました';

  @override
  String get importDialogTitle => 'ボルトをインポート';

  @override
  String get importDialogContent => 'このバックアップを作成したときのマスターパスワードを入力してください。';

  @override
  String get importButton => 'インポート';

  @override
  String importSuccess(int passwords, int totp) {
    return '$passwords件のパスワードと$totp件の2FAエントリをインポートしました';
  }

  @override
  String get importFailed => 'パスワードが違うか、バックアップが破損しています。';

  @override
  String get importFileError => '選択したファイルを読み込めませんでした。';

  @override
  String get generatorTab => 'ジェネレーター';

  @override
  String get regenerate => '再生成';

  @override
  String get copy => 'コピー';

  @override
  String get passwordLength => '長さ';

  @override
  String get includeUppercase => '大文字 (A-Z)';

  @override
  String get includeLowercase => '小文字 (a-z)';

  @override
  String get includeNumbers => '数字 (0-9)';

  @override
  String get includeSymbols => '記号 (!@#...)';

  @override
  String get generatorHistory => '履歴';

  @override
  String get autoLock => '自動ロック';

  @override
  String get autoLockSubtitle => 'バックグラウンド時にボルトをロック';

  @override
  String get autoLockAfter => 'ロックまでの時間';

  @override
  String lockAfterMinutes(int n) {
    return '$n 分';
  }
}
