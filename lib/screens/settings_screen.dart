import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../models/password_entry.dart';
import '../models/totp_entry.dart';
import '../services/auth_service.dart';
import '../services/auto_lock_service.dart';
import '../services/backup_service.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/password_field.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback? onDataChanged;
  const SettingsScreen({super.key, required this.onLogout, this.onDataChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _bioEnabled = false;
  bool _bioAvailable = false;
  ThemeMode _themeMode = ThemeService.notifier.value;
  bool _autoLockEnabled = false;
  int _autoLockMinutes = 5;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final results = await Future.wait([
      AuthService.isBiometricAvailable(),
      AuthService.isBiometricEnabled(),
      AutoLockService.isEnabled(),
      AutoLockService.getMinutes(),
    ]);
    setState(() {
      _bioAvailable = results[0] as bool;
      _bioEnabled = results[1] as bool;
      _autoLockEnabled = results[2] as bool;
      _autoLockMinutes = results[3] as int;
      _themeMode = ThemeService.notifier.value;
    });
  }

  Future<void> _toggleAutoLock(bool val) async {
    await AutoLockService.setEnabled(val);
    setState(() => _autoLockEnabled = val);
  }

  Future<void> _setAutoLockMinutes(int minutes) async {
    await AutoLockService.setMinutes(minutes);
    setState(() => _autoLockMinutes = minutes);
  }

  Future<void> _toggleTheme(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    await ThemeService.setMode(mode);
    setState(() => _themeMode = mode);
  }

  Future<void> _toggleBiometric(bool val) async {
    await AuthService.setBiometricEnabled(val);
    setState(() => _bioEnabled = val);
  }

  Future<void> _changePassword() async {
    final l = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _ChangePasswordDialog(),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.passwordUpdated)),
      );
    }
  }

  Future<void> _exportVault() async {
    await showDialog(
      context: context,
      builder: (ctx) => const _ExportDialog(),
    );
  }

  Future<void> _importVault() async {
    final l = AppLocalizations.of(context)!;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    String content;
    try {
      content = utf8.decode(result.files.single.bytes!);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.importFileError)),
        );
      }
      return;
    }

    if (!mounted) return;
    final counts = await showDialog<Map<String, int>>(
      context: context,
      builder: (ctx) => _ImportDialog(fileContent: content),
    );
    if (counts != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.importSuccess(counts['passwords']!, counts['totp']!)),
        ),
      );
      widget.onDataChanged?.call();
    }
  }

  Future<void> _resetVault() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l.resetVault,
      content: l.resetVaultContent,
      confirmLabel: l.resetEverything,
      cancelLabel: l.cancel,
    );

    if (!confirmed) return;

    final database = await DatabaseService.db;
    await database.delete(DatabaseService.tablePasswords);
    await database.delete(DatabaseService.tableTotp);
    await AuthService.deleteAll();

    if (!mounted) return;
    widget.onLogout();
  }

  void _pickLanguage() {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.language),
        children: LocaleService.supported.map((locale) {
          final name = LocaleService.names[locale.languageCode]!;
          final selected =
              LocaleService.notifier.value.languageCode == locale.languageCode;
          return SimpleDialogOption(
            onPressed: () {
              LocaleService.setLocale(locale);
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                Expanded(child: Text(name)),
                if (selected)
                  Icon(Icons.check,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final currentLocale = LocaleService.notifier.value;
    final localeName = LocaleService.names[currentLocale.languageCode]!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionHeader(l.appearance),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: Text(l.darkMode),
                secondary: const Icon(Icons.dark_mode),
                value: _themeMode == ThemeMode.dark,
                onChanged: _toggleTheme,
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l.language),
                trailing: Text(localeName,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                onTap: _pickLanguage,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionHeader(l.security),
        Card(
          child: Column(
            children: [
              if (_bioAvailable)
                SwitchListTile(
                  title: Text(l.biometricUnlock),
                  subtitle: Text(l.biometricSubtitle),
                  secondary: const Icon(Icons.fingerprint),
                  value: _bioEnabled,
                  onChanged: _toggleBiometric,
                ),
              SwitchListTile(
                title: Text(l.autoLock),
                subtitle: Text(l.autoLockSubtitle),
                secondary: const Icon(Icons.timer_outlined),
                value: _autoLockEnabled,
                onChanged: _toggleAutoLock,
              ),
              if (_autoLockEnabled)
                ListTile(
                  leading: const Icon(Icons.hourglass_bottom_outlined),
                  title: Text(l.autoLockAfter),
                  trailing: DropdownButton<int>(
                    value: _autoLockMinutes,
                    underline: const SizedBox.shrink(),
                    onChanged: (v) => _setAutoLockMinutes(v!),
                    items: [1, 5, 15, 30]
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(l.lockAfterMinutes(m)),
                            ))
                        .toList(),
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.key),
                title: Text(l.changeMasterPassword),
                trailing: const Icon(Icons.chevron_right),
                onTap: _changePassword,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionHeader(l.data),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.upload),
                title: Text(l.exportVault),
                subtitle: Text(l.exportVaultSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: _exportVault,
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: Text(l.importVault),
                subtitle: Text(l.importVaultSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: _importVault,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionHeader(l.dangerZone),
        Card(
          color: Colors.red.shade900.withAlpha(80),
          child: ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(l.resetVault,
                style: const TextStyle(color: Colors.red)),
            subtitle: Text(l.resetVaultSubtitle),
            onTap: _resetVault,
          ),
        ),
        const SizedBox(height: 16),
        _SectionHeader(l.about),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.appTitle),
            subtitle: Text(l.aboutSubtitle),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ExportDialog extends StatefulWidget {
  const _ExportDialog();

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    final l = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final valid = await AuthService.verifyPassword(_ctrl.text);
    if (!valid) {
      setState(() {
        _loading = false;
        _error = l.incorrectCurrentPassword;
      });
      return;
    }

    final passwords = await DatabaseService.getPasswords();
    final totpEntries = await DatabaseService.getTotpEntries();

    final passwordMaps = passwords
        .map((e) => {
              'title': e.title,
              'username': e.username,
              'password': AuthService.decrypt(e.encryptedPassword),
              'url': e.url ?? '',
              'notes': e.notes ?? '',
            })
        .toList();

    final totpMaps = totpEntries
        .map((e) => {
              'name': e.name,
              'issuer': e.issuer,
              'secret': AuthService.decrypt(e.encryptedSecret),
              'digits': e.digits,
              'period': e.period,
            })
        .toList();

    final exportJson = BackupService.createExport(
      passwords: passwordMaps,
      totp: totpMaps,
      masterPassword: _ctrl.text,
    );

    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-')
        .substring(0, 19);
    final filePath = '${dir.path}/odin_vault_$timestamp.ovault';
    await File(filePath).writeAsString(exportJson);

    if (!mounted) return;
    Navigator.pop(context);
    await Share.shareXFiles([XFile(filePath)]);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.exportDialogTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.exportDialogContent),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ),
            PasswordField(
              controller: _ctrl,
              labelText: l.masterPasswordLabel,
              validator: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: _loading ? null : _export,
          child: _loading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l.exportButton),
        ),
      ],
    );
  }
}

