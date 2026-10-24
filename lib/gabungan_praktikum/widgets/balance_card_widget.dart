import 'package:flutter/material.dart';

import '../models/transaction_model.dart';

// State dan toggle diadaptasi dari modul widgets; warna mengikuti kelanjutan Modul V.
class BalanceCardWidget extends StatefulWidget {
  const BalanceCardWidget({super.key, required this.balance});
  final int balance;

  @override
  State<BalanceCardWidget> createState() => _BalanceCardWidgetState();
}

class _BalanceCardWidgetState extends State<BalanceCardWidget> {
  // Menyimpan status apakah saldo ditampilkan atau disembunyikan
  bool _isBalanceVisible = true;

  // Mengubah status tampilan saldo
  void _toggleVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.amber.shade700,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Saldo Utama',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
                IconButton(
                  tooltip: _isBalanceVisible
                      ? 'Sembunyikan saldo'
                      : 'Tampilkan saldo',
                  icon: Icon(
                    _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: _toggleVisibility,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isBalanceVisible ? rupiah(widget.balance) : 'Rp *********',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
