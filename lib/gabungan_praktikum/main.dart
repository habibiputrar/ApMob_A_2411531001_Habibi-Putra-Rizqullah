import 'package:flutter/material.dart';

import 'main_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'add_transaction_screen.dart';
import 'storage.dart';
import 'store_scope.dart';
import 'loading_screen.dart';
import 'models/transaction_model.dart';
import 'latihan/kalkulator_kabataku.dart' as calculator;
import 'edit_profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.store});
  final AppStore? store;
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final store = widget.store ?? AppStore();
  @override
  Widget build(BuildContext context) => StoreScope(
    store: store,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.amber, useMaterial3: false),
      initialRoute: '/',
      routes: {
        '/': (_) => _SessionGate(store: store),
        '/login': (_) => LoginScreen(store: store),
        '/register': (_) => RegisterScreen(store: store),
      },
      onGenerateRoute: (settings) => MaterialPageRoute<dynamic>(
        settings: settings,
        builder: (context) {
          if (store.user == null) return LoginScreen(store: store);
          switch (settings.name) {
            case '/main':
              return MainScreen(store: store);
            case '/add':
              return AddTransactionScreen(
                store: store,
                initialKind: settings.arguments is String
                    ? settings.arguments as String
                    : 'expense',
                transaction: settings.arguments is TransactionModel
                    ? settings.arguments as TransactionModel
                    : null,
              );
            case '/calculator':
              return _exercise(
                'Kalkulator Kabataku',
                const calculator.KalkulatorForm(),
              );
            case '/edit-profile':
              return EditProfileScreen(store: store);
            default:
              return MainScreen(store: store);
          }
        },
      ),
    ),
  );
  Widget _exercise(String title, Widget body) => Theme(
    data: ThemeData(),
    child: Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(child: SingleChildScrollView(child: body)),
    ),
  );
}

class _SessionGate extends StatefulWidget {
  final AppStore store;
  const _SessionGate({required this.store});
  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  Future<void> _initialize() async {
    await Future.wait([
      widget.store.restoreSession(),
      Future<void>.delayed(const Duration(milliseconds: 900)),
    ]);
  }

  late Future<void> session = _initialize();
  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: session,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const LoadingScreen();
      }
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => setState(() {
                session = _initialize();
              }),
              child: const Text('Belum dapat membuka data. Coba lagi.'),
            ),
          ),
        );
      }
      return widget.store.user == null
          ? LoginScreen(store: widget.store)
          : MainScreen(store: widget.store);
    },
  );
}