class _ImportDialog extends StatefulWidget {
  final String fileContent;
  const _ImportDialog({required this.fileContent});

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    final l = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final parsed = BackupService.parseImport(widget.fileContent, _ctrl.text);
    if (parsed == null) {
      setState(() {
        _loading = false;
        _error = l.importFailed;
      });
      return;
    }

    final key = AuthService.sessionKey!;
    int passwordCount = 0;
    int totpCount = 0;
    final now = DateTime.now();

    final passwords = parsed['passwords'] as List<dynamic>? ?? [];
    for (final p in passwords) {
      final map = p as Map<String, dynamic>;
      await DatabaseService.insertPassword(PasswordEntry(
        title: map['title'] as String,
        username: map['username'] as String,
        encryptedPassword:
            EncryptionService.encrypt(map['password'] as String, key),
        url: (map['url'] as String).isEmpty ? null : map['url'] as String,
        notes:
            (map['notes'] as String).isEmpty ? null : map['notes'] as String,
        createdAt: now,
        updatedAt: now,
      ));
      passwordCount++;
    }

    final totpList = parsed['totp'] as List<dynamic>? ?? [];
    for (final t in totpList) {
      final map = t as Map<String, dynamic>;
      await DatabaseService.insertTotp(TotpEntry(
        name: map['name'] as String,
        issuer: map['issuer'] as String,
        encryptedSecret:
            EncryptionService.encrypt(map['secret'] as String, key),
        digits: map['digits'] as int,
        period: map['period'] as int,
        createdAt: now,
      ));
      totpCount++;
    }

    if (!mounted) return;
    Navigator.pop(context, {'passwords': passwordCount, 'totp': totpCount});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.importDialogTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.importDialogContent),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ),
            PasswordField(
              controller: _ctrl,
              labelText: l.masterPasswordLabel,
              validator: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: _loading ? null : _import,
          child: _loading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l.importButton),
        ),
      ],
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final valid = await AuthService.verifyPassword(_currentCtrl.text);
    if (!valid) {
      setState(() {
        _loading = false;
        _error = l.incorrectCurrentPassword;
      });
      return;
    }
    await AuthService.changeMasterPassword(_newCtrl.text);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.changePasswordTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ),
            PasswordField(
              controller: _currentCtrl,
              labelText: l.currentPasswordField,
              validator: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
            const SizedBox(height: 12),
            PasswordField(
              controller: _newCtrl,
              labelText: l.newPasswordField,
              validator: (v) =>
                  (v == null || v.length < 8) ? l.minimumCharacters : null,
            ),
            const SizedBox(height: 12),
            PasswordField(
              controller: _confirmCtrl,
              labelText: l.confirmNewPasswordField,
              validator: (v) =>
                  v != _newCtrl.text ? l.passwordsDoNotMatch : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l.update),
        ),
      ],
    );
  }
}
