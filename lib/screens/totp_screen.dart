import 'dart:async';
import 'package:flutter/material.dart';
import '../models/totp_entry.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
import '../services/totp_service.dart';
import '../widgets/totp_card.dart';

class TotpScreen extends StatefulWidget {
  const TotpScreen({super.key});

  @override
  State<TotpScreen> createState() => _TotpScreenState();
}

class _TotpScreenState extends State<TotpScreen> {
  List<TotpEntry> _entries = [];
  Timer? _timer;
  int _secondsLeft = 30;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _startTimer();
  }

  Future<void> _loadEntries() async {
    setState(() => _loading = true);
    final entries = await DatabaseService.getTotpEntries();
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  void _startTimer() {
    _secondsLeft = TotpService.secondsRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _secondsLeft = TotpService.secondsRemaining());
    });
  }

  String _decryptSecret(String encrypted) {
    final key = AuthService.sessionKey;
    if (key == null) return '';
    return EncryptionService.decrypt(encrypted, key);
  }

  Future<void> _deleteEntry(TotpEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove 2FA'),
        content: Text('Remove "${entry.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseService.deleteTotp(entry.id!);
      _loadEntries();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.security, size: 64, color: Theme.of(context).colorScheme.onSurface.withAlpha(61)),
            const SizedBox(height: 16),
            Text(
              'No 2FA entries yet.\nTap + to add an authenticator.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Refreshes in ${_secondsLeft}s',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  value: _secondsLeft / 30,
                  color: _secondsLeft <= 5 ? Colors.red : const Color(0xFF5C6BC0),
                  backgroundColor: Theme.of(context).colorScheme.onSurface.withAlpha(30),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _entries.length,
            itemBuilder: (_, i) {
              final entry = _entries[i];
              final secret = _decryptSecret(entry.encryptedSecret);
              return TotpCard(
                entry: entry,
                secret: secret,
                secondsLeft: _secondsLeft,
                onDelete: () => _deleteEntry(entry),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TotpFab extends StatefulWidget {
  const TotpFab({super.key});

  @override
  State<TotpFab> createState() => _TotpFabState();
}

class _TotpFabState extends State<TotpFab> {
  Future<void> _addTotp() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => const _AddTotpDialog(),
    );
    if (result == null) return;

    final key = AuthService.sessionKey;
    if (key == null) return;

    final encryptedSecret =
        EncryptionService.encrypt(result['secret']!, key);
    final entry = TotpEntry(
      name: result['name']!,
      issuer: result['issuer'] ?? '',
      encryptedSecret: encryptedSecret,
      createdAt: DateTime.now(),
    );
    await DatabaseService.insertTotp(entry);

    if (!mounted) return;
    final state = context.findAncestorStateOfType<_TotpScreenState>();
    state?._loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _addTotp,
      tooltip: 'Add 2FA',
      child: const Icon(Icons.add),
    );
  }
}

class _AddTotpDialog extends StatefulWidget {
  const _AddTotpDialog();

  @override
  State<_AddTotpDialog> createState() => _AddTotpDialogState();
}

class _AddTotpDialogState extends State<_AddTotpDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _issuerCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _issuerCtrl.dispose();
    _secretCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add 2FA Account'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Account Name *',
                  hintText: 'e.g. john@gmail.com'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _issuerCtrl,
              decoration: const InputDecoration(
                  labelText: 'Issuer', hintText: 'e.g. Google'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _secretCtrl,
              decoration: const InputDecoration(
                labelText: 'Secret Key *',
                hintText: 'Base32 secret from your app',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the base32 secret key shown when setting up 2FA in your account.',
              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameCtrl.text.trim(),
                'issuer': _issuerCtrl.text.trim(),
                'secret': _secretCtrl.text.trim().toUpperCase(),
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
