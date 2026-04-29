import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/password_entry.dart';
import '../services/auth_service.dart';
import '../utils/clipboard_utils.dart';
import '../utils/password_health.dart';

class PasswordCard extends StatefulWidget {
  final PasswordEntry entry;
  final HealthIssue health;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PasswordCard({
    super.key,
    required this.entry,
    this.health = HealthIssue.none,
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

  String? _domain(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final host = Uri.parse(url).host;
      if (host.isEmpty) return null;
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (_) {
      return null;
    }
  }

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
      if (!_expanded) _showPassword = false;
    });
  }

  void _revealPassword() {
    _decryptedPassword ??= AuthService.decrypt(widget.entry.encryptedPassword);
    setState(() => _showPassword = !_showPassword);
  }

  Future<void> _copyUsername() async {
    final l = AppLocalizations.of(context)!;
    await copyWithFeedback(context, widget.entry.username, l.usernameCopied);
  }

  Future<void> _copyPassword() async {
    final l = AppLocalizations.of(context)!;
    final pwd = AuthService.decrypt(widget.entry.encryptedPassword);
    await copyWithFeedback(context, pwd, l.passwordCopied);
  }

  Color get _healthColor => widget.health == HealthIssue.duplicate
      ? Colors.orange
      : Colors.red;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final domain = _domain(widget.entry.url);
    final hasIssue = widget.health != HealthIssue.none;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ListTile(
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    widget.entry.title[0].toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (hasIssue)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _healthColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: colorScheme.surface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(widget.entry.title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              [widget.entry.username, domain]
                  .whereType<String>()
                  .join(' · '),
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: l.copyPasswordTooltip,
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
                    label: l.usernameLabel,
                    value: widget.entry.username,
                    onCopy: _copyUsername,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          label: l.passwordLabel,
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
                        tooltip: l.togglePasswordTooltip,
                      ),
                    ],
                  ),
                  if (hasIssue) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 14, color: _healthColor),
                        const SizedBox(width: 4),
                        Text(
                          switch (widget.health) {
                            HealthIssue.both =>
                              '${l.weakPasswordWarning} · ${l.reusedPasswordWarning}',
                            HealthIssue.weak => l.weakPasswordWarning,
                            _ => l.reusedPasswordWarning,
                          },
                          style: TextStyle(
                              fontSize: 12, color: _healthColor),
                        ),
                      ],
                    ),
                  ],
                  if (widget.entry.url != null &&
                      widget.entry.url!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _Field(label: l.urlLabel, value: widget.entry.url!),
                  ],
                  if (widget.entry.notes != null &&
                      widget.entry.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _Field(label: l.notesLabel, value: widget.entry.notes!),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: widget.onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                        label: Text(l.edit),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: Text(l.deleteButton),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
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
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                  child: Icon(Icons.copy,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
