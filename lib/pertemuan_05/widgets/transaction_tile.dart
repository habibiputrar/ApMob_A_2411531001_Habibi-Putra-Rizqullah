import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../transaction_detail_screen.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});
  final TransactionModel transaction;
  @override
  Widget build(BuildContext context) {
    final amount = '${transaction.isIncome ? '+' : '-'} ${rupiah(transaction.amount)}';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: transaction.isIncome ? Colors.green : Colors.orange,
        child: Icon(transaction.isIncome ? Icons.attach_money : Icons.fastfood,
          color: Colors.white),
      ),
      title: Text(transaction.title),
      subtitle: Text(transaction.date),
      trailing: Text(amount, style: TextStyle(
        color: transaction.isIncome ? Colors.green : Colors.red,
        fontWeight: FontWeight.bold)),
      onTap: () => Navigator.push(context, MaterialPageRoute<void>(
        builder: (_) => TransactionDetailScreen(
          title: transaction.title, amount: amount,
          category: transaction.category, date: transaction.date,
        ),
      )),
    );
  }
}
