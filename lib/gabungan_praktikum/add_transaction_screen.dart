import 'package:flutter/material.dart';

import 'models/transaction_model.dart';
import 'storage.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({
    super.key,
    required this.store,
    this.initialKind = 'expense',
    this.transaction,
  });
  final AppStore store;
  final String initialKind;
  final TransactionModel? transaction;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _category = 'Makanan';
  bool _isIncome = false;
  bool _isTransfer = false;
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isIncome = widget.initialKind == 'income';
    _isTransfer = widget.initialKind == 'transfer';
    _category = _isIncome
        ? 'Pemasukan'
        : _isTransfer
        ? 'Transfer'
        : 'Makanan';
    final item = widget.transaction;
    if (item != null) {
      _titleController.text = item.title;
      _amountController.text = '${item.amount}';
      _dateController.text = displayDate(item.date);
      _category = item.category;
      _isIncome = item.isIncome;
      _isTransfer = item.isTransfer;
    } else {
      _loadDraft();
    }
    for (final controller in [
      _titleController,
      _amountController,
      _dateController,
    ]) {
      controller.addListener(_saveDraft);
    }
  }

  bool _restoring = false;
  Future<void> _loadDraft() async {
    try {
      final draft = await widget.store.draft('transaction');
      if (!mounted || draft.isEmpty || _titleController.text.isNotEmpty) return;
      _restoring = true;
      setState(() {
        _titleController.text = draft['title'] ?? '';
        _amountController.text = draft['amount'] ?? '';
        _dateController.text = draft['date'] ?? '';
        _category = draft['category'] ?? _category;
        _isIncome = draft['income'] == 'true';
        _isTransfer = draft['transfer'] == 'true';
      });
      _restoring = false;
    } catch (_) {
      if (mounted) _notice('Input belum dapat dibuka.');
    }
  }

  void _notice(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  void _saveDraft() {
    if (widget.transaction != null || _restoring || _saving) return;
    widget.store
        .saveDraft('transaction', {
          'title': _titleController.text,
          'amount': _amountController.text,
          'date': _dateController.text,
          'category': _category,
          'income': '$_isIncome',
          'transfer': '$_isTransfer',
        })
        .catchError((Object _) {
          if (mounted) _notice('Input belum tersimpan. Coba lagi.');
        });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Pilih Tanggal Transaksi',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    final String day = selectedDate.day.toString().padLeft(2, '0');
    final String month = selectedDate.month.toString().padLeft(2, '0');
    final String year = selectedDate.year.toString();

    setState(() {
      _dateController.text = '$day/$month/$year';
    });
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _saving = true);
      final parts = _dateController.text.split('/').map(int.parse).toList();
      final now = DateTime.now();
      final item = TransactionModel(
        id: widget.transaction?.id,
        userId: widget.store.userId,
        title: _titleController.text.trim(),
        amount: int.parse(_amountController.text.trim()),
        category: _category,
        date: DateTime(
          parts[2],
          parts[1],
          parts[0],
          now.hour,
          now.minute,
          now.second,
        ).toUtc().toIso8601String(),
        isIncome: _isIncome,
        isTransfer: _isTransfer,
      );
      try {
        await widget.store.saveTransaction(item);
        if (widget.transaction == null) {
          await widget.store.saveDraft('transaction', {});
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transaksi ${_titleController.text} '
              'pada ${_dateController.text} berhasil disimpan!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, item);
      } catch (_) {
        if (mounted) _notice('Transaksi belum tersimpan. Coba lagi.');
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Kalkulator Kabataku',
            onPressed: () => Navigator.pushNamed(context, '/calculator'),
            icon: const Icon(Icons.calculate),
          ),
        ],
        title: Text(
          widget.transaction == null ? 'Catat Transaksi' : 'Edit Transaksi',
        ),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('tx-title'),
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  hintText: 'Contoh: Belanja Bulanan',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('tx-amount'),
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal',
                  hintText: 'Contoh: 100000',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nominal tidak boleh kosong';
                  }

                  final int? amount = int.tryParse(value.trim());

                  if (amount == null) {
                    return 'Nominal harus berupa angka';
                  }

                  if (amount <= 0 || amount > 1000000000000) {
                    return 'Nominal harus 1 sampai 1000000000000';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input tanggal untuk bagian tugas
              TextFormField(
                key: const Key('tx-date'),
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Transaksi',
                  hintText: 'DD/MM/YYYY',
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tanggal transaksi wajib diisi';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: transactionCategories
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: _saving
                    ? null
                    : (v) {
                        setState(() => _category = v!);
                        _saveDraft();
                      },
                validator: (value) => transactionCategories.contains(value)
                    ? null
                    : 'Pilih kategori.',
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                key: const Key('tx-income'),
                title: const Text('Pemasukan'),
                subtitle: Text(_isIncome ? 'Menambah saldo' : 'Pengeluaran'),
                value: _isIncome,
                onChanged: _isTransfer || _saving
                    ? null
                    : (v) {
                        setState(() => _isIncome = v);
                        _saveDraft();
                      },
              ),
              if (_isTransfer)
                const Text('Catatan transfer tidak mengubah saldo.'),
              const SizedBox(height: 32),
              ElevatedButton(
                key: const Key('tx-save'),
                onPressed: _saving ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Simpan', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
