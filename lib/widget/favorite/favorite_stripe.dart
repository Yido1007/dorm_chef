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
                  future: RecipeSource.load(),
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
    final radius = BorderRadius.circular(14);

    // Güvenli tag listesi (null/karışık tiplere karşı korumalı)
    final List<String> tags =
        (recipe.tags as List?)
            ?.whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        const <String>[];

    return SizedBox(
      width: 240,
      child: Material(
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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: radius, 
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Text(
                  recipe.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 8),

                // TAG ŞERİDİ (ilk 6 tag, max ~2 satır görünür)
                if (tags.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 56,
                    ), // taşmayı önler (yaklaşık iki satır)
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.take(6).map((t) => _TagPill(t)).toList(),
                    ),
                  ),

                const Spacer(),

                // Alt satır: süre + (opsiyonel) kalp
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _totalMins(recipe),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    // Favoriler kapalıysa bu satırı kaldırabilirsin:
                    FavoriteHeartButton(recipeId: recipe.id ?? ''),
                  ],
                ),
              ],
            ),
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

// Küçük "pill" etiketi
class _TagPill extends StatelessWidget {
  const _TagPill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
