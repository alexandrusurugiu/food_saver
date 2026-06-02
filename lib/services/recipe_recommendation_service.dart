import '../models/product.dart';
import '../models/recipe.dart';
import '../models/recipe_recommendation.dart';

class RecipeRecommendationService {
  final List<Recipe> recipes = [
    Recipe(
      id: 'omelette_vegetables',
      title: 'Omletă cu legume și brânză',
      description: 'O rețetă rapidă pentru lactate și legume care expiră curând.',
      ingredients: ['oua', 'lapte', 'branza', 'rosii', 'ardei'],
      categories: [FoodCategory.lactate, FoodCategory.legume],
      cookingTimeMinutes: 15,
      difficulty: 'Ușor',
    ),
    Recipe(
      id: 'chicken_salad',
      title: 'Salată cu pui',
      description: 'Ideală pentru carne și legume proaspete.',
      ingredients: ['pui', 'salata', 'rosii', 'castraveti', 'iaurt'],
      categories: [FoodCategory.carne, FoodCategory.legume, FoodCategory.lactate],
      cookingTimeMinutes: 20,
      difficulty: 'Ușor',
    ),
    Recipe(
      id: 'fruit_smoothie',
      title: 'Smoothie cu fructe și iaurt',
      description: 'Perfect pentru fructe moi sau aproape de expirare.',
      ingredients: ['banana', 'mere', 'capsuni', 'iaurt', 'lapte'],
      categories: [FoodCategory.fructe, FoodCategory.lactate],
      cookingTimeMinutes: 5,
      difficulty: 'Foarte ușor',
    ),
    Recipe(
      id: 'vegetable_pasta',
      title: 'Paste cu legume',
      description: 'Folosește rapid legumele rămase în frigider.',
      ingredients: ['paste', 'rosii', 'ardei', 'dovlecel', 'ceapa'],
      categories: [FoodCategory.legume, FoodCategory.altele],
      cookingTimeMinutes: 25,
      difficulty: 'Mediu',
    ),
    Recipe(
      id: 'warm_sandwich',
      title: 'Sandwich cald',
      description: 'Bun pentru pâine, cașcaval, șuncă sau alte resturi.',
      ingredients: ['paine', 'cascaval', 'sunca', 'rosii'],
      categories: [FoodCategory.patiserie, FoodCategory.lactate, FoodCategory.carne],
      cookingTimeMinutes: 10,
      difficulty: 'Ușor',
    ),
    Recipe(
      id: 'cream_soup',
      title: 'Supă cremă de legume',
      description: 'Foarte bună pentru legume care trebuie folosite urgent.',
      ingredients: ['morcovi', 'cartofi', 'ceapa', 'dovlecel', 'smantana'],
      categories: [FoodCategory.legume, FoodCategory.lactate],
      cookingTimeMinutes: 35,
      difficulty: 'Mediu',
    ),
  ];

  List<RecipeRecommendation> recommendRecipes(List<Product> products) {
    if (products.isEmpty) {
      return [];
    }

    final validProducts = products
        .where((product) => product.daysUntilExpiry >= 0)
        .toList();

    validProducts.sort(
      (a, b) => a.expiryDate.compareTo(b.expiryDate),
    );

    final recommendations = recipes.map((recipe) {
      return _calculateRecommendation(recipe, validProducts);
    }).where((recommendation) {
      return recommendation.score > 0;
    }).toList();

    recommendations.sort(
      (a, b) => b.score.compareTo(a.score),
    );

    return recommendations;
  }

