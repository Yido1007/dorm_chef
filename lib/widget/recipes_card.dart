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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipe.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '$haveCount / $needCount malzeme var (%$percent)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: ratio),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: -8,
              children:
                  recipe.ingredients.map((e) => Chip(label: Text(e))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
