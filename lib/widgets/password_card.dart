import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_entry.dart';

class PasswordCard extends StatefulWidget {
  final PasswordEntry entry;
  final String Function(String) getDecryptedPassword;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PasswordCard({
    super.key,
    required this.entry,
    required this.getDecryptedPassword,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<PasswordCard> {
  bool _expanded = false;
  bool _showPassword = false;
  String? _decryptedPassword;

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
      if (!_expanded) _showPassword = false;
    });
  }

  void _revealPassword() {
    _decryptedPassword ??=
        widget.getDecryptedPassword(widget.entry.encryptedPassword);
    setState(() => _showPassword = !_showPassword);
  }

  Future<void> _copyUsername() async {
    await Clipboard.setData(ClipboardData(text: widget.entry.username));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Username copied'), duration: Duration(seconds: 2)),
    );
  }

  Future<void> _copyPassword() async {
    final pwd = widget.getDecryptedPassword(widget.entry.encryptedPassword);
    await Clipboard.setData(ClipboardData(text: pwd));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Password copied'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                widget.entry.title[0].toUpperCase(),
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(widget.entry.title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(widget.entry.username,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'Copy password',
                  onPressed: _copyPassword,
                ),
                IconButton(
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  onPressed: _toggleExpand,
                ),
              ],
            ),
            onTap: _toggleExpand,
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Field(
                    label: 'Username',
                    value: widget.entry.username,
                    onCopy: _copyUsername,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          label: 'Password',
                          value: _showPassword
                              ? (_decryptedPassword ?? '••••••••')
                              : '••••••••',
                          onCopy: _copyPassword,
                        ),
                      ),
                      IconButton(
                        icon: Icon(_showPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: _revealPassword,
                        tooltip: 'Toggle password',
                      ),
                    ],
                  ),
                  if (widget.entry.url != null &&
                      widget.entry.url!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _Field(label: 'URL', value: widget.entry.url!),
                  ],
                  if (widget.entry.notes != null &&
                      widget.entry.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _Field(label: 'Notes', value: widget.entry.notes!),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: widget.onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _Field({required this.label, required this.value, this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: Text(value,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis),
            ),
            if (onCopy != null)
              InkWell(
                onTap: onCopy,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.copy, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
