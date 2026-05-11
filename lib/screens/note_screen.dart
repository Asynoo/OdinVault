import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/note_entry.dart';
import '../services/database_service.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import 'add_edit_note_screen.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  NoteScreenState createState() => NoteScreenState();
}

class NoteScreenState extends State<NoteScreen> {
  List<NoteEntry> _entries = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _loading = true);
    final entries = await DatabaseService.getNotes();
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  void refresh() => _loadEntries();

  List<NoteEntry> get _filtered {
    if (_search.isEmpty) return _entries;
    final q = _search.toLowerCase();
    return _entries.where((e) => e.title.toLowerCase().contains(q)).toList();
  }

  Future<void> _editEntry(NoteEntry entry) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddEditNoteScreen(entry: entry)),
    );
    if (result == true) _loadEntries();
  }

  Future<void> _deleteEntry(NoteEntry entry) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: l.deleteNoteTitle,
      content: l.deleteEntryContent(entry.title),
      confirmLabel: l.delete,
      cancelLabel: l.cancel,
    );
    if (confirmed) {
      await DatabaseService.deleteNote(entry.id!);
      _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());

    final filtered = _filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SearchBar(
            hintText: l.searchNotes,
            leading: const Icon(Icons.search),
            onChanged: (v) => setState(() => _search = v),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  icon: Icons.note_outlined,
                  message: _search.isEmpty
                      ? l.noNotesYet
                      : l.noSearchResults(_search),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final entry = filtered[i];
                    return NoteCard(
                      entry: entry,
                      onEdit: () => _editEntry(entry),
                      onDelete: () => _deleteEntry(entry),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class NoteFab extends StatelessWidget {
  final VoidCallback? onAdded;
  const NoteFab({super.key, this.onAdded});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return FloatingActionButton(
      onPressed: () async {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const AddEditNoteScreen()),
        );
        if (result == true) onAdded?.call();
      },
      tooltip: l.addNoteTooltip,
      child: const Icon(Icons.add),
    );
  }
}
