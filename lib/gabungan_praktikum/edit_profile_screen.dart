import 'package:flutter/material.dart';

import 'storage.dart';

// Form, controller, validator, dan padding dari pertemuan_01/textformfield.dart.
// Isian nama/email dipakai sebagai edit akun, bukan menu latihan terpisah.
class EditProfileScreen extends StatefulWidget {
  final AppStore store;
  const EditProfileScreen({super.key, required this.store});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.store.user!.name,
  );
  late final _emailController = TextEditingController(
    text: widget.store.user!.email,
  );
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.store.updateProfile(
        _nameController.text,
        _emailController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil disimpan.')),
      );
      Navigator.pop(context, true);
    } on FormatException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Profil belum tersimpan. Coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit Profil')),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  key: const Key('profile-name'),
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama lengkap',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama wajib diisi.'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  key: const Key('profile-email'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: emailValidator,
                ),
                const SizedBox(height: 10),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ElevatedButton(
                  key: const Key('profile-save'),
                  onPressed: _saving ? null : _submitForm,
                  child: Text(_saving ? 'Menyimpan...' : 'Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
