import 'package:hive_flutter/hive_flutter.dart';
import '../model/ingredient.dart';

class PantryLocal {
  static const String binName = 'pantry_box_v2';

  static Future<void> boot() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(17)) {
      Hive.registerAdapter(PantryItemAdapter());
    }
    await Hive.openBox<PantryItem>(binName);
  }

  static Box<PantryItem> get bin => Hive.box<PantryItem>(binName);
}
