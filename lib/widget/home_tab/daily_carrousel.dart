import 'dart:math';
import 'package:dorm_chef/screen/static/recipe_detail.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dorm_chef/model/recipes.dart';
import 'package:dorm_chef/service/recipes.dart';

class DailyRecipeCarousel extends StatelessWidget {
  const DailyRecipeCarousel({
    super.key,
    this.height = 230,
    this.viewportFraction = .88,
  });
  final double height;
  final double viewportFraction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    List<Recipe> _pickDaily(List<Recipe> all) {
      final cleaned = all
          .where((r) => r.title.trim().isNotEmpty)
          .toList(growable: false);
      if (cleaned.isEmpty) return const [];
      final now = DateTime.now();
      final seed =
          DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      final rand = Random(seed);
      final picks = [...cleaned]..shuffle(rand);
      return picks.take(5).toList(growable: false);
    }

    Widget _buildCarousel(List<Recipe> items) {
      if (items.isEmpty) {
        return Center(child: Text('recipes'.tr()));
      }
      return PageView.builder(
        controller: PageController(viewportFraction: viewportFraction),
        padEnds: false,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final r = items[i];
          return Padding(
            padding: EdgeInsets.only(
              left: i == 0 ? 16 : 8,
              right: i == items.length - 1 ? 16 : 8,
            ),
            child: Material(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(recipe: r),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      if (r.tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children:
                              r.tags.take(4).map((t) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.secondaryContainer,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: cs.outlineVariant.withOpacity(.6),
                                    ),
                                  ),
                                  child: Text(
                                    t,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelSmall?.copyWith(
                                      color: cs.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.restaurant, size: 16),
                          const SizedBox(width: 6),
                          Text('recipe'.tr()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    // ---- HAZIRSA SENKRON, DEĞİLSE FUTURE FALLBACK ----
    final ready = RecipeSource.isReady;
    if (ready) {
      final items = _pickDaily(RecipeSource.cached);
      return SizedBox(height: height, child: _buildCarousel(items));
    }

    // Fallback: çok nadiren ilk açılışta (warm-up gelmeden önce)
    return SizedBox(
      height: height,
      child: FutureBuilder<List<Recipe>>(
        future: RecipeSource.load(),
        builder: (context, s) {
          if (s.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = _pickDaily(s.data ?? const <Recipe>[]);
          return _buildCarousel(items);
        },
      ),
    );
  }
}
