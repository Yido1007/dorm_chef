import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/grocery.dart';

Future<void> showGrocerySheet(BuildContext context) async {
  final bag = context.read<GroceryBag>();
  await bag.ensure();

  // ignore: use_build_context_synchronously
  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_cart_outlined),
                  const SizedBox(width: 8),
                  Text(
                    'Alışveriş Listesi',
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      await bag.clear();
                    },
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Temizle'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Consumer<GroceryBag>(
                  builder: (ctx, gb, _) {
                    if (gb.items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'Liste boş. Tarif detayından eksikleri ekleyebilirsin.',
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: gb.items.length,
                      separatorBuilder: (_, __) => const Divider(height: 0),
                      itemBuilder: (_, i) {
                        final it = gb.items[i];
                        return CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          value: it.done,
                          onChanged: (_) => gb.toggle(it.id),
                          title: Text(
                            it.label,
                            style: TextStyle(
                              decoration:
                                  it.done ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          secondary: IconButton(
                            tooltip: 'Kaldır',
                            icon: const Icon(Icons.close),
                            onPressed: () => gb.remove(it.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // alt güvenli boşluk
              SizedBox(height: MediaQuery.of(ctx).padding.bottom),
            ],
          ),
        ),
      );
    },
  );
}
