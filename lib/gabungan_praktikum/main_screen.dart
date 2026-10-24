import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'models/transaction_model.dart';
import 'storage.dart';
import 'loading_screen.dart';

// Kerangka tab dan IndexedStack dipertahankan dari pertemuan_05.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.store});
  final AppStore store;
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<TransactionModel> _transactions = [];
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final items = await widget.store.transactions();
      if (mounted) {
        setState(() {
          _transactions = items;
          _loading = false;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Transaksi belum dapat dibuka.';
          _loading = false;
        });
      }
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);
  @override
  Widget build(BuildContext context) {
    if (widget.store.user == null) return const SizedBox.shrink();
    if (_loading) return const LoadingScreen();
    return Scaffold(
      body: _error != null
          ? Center(
              child: TextButton(
                onPressed: _refresh,
                child: Text('$_error Coba lagi.'),
              ),
            )
          : IndexedStack(
              index: _selectedIndex,
              children: [
                DashboardScreen(
                  user: widget.store.user!,
                  store: widget.store,
                  transactions: _transactions,
                  onAdded: (_) => _refresh(),
                  onHistory: () => _onItemTapped(1),
                  onProfile: () => _onItemTapped(2),
                ),
                HistoryScreen(
                  transactions: _transactions,
                  store: widget.store,
                  onChanged: _refresh,
                ),
                ProfileScreen(store: widget.store, onChanged: _refresh),
              ],
            ),
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
