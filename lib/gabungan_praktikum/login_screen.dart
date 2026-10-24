import 'package:flutter/material.dart';

import 'storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final valid = await widget.store.login(_email.text, _password.text);
      if (!mounted) return;
      if (valid) {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      } else {
        setState(() => _error = 'Email atau password salah.');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Belum dapat masuk. Coba lagi.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _register() async {
    final result = await Navigator.pushNamed(context, '/register');
    if (!mounted || result is! String) return;
    _email.text = result;
    _password.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Akun berhasil dibuat. Silakan login.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 64,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Expense Tracker',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _email,
                    key: const Key('email'),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return 'Email wajib diisi.';
                      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                          .hasMatch(email)) {
                        return 'Format email tidak valid.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    key: const Key('password'),
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Tampilkan password'
                            : 'Sembunyikan password',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Password wajib diisi.'
                        : null,
                    onFieldSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 20),
                  if (_error != null)
                    Text(
                      _error!,
                      key: const Key('auth-error'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ElevatedButton(
                    key: const Key('login-submit'),
                    onPressed: _busy ? null : _login,
                    child: Text(_busy ? 'Memproses...' : 'Login'),
                  ),
                  TextButton(
                    key: const Key('open-register'),
                    onPressed: _busy ? null : _register,
                    child: const Text('Daftar akun baru'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Masuk untuk melihat catatan keuanganmu.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
