import 'package:flutter/material.dart';

import 'models/transaction_model.dart';
import 'widgets/transaction_tile.dart';
import 'storage.dart';
import 'widgets/action_buttons_widget.dart';
import 'widgets/balance_card_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.user,
    required this.store,
    required this.transactions,
    required this.onAdded,
    required this.onHistory,
    required this.onProfile,
  });
  final LocalUser user;
  final AppStore store;
  final List<TransactionModel> transactions;
  final ValueChanged<TransactionModel> onAdded;
  final VoidCallback onHistory;
  final VoidCallback onProfile;

  Future<void> _openAdd(BuildContext context, [String kind = 'expense']) async {
    final result = await Navigator.pushNamed(context, '/add', arguments: kind);
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
              'Halo, ${user.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(user.email),
            const SizedBox(height: 12),
            BalanceCardWidget(
              balance: transactions.fold<int>(
                user.openingBalance,
                (sum, item) =>
                    sum +
                    (item.isTransfer
                        ? 0
                        : item.isIncome
                        ? item.amount
                        : -item.amount),
              ),
            ),
            const SizedBox(height: 12),
            ActionButtonsWidget(onAction: (kind) => _openAdd(context, kind)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  tooltip: 'Kalkulator Kabataku',
                  onPressed: () => Navigator.pushNamed(context, '/calculator'),
                  icon: const Icon(Icons.calculate),
                ),
                IconButton(
                  tooltip: 'Catat transaksi',
                  onPressed: () => _openAdd(context),
                  icon: const Icon(Icons.add_circle_outline),
                ),
                IconButton(
                  tooltip: 'Riwayat',
                  onPressed: onHistory,
                  icon: const Icon(Icons.history),
                ),
                IconButton(
                  tooltip: 'Profil',
                  onPressed: onProfile,
                  icon: const Icon(Icons.person),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Transaksi Terakhir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTransactionList(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Belum ada transaksi.'),
      );
    }
    return Card(
      elevation: 2,
      child: Column(
        children: [
          for (int i = 0; i < transactions.length; i++) ...[
            TransactionTile(
              transaction: transactions[i],
              store: store,
              onChanged: () => onAdded(transactions[i]),
            ),
            if (i < transactions.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}
