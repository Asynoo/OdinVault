import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> copyWithFeedback(
  BuildContext context,
  String text,
  String message,
) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}
