import 'package:flutter/material.dart';

import 'storage.dart';

class StoreScope extends InheritedWidget {
  final AppStore store;
  const StoreScope({super.key, required this.store, required super.child});
  static AppStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StoreScope>()!.store;
  @override
  bool updateShouldNotify(StoreScope oldWidget) => oldWidget.store != store;
}

// Mempertahankan widget latihan asli; controller hanya dihubungkan ke draft akun.
mixin SavedInputs<T extends StatefulWidget> on State<T> {
  Map<String, TextEditingController> get savedControllers;
  String get draftKey;
  bool _loaded = false;
  bool _restoring = false;
  AppStore? _store;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _store = StoreScope.of(context);
    _restore();
  }

  Future<void> _restore() async {
    try {
      final values = await _store!.draft(draftKey);
      if (!mounted) return;
      _restoring = true;
      for (final entry in savedControllers.entries) {
        if (entry.value.text.isEmpty) {
          entry.value.text = values[entry.key] ?? '';
        }
        entry.value.addListener(saveInputs);
      }
      _restoring = false;
      setState(() {});
    } catch (_) {
      if (mounted) _notifyFailure();
    }
  }

  void _notifyFailure() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Input belum tersimpan. Coba lagi.')),
  );
  void saveInputs() {
    if (_restoring || _store == null) return;
    _store!
        .saveDraft(
          draftKey,
          savedControllers.map((key, value) => MapEntry(key, value.text)),
        )
        .catchError((Object _) {
          if (mounted) _notifyFailure();
        });
  }
}
