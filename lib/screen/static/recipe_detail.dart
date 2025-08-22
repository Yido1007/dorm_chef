import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/recipes.dart';
import '../../provider/grocery.dart';
import '../../provider/ingredient.dart';
import '../../service/norm.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pantry = context.watch<PantryStore>();
    final normalizedPantry =
        pantry.list
            .where((p) => p.amount > 0)
            .map((p) => norm(p.label))
            .toSet();

    final have = <String>[];
    final missing = <String>[];
    for (final ing in recipe.ingredients) {
      final n = norm(ing);
      (normalizedPantry.contains(n) ? have : missing).add(ing);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        actions: [
          IconButton(
            tooltip: 'Alışveriş Listesi',
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => _openGrocerySheet(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Malzemeler', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),

            if (have.isNotEmpty) ...[
              _SectionLabel(text: 'Elinde olanlar'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    have.map((e) {
                      return Chip(
                        label: Text(e),
                        side: BorderSide(color: cs.outlineVariant),
                        backgroundColor: cs.primaryContainer.withOpacity(.25),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            if (missing.isNotEmpty) ...[
              _SectionLabel(text: 'Eksik olanlar'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    missing.map((e) {
                      return Chip(
                        label: Text(e),
                        side: BorderSide(color: cs.outlineVariant),
                        backgroundColor: cs.surface,
                      );
                    }).toList(),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Eksikleri alışveriş listesine ekle'),
                onPressed: () async {
                  await context.read<GroceryBag>().addAllIfMissing(missing);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Eksikler alışveriş listesine eklendi'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
            Text('Yapılışı', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Column(
              children: [
                for (int i = 0; i < recipe.steps.length; i++)
                  _StepTile(index: i + 1, text: recipe.steps[i]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGrocerySheet(BuildContext context) async {
    final bag = context.read<GroceryBag>();
    await bag.ensure();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
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
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(color: cs.onSurface),
    );
  }
}

class _StepTile extends StatelessWidget {
  final int index;
  final String text;
  const _StepTile({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: cs.primary.withOpacity(.2)),
            ),
            child: Text(
              '$index',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: cs.onPrimaryContainer),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
