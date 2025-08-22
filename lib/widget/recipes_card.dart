import 'package:flutter/material.dart';
import '../model/recipes.dart';
import '../screen/static/recipe_detail.dart';

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
    final radius = BorderRadius.circular(16);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: radius),
      color: cs.surfaceContainerHigh,
      child: InkWell(
        borderRadius: radius,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık + yüzde rozeti
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
                  _PercentBadge(percent: percent),
                ],
              ),
              const SizedBox(height: 10),

              // İlerleme barı (kalın ve yuvarlatılmış)
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

              // CHIP’LER — ferah boşluklar
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
                        side: BorderSide(color: cs.outlineVariant),
                        backgroundColor: cs.surface,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PercentBadge extends StatelessWidget {
  final int percent;
  const _PercentBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.withOpacity(.25)),
      ),
      child: Text(
        '%$percent',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: cs.onPrimaryContainer),
      ),
    );
  }
}
