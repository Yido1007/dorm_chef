import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/ingredient.dart';
import '../../widget/ingredient/ingredient_tile.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer dışında, dinlemeden store'u alıyoruz:
    final store = context.read<PantryStore>();
    final bootFuture = store.warmUp();
    return Scaffold(
      appBar: AppBar(
        title: Text('inventory'.tr()),
        actions: [
          IconButton(
            tooltip: 'add_ing'.tr(),
            icon: const Icon(Icons.add),
            onPressed: () => _addDialog(context),
          ),
          IconButton(
            tooltip: 'delete_all'.tr(),
            onPressed: () async {
              if (store.list.isEmpty) return;
              final ok = await showDialog<bool>(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: Text('delete_all'.tr()),
                      content: Text('inventory_delete'.tr()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text('cancel'.tr()),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('delete'.tr()),
                        ),
                      ],
                    ),
              );
              if (ok == true) {
                await store.clearEverything();
              }
            },
            icon: const Icon(Icons.delete_forever_outlined),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: bootFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return Consumer<PantryStore>(
            builder: (context, s, _) {
              if (s.list.isEmpty) {
                return const _Empty();
              }
              return ListView.separated(
                itemCount: s.list.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (_, i) => PantryItemTile(data: s.list[i]),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    int amt = 1;

    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            // <-- markNeedsBuild yerine
            builder: (ctx, setLocalState) {
              return AlertDialog(
                title: Text('add_ing'.tr()),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: ctrl,
                      decoration: InputDecoration(labelText: 'example_2'.tr()),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('amount'.tr()),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Slider(
                            min: 0,
                            max: 100,
                            divisions: 100,
                            value: amt.toDouble(),
                            onChanged:
                                (v) => setLocalState(() => amt = v.toInt()),
                          ),
                        ),
                        Text('$amt'),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text('cancel'.tr()),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text('add'.tr()),
                  ),
                ],
              );
            },
          ),
    );

    if (ok == true && ctrl.text.trim().isNotEmpty) {
      await context.read<PantryStore>().addByLabel(ctrl.text, start: amt);
    }
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

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
            Text('inventory_main'.tr(), style: TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
            Text(
              'inventory_alt'.tr(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
