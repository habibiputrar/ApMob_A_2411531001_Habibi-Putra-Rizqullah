import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../transaction_detail_screen.dart';
import '../storage.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.store,
    required this.onChanged,
  });
  final AppStore store;
  final VoidCallback onChanged;
  final TransactionModel transaction;
  @override
  Widget build(BuildContext context) {
    final amount = transaction.signedAmount;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 350 ||
            MediaQuery.textScalerOf(context).scale(14) > 20 ||
            transaction.amount >= 1000000000;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: transaction.isTransfer
                ? Colors.blue
                : transaction.isIncome
                ? Colors.green
                : Colors.orange,
            child: Icon(
              transaction.isTransfer
                  ? Icons.swap_horiz
                  : transaction.isIncome
                  ? Icons.attach_money
                  : Icons.fastfood,
              color: Colors.white,
            ),
          ),
          title: Text(transaction.title),
          subtitle: Text(
            '${displayDate(transaction.date)} • ${transaction.category}${compact ? '\n$amount' : ''}',
          ),
          trailing: compact
              ? null
              : Text(
                  amount,
                  style: TextStyle(
                    color: transaction.isTransfer
                        ? Colors.blue
                        : transaction.isIncome
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => TransactionDetailScreen(
                  transaction: transaction,
                  store: store,
                ),
              ),
            );
            onChanged();
          },
        );
      },
    );
  }
}
