import 'dart:math';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/clipboard_utils.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  int _length = 20;
  bool _upper = true;
  bool _lower = true;
  bool _numbers = true;
  bool _symbols = true;
  String _password = '';
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    final chars = _buildCharset();
    if (chars.isEmpty) return;
    final rng = Random.secure();
    final next =
        List.generate(_length, (_) => chars[rng.nextInt(chars.length)]).join();
    setState(() {
      if (_password.isNotEmpty) {
        _history.insert(0, _password);
        if (_history.length > 10) _history.removeLast();
      }
      _password = next;
    });
  }

  String _buildCharset() {
    var chars = '';
    if (_lower) chars += 'abcdefghijklmnopqrstuvwxyz';
    if (_upper) chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_numbers) chars += '0123456789';
    if (_symbols) chars += r'!@#$%^&*()-_=+[]{}|;:,.<>?';
    return chars;
  }

  void _onToggle(void Function() update) {
    setState(update);
    _generate();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              children: [
                SelectableText(
                  _password,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: _generate,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(l.regenerate),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () =>
                          copyWithFeedback(context, _password, l.passwordCopied),
                      icon: const Icon(Icons.copy, size: 18),
                      label: Text(l.copy),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.passwordLength,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '$_length',
                      style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: _length.toDouble(),
                  min: 8,
                  max: 64,
                  divisions: 56,
                  onChanged: (v) =>
                      _onToggle(() => _length = v.round()),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.includeUppercase),
                  value: _upper,
                  onChanged: (v) => _onToggle(() => _upper = v),
                ),
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.includeLowercase),
                  value: _lower,
                  onChanged: (v) => _onToggle(() => _lower = v),
                ),
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.includeNumbers),
                  value: _numbers,
                  onChanged: (v) => _onToggle(() => _numbers = v),
                ),
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.includeSymbols),
                  value: _symbols,
                  onChanged: (v) => _onToggle(() => _symbols = v),
                ),
              ],
            ),
          ),
        ),
        if (_history.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: Text(
              l.generatorHistory.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ..._history.map((pwd) => Card(
                margin: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  dense: true,
                  title: Text(
                    pwd,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () =>
                        copyWithFeedback(context, pwd, l.passwordCopied),
                  ),
                ),
              )),
        ],
      ],
    );
  }
}
