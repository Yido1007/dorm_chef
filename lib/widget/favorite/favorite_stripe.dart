import 'package:dorm_chef/provider/favorite.dart';
import 'package:dorm_chef/screen/static/recipe_detail.dart';
import 'package:dorm_chef/widget/favorite/heart_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dorm_chef/model/recipes.dart';
import 'package:dorm_chef/service/recipes.dart';

class FavoritesStrip extends StatelessWidget {
  const FavoritesStrip({super.key, this.height = 170});
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SizedBox(
            height: height,
            child: Consumer<FavoriteStore>(
              builder: (context, fav, _) {
                final favIds = fav.orderedIds; 
                return FutureBuilder<List<Recipe>>(
                  future:
                      RecipeSource.load(),
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final all = snap.data ?? const <Recipe>[];
                    final byId = {for (final r in all) r.id: r};

                    final items = <Recipe>[];
                    for (final id in favIds) {
                      final r = byId[id];
                      if (r != null) items.add(r);
                    }

                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          'Henüz favorin yok',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      );
                    }

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _FavCard(recipe: items[i]),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _FavCard extends StatelessWidget {
  const _FavCard({required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 240,
      child: Material(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(recipe: recipe),
              ),
            );
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primaryContainer, cs.secondaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              // Başlık
              Positioned(
                left: 12,
                right: 48,
                top: 12,
                child: Text(
                  recipe.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              // Süre + kalp
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _totalMins(recipe),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const Spacer(),
                    FavoriteHeartButton(recipeId: recipe.id),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _totalMins(Recipe r) {
    final t = (r.prepMinutes ?? 0) + (r.cookMinutes ?? 0);
    return t > 0 ? '$t dk' : 'Tarif';
  }
}
