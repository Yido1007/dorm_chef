import 'package:dorm_chef/widget/favorite/heart_button.dart';
import 'package:dorm_chef/widget/recipe/badge.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../model/recipes.dart';
import '../../screen/static/recipe_detail.dart';

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

  String _fmtNum(BuildContext context, num v) =>
      NumberFormat.decimalPattern(context.locale.toString()).format(v);

  @override
  Widget build(BuildContext context) {
    final percent = (ratio * 100).round();
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(16);
    final metaParts = <String>[];
    if (recipe.prepMinutes != null && recipe.prepMinutes! > 0) {
      metaParts.add(
        'prep_n_min'.tr(
          namedArgs: {
            'n': _fmtNum(context, recipe.prepMinutes!),
            'min': 'unit_min'.tr(),
          },
        ),
      );
    }
    if (recipe.cookMinutes != null && recipe.cookMinutes! > 0) {
      metaParts.add(
        'cook_n_min'.tr(
          namedArgs: {
            'n': _fmtNum(context, recipe.cookMinutes!),
            'min': 'unit_min'.tr(),
          },
        ),
      );
    }
    if (recipe.servings != null && recipe.servings! > 0) {
      metaParts.add(
        'servings_n'.tr(namedArgs: {'n': _fmtNum(context, recipe.servings!)}),
      );
    }
    final metaText = metaParts.join(' · ');

    final tagList = (recipe.tags).take(4).toList();

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
                  const SizedBox(width: 4),
                  PercentBadge(percent: percent),
                  const SizedBox(width: 4),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: FavoriteHeartButton(recipeId: recipe.id),
                  ),
                ],
              ),
              if (metaText.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        metaText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (tagList.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      tagList.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            t,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: cs.onSecondaryContainer),
                          ),
                        );
                      }).toList(),
                ),
              ],
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
                'ingredients_have_need_p'.tr(
                  namedArgs: {
                    'have': _fmtNum(context, haveCount),
                    'need': _fmtNum(context, needCount),
                    'p': _fmtNum(context, percent),
                  },
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),

              const SizedBox(height: 14),
              Text(
                'required_ingredients'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: 8),
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
