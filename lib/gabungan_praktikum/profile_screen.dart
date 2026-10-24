import 'package:flutter/material.dart';

import 'models/transaction_model.dart';
import 'storage.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.store,
    required this.onChanged,
  });
  final AppStore store;
  final VoidCallback onChanged;
  Future<void> _logout(BuildContext context) async {
    try {
      await store.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Belum dapat logout. Coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.amber,
              child: Icon(Icons.person, size: 56, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            store.user!.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(store.user!.email, textAlign: TextAlign.center),
          const SizedBox(height: 28),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit profil'),
            onTap: () async {
              await Navigator.pushNamed(context, '/edit-profile');
              if (context.mounted) onChanged();
            },
          ),
          ListTile(
            title: const Text('Saldo awal'),
            subtitle: Text(rupiah(store.user!.openingBalance)),
            leading: const Icon(Icons.account_balance_wallet),
            onTap: () async {
              final amount = await showDialog<int>(
                context: context,
                builder: (_) =>
                    _OpeningBalanceDialog(amount: store.user!.openingBalance),
              );
              if (!context.mounted || amount == null) return;
              try {
                await store.setOpeningBalance(amount);
                onChanged();
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saldo awal belum tersimpan.'),
                    ),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 20),
          ElevatedButton.icon(
            key: const Key('logout'),
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _OpeningBalanceDialog extends StatefulWidget {
  final int amount;
  const _OpeningBalanceDialog({required this.amount});
  @override
  State<_OpeningBalanceDialog> createState() => _OpeningBalanceDialogState();
}

class _OpeningBalanceDialogState extends State<_OpeningBalanceDialog> {
  final _form = GlobalKey<FormState>();
  late final _amount = TextEditingController(text: '${widget.amount}');
  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Saldo awal'),
    content: Form(
      key: _form,
      child: TextFormField(
        key: const Key('opening-balance'),
        controller: _amount,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
        validator: (value) {
          final amount = int.tryParse(value ?? '');
          return amount == null || amount < 0 || amount > 1000000000000
              ? 'Masukkan angka 0 sampai 1000000000000.'
              : null;
        },
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Batal'),
      ),
      TextButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, int.parse(_amount.text));
          }
        },
        child: const Text('Simpan'),
      ),
    ],
  );
}
