import 'package:flutter/foundation.dart';

class Ingredient {
  final String id;
  final String name;
  int quantity;

  Ingredient({required this.id, required this.name, this.quantity = 0});

  factory Ingredient.fromName(String name, {int initial = 0}) {
    return Ingredient(
      id: UniqueKey().toString(),
      name: name.trim(),
      quantity: initial,
    );
  }
}
