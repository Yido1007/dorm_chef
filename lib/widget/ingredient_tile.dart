import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/ingredient.dart';
import '../provider/ingredient.dart';

class PantryItemTile extends StatelessWidget {
  final PantryItem data;
  const PantryItemTile({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _openAmountSheet(context, data),
      leading: const Icon(Icons.kitchen),
      title: Text(data.label),
      subtitle: Text('Miktar: ${data.amount}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Azalt',
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () async {
              await context.read<PantryStore>().decrease(data.id);
            },
          ),
          IconButton(
            tooltip: 'Arttır',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              await context.read<PantryStore>().increase(data.id);
            },
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Sil',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text('Malzemeyi sil?'),
                      content: Text('"${data.label}" kaldırılsın mı?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Vazgeç'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Sil'),
                        ),
                      ],
                    ),
              );
              if (ok == true) {
                await context.read<PantryStore>().deleteById(data.id);
              }
            },
          ),
        ],
      ),
    );
  }

  void _openAmountSheet(BuildContext context, PantryItem data) {
    final store = context.read<PantryStore>();
    double value = data.amount.toDouble();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(data.label, style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Miktar: ${value.toInt()}'),
                  Slider(
                    min: 0,
                    max: 100,
                    divisions: 100,
                    value: value,
                    label: value.toInt().toString(),
                    onChanged: (v) => setState(() => value = v),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () async {
                      await store.setAmount(data.id, value.toInt());
                      Navigator.pop(ctx);
                    },
                    child: const Text('Kaydet'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
