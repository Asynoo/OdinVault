import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/totp_entry.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
import '../services/totp_service.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/totp_card.dart';
import 'qr_scanner_screen.dart';

class TotpScreen extends StatefulWidget {
  const TotpScreen({super.key});

  @override
  TotpScreenState createState() => TotpScreenState();
}

class TotpScreenState extends State<TotpScreen> {
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

  void refresh() => _loadEntries();

  void _startTimer() {
    _secondsLeft = TotpService.secondsRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _secondsLeft = TotpService.secondsRemaining());
    });
  }

  Future<void> _deleteEntry(TotpEntry entry) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l.removeTwoFaTitle,
      content: l.removeTwoFaContent(entry.name),
      confirmLabel: l.remove,
      cancelLabel: l.cancel,
    );
    if (confirmed) {
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
    final l = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_entries.isEmpty) {
      return EmptyState(icon: Icons.security, message: l.noTotpEntries);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.refreshesIn(_secondsLeft),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13),
              ),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  value: _secondsLeft / 30,
                  color: _secondsLeft <= 5
                      ? Colors.red
                      : const Color(0xFF5C6BC0),
                  backgroundColor:
                      Theme.of(context).colorScheme.onSurface.withAlpha(30),
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
              final secret = AuthService.decrypt(entry.encryptedSecret);
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
  final VoidCallback? onAdded;
  const TotpFab({super.key, this.onAdded});

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

    final encryptedSecret = EncryptionService.encrypt(result['secret']!, key);
    final entry = TotpEntry(
      name: result['name']!,
      issuer: result['issuer'] ?? '',
      encryptedSecret: encryptedSecret,
      createdAt: DateTime.now(),
    );
    await DatabaseService.insertTotp(entry);

    widget.onAdded?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return FloatingActionButton(
      onPressed: _addTotp,
      tooltip: l.addTwoFaTooltip,
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

  Future<void> _scanQr() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (result == null) return;
    setState(() {
      _nameCtrl.text = result['name'] ?? '';
      _issuerCtrl.text = result['issuer'] ?? '';
      _secretCtrl.text = result['secret'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l.addTwoFaTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            OutlinedButton.icon(
              onPressed: _scanQr,
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: Text(l.scanQrButton),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                  labelText: l.accountNameField, hintText: l.accountNameHint),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.required : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _issuerCtrl,
              decoration: InputDecoration(
                  labelText: l.issuerField, hintText: l.issuerHint),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _secretCtrl,
              decoration: InputDecoration(
                labelText: l.secretKeyField,
                hintText: l.secretKeyHint,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.required : null,
            ),
            const SizedBox(height: 8),
            Text(
              l.secretKeyHelp,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
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
          child: Text(l.add),
        ),
      ],
    );
  }
}
