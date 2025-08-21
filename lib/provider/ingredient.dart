import 'dart:collection';
import 'package:flutter/material.dart';
import '../model/ingredient.dart';

class InventoryProvider extends ChangeNotifier {
  final List<Ingredient> _items = [];

  UnmodifiableListView<Ingredient> get items => UnmodifiableListView(_items);

  void addOrIncrease(String name, {int initial = 1}) {
    final idx = _items.indexWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase().trim(),
    );
    if (idx >= 0) {
      _items[idx].quantity += initial;
    } else {
      _items.add(Ingredient.fromName(name, initial: initial));
    }
    notifyListeners();
  }

  void setQuantity(String id, int qty) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i >= 0) {
      _items[i].quantity = qty.clamp(0, 1000);
      notifyListeners();
    }
  }

  void increment(String id, [int step = 1]) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i >= 0) {
      _items[i].quantity += step;
      notifyListeners();
    }
  }

  void decrement(String id, [int step = 1]) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i >= 0) {
      _items[i].quantity = (_items[i].quantity - step).clamp(0, 1000);
      notifyListeners();
    }
  }

  void remove(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
