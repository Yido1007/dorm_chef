import 'package:dorm_chef/provider/ingredient.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/ingredient.dart';

class IngredientTile extends StatelessWidget {
  final Ingredient item;
  const IngredientTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _openAmountSheet(context, item),
      leading: const Icon(Icons.kitchen),
      title: Text(item.name),
      subtitle: Text('Miktar: ${item.quantity}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Azalt',
            icon: const Icon(Icons.remove_circle_outline),
            onPressed:
                () => context.read<InventoryProvider>().decrement(item.id),
          ),
          IconButton(
            tooltip: 'Arttır',
            icon: const Icon(Icons.add_circle_outline),
            onPressed:
                () => context.read<InventoryProvider>().increment(item.id),
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
                      content: Text(
                        '"${item.name}" envanterden kaldırılsın mı?',
                      ),
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
                context.read<InventoryProvider>().remove(item.id);
              }
            },
          ),
        ],
      ),
    );
  }

  void _openAmountSheet(BuildContext context, Ingredient item) {
    final provider = context.read<InventoryProvider>();
    double value = item.quantity.toDouble();

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
                  Text(item.name, style: Theme.of(ctx).textTheme.titleLarge),
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
                    onPressed: () {
                      provider.setQuantity(item.id, value.toInt());
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
