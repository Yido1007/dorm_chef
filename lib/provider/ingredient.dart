import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../model/ingredient.dart';
import '../service/inventory.dart';

/// Uygulama durumu: malzeme listesi + Hive ile kalıcılık
class PantryStore extends ChangeNotifier {
  Box<PantryItem>? _bin; // Hive kutusu
  final List<PantryItem> _catalog = []; // Bellekteki veri

  UnmodifiableListView<PantryItem> get list => UnmodifiableListView(_catalog);

  bool _booted = false;
  Future<void>? _bootJob;

  /// Ekrandan güvenle çağır: yalnız ilk çağrıda Hive’dan yükler.
  Future<void> warmUp() {
    _bootJob ??= _loadOnce();
    return _bootJob!;
  }

  Future<void> _loadOnce() async {
    if (_booted) return;

    // Build aşaması tamamlandıktan sonra çalışsın:
    await Future<void>.delayed(Duration.zero);

    _bin = PantryLocal.bin;
    _catalog
      ..clear()
      ..addAll(_bin!.values);

    _booted = true;
    notifyListeners(); // artık build bittikten sonra çağrılır
  }

  Future<void> _upsert(PantryItem m) async {
    await _bin!.put(m.id, m);
  }

  Future<void> _purge(String id) async {
    await _bin!.delete(id);
  }

  Future<void> _wipe() async {
    await _bin!.clear();
  }

  // ----------------- Mutasyonlar (tamamı kalıcı) -----------------

  /// Ada göre ekle/varsa miktar arttır.
  Future<void> addByLabel(String label, {int start = 1}) async {
    final ix = _catalog.indexWhere(
      (e) => e.label.toLowerCase() == label.toLowerCase().trim(),
    );

    if (ix >= 0) {
      _catalog[ix].amount += start;
      await _upsert(_catalog[ix]);
    } else {
      final n = PantryItem.fromLabel(label, start: start);
      _catalog.add(n);
      await _upsert(n);
    }
    notifyListeners();
  }

  Future<void> setAmount(String id, int value) async {
    final ix = _catalog.indexWhere((e) => e.id == id);
    if (ix < 0) return;
    _catalog[ix].amount = value.clamp(0, 1000);
    await _upsert(_catalog[ix]);
    notifyListeners();
  }

  Future<void> increase(String id, [int step = 1]) async {
    final ix = _catalog.indexWhere((e) => e.id == id);
    if (ix < 0) return;
    _catalog[ix].amount += step;
    await _upsert(_catalog[ix]);
    notifyListeners();
  }

  Future<void> decrease(String id, [int step = 1]) async {
    final ix = _catalog.indexWhere((e) => e.id == id);
    if (ix < 0) return;
    _catalog[ix].amount = (_catalog[ix].amount - step).clamp(0, 1000);
    await _upsert(_catalog[ix]);
    notifyListeners();
  }

  Future<void> deleteById(String id) async {
    _catalog.removeWhere((e) => e.id == id);
    await _purge(id);
    notifyListeners();
  }

  Future<void> clearEverything() async {
    _catalog.clear();
    await _wipe();
    notifyListeners();
  }
}
