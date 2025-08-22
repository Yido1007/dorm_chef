import 'package:hive/hive.dart';

class GroceryEntry {
  final String id;
  final String label;
  bool done;

  GroceryEntry({required this.id, required this.label, this.done = false});

  factory GroceryEntry.fromLabel(String label) => GroceryEntry(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    label: label.trim(),
  );
}

class GroceryEntryAdapter extends TypeAdapter<GroceryEntry> {
  @override
  final int typeId = 23;

  @override
  GroceryEntry read(BinaryReader r) {
    final id = r.read() as String;
    final label = r.read() as String;
    final done = r.read() as bool;
    return GroceryEntry(id: id, label: label, done: done);
  }

  @override
  void write(BinaryWriter w, GroceryEntry obj) {
    w
      ..write(obj.id)
      ..write(obj.label)
      ..write(obj.done);
  }
}
