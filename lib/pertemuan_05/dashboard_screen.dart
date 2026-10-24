import 'package:flutter/material.dart';

import 'models/transaction_model.dart';
import 'widgets/transaction_tile.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.email,
    required this.transactions, required this.onAdded,
    required this.onHistory, required this.onProfile});
  final String email;
  final List<TransactionModel> transactions;
  final ValueChanged<TransactionModel> onAdded;
  final VoidCallback onHistory;
  final VoidCallback onProfile;

  Future<void> _openAdd(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/add');
    if (result is TransactionModel) onAdded(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Keuangan'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        tooltip: 'Tambah transaksi',
        onPressed: () => _openAdd(context),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${userName(email)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(email),
            const SizedBox(height: 12),
            _buildBalanceCard(),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              IconButton(tooltip: 'Catat transaksi', onPressed: () => _openAdd(context),
                icon: const Icon(Icons.add_circle_outline)),
              IconButton(tooltip: 'Riwayat', onPressed: onHistory,
                icon: const Icon(Icons.history)),
              IconButton(tooltip: 'Profil', onPressed: onProfile,
                icon: const Icon(Icons.person)),
            ]),
            const SizedBox(height: 20),
            const Text(
              'Transaksi Terakhir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTransactionList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final balance = transactions.fold<int>(50000,
      (sum, item) => sum + (item.isIncome ? item.amount : -item.amount));
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        color: Colors.amber.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saldo Utama',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                rupiah(balance),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(children: [
        for (int i = 0; i < transactions.length; i++) ...[
          TransactionTile(transaction: transactions[i]),
          if (i < transactions.length - 1) const Divider(height: 1),
        ],
      ]),
    );
  }
}
