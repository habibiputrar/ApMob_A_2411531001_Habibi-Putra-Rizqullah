import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'login_screen.dart';
import 'add_transaction_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.amber, useMaterial3: false),
      initialRoute: '/login',
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute<void>(settings: const RouteSettings(name: '/login'),
          builder: (_) => const LoginScreen()),
      ],
      routes: {
        '/login': (context) => const LoginScreen(),
        '/': (context) {
          final email = ModalRoute.of(context)!.settings.arguments as String?;
          return MainScreen(email: email ?? '');
        },
        '/add': (context) => const AddTransactionScreen(),
      },
    );
  }
}
