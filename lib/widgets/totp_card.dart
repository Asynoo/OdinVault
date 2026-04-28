import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/totp_entry.dart';
import '../services/totp_service.dart';

class TotpCard extends StatelessWidget {
  final TotpEntry entry;
  final String secret;
  final int secondsLeft;
  final VoidCallback onDelete;

  const TotpCard({
    super.key,
    required this.entry,
    required this.secret,
    required this.secondsLeft,
    required this.onDelete,
  });

  Future<void> _copyCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Code copied'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final code = secret.isEmpty
        ? '------'
        : TotpService.generateCode(secret,
            digits: entry.digits, period: entry.period);

    final formattedCode = code.length == 6
        ? '${code.substring(0, 3)} ${code.substring(3)}'
        : code;

    final colorScheme = Theme.of(context).colorScheme;
    final isExpiring = secondsLeft <= 5;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Text(
            entry.name[0].toUpperCase(),
            style: TextStyle(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(entry.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: entry.issuer.isNotEmpty
            ? Text(entry.issuer,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12))
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedCode,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: isExpiring ? Colors.red : colorScheme.primary,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  '${secondsLeft}s',
                  style: TextStyle(
                    fontSize: 11,
                    color: isExpiring ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'Copy code',
                  onPressed: () => _copyCode(context, code),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: Colors.red),
                  tooltip: 'Remove',
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
