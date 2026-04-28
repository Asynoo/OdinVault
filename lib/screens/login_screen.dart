import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/password_field.dart';
import 'vault_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _bioAvailable = false;
  bool _bioEnabled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final results = await Future.wait([
      AuthService.isBiometricAvailable(),
      AuthService.isBiometricEnabled(),
    ]);
    setState(() {
      _bioAvailable = results[0];
      _bioEnabled = results[1];
    });
    if (results[0] && results[1]) _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    setState(() => _loading = true);
    final success = await AuthService.loginWithBiometric();
    if (!mounted) return;
    if (success) {
      _goToVault();
    } else {
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context)!.biometricFailed;
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final success = await AuthService.loginWithPassword(_passwordCtrl.text);
    if (!mounted) return;
    if (success) {
      _goToVault();
    } else {
      setState(() {
        _loading = false;
        _error = AppLocalizations.of(context)!.incorrectPassword;
      });
    }
  }

  void _goToVault() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const VaultScreen()),
    );
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.shield, size: 80, color: Color(0xFF5C6BC0)),
                  const SizedBox(height: 16),
                  Text(
                    l.appTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 40),
                  PasswordField(
                    controller: _passwordCtrl,
                    labelText: l.masterPasswordLabel,
                    onFieldSubmitted: (_) => _login(),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? l.enterYourPassword : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _login,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l.unlockButton,
                            style: const TextStyle(fontSize: 16)),
                  ),
                  if (_bioAvailable && _bioEnabled) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _loading ? null : _tryBiometric,
                      icon: const Icon(Icons.fingerprint),
                      label: Text(l.useBiometric),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
