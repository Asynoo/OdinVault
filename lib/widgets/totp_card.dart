import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/totp_entry.dart';
import '../services/totp_service.dart';
import '../utils/clipboard_utils.dart';

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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.secondaryContainer,
              child: Text(
                entry.name[0].toUpperCase(),
                style: TextStyle(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (entry.issuer.isNotEmpty)
                    Text(
                      entry.issuer,
                      style: TextStyle(
                          color: colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedCode,
                  style: TextStyle(
                    fontSize: 22,
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
                    color:
                        isExpiring ? Colors.red : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: l.copyCodeTooltip,
                  onPressed: () =>
                      copyWithFeedback(context, code, l.codeCopied),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: Colors.red),
                  tooltip: l.removeTooltip,
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
