import 'package:flutter/material.dart';

// Disalin dari modul layout, kini tiap tombol memiliki callback.
class ActionButtonsWidget extends StatelessWidget {
  const ActionButtonsWidget({super.key, required this.onAction});
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.arrow_downward, 'Pemasukan', Colors.green),
        _buildActionButton(Icons.arrow_upward, 'Pengeluaran', Colors.red),
        _buildActionButton(Icons.swap_horiz, 'Transfer', Colors.blue),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () => onAction(
          label == 'Pemasukan'
              ? 'income'
              : label == 'Pengeluaran'
              ? 'expense'
              : 'transfer',
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
