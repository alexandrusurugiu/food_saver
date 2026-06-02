import 'product.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<FoodCategory> categories;
  final int cookingTimeMinutes;
  final String difficulty;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.categories,
    required this.cookingTimeMinutes,
    required this.difficulty,
  });
}