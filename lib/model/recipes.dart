class Recipe {
  final String id;
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final List<String> tags;
  final String? cuisine;
  final int? servings;
  final int? prepMinutes;
  final int? cookMinutes;
  final String? image;
  final String? notes;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    this.tags = const [],
    this.cuisine,
    this.servings,
    this.prepMinutes,
    this.cookMinutes,
    this.image,
    this.notes,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    final rawIngs = map['ingredients'];
    List<String> ingNames;
    if (rawIngs is List) {
      if (rawIngs.isNotEmpty && rawIngs.first is Map) {
        ingNames =
            rawIngs
                .map((e) => (e as Map)['name'])
                .where((n) => n != null && n.toString().trim().isNotEmpty)
                .map((n) => n.toString())
                .toList();
      } else {
        ingNames = rawIngs.map((e) => e.toString()).toList();
      }
    } else {
      ingNames = const <String>[];
    }
    final rawSteps = map['steps'];
    List<String> stepTexts;
    if (rawSteps is List) {
      if (rawSteps.isNotEmpty && rawSteps.first is Map) {
        stepTexts =
            rawSteps
                .map((e) => (e as Map)['text'])
                .where((t) => t != null && t.toString().trim().isNotEmpty)
                .map((t) => t.toString())
                .toList();
      } else {
        stepTexts = rawSteps.map((e) => e.toString()).toList();
      }
    } else {
      stepTexts = const <String>[];
    }
    final tags =
        (map['tags'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];
    int? _toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());

    return Recipe(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      ingredients: ingNames,
      steps: stepTexts,
      tags: tags,
      cuisine: (map['cuisine'] as String?)?.toString(),
      servings: _toInt(map['servings']),
      prepMinutes: _toInt(map['prepMinutes']),
      cookMinutes: _toInt(map['cookMinutes']),
      image: (map['image'] as String?)?.toString(),
      notes: (map['notes'] as String?)?.toString(),
    );
  }
}
