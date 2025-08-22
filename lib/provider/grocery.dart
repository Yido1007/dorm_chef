import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../model/grocery.dart';
import '../service/inventory.dart';

class GroceryBag extends ChangeNotifier {
  Box<GroceryEntry>? _box;
  final List<GroceryEntry> _items = [];
  bool _ready = false;

  UnmodifiableListView<GroceryEntry> get items => UnmodifiableListView(_items);

  Future<void> ensure() async {
    if (_ready) return;
    _box = PantryLocal.groceries;
    _items
      ..clear()
      ..addAll(_box!.values);
    _ready = true;
    notifyListeners();
  }

  Future<void> addAllIfMissing(Iterable<String> labels) async {
    await ensure();
    for (final raw in labels) {
      final label = raw.trim();
      final exists = _items.any(
        (e) => e.label.toLowerCase() == label.toLowerCase(),
      );
      if (exists) continue;
      final e = GroceryEntry.fromLabel(label);
      _items.add(e);
      await _box!.put(e.id, e);
    }
    notifyListeners();
  }

  Future<void> toggle(String id) async {
    final i = _items.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _items[i].done = !_items[i].done;
    await _box!.put(_items[i].id, _items[i]);
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _box!.delete(id);
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    await _box!.clear();
    notifyListeners();
  }
}
