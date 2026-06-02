import '../models/product.dart';
import '../models/recipe.dart';

class RecipeRecommendation {
  final Recipe recipe;
  final double score;
  final List<Product> usedProducts;
  final List<Product> urgentProducts;
  final List<String> missingIngredients;
  final String reason;

  RecipeRecommendation({
    required this.recipe,
    required this.score,
    required this.usedProducts,
    required this.urgentProducts,
    required this.missingIngredients,
    required this.reason,
  });
}