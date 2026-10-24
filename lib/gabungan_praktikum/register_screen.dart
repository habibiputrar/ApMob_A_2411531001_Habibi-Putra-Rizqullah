import 'package:flutter/material.dart';

import 'storage.dart';

// Form registrasi melanjutkan pola Form/controller latihan Basic Form.
class RegisterScreen extends StatefulWidget {
  final AppStore store;
  const RegisterScreen({super.key, required this.store});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _email = TextEditingController(),
      _password = TextEditingController(),
      _confirm = TextEditingController();
  bool _hidden = true, _busy = false;
  String? _error;
  @override
  void dispose() {
    for (final controller in [_name, _email, _password, _confirm]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.store.register(_name.text, _email.text, _password.text);
      if (mounted) Navigator.pop(context, _email.text.trim());
    } on FormatException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (error, stack) {
      debugPrint('Registrasi lokal gagal: $error\n$stack');
      if (mounted) setState(() => _error = 'Akun belum tersimpan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Daftar Akun')),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 64,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    key: const Key('register-name'),
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Nama lengkap',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Nama wajib diisi.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('register-email'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: emailValidator,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('register-password'),
                    controller: _password,
                    obscureText: _hidden,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: 'Tampilkan/sembunyikan password',
                        onPressed: () => setState(() => _hidden = !_hidden),
                        icon: Icon(
                          _hidden ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (v) => (v?.length ?? 0) < 8
                        ? 'Password minimal 8 karakter.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('register-confirm'),
                    controller: _confirm,
                    obscureText: _hidden,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty || v != _password.text
                        ? 'Konfirmasi password tidak sama.'
                        : null,
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        _error!,
                        key: const Key('register-error'),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    key: const Key('register-submit'),
                    onPressed: _busy ? null : _register,
                    child: Text(_busy ? 'Memproses...' : 'Daftar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
