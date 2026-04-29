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
  // Clear clipboard after 30 s, but only if it still holds our text
  Future.delayed(const Duration(seconds: 30), () async {
    final current = await Clipboard.getData('text/plain');
    if (current?.text == text) {
      await Clipboard.setData(const ClipboardData(text: ''));
    }
  });
}
