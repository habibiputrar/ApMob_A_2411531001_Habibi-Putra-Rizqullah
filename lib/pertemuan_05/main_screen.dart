import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'models/transaction_model.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.email});
  final String email;
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  // Saldo awal sebelum dua transaksi contoh adalah Rp 50.000.
  final List<TransactionModel> _transactions = [
    const TransactionModel(title: 'Makan Siang', amount: 50000,
      category: 'Makanan', date: '13 September 2026', isIncome: false),
    const TransactionModel(title: 'Gaji Bulanan', amount: 5000000,
      category: 'Pemasukan', date: '1 September 2026', isIncome: true),
  ];

  void _addTransaction(TransactionModel transaction) {
    setState(() => _transactions.insert(0, transaction));
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardScreen(email: widget.email, transactions: _transactions,
        onAdded: _addTransaction, onHistory: () => _onItemTapped(1),
        onProfile: () => _onItemTapped(2)),
      HistoryScreen(transactions: _transactions),
      ProfileScreen(email: widget.email),
    ];
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.amber[800],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
