import 'package:dorm_chef/widget/badge.dart';
import 'package:flutter/material.dart';
import '../model/recipes.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final int haveCount;
  final int needCount;
  final double ratio;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.haveCount,
    required this.needCount,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (ratio * 100).round();
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.restaurant_menu, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                PercentBadge(percent: percent),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: SizedBox(
                height: 10,
                child: LinearProgressIndicator(value: ratio),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$haveCount / $needCount malzeme var (%$percent)',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),

            const SizedBox(height: 14),
            Text(
              'Gerekli malzemeler',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children:
                  recipe.ingredients.map((e) {
                    return Chip(
                      label: Text(e),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      shape: const StadiumBorder(),
                      side: BorderSide(color: cs.outlineVariant),
                      backgroundColor: cs.surface,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
