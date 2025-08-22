import 'package:hive_flutter/hive_flutter.dart';
import '../model/grocery.dart';
import '../model/ingredient.dart';

class PantryLocal {
  static const String binName = 'pantry_box_v2';
  static const String groceriesName = 'groceries_box_v1';

  static Future<void> boot() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(17)) {
      Hive.registerAdapter(PantryItemAdapter());
    }
    if (!Hive.isAdapterRegistered(23)) {
      Hive.registerAdapter(GroceryEntryAdapter());
    }

    await Future.wait([
      Hive.openBox<PantryItem>(binName),
      Hive.openBox<GroceryEntry>(groceriesName),
    ]);
  }

  static Box<PantryItem> get bin => Hive.box<PantryItem>(binName);
  static Box<GroceryEntry> get groceries =>
      Hive.box<GroceryEntry>(groceriesName);
}
