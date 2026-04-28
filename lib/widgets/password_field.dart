import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? prefixIcon;
  final Widget? extraSuffixAction;

  const PasswordField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.extraSuffixAction,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final toggleButton = IconButton(
      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
      onPressed: () => setState(() => _obscure = !_obscure),
    );

    final suffix = widget.extraSuffixAction != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [toggleButton, widget.extraSuffixAction!],
          )
        : toggleButton;

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: widget.prefixIcon ?? const Icon(Icons.lock),
        suffixIcon: suffix,
        border: const OutlineInputBorder(),
      ),
      validator: widget.validator,
    );
  }
}