  RecipeRecommendation _calculateRecommendation(
    Recipe recipe,
    List<Product> products,
  ) {
    double score = 0;
    final usedProducts = <Product>[];
    final urgentProducts = <Product>[];
    final missingIngredients = <String>[];

    for (final ingredient in recipe.ingredients) {
      Product? bestMatch;
      double bestMatchScore = 0;

      for (final product in products) {
        final matchScore = _ingredientMatchScore(
          product.name,
          ingredient,
          product.category,
          recipe.categories,
        );

        if (matchScore > bestMatchScore) {
          bestMatchScore = matchScore;
          bestMatch = product;
        }
      }

      if (bestMatch != null && bestMatchScore > 0) {
        usedProducts.add(bestMatch);

        final expiryScore = _expiryPriorityScore(bestMatch.daysUntilExpiry);
        final quantityScore = _quantityScore(bestMatch);

        score += bestMatchScore;
        score += expiryScore;
        score += quantityScore;

        if (bestMatch.daysUntilExpiry <= 3) {
          urgentProducts.add(bestMatch);
        }
      } else {
        missingIngredients.add(ingredient);
        score -= 8;
      }
    }

    final coverageRatio = usedProducts.length / recipe.ingredients.length;

    score += coverageRatio * 40;

    if (coverageRatio >= 0.8) {
      score += 25;
    } else if (coverageRatio >= 0.5) {
      score += 10;
    } else {
      score -= 20;
    }

    if (urgentProducts.isNotEmpty) {
      score += urgentProducts.length * 30;
    }

    if (recipe.cookingTimeMinutes <= 15) {
      score += 8;
    }

    if (score < 0) {
      score = 0;
    }

    return RecipeRecommendation(
      recipe: recipe,
      score: score,
      usedProducts: usedProducts.toSet().toList(),
      urgentProducts: urgentProducts.toSet().toList(),
      missingIngredients: missingIngredients,
      reason: _buildReason(
        usedProducts: usedProducts.toSet().toList(),
        urgentProducts: urgentProducts.toSet().toList(),
        missingIngredients: missingIngredients,
      ),
    );
  }

  double _ingredientMatchScore(
    String productName,
    String ingredientName,
    FoodCategory productCategory,
    List<FoodCategory> recipeCategories,
  ) {
    final normalizedProduct = _normalize(productName);
    final normalizedIngredient = _normalize(ingredientName);

    if (normalizedProduct == normalizedIngredient) {
      return 50;
    }

    if (normalizedProduct.contains(normalizedIngredient) ||
        normalizedIngredient.contains(normalizedProduct)) {
      return 40;
    }

    if (_areSimilarWords(normalizedProduct, normalizedIngredient)) {
      return 30;
    }

    if (recipeCategories.contains(productCategory)) {
      return 12;
    }

    return 0;
  }

  double _expiryPriorityScore(int daysUntilExpiry) {
    if (daysUntilExpiry < 0) return -100;
    if (daysUntilExpiry == 0) return 70;
    if (daysUntilExpiry == 1) return 60;
    if (daysUntilExpiry == 2) return 50;
    if (daysUntilExpiry == 3) return 40;
    if (daysUntilExpiry <= 5) return 25;
    if (daysUntilExpiry <= 7) return 15;
    return 5;
  }

  double _quantityScore(Product product) {
    final quantity = product.quantity ?? 1.0;

    if (quantity <= 0) return -20;
    if (quantity < 1) return 5;
    if (quantity <= 2) return 10;
    return 15;
  }

  bool _areSimilarWords(String a, String b) {
    if (a.length < 3 || b.length < 3) {
      return false;
    }

    return a.startsWith(b.substring(0, 3)) ||
        b.startsWith(a.substring(0, 3));
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('ă', 'a')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ș', 's')
        .replaceAll('ş', 's')
        .replaceAll('ț', 't')
        .replaceAll('ţ', 't')
        .trim();
  }

  String _buildReason({
    required List<Product> usedProducts,
    required List<Product> urgentProducts,
    required List<String> missingIngredients,
  }) {
    if (usedProducts.isEmpty) {
      return 'Această rețetă nu se potrivește foarte bine cu produsele disponibile.';
    }

    final usedNames = usedProducts.map((product) => product.name).join(', ');

    if (urgentProducts.isNotEmpty) {
      final urgentNames = urgentProducts
          .map((product) => '${product.name} expiră în ${product.daysUntilExpiry} zile')
          .join(', ');

      return 'Recomandată deoarece folosește produse disponibile: $usedNames. Prioritate mare: $urgentNames.';
    }

    if (missingIngredients.isNotEmpty) {
      return 'Recomandată deoarece folosește: $usedNames. Lipsesc: ${missingIngredients.join(', ')}.';
    }

    return 'Recomandată deoarece folosește foarte bine produsele disponibile: $usedNames.';
  }
}