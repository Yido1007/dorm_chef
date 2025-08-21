import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/ingredient.dart';
import '../../widget/ingredient_tile.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer dışında, dinlemeden store'u alıyoruz:
    final store = context.read<PantryStore>();
    final bootFuture = store.warmUp();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Envanter'),
        actions: [
          IconButton(
            tooltip: 'Tümünü sil',
            onPressed: () async {
              if (store.list.isEmpty) return;
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Malzeme ekle'),
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
                title: const Text('Malzeme ekle'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: ctrl,
                      decoration: const InputDecoration(
                        labelText: 'Ad (ör. Domates)',
                      ),
                      textInputAction: TextInputAction.done,
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
                    child: const Text('Vazgeç'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Ekle'),
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
