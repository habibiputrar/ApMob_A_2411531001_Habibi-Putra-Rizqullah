import 'package:flutter/material.dart';
import 'models/transaction_model.dart';
import 'widgets/transaction_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.transactions});
  final List<TransactionModel> transactions;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi'), automaticallyImplyLeading: false),
      body: transactions.isEmpty
        ? const Center(child: Text('Belum ada transaksi.'))
        : ListView.separated(
            itemCount: transactions.length,
            separatorBuilder: (_, index) => const Divider(height: 1),
            itemBuilder: (_, index) => TransactionTile(transaction: transactions[index]),
          ),
    );
  }
}
