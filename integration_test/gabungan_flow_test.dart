import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:praktikum_1/gabungan_praktikum/main.dart' as app;
import 'package:praktikum_1/gabungan_praktikum/storage.dart';
import 'package:praktikum_1/gabungan_praktikum/main_screen.dart';
import 'package:praktikum_1/gabungan_praktikum/login_screen.dart';
import 'package:praktikum_1/gabungan_praktikum/add_transaction_screen.dart';
import 'package:praktikum_1/gabungan_praktikum/transaction_detail_screen.dart';
import 'package:praktikum_1/gabungan_praktikum/models/transaction_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Pixel 9: akun, transaksi, edit profil, kalkulator, isolasi dan logout',
    (tester) async {
      tester.testTextInput.register();
      addTearDown(tester.testTextInput.unregister);
      final store = AppStore();
      Future<void> wait(Finder finder) async {
        for (var i = 0; i < 300; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          if (finder.evaluate().isNotEmpty) {
            await tester.pumpAndSettle();
            return;
          }
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        final texts = find
            .byType(Text)
            .evaluate()
            .map((e) => (e.widget as Text).data)
            .whereType<String>()
            .join(' | ');
        fail('Tidak muncul: $finder. Layar: $texts');
      }

      Future<void> tap(Finder finder) async {
        FocusManager.instance.primaryFocus?.unfocus();
        if (find.byType(SnackBar).evaluate().isNotEmpty) {
          tester
              .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
              .hideCurrentSnackBar();
        }
        await tester.pumpAndSettle();
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      Future<void> text(String label) => tap(find.text(label).first);
      Future<void> fill(String key, String value) async {
        final finder = find.byKey(Key(key));
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        await tester.enterText(finder, value);
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextFormField>(finder).controller!.text == value,
          isTrue,
        );
      }

      Future<void> fields(
        String name,
        String email,
        String password,
        String confirm,
      ) async {
        await fill('register-name', name);
        await fill('register-email', email);
        await fill('register-password', password);
        await fill('register-confirm', confirm);
      }

      Future<void> register(
        String name,
        String email,
        String password, {
        bool validate = false,
      }) async {
        await tap(find.byKey(const Key('open-register')));
        await fields(name, email, password, validate ? 'berbeda123' : password);
        if (validate) {
          await tap(find.byKey(const Key('register-submit')));
          expect(find.text('Konfirmasi password tidak sama.'), findsOneWidget);
          await tester.pageBack();
          await tester.pumpAndSettle();
          await tap(find.byKey(const Key('open-register')));
          await fields(name, email, password, password);
        }
        await tap(find.byKey(const Key('register-submit')));
        for (var i = 0; i < 300; i++) {
          await tester.pump(const Duration(milliseconds: 100));
          if (find.byType(LoginScreen).evaluate().isNotEmpty ||
              find.text('Email sudah terdaftar.').evaluate().isNotEmpty) {
            break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        if (find.text('Email sudah terdaftar.').evaluate().isNotEmpty) {
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
        await wait(find.byType(LoginScreen));
      }

      Future<void> login(String email, String password) async {
        await fill('email', email);
        await fill('password', password);
        await tap(find.byKey(const Key('login-submit')));
        await wait(find.byType(MainScreen));
        await wait(find.textContaining('Halo,'));
      }

      Future<void> logout() async {
        await text('Profil');
        await tap(find.byKey(const Key('logout')));
        await wait(find.byType(LoginScreen));
        expect(
          Navigator.of(tester.element(find.byType(LoginScreen))).canPop(),
          isFalse,
        );
      }

      Future<void> add(String kind, String title, String amount) async {
        await text(kind);
        await wait(find.byType(AddTransactionScreen));
        await fill('tx-title', title);
        await fill('tx-amount', amount);
        await tap(find.byKey(const Key('tx-date')));
        await text('Pilih');
        await tap(find.byKey(const Key('tx-save')));
        await wait(find.byType(MainScreen));
        await wait(find.text(title));
        debugPrint('STEP: $kind disimpan');
      }

      await tester.pumpWidget(app.MyApp(store: store));
      await store.restoreSession();
      await tester.pumpAndSettle();
      if (store.user != null) await logout();
      await wait(find.byType(LoginScreen));
      await register(
        'Pengguna Uji',
        'pengguna.satu@example.com',
        'uji-lokal-123',
        validate: true,
      );
      await tap(find.byKey(const Key('open-register')));
      await fields(
        'Pengguna Uji',
        'pengguna.satu@example.com',
        'uji-lokal-123',
        'uji-lokal-123',
      );
      await tap(find.byKey(const Key('register-submit')));
      await wait(find.text('Email sudah terdaftar.'));
      await tester.pageBack();
      await tester.pumpAndSettle();
      await fill('email', 'pengguna.satu@example.com');
      await fill('password', 'password-salah');
      await tap(find.byKey(const Key('login-submit')));
      await wait(find.text('Email atau password salah.'));
      await login('pengguna.satu@example.com', 'uji-lokal-123');
      expect(find.text('Halo, Pengguna Uji'), findsOneWidget);
      expect(find.text('pengguna.satu@example.com'), findsOneWidget);
      final firstOwner = store.userId;
      // Samakan judul data uji lama sebelum menjalankan skenario transaksi.
      for (final item in await store.transactions()) {
        final natural = RegExp(r'^Gaji praktikum \d+$').hasMatch(item.title)
            ? 'Gaji Bulanan'
            : RegExp(r'^Makan siang \d+$').hasMatch(item.title)
            ? 'Makan Siang'
            : RegExp(r'^Catatan transfer \d+$').hasMatch(item.title)
            ? 'Transfer Tabungan'
            : item.title;
        if (natural != item.title) {
          await store.saveTransaction(
            TransactionModel(
              id: item.id,
              userId: item.userId,
              title: natural,
              amount: item.amount,
              category: item.category,
              date: item.date,
              isIncome: item.isIncome,
              isTransfer: item.isTransfer,
            ),
          );
        }
      }
      final initial = (await store.transactions()).fold<int>(
        store.user!.openingBalance,
        (sum, t) =>
            sum +
            (t.isTransfer
                ? 0
                : t.isIncome
                ? t.amount
                : -t.amount),
      );
      await add('Pemasukan', 'Gaji Bulanan', '1000000');
      await add('Pengeluaran', 'Makan Siang', '25000');
      expect(find.text(rupiah(initial + 975000)), findsOneWidget);
      await add('Transfer', 'Transfer Tabungan', '50000');
      expect(find.text(rupiah(initial + 975000)), findsOneWidget);
      await text('Riwayat');
      await text('Makan Siang');
      await wait(find.byType(TransactionDetailScreen));
      expect(
        tester.widget<AppBar>(find.byType(AppBar).last).backgroundColor,
        Colors.red,
      );
      expect(find.text('- Rp 25.000'), findsOneWidget);
      await text('Edit');
      await fill('tx-amount', '30000');
      await tap(find.byKey(const Key('tx-save')));
      await wait(find.text('- Rp 30.000'));
      await tester.pageBack();
      await tester.pumpAndSettle();
      await text('Beranda');
      await wait(find.text(rupiah(initial + 970000)));
      await add('Pengeluaran', 'Belanja Harian', '1000');
      await text('Riwayat');
      await text('Belanja Harian');
      await wait(find.byType(TransactionDetailScreen));
      await text('Hapus transaksi');
      await text('Batal');
      expect(find.byType(TransactionDetailScreen), findsOneWidget);
      await text('Hapus transaksi');
      await text('Hapus');
      await wait(find.byType(MainScreen));
      await text('Beranda');
      await wait(find.text(rupiah(initial + 970000)));
      await text('Profil');
      expect(find.text('Pengguna Uji'), findsOneWidget);
      expect(find.text('pengguna.satu@example.com'), findsOneWidget);
      expect(find.text('Basic Form'), findsNothing);
      expect(find.text('Basic Form TextFormField'), findsNothing);
      expect(find.byTooltip('Kalkulator Kabataku'), findsNothing);
      await text('Edit profil');
      await fill('profile-name', '');
      await fill('profile-email', 'salah');
      await tap(find.byKey(const Key('profile-save')));
      expect(find.text('Nama wajib diisi.'), findsOneWidget);
      expect(find.text('Format email tidak valid.'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await text('Edit profil');
      await fill('profile-name', 'Pengguna Uji');
      await fill('profile-email', 'pengguna.satu@example.com');
      await tap(find.byKey(const Key('profile-save')));
      await wait(find.byKey(const Key('logout')));
      await text('Beranda');
      await tap(find.byTooltip('Kalkulator Kabataku'));
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Angka Pertama'),
        '10',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Angka Kedua'),
        '5',
      );
      await text('+');
      expect(find.text('Hasil : 15.0'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tap(find.byTooltip('Kalkulator Kabataku'));
      await wait(find.text('Hasil : 15.0'));
      await tester.pageBack();
      await tester.pumpAndSettle();
      await logout();
      await register(
        'Pengguna Kedua',
        'kedua.gabungan@example.com',
        'ujiakun123',
      );
      await login('kedua.gabungan@example.com', 'ujiakun123');
      expect(find.text('Gaji Bulanan'), findsNothing);
      expect(store.userId, isNot(firstOwner));
      expect(await store.transactions(), isEmpty);
      expect(await store.draft('calculator'), isEmpty);
      await logout();
      await login('pengguna.satu@example.com', 'uji-lokal-123');
      await wait(find.text(rupiah(initial + 970000)));
      expect(find.text('Gaji Bulanan'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
