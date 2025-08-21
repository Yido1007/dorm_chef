import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/recipes.dart';
import '../../model/scored.dart';
import '../../provider/ingredient.dart';
import '../../service/norm.dart';
import '../../service/recipes.dart';
import '../../widget/recipes_card.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pantryReady = context.read<PantryStore>().warmUp();
    final recipesFuture = RecipeSource.load();

    return FutureBuilder<List<Recipe>>(
      future: recipesFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text('Tarifler')),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final recipes = snap.data ?? const <Recipe>[];

        return FutureBuilder<void>(
          future: pantryReady,
          builder: (context, pantrySnap) {
            if (pantrySnap.connectionState != ConnectionState.done) {
              return Scaffold(
                appBar: AppBar(title: Text('Tarifler')),
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return Consumer<PantryStore>(
              builder: (context, pantry, _) {
                final scored =
                    recipes.map((r) {
                        final total = r.ingredients.length;
                        final have =
                            r.ingredients.where((ing) {
                              final want = norm(ing);
                              return pantry.list.any(
                                (p) => norm(p.label) == want && p.amount > 0,
                              );
                            }).length;
                        final ratio = total == 0 ? 0.0 : have / total;
                        return Scored(
                          recipe: r,
                          have: have,
                          total: total,
                          ratio: ratio,
                        );
                      }).toList()
                      ..removeWhere((s) => s.have == 0)
                      ..sort((a, b) => b.ratio.compareTo(a.ratio));

                return Scaffold(
                  appBar: AppBar(title: const Text('Tarifler')),
                  body:
                      scored.isEmpty
                          ? const SizedBox.shrink()
                          : ListView.builder(
                            itemCount: scored.length,
                            itemBuilder: (_, i) {
                              final s = scored[i];
                              return RecipeCard(
                                recipe: s.recipe,
                                haveCount: s.have,
                                needCount: s.total,
                                ratio: s.ratio,
                              );
                            },
                          ),
                );
              },
            );
          },
        );
      },
    );
  }
}
