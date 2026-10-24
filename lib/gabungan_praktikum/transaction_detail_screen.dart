import 'package:flutter/material.dart';

import 'models/transaction_model.dart';
import 'storage.dart';

// Struktur detail dan warna dari pertemuan_04/Tugas; data constructor diverifikasi ulang berdasarkan pemilik.
class TransactionDetailScreen extends StatefulWidget {
  final TransactionModel transaction;
  final AppStore store;
  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.store,
  });
  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late Future<TransactionModel?> _item = widget.store.transaction(
    widget.transaction.id!,
  );
  bool _busy = false;
  Future<void> _edit(TransactionModel item) async {
    await Navigator.pushNamed(context, '/add', arguments: item);
    if (mounted) {
      setState(() {
        _item = widget.store.transaction(widget.transaction.id!);
      });
    }
  }

  Future<void> _delete(TransactionModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: const Text('Transaksi ini akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || confirm != true) return;
    setState(() => _busy = true);
    try {
      await widget.store.deleteTransaction(item.id!);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi belum dapat dihapus.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: ThemeData(primarySwatch: Colors.red, useMaterial3: true),
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: FutureBuilder<TransactionModel?>(
          future: _item,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final item = snapshot.data;
            if (snapshot.hasError || item == null) {
              return const Center(child: Text('Transaksi tidak ditemukan.'));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.signedAmount,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: item.isTransfer
                          ? Colors.blue
                          : item.isIncome
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  const Divider(height: 40, thickness: 2),
                  _buildDetailRow('Kategori', item.category),
                  const SizedBox(height: 16),
                  _buildDetailRow('Tanggal', displayDate(item.date)),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Jenis',
                    item.isTransfer
                        ? 'Transfer'
                        : item.isIncome
                        ? 'Pemasukan'
                        : 'Pengeluaran',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Status', 'Berhasil'),
                  if (item.isTransfer)
                    const Text('Catatan transfer tidak mengubah saldo.'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _busy ? null : () => _edit(item),
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    onPressed: _busy ? null : () => _delete(item),
                    child: const Text('Hapus transaksi'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
  Widget _buildDetailRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      const SizedBox(width: 16),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}
