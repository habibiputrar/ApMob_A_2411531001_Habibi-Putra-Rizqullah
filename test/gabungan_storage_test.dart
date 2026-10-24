import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:praktikum_1/gabungan_praktikum/storage.dart';
import 'package:praktikum_1/gabungan_praktikum/models/transaction_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  test('Register, login, CRUD, sesi, draft, dan isolasi SQLite bertahan setelah koneksi dibuka ulang', () async {
    final temp = await Directory.systemTemp.createTemp('gabungan_test_');
    final dbPath = '${temp.path}/app.db';
    var store = AppStore(factory: databaseFactoryFfi, path: dbPath);
    try {
      await store.restoreSession();
      expect(store.user, isNull);
      await expectLater(
        store.register('', 'bad', 'short'),
        throwsFormatException,
      );
      await store.register('Pengguna Satu', 'SATU@example.com', 'password123');
      await expectLater(
        store.register('Duplikat', 'satu@example.com', 'password123'),
        throwsFormatException,
      );
      expect(await store.login('satu@example.com', 'salah'), isFalse);
      expect(await store.login('satu@example.com', 'password123'), isTrue);
      expect(store.user!.name, 'Pengguna Satu');
      final owner = store.userId;
      final raw = (await (await store.database).query('users')).first;
      expect(raw['password_hash'], isNot('password123'));
      expect((raw['password_salt'] as String).length, greaterThan(16));
      expect(
        (await (await store.database).rawQuery('PRAGMA foreign_keys'))
            .first
            .values
            .first,
        1,
      );
      TransactionModel item(
        int amount, {
        int? id,
        int? userId,
        bool income = false,
        bool transfer = false,
      }) => TransactionModel(
        id: id,
        userId: userId ?? store.userId,
        title: 'Uji',
        amount: amount,
        category: 'Lainnya',
        date: DateTime.now().toUtc().toIso8601String(),
        isIncome: income,
        isTransfer: transfer,
      );
      await store.setOpeningBalance(50000);
      await store.saveTransaction(item(100000, income: true));
      await store.saveTransaction(item(25000));
      await store.saveTransaction(item(40000, transfer: true));
      int balance(List<TransactionModel> items) => items.fold(
        store.user!.openingBalance,
        (sum, t) =>
            sum +
            (t.isTransfer
                ? 0
                : t.isIncome
                ? t.amount
                : -t.amount),
      );
      expect(balance(await store.transactions()), 125000);
      final expense = (await store.transactions()).firstWhere(
        (t) => !t.isIncome && !t.isTransfer,
      );
      await store.saveTransaction(item(30000, id: expense.id));
      expect((await store.transaction(expense.id!))!.amount, 30000);
      expect(balance(await store.transactions()), 120000);
      await store.deleteTransaction(expense.id!);
      expect(balance(await store.transactions()), 150000);
      await expectLater(store.saveTransaction(item(0)), throwsFormatException);
      await store.saveDraft('calculator', {
        'first': '10',
        'second': '5',
        'result': 'Hasil : 15.0',
      });
      await store.updateProfile('Pengguna Satu Baru', 'satu@example.com');
      final keptId = (await store.transactions()).first.id!;
      await store.close();
      store = AppStore(factory: databaseFactoryFfi, path: dbPath);
      await store.restoreSession();
      expect(store.userId, owner);
      expect(store.user!.name, 'Pengguna Satu Baru');
      expect(balance(await store.transactions()), 150000);
      expect((await store.draft('calculator'))['result'], 'Hasil : 15.0');
      await store.logout();
      expect(store.user, isNull);
      expect(await (await store.database).query('session'), isEmpty);
      await store.register('Pengguna Dua', 'dua@example.com', 'password456');
      expect(await store.login('dua@example.com', 'password456'), isTrue);
      await expectLater(
        store.updateProfile('Pengguna Dua', 'satu@example.com'),
        throwsFormatException,
      );
      expect(store.user!.email, 'dua@example.com');
      expect(await store.transactions(), isEmpty);
      expect(await store.draft('calculator'), isEmpty);
      expect(await store.transaction(keptId), isNull);
      await expectLater(store.deleteTransaction(keptId), throwsStateError);
      await expectLater(
        store.saveTransaction(item(1, id: keptId)),
        throwsStateError,
      );
      await expectLater(
        store.saveTransaction(item(1, userId: owner)),
        throwsStateError,
      );
      await store.logout();
      expect(await store.login('satu@example.com', 'password123'), isTrue);
      expect((await store.transactions()).length, 2);
      expect((await store.draft('calculator'))['first'], '10');
    } finally {
      await store.close();
      await temp.delete(recursive: true);
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}
