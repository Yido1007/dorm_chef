import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/recipes.dart';
import '../../model/scored.dart';
import '../../provider/ingredient.dart';
import '../../service/norm.dart';
import '../../service/recipes.dart';
import '../../widget/recipe/recipe_filter.dart';
import '../../widget/recipe/recipes_card.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  late Future<void> _warmFuture;
  late Future<List<Recipe>> _recipesFuture;
  RecipeFilter _filter = RecipeFilter();

  @override
  void initState() {
    super.initState();
    _warmFuture = context.read<PantryStore>().warmUp();
    _recipesFuture = RecipeSource.load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _warmFuture,
      builder: (context, warmSnap) {
        if (warmSnap.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text('recipe').tr()),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Consumer<PantryStore>(
          builder: (context, store, _) {
            final inv =
                store.list
                    .where((e) => e.amount > 0)
                    .map((e) => norm(e.label))
                    .toList();
            return FutureBuilder<List<Recipe>>(
              future: _recipesFuture,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return Scaffold(
                    appBar: AppBar(title: Text('recipes').tr()),
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                final all = snap.data ?? const <Recipe>[];
                final cuisines =
                    all
                        .map((r) => r.cuisine)
                        .whereType<String>()
                        .map(_titleCase)
                        .toSet()
                        .toList()
                      ..sort();
                final tags =
                    all.expand((r) => r.tags).map(_titleCase).toSet().toList()
                      ..sort();
                return Scaffold(
                  appBar: AppBar(
                    title: Text('recipe').tr(),
                    actions: [
                      if (!_filter.isEmpty)
                        IconButton(
                          tooltip: '',
                          onPressed:
                              () => setState(() => _filter = RecipeFilter()),
                          icon: const Icon(Icons.filter_alt_off),
                        ),
                      IconButton(
                        tooltip: 'clear_filter'.tr(),
                        onPressed: () async {
                          final updated = await showRecipeFilterSheet(
                            context,
                            current: _filter,
                            availableCuisines: cuisines,
                            availableTags: tags,
                          );
                          if (updated != null) {
                            setState(() => _filter = updated);
                          }
                        },
                        icon: const Icon(Icons.filter_alt),
                      ),
                    ],
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(56),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: TextField(
                          controller: _searchCtrl,
                          focusNode: _searchFocus, // <- odak korunur
                          textInputAction: TextInputAction.search,
                          onChanged: (v) => setState(() => _filter.query = v),
                          decoration: InputDecoration(
                            hintText: 'recipe_search'.tr(),
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  body: Builder(
                    builder: (context) {
                      final afterFilter = _applyFilter(all, _filter);
                      final onlyMatch =
                          afterFilter.where((r) {
                            final rIngs = r.ingredients.map(norm).toList();
                            return inv.any(
                              (p) => rIngs.any(
                                (ri) => ri.contains(p) || p.contains(ri),
                              ),
                            );
                          }).toList();
                      final scored =
                          onlyMatch.map((r) {
                              final rIngs = r.ingredients.map(norm).toList();
                              final total = rIngs.isEmpty ? 1 : rIngs.length;
                              final have =
                                  rIngs
                                      .where(
                                        (ri) => inv.any(
                                          (p) =>
                                              ri.contains(p) || p.contains(ri),
                                        ),
                                      )
                                      .length;
                              final ratio = have / total;
                              return Scored(
                                r: r,
                                have: have,
                                total: total,
                                ratio: ratio,
                              );
                            }).toList()
                            ..sort((a, b) => b.ratio.compareTo(a.ratio));
                      if (scored.isEmpty) return const SizedBox.shrink();
                      return ListView.builder(
                        itemCount: scored.length,
                        itemBuilder: (_, i) {
                          final s = scored[i];
                          return RecipeCard(
                            recipe: s.r,
                            haveCount: s.have,
                            needCount: s.total,
                            ratio: s.ratio,
                          );
                        },
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

  List<Recipe> _applyFilter(List<Recipe> input, RecipeFilter f) {
    if (input.isEmpty) return input;

    final q = norm(f.query);
    final cu = f.cuisine?.trim();
    final tagSet = f.tags.map((e) => e.trim()).toSet();
    final limit = f.maxMinutes;
    bool matches(Recipe r) {
      if (q.isNotEmpty) {
        final titleHit = norm(r.title).contains(q);
        final ingHit = r.ingredients.map(norm).any((ri) => ri.contains(q));
        final tagHit = r.tags.map(norm).any((t) => t.contains(q));
        final cuiHit = r.cuisine != null && norm(r.cuisine!).contains(q);
        if (!(titleHit || ingHit || tagHit || cuiHit)) return false;
      }
      if (cu != null) {
        final rc = r.cuisine == null ? null : norm(r.cuisine!);
        if (rc != cu) return false;
      }
      if (tagSet.isNotEmpty) {
        final rtags = r.tags.map(norm).toSet();
        if (rtags.intersection(tagSet).isEmpty) return false;
      }
      if (limit != null) {
        final total = (r.prepMinutes ?? 0) + (r.cookMinutes ?? 0);
        if (total > 0 && total > limit) return false;
      }
      return true;
    }

    return input.where(matches).toList();
  }

  String _titleCase(String? s) {
    if (s == null || s.isEmpty) return '';
    final n = norm(s);
    if (n.isEmpty) return '';
    return n[0].toUpperCase() + n.substring(1);
  }
}
