class Recipe {
  final String id;
  final String title;
  final List<String> ingredients;
  final List<String> steps;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      ingredients:
          (map['ingredients'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .toList(),
      steps:
          (map['steps'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .toList(),
    );
  }
}
