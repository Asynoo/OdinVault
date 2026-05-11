import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/note_entry.dart';
import '../services/auth_service.dart';

class NoteCard extends StatelessWidget {
  final NoteEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final content = AuthService.decrypt(entry.encryptedContent);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(entry.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: content.isEmpty
            ? null
            : Text(
                content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'edit', child: Text(l.edit)),
            PopupMenuItem(
              value: 'delete',
              child:
                  Text(l.delete, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}
