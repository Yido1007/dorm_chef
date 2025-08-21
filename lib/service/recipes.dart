import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../model/recipes.dart';

class RecipeSource {
  static List<Recipe>? _cache;

  static Future<List<Recipe>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('asset/recipes.json');
    final List list = json.decode(raw) as List;
    _cache =
        list.map((e) => Recipe.fromMap(Map<String, dynamic>.from(e))).toList();
    return _cache!;
  }
}
