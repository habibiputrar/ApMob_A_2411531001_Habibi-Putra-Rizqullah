import 'package:flutter/material.dart';
import 'models/transaction_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.email});
  final String email;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), automaticallyImplyLeading: false),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const Center(child: CircleAvatar(radius: 45, backgroundColor: Colors.amber,
          child: Icon(Icons.person, size: 56, color: Colors.white))),
        const SizedBox(height: 20),
        Text(userName(email), textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(email, textAlign: TextAlign.center),
        const SizedBox(height: 28),

        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, '/login', (route) => false),
          icon: const Icon(Icons.logout), label: const Text('Logout'),
        ),
      ]),
    );
  }
}
