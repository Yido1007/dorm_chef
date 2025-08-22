import 'package:flutter/material.dart';

class RecipeFilter {
  String query;
  String? cuisine; // null => hepsi
  Set<String> tags; // boş => hepsi
  int? maxMinutes; // null => sınırsız

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

/// Filtre alt sayfası: kullanıcı seçim yapar, kaydedince güncel RecipeFilter döner.
Future<RecipeFilter?> showRecipeFilterSheet(
  BuildContext context, {
  required RecipeFilter current,
  required List<String> availableCuisines,
  required List<String> availableTags,
}) async {
  final cs = Theme.of(context).colorScheme;
  final local = current.copy();
  bool limitTime = local.maxMinutes != null;
  double minutes = (local.maxMinutes ?? 45).toDouble();

  return await showModalBottomSheet<RecipeFilter>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                  const SizedBox(height: 12),

                  // Mutfak
                  if (availableCuisines.isNotEmpty) ...[
                    Text('Mutfak', style: Theme.of(ctx).textTheme.labelLarge),
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
                            selected: local.cuisine == _norm(c),
                            onSelected:
                                (_) => setState(() => local.cuisine = _norm(c)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Etiketler
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
                            selected: local.tags.contains(_norm(t)),
                            onSelected: (val) {
                              setState(() {
                                final key = _norm(t);
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

                  // Süre sınırı
                  Row(
                    children: [
                      Switch(
                        value: limitTime,
                        onChanged: (v) {
                          setState(() {
                            limitTime = v;
                            local.maxMinutes = v ? minutes.toInt() : null;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          limitTime
                              ? 'Toplam süre ≤ ${minutes.toInt()} dk'
                              : 'Süre sınırlaması yok',
                          style: Theme.of(ctx).textTheme.bodyMedium,
                        ),
                      ),
                    ],
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
                  ],

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, null),
                          child: const Text('Vazgeç'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pop(ctx, local),
                          icon: const Icon(Icons.check),
                          label: const Text('Uygula'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

String _norm(String v) {
  return v
      .trim()
      .replaceAll('İ', 'i')
      .replaceAll('I', 'ı')
      .replaceAll('Ş', 'ş')
      .replaceAll('Ğ', 'ğ')
      .replaceAll('Ü', 'ü')
      .replaceAll('Ö', 'ö')
      .replaceAll('Ç', 'ç')
      .toLowerCase();
}
