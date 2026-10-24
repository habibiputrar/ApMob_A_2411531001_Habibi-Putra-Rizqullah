import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'models/transaction_model.dart';

class LocalUser {
  final int id;
  final String name, email;
  final int openingBalance;
  const LocalUser(this.id, this.name, this.email, this.openingBalance);
  factory LocalUser.fromMap(Map<String, Object?> row) => LocalUser(
    row['id'] as int,
    row['name'] as String,
    row['email'] as String,
    row['opening_balance'] as int,
  );
}

String? emailValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Email wajib diisi.';
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())
      ? null
      : 'Format email tidak valid.';
}

Future<String> _passwordKey(Map<String, String> input) async {
  final key = await Pbkdf2.hmacSha256(iterations: 600000, bits: 256).deriveKey(
    secretKey: SecretKey(utf8.encode(input['password']!)),
    nonce: base64Decode(input['salt']!),
  );
  return base64Encode(await key.extractBytes());
}

// Satu SQLite untuk akun, sesi, transaksi, dan input latihan. Tidak ada data contoh.
class AppStore {
  final DatabaseFactory? factory;
  final String? path;
  AppStore({this.factory, this.path});
  Future<Database>? _opening;
  LocalUser? user;
  int get userId => user?.id ?? (throw StateError('Silakan login kembali.'));
  Future<Database> get database => _opening ??= _open();
  Future<Database> _open() async {
    try {
      final driver = factory ?? databaseFactory;
      return await driver.openDatabase(
        path ??
            p.join(await driver.getDatabasesPath(), 'gabungan_praktikum.db'),
        options: OpenDatabaseOptions(
          version: 1,
          onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
          onCreate: (db, version) async {
            await db.execute(
              '''CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL, email TEXT NOT NULL UNIQUE, password_hash TEXT NOT NULL,
            password_salt TEXT NOT NULL, opening_balance INTEGER NOT NULL DEFAULT 0 CHECK(opening_balance >= 0), created_at TEXT NOT NULL)''',
            );
            await db.execute(
              '''CREATE TABLE transactions(id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL REFERENCES users(id), title TEXT NOT NULL CHECK(length(trim(title)) > 0),
            amount INTEGER NOT NULL CHECK(amount > 0 AND amount <= 1000000000000), category TEXT NOT NULL,
            kind TEXT NOT NULL CHECK(kind IN ('income','expense','transfer')), created_at TEXT NOT NULL)''',
            );
            await db.execute(
              'CREATE INDEX tx_user_date ON transactions(user_id, created_at DESC)',
            );
            await db.execute(
              'CREATE TABLE session(id INTEGER PRIMARY KEY CHECK(id = 1), user_id INTEGER NOT NULL REFERENCES users(id))',
            );
            await db.execute(
              'CREATE TABLE drafts(user_id INTEGER NOT NULL REFERENCES users(id), name TEXT NOT NULL, payload TEXT NOT NULL, PRIMARY KEY(user_id,name))',
            );
          },
        ),
      );
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<void> restoreSession() async {
    final rows = await (await database).rawQuery(
      'SELECT users.* FROM users JOIN session ON session.user_id = users.id WHERE session.id = ?',
      [1],
    );
    user = rows.isEmpty ? null : LocalUser.fromMap(rows.first);
  }

  Future<void> register(String name, String email, String password) async {
    if (name.trim().isEmpty ||
        emailValidator(email) != null ||
        password.length < 8) {
      throw const FormatException(
        'Periksa data pendaftaran. Password minimal 8 karakter.',
      );
    }
    final normalized = email.trim().toLowerCase();
    final db = await database;
    if ((await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [normalized],
    )).isNotEmpty) {
      throw const FormatException('Email sudah terdaftar.');
    }
    final random = Random.secure();
    final salt = base64Encode(List.generate(16, (_) => random.nextInt(256)));
    final hash = await compute(_passwordKey, {
      'password': password,
      'salt': salt,
    });
    try {
      await db.insert('users', {
        'name': name.trim(),
        'email': normalized,
        'password_hash': hash,
        'password_salt': salt,
        'opening_balance': 0,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const FormatException('Email sudah terdaftar.');
      }
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    if (rows.isEmpty) return false;
    final row = rows.first;
    final actual = base64Decode(
      await compute(_passwordKey, {
        'password': password,
        'salt': row['password_salt'] as String,
      }),
    );
    final expected = base64Decode(row['password_hash'] as String);
    var difference = actual.length ^ expected.length;
    for (var i = 0; i < actual.length && i < expected.length; i++) {
      difference |= actual[i] ^ expected[i];
    }
    if (difference != 0) return false;
    await db.insert('session', {
      'id': 1,
      'user_id': row['id'],
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    user = LocalUser.fromMap(row);
    return true;
  }

  Future<void> logout() async {
    await (await database).delete('session', where: 'id = ?', whereArgs: [1]);
    user = null;
  }

  Future<List<TransactionModel>> transactions() async {
    final owner = userId;
    return (await (await database).query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [owner],
      orderBy: 'created_at DESC, id DESC',
    )).map(TransactionModel.fromMap).toList();
  }

  Future<TransactionModel?> transaction(int id) async {
    final owner = userId;
    final rows = await (await database).query(
      'transactions',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, owner],
    );
    return rows.isEmpty ? null : TransactionModel.fromMap(rows.first);
  }

  Future<void> saveTransaction(TransactionModel item) async {
    final owner = userId;
    if (item.userId != owner) {
      throw StateError('Transaksi tidak dapat diakses.');
    }
    if (item.title.trim().isEmpty ||
        item.amount <= 0 ||
        item.amount > 1000000000000 ||
        !transactionCategories.contains(item.category)) {
      throw const FormatException('Data transaksi tidak valid.');
    }
    final db = await database;
    if (item.id == null) {
      await db.insert('transactions', item.toMap());
    } else {
      final values = item.toMap()
        ..remove('id')
        ..remove('user_id');
      if (await db.update(
            'transactions',
            values,
            where: 'id = ? AND user_id = ?',
            whereArgs: [item.id, owner],
          ) !=
          1) {
        throw StateError('Transaksi tidak ditemukan.');
      }
    }
  }

  Future<void> deleteTransaction(int id) async {
    final owner = userId;
    if (await (await database).delete(
          'transactions',
          where: 'id = ? AND user_id = ?',
          whereArgs: [id, owner],
        ) !=
        1) {
      throw StateError('Transaksi tidak ditemukan.');
    }
  }

  Future<void> setOpeningBalance(int amount) async {
    final owner = userId;
    if (amount < 0 || amount > 1000000000000) {
      throw const FormatException('Saldo awal tidak valid.');
    }
    await (await database).update(
      'users',
      {'opening_balance': amount},
      where: 'id = ?',
      whereArgs: [owner],
    );
    user = LocalUser(owner, user!.name, user!.email, amount);
  }

  Future<void> updateProfile(String name, String email) async {
    final owner = userId;
    if (name.trim().isEmpty || emailValidator(email) != null) {
      throw const FormatException('Periksa nama dan email.');
    }
    final normalized = email.trim().toLowerCase();
    try {
      await (await database).update(
        'users',
        {'name': name.trim(), 'email': normalized},
        where: 'id = ?',
        whereArgs: [owner],
      );
      user = LocalUser(owner, name.trim(), normalized, user!.openingBalance);
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw const FormatException('Email sudah digunakan akun lain.');
      }
      rethrow;
    }
  }

  Future<Map<String, String>> draft(String name) async {
    final owner = userId;
    final rows = await (await database).query(
      'drafts',
      where: 'user_id = ? AND name = ?',
      whereArgs: [owner, name],
    );
    return rows.isEmpty
        ? {}
        : Map<String, String>.from(
            jsonDecode(rows.first['payload'] as String) as Map,
          );
  }

  Future<void> saveDraft(String name, Map<String, String> values) async {
    final owner = userId;
    await (await database).insert('drafts', {
      'user_id': owner,
      'name': name,
      'payload': jsonEncode(values),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> close() async {
    if (_opening != null) await (await _opening!).close();
    _opening = null;
  }
}
