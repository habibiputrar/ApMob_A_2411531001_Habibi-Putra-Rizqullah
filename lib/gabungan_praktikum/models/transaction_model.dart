class TransactionModel {
  const TransactionModel({
    this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isIncome,
    this.isTransfer = false,
  });
  final int? id;
  final int userId;
  final String title;
  final int amount;
  final String category;
  final String date;
  final bool isIncome;
  final bool isTransfer;
  String get signedAmount =>
      '${isTransfer
          ? '↔'
          : isIncome
          ? '+'
          : '-'} ${rupiah(amount)}';
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'title': title,
    'amount': amount,
    'category': category,
    'created_at': date,
    'kind': isTransfer
        ? 'transfer'
        : isIncome
        ? 'income'
        : 'expense',
  };
  factory TransactionModel.fromMap(Map<String, Object?> row) =>
      TransactionModel(
        id: row['id'] as int,
        userId: row['user_id'] as int,
        title: row['title'] as String,
        amount: row['amount'] as int,
        category: row['category'] as String,
        date: row['created_at'] as String,
        isIncome: row['kind'] == 'income',
        isTransfer: row['kind'] == 'transfer',
      );
}

const transactionCategories = [
  'Makanan',
  'Transportasi',
  'Belanja',
  'Hiburan',
  'Pemasukan',
  'Gaji',
  'Bonus',
  'Transfer',
  'Lainnya',
];
String displayDate(String value) {
  final date = DateTime.tryParse(value)?.toLocal();
  return date == null
      ? value
      : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String rupiah(int value) {
  final digits = value.abs().toString();
  final formatted = digits.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return '${value < 0 ? '-' : ''}Rp $formatted';
}
