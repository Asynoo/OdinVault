import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/note_entry.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteEntry? entry;

  const AddEditNoteScreen({super.key, this.entry});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _titleCtrl = TextEditingController(text: widget.entry?.title ?? '');
  late final _contentCtrl = TextEditingController(
    text: widget.entry != null
        ? AuthService.decrypt(widget.entry!.encryptedContent)
        : '',
  );

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final key = AuthService.sessionKey;
    if (key == null) return;

    final now = DateTime.now();
    final encryptedContent =
        EncryptionService.encrypt(_contentCtrl.text.trim(), key);

    if (widget.entry == null) {
      await DatabaseService.insertNote(NoteEntry(
        title: _titleCtrl.text.trim(),
        encryptedContent: encryptedContent,
        createdAt: now,
        updatedAt: now,
      ));
    } else {
      await DatabaseService.updateNote(widget.entry!.copyWith(
        title: _titleCtrl.text.trim(),
        encryptedContent: encryptedContent,
        updatedAt: now,
      ));
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.entry == null ? l.addNoteTitle : l.editNoteTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: l.save,
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(labelText: l.titleField),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l.titleRequired : null,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  controller: _contentCtrl,
                  decoration: InputDecoration(
                    labelText: l.noteContentField,
                    hintText: l.noteContentHint,
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? l.noteContentRequired
                          : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
