class TransactionModel {
  const TransactionModel({required this.title, required this.amount,
    required this.category, required this.date, required this.isIncome});
  final String title;
  final int amount;
  final String category;
  final String date;
  final bool isIncome;
}

String rupiah(int value) {
  final digits = value.abs().toString();
  final formatted = digits.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  return '${value < 0 ? '-' : ''}Rp $formatted';
}

String userName(String email) => email.split('@').first;
