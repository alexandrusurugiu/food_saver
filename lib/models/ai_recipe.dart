class AiRecipe {
  final String title;
  final String description;
  final int cookingTime;
  final String difficulty;
  final List<String> usedIngredients;
  final List<String> missingIngredients;
  final List<String> instructions;

  AiRecipe({
    required this.title,
    required this.description,
    required this.cookingTime,
    required this.difficulty,
    required this.usedIngredients,
    required this.missingIngredients,
    required this.instructions,
  });

  factory AiRecipe.fromJson(Map<String, dynamic> json) {
    return AiRecipe(
      title: json['title'] ?? 'Rețetă fără titlu',
      description: json['description'] ?? '',
      cookingTime: json['cooking_time'] ?? 0,
      difficulty: json['difficulty'] ?? 'Nedefinit',
      usedIngredients: List<String>.from(json['used_ingredients'] ?? []),
      missingIngredients: List<String>.from(json['missing_ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }
}