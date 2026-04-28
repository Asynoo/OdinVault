import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const SettingsScreen({super.key, required this.onLogout});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _bioEnabled = false;
  bool _bioAvailable = false;
  ThemeMode _themeMode = ThemeService.notifier.value;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final available = await AuthService.isBiometricAvailable();
    final enabled = await AuthService.isBiometricEnabled();
    setState(() {
      _bioAvailable = available;
      _bioEnabled = enabled;
      _themeMode = ThemeService.notifier.value;
    });
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

  Future<void> _resetVault() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.resetVault),
        content: Text(l.resetVaultContent),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l.resetEverything),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final db = await DatabaseService.db;
    await db.delete('passwords');
    await db.delete('totp_entries');
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
            TextFormField(
              controller: _currentCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: l.currentPasswordField),
              validator: (v) => (v == null || v.isEmpty) ? l.required : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: l.newPasswordField),
              validator: (v) =>
                  (v == null || v.length < 8) ? l.minimumCharacters : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration:
                  InputDecoration(labelText: l.confirmNewPasswordField),
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
