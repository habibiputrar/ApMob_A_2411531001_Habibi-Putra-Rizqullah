import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_1/gabungan_praktikum/register_screen.dart';
import 'package:praktikum_1/gabungan_praktikum/dashboard_screen.dart';
import 'package:praktikum_1/gabungan_praktikum/storage.dart';
import 'package:praktikum_1/gabungan_praktikum/widgets/balance_card_widget.dart';
import 'package:praktikum_1/gabungan_praktikum/loading_screen.dart';

void main() {
  testWidgets('Loading menampilkan logo dan nama Expense Tracker', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoadingScreen()));
    await tester.pump();
    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets(
    'Register menolak input kosong, email salah, dan konfirmasi berbeda',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: RegisterScreen(store: AppStore())),
      );
      Future<void> submit() async {
        await tester.ensureVisible(find.byKey(const Key('register-submit')));
        await tester.tap(find.byKey(const Key('register-submit')));
        await tester.pumpAndSettle();
      }

      await submit();
      expect(find.text('Nama wajib diisi.'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('register-name')), 'Uji');
      await tester.enterText(
        find.byKey(const Key('register-email')),
        'tidakvalid',
      );
      await tester.enterText(
        find.byKey(const Key('register-password')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('register-confirm')),
        'password456',
      );
      await submit();
      expect(find.text('Format email tidak valid.'), findsOneWidget);
      expect(find.text('Konfirmasi password tidak sama.'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('register-email')),
        'uji@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('register-confirm')),
        'password123',
      );
      expect(tester.state<FormState>(find.byType(Form)).validate(), isTrue);
    },
  );
  testWidgets(
    'Dashboard tetap amber, toggle saldo dan layar kecil tidak overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primarySwatch: Colors.amber, useMaterial3: false),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: DashboardScreen(
            user: const LocalUser(
              1,
              'Nama lengkap pengguna yang panjang',
              'uji@example.com',
              1250000,
            ),
            store: AppStore(),
            transactions: const [],
            onAdded: (_) {},
            onHistory: () {},
            onProfile: () {},
          ),
        ),
      );
      expect(
        tester.widget<AppBar>(find.byType(AppBar)).backgroundColor,
        Colors.amber,
      );
      await tester.ensureVisible(find.byType(BalanceCardWidget));
      expect(find.text('Rp 1.250.000'), findsOneWidget);
      await tester.tap(find.byTooltip('Sembunyikan saldo'));
      await tester.pump();
      expect(find.text('Rp *********'), findsOneWidget);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
