import 'package:dorm_chef/provider/favorite.dart';
import 'package:dorm_chef/screen/static/recipe_detail.dart';
import 'package:dorm_chef/widget/favorite/heart_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dorm_chef/model/recipes.dart';
import 'package:dorm_chef/service/recipes.dart';

class FavoritesStrip extends StatelessWidget {
  const FavoritesStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<FavoriteStore>(
          builder: (context, fav, _) {
            final favIds = fav.orderedIds;
            return FutureBuilder<List<Recipe>>(
              future: RecipeSource.load(),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final all = snap.data ?? const <Recipe>[];
                final byId = {for (final r in all) r.id: r};
                final items = <Recipe>[];
                for (final id in favIds) {
                  final r = byId[id];
                  if (r != null) items.add(r);
                }

                if (items.isEmpty) {
                  return const _EmptyFavoritesWidget();
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _FavCardSmall(recipe: items[i]),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _EmptyFavoritesWidget extends StatelessWidget {
  const _EmptyFavoritesWidget();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'asset/icon/recipe.png',
                width: 140,
                fit: BoxFit.contain,
                semanticLabel: 'Boş favoriler',
                errorBuilder:
                    (_, __, ___) => Icon(
                      Icons.image_not_supported_outlined,
                      color: cs.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Henüz favorin yok',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavCardSmall extends StatelessWidget {
  const _FavCardSmall({required this.recipe});
  final Recipe recipe;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(12);
    final List<String> tags =
        (recipe.tags as List?)
            ?.whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        const <String>[];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: radius,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: const Icon(Icons.restaurant_rounded, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 68,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children:
                              tags
                                  .take(3)
                                  .map((t) => _TagPillSmall(t))
                                  .toList(),
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _totalMins(recipe),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FavoriteHeartButton(recipeId: recipe.id),
            ],
          ),
        ),
      ),
    );
  }

  String _totalMins(Recipe r) {
    final t = (r.prepMinutes ?? 0) + (r.cookMinutes ?? 0);
    return t > 0
        ? 'total_minutes'.tr(args: [t.toString()])
        : 'recipe_label'.tr();
  }
}

class _TagPillSmall extends StatelessWidget {
  const _TagPillSmall(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(.6)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
