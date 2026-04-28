import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const SettingsScreen({super.key, required this.onLogout});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _bioEnabled = false;
  bool _bioAvailable = false;

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
    });
  }

  Future<void> _toggleBiometric(bool val) async {
    await AuthService.setBiometricEnabled(val);
    setState(() => _bioEnabled = val);
  }

  Future<void> _changePassword() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _ChangePasswordDialog(),
    );
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Master password updated.')),
      );
    }
  }

  Future<void> _resetVault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Vault'),
        content: const Text(
          'This will permanently delete ALL passwords, 2FA entries, and your master password. This cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset Everything'),
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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionHeader('Security'),
        Card(
          child: Column(
            children: [
              if (_bioAvailable)
                SwitchListTile(
                  title: const Text('Biometric Unlock'),
                  subtitle: const Text('Use fingerprint to unlock vault'),
                  secondary: const Icon(Icons.fingerprint),
                  value: _bioEnabled,
                  onChanged: _toggleBiometric,
                ),
              ListTile(
                leading: const Icon(Icons.key),
                title: const Text('Change Master Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _changePassword,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _SectionHeader('Danger Zone'),
        Card(
          color: Colors.red.shade900.withAlpha(80),
          child: ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Reset Vault',
                style: TextStyle(color: Colors.red)),
            subtitle: const Text('Delete all data and start over'),
            onTap: _resetVault,
          ),
        ),
        const SizedBox(height: 16),
        const _SectionHeader('About'),
        const Card(
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('VaultPass'),
            subtitle: Text('v1.0.0 — Local password manager\nAll data stored on this device only.'),
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
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final valid = await AuthService.verifyPassword(_currentCtrl.text);
    if (!valid) {
      setState(() {
        _loading = false;
        _error = 'Current password is incorrect.';
      });
      return;
    }
    await AuthService.changeMasterPassword(_newCtrl.text);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Master Password'),
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
              decoration: const InputDecoration(labelText: 'Current Password'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
              validator: (v) => (v == null || v.length < 8)
                  ? 'Minimum 8 characters'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm New Password'),
              validator: (v) =>
                  v != _newCtrl.text ? 'Passwords do not match' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Update'),
        ),
      ],
    );
  }
}
