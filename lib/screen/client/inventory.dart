import 'package:dorm_chef/provider/ingredient.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widget/ingredient_tile.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Envanter'),
        actions: [
          IconButton(
            tooltip: 'Temizle (tümünü sil)',
            onPressed: () async {
              final prov = context.read<InventoryProvider>();
              if (prov.items.isEmpty) return;
              final ok = await showDialog<bool>(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text('Tümünü sil?'),
                      content: const Text(
                        'Envanterdeki tüm malzemeler silinsin mi?',
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
                final ids = prov.items.map((e) => e.id).toList();
                for (final id in ids) {
                  prov.remove(id);
                }
              }
            },
            icon: const Icon(Icons.delete_forever_outlined),
          ),
        ],
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, inv, _) {
          if (inv.items.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            itemCount: inv.items.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, i) => IngredientTile(item: inv.items[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Malzeme ekle'),
      ),
    );
  }

  Future<void> _openAddDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    int qty = 1;

    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Malzeme ekle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrl,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Ad (ör. Domates)',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Miktar:'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Slider(
                        min: 0,
                        max: 100,
                        divisions: 100,
                        value: qty.toDouble(),
                        onChanged: (v) {
                          qty = v.toInt();
                          (ctx as Element).markNeedsBuild();
                        },
                      ),
                    ),
                    Text('$qty'),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Vazgeç'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Ekle'),
              ),
            ],
          ),
    );

    if (ok == true && ctrl.text.trim().isNotEmpty) {
      context.read<InventoryProvider>().addOrIncrease(ctrl.text, initial: qty);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64),
            const SizedBox(height: 12),
            const Text('Henüz malzeme yok', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              'Sağ alttaki “Malzeme ekle” butonuyla başlamayı deneyebilirsin.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
