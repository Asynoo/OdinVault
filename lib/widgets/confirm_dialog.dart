import 'package:flutter/material.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  required String confirmLabel,
  Color confirmColor = Colors.red,
  required String cancelLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(backgroundColor: confirmColor),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
