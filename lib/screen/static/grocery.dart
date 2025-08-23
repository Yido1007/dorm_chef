import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/grocery.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  @override
  void initState() {
    super.initState();
    // Hive kutusunu hazırla
    Future.microtask(() => context.read<GroceryBag>().ensure());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alışveriş Sepeti'),
        actions: [
          IconButton(
            tooltip: 'Sepeti temizle',
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text('Tümünü sil?'),
                      content: const Text('Sepetteki tüm öğeler silinsin mi?'),
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
              if (ok == true) await context.read<GroceryBag>().clear();
            },
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: Consumer<GroceryBag>(
        builder: (context, bag, _) {
          if (bag.items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Sepet boş. Tarif detayından “Eksikleri ekle” ile doldurabilirsin.',
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: bag.items.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, i) {
              final it = bag.items[i];
              return CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                value: it.done,
                onChanged: (_) => bag.toggle(it.id),
                title: Text(
                  it.label,
                  style: TextStyle(
                    decoration: it.done ? TextDecoration.lineThrough : null,
                  ),
                ),
                secondary: IconButton(
                  tooltip: 'Kaldır',
                  icon: const Icon(Icons.close),
                  onPressed: () => bag.remove(it.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ctrl = TextEditingController();
          final added = await showDialog<bool>(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text('Öğe ekle'),
                  content: TextField(
                    controller: ctrl,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(hintText: 'Örn. Süt'),
                    onSubmitted: (_) => Navigator.pop(ctx, true),
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
          final text = ctrl.text.trim();
          if (added == true && text.isNotEmpty) {
            await context.read<GroceryBag>().addAllIfMissing([text]);
          }
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Ekle'),
      ),
    );
  }
}
