import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'vault_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
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
    final available = await AuthService.isBiometricAvailable();
    final enabled = await AuthService.isBiometricEnabled();
    setState(() {
      _bioAvailable = available;
      _bioEnabled = enabled;
    });
    if (enabled && available) _tryBiometric();
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
        _error = 'Biometric authentication failed.';
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
        _error = 'Incorrect master password.';
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
                    'Odin Vault',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your master password to unlock.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Master Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      border: const OutlineInputBorder(),
                      errorText: _error,
                    ),
                    onFieldSubmitted: (_) => _login(),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter your password' : null,
                  ),
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
                        : const Text('Unlock', style: TextStyle(fontSize: 16)),
                  ),
                  if (_bioAvailable && _bioEnabled) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _loading ? null : _tryBiometric,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Use Biometric'),
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
