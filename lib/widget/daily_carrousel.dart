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

    return SizedBox(
      height: height,
      child: FutureBuilder<List<Recipe>>(
        future: RecipeSource.load(),
        builder: (context, s) {
          if (s.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final all =
              (s.data ?? const <Recipe>[])
                  .where((r) => r.title.trim().isNotEmpty)
                  .toList();
          if (all.isEmpty) return Center(child: Text('recipes'.tr()));
          final now = DateTime.now();
          final seed =
              DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
          final rand = Random(seed);
          final picks = [...all]..shuffle(rand);
          final items = picks.take(5).toList();

          return PageView.builder(
            controller: PageController(viewportFraction: viewportFraction),
            padEnds: false,
            itemCount: items.length,
            physics: const BouncingScrollPhysics(),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailScreen(recipe: r),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
                          if ((r.tags).isNotEmpty)
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
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        t,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelLarge?.copyWith(
                                          color: cs.onSecondaryContainer,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 18),
                              const SizedBox(width: 6),
                              Text(_timeMeta(r)),
                              const Spacer(),
                              const Icon(Icons.arrow_forward, size: 18),
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
        },
      ),
    );
  }

  String _timeMeta(Recipe r) {
    final t = (r.prepMinutes ?? 0) + (r.cookMinutes ?? 0);
    return t > 0 ? tr('total_minutes', args: [t.toString()]) : tr('recipes');
  }
}
