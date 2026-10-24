import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false,
      arguments: _email.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), automaticallyImplyLeading: false),
      body: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440),
          child: Form(key: _formKey, child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.account_balance_wallet, size: 64, color: Colors.amber),
              const SizedBox(height: 16),
              const Text('Expense Tracker', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(controller: _email,
                key: const Key('email'), keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return 'Email wajib diisi.';
                  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                    return 'Format email tidak valid.';
                  }
                  return null;
                }),
              const SizedBox(height: 16),
              TextFormField(controller: _password,
                key: const Key('password'), obscureText: _obscurePassword,
                decoration: InputDecoration(labelText: 'Password', border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword ? 'Tampilkan password' : 'Sembunyikan password',
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off))),
                validator: (value) => value == null || value.trim().isEmpty
                  ? 'Password wajib diisi.' : null,
                onFieldSubmitted: (_) => _login()),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
              const SizedBox(height: 12),
              const Text('Masuk untuk melihat catatan keuanganmu.', textAlign: TextAlign.center),
            ],
          )),
        ),
      )),
    );
  }
}
