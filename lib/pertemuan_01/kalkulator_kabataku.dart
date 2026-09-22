import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Kalkulator Kabataku')),
        body: const KalkulatorForm(),
      ),
    );
  }
}

class KalkulatorForm extends StatefulWidget {
  const KalkulatorForm({super.key});

  @override
  State<KalkulatorForm> createState() => _KalkulatorFormState();
}

class _KalkulatorFormState extends State<KalkulatorForm> {
  final _formKey = GlobalKey<FormState>();
  final _angka1Controller = TextEditingController();
  final _angka2Controller = TextEditingController();

  String _hasil = '';

  @override
  void dispose() {
    _angka1Controller.dispose();
    _angka2Controller.dispose();
    super.dispose();
  }

  void _hitung(String operator) {
    if (_formKey.currentState!.validate()) {
      double angka1 = double.parse(_angka1Controller.text);
      double angka2 = double.parse(_angka2Controller.text);
      double hasil;

      switch (operator) {
        case '+':
          hasil = angka1 + angka2;
          break;
        case '-':
          hasil = angka1 - angka2;
          break;
        case '×':
          hasil = angka1 * angka2;
          break;
        case '÷':
          if (angka2 == 0) {
            setState(() {
              _hasil = 'Tidak bisa membagi dengan 0';
            });
            return;
          }
          hasil = angka1 / angka2;
          break;
        default:
          hasil = 0;
      }

      setState(() {
        _hasil = 'Hasil : $hasil';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextFormField(
              controller: _angka1Controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Angka Pertama',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan angka';
                }
                if (double.tryParse(value) == null) {
                  return 'Masukkan angka yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _angka2Controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Angka Kedua',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan angka';
                }
                if (double.tryParse(value) == null) {
                  return 'Masukkan angka yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _hitung('+'),
                  child: const Text('+'),
                ),
                ElevatedButton(
                  onPressed: () => _hitung('-'),
                  child: const Text('-'),
                ),
                ElevatedButton(
                  onPressed: () => _hitung('×'),
                  child: const Text('×'),
                ),
                ElevatedButton(
                  onPressed: () => _hitung('÷'),
                  child: const Text('÷'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _hasil,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
