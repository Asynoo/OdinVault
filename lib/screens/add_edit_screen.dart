import 'dart:math';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/password_entry.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
import '../widgets/password_field.dart';

class AddEditScreen extends StatefulWidget {
  final PasswordEntry? entry;
  const AddEditScreen({super.key, this.entry});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _notesCtrl;
  bool _loading = false;

  bool get _isEdit => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _usernameCtrl = TextEditingController(text: e?.username ?? '');
    _urlCtrl = TextEditingController(text: e?.url ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _passwordCtrl = TextEditingController(
      text: e != null
          ? EncryptionService.decrypt(e.encryptedPassword, AuthService.sessionKey!)
          : '',
    );
  }

  void _generatePassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final rng = Random.secure();
    _passwordCtrl.text =
        List.generate(20, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final key = AuthService.sessionKey;
    if (key == null) return;

    setState(() => _loading = true);
    final encrypted = EncryptionService.encrypt(_passwordCtrl.text, key);
    final now = DateTime.now();
    final url = _urlCtrl.text.trim();
    final notes = _notesCtrl.text.trim();

    if (_isEdit) {
      await DatabaseService.updatePassword(widget.entry!.copyWith(
        title: _titleCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        encryptedPassword: encrypted,
        url: url.isEmpty ? null : url,
        notes: notes.isEmpty ? null : notes,
        updatedAt: now,
      ));
    } else {
      await DatabaseService.insertPassword(PasswordEntry(
        title: _titleCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        encryptedPassword: encrypted,
        url: url.isEmpty ? null : url,
        notes: notes.isEmpty ? null : notes,
        createdAt: now,
        updatedAt: now,
      ));
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _urlCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l.editPasswordTitle : l.newPasswordTitle),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: Text(l.save, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l.titleField,
                  hintText: l.titleHint,
                  prefixIcon: const Icon(Icons.label_outline),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l.titleRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l.usernameField,
                  prefixIcon: const Icon(Icons.person_outline),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l.usernameRequired : null,
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: _passwordCtrl,
                labelText: l.passwordField,
                validator: (v) =>
                    (v == null || v.isEmpty) ? l.passwordRequired : null,
                extraSuffixAction: IconButton(
                  icon: const Icon(Icons.auto_fix_high),
                  onPressed: _generatePassword,
                  tooltip: l.generatePassword,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlCtrl,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l.urlField,
                  hintText: l.urlHint,
                  prefixIcon: const Icon(Icons.link),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l.notesField,
                  prefixIcon: const Icon(Icons.notes),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _loading ? null : _save,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEdit ? l.saveChanges : l.addPasswordButton,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
