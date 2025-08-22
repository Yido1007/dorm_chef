import 'package:flutter/material.dart';

import '../service/norm.dart';

class RecipeFilter {
  String query;
  String? cuisine;
  Set<String> tags;
  int? maxMinutes;

  RecipeFilter({
    this.query = '',
    this.cuisine,
    Set<String>? tags,
    this.maxMinutes,
  }) : tags = tags ?? {};

  bool get isEmpty =>
      (query.trim().isEmpty) &&
      cuisine == null &&
      tags.isEmpty &&
      maxMinutes == null;

  RecipeFilter copy() => RecipeFilter(
    query: query,
    cuisine: cuisine,
    tags: {...tags},
    maxMinutes: maxMinutes,
  );
}

Future<RecipeFilter?> showRecipeFilterSheet(
  BuildContext context, {
  required RecipeFilter current,
  required List<String> availableCuisines,
  required List<String> availableTags,
}) async {
  final local = current.copy();
  bool limitTime = local.maxMinutes != null;
  double minutes = (local.maxMinutes ?? 45).toDouble();

  return await showModalBottomSheet<RecipeFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetCtx) {
      final cs = Theme.of(sheetCtx).colorScheme;

      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) {
          return StatefulBuilder(
            builder: (ctx, setState) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list),
                        const SizedBox(width: 8),
                        Text(
                          'Filtreler',
                          style: Theme.of(ctx).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            local.query = '';
                            local.cuisine = null;
                            local.tags.clear();
                            limitTime = false;
                            minutes = 45;
                            local.maxMinutes = null;
                            setState(() {});
                          },
                          icon: const Icon(Icons.restore),
                          label: const Text('Sıfırla'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        if (availableCuisines.isNotEmpty) ...[
                          Text(
                            'Mutfak',
                            style: Theme.of(ctx).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('Hepsi'),
                                selected: local.cuisine == null,
                                onSelected:
                                    (_) => setState(() => local.cuisine = null),
                              ),
                              for (final c in availableCuisines)
                                ChoiceChip(
                                  label: Text(c),
                                  selected: local.cuisine == norm(c),
                                  onSelected:
                                      (_) => setState(
                                        () => local.cuisine = norm(c),
                                      ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (availableTags.isNotEmpty) ...[
                          Text(
                            'Etiketler',
                            style: Theme.of(ctx).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final t in availableTags)
                                FilterChip(
                                  label: Text(t),
                                  selected: local.tags.contains(norm(t)),
                                  onSelected: (val) {
                                    setState(() {
                                      final key = norm(t);
                                      if (val) {
                                        local.tags.add(key);
                                      } else {
                                        local.tags.remove(key);
                                      }
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: limitTime,
                          onChanged: (v) {
                            setState(() {
                              limitTime = v;
                              local.maxMinutes = v ? minutes.toInt() : null;
                            });
                          },
                          title: Text(
                            limitTime
                                ? 'Toplam süre ≤ ${minutes.toInt()} dk'
                                : 'Süre sınırlaması yok',
                          ),
                          subtitle: const Text('Hazırlık + pişirme süresi'),
                        ),
                        if (limitTime) ...[
                          Slider(
                            min: 5,
                            max: 180,
                            divisions: 35,
                            value: minutes,
                            label: '${minutes.toInt()} dk',
                            onChanged: (v) {
                              setState(() {
                                minutes = v;
                                local.maxMinutes = minutes.toInt();
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      10,
                      16,
                      10 + MediaQuery.of(ctx).viewInsets.bottom,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      border: Border(top: BorderSide(color: cs.outlineVariant)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetCtx, null),
                            child: const Text('Vazgeç'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => Navigator.pop(sheetCtx, local),
                            icon: const Icon(Icons.check),
                            label: const Text('Uygula'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}
