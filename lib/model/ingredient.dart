import 'package:hive/hive.dart';
class PantryItem {
  final String id;
  final String label;
  int amount;

  PantryItem({required this.id, required this.label, this.amount = 0});

  factory PantryItem.fromLabel(String label, {int start = 0}) {
    return PantryItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      label: label.trim(),
      amount: start,
    );
  }
}

/// Elle yazılmış Hive adapter (build_runner gerekmez)
class PantryItemAdapter extends TypeAdapter<PantryItem> {
  @override
  final int typeId = 17; // Projede benzersiz bir id veriyoruz

  @override
  PantryItem read(BinaryReader reader) {
    final id = reader.read() as String;
    final label = reader.read() as String;
    final amount = reader.read() as int;
    return PantryItem(id: id, label: label, amount: amount);
  }

  @override
  void write(BinaryWriter writer, PantryItem obj) {
    writer
      ..write(obj.id)
      ..write(obj.label)
      ..write(obj.amount);
  }
}
