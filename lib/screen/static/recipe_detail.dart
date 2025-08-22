import 'package:flutter/material.dart';
import '../../model/recipes.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Malzemeler
            Text(
              'Gerekli malzemeler',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  recipe.ingredients.map((e) {
                    return Chip(
                      label: Text(e),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      shape: const StadiumBorder(),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 20),
            // Yapılışı
            Text(
              'Yapılışı',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: cs.onSurface),
            ),
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
          // numaralı rozet
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
