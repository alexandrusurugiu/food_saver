import '../models/product.dart';
import '../models/recipe.dart';
import '../models/recipe_recommendation.dart';

class RecipeRecommendationService {
  final List<Recipe> recipes = [
    Recipe(id: 'omelette_vegetables', title: 'Omletă cu legume și brânză', description: 'O rețetă rapidă.', ingredients: ['oua', 'lapte', 'branza', 'rosii', 'ardei'], categories: [FoodCategory.lactate, FoodCategory.legume], cookingTimeMinutes: 15, difficulty: 'Ușor'),
    Recipe(id: 'chicken_salad', title: 'Salată cu pui', description: 'Ideală pentru carne proaspătă.', ingredients: ['pui', 'salata', 'rosii', 'castraveti', 'iaurt'], categories: [FoodCategory.carne, FoodCategory.legume, FoodCategory.lactate], cookingTimeMinutes: 20, difficulty: 'Ușor'),
    Recipe(id: 'fruit_smoothie', title: 'Smoothie cu fructe', description: 'Perfect pentru fructe moi.', ingredients: ['banana', 'mere', 'capsuni', 'iaurt', 'lapte'], categories: [FoodCategory.fructe, FoodCategory.lactate], cookingTimeMinutes: 5, difficulty: 'Foarte ușor'),
    Recipe(id: 'vegetable_pasta', title: 'Paste cu legume', description: 'Folosește legumele rămase.', ingredients: ['paste', 'rosii', 'ardei', 'dovlecel', 'ceapa'], categories: [FoodCategory.legume, FoodCategory.altele], cookingTimeMinutes: 25, difficulty: 'Mediu'),
    Recipe(id: 'warm_sandwich', title: 'Sandwich cald', description: 'Bun pentru resturi.', ingredients: ['paine', 'cascaval', 'sunca', 'rosii'], categories: [FoodCategory.patiserie, FoodCategory.lactate, FoodCategory.carne], cookingTimeMinutes: 10, difficulty: 'Ușor'),
    Recipe(id: 'cream_soup', title: 'Supă cremă de legume', description: 'Pentru legume urgente.', ingredients: ['morcovi', 'cartofi', 'ceapa', 'dovlecel', 'smantana'], categories: [FoodCategory.legume, FoodCategory.lactate], cookingTimeMinutes: 35, difficulty: 'Mediu'),
  ];

  List<RecipeRecommendation> recommendRecipes(List<Product> products) {
    if (products.isEmpty) return [];

    final validProducts = products.where((p) => p.daysUntilExpiry >= 0).toList();
    validProducts.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    final recommendations = recipes.map((recipe) {
      return _calculateRecommendation(recipe, validProducts);
    }).where((rec) => rec.score > 0).toList();

    recommendations.sort((a, b) => b.score.compareTo(a.score));
    return recommendations;
  }

  RecipeRecommendation _calculateRecommendation(Recipe recipe, List<Product> products) {
    double score = 0;
    final usedProducts = <Product>[];
    final urgentProducts = <Product>[];
    final missingIngredients = <String>[];

    for (final ingredient in recipe.ingredients) {
      Product? bestMatch;
      double bestMatchScore = 0;

      for (final product in products) {
        if (usedProducts.contains(product)) continue;

        final matchScore = _ingredientMatchScore(product.name, ingredient, product.category, recipe.categories);
        if (matchScore > bestMatchScore) {
          bestMatchScore = matchScore;
          bestMatch = product;
        }
      }

      if (bestMatch != null && bestMatchScore > 0) {
        usedProducts.add(bestMatch);
        
        score += 50;
        
        if (bestMatch.daysUntilExpiry <= 3) {
          urgentProducts.add(bestMatch);
          score += 150 + ((3 - bestMatch.daysUntilExpiry) * 30); 
        } else {
          score += 20; 
        }
      } else {
        missingIngredients.add(ingredient);
        score -= 10; 
      }
    }

    final coverageRatio = recipe.ingredients.isEmpty ? 0 : (usedProducts.length / recipe.ingredients.length);
    if (coverageRatio >= 0.8) score += 30;

    return RecipeRecommendation(
      recipe: recipe,
      score: score < 0 ? 0 : score,
      usedProducts: usedProducts,
      urgentProducts: urgentProducts,
      missingIngredients: missingIngredients,
      reason: '', 
    );
  }

  double _ingredientMatchScore(String productName, String ingredientName, FoodCategory productCategory, List<FoodCategory> recipeCategories) {
    final normProduct = _normalize(productName);
    final normIngredient = _normalize(ingredientName);

    if (normProduct == normIngredient) return 50;
    if (normProduct.contains(normIngredient) || normIngredient.contains(normProduct)) return 40;
    if (normProduct.length >= 4 && normIngredient.length >= 4 && 
       (normProduct.substring(0, 4) == normIngredient.substring(0, 4))) return 30;
    
    return 0; 
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll('ă', 'a').replaceAll('â', 'a').replaceAll('î', 'i')
        .replaceAll('ș', 's').replaceAll('ş', 's').replaceAll('ț', 't').replaceAll('ţ', 't').trim();
  }
}