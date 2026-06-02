import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/recipe_recommendation.dart';
import '../services/recipe_recommendation_service.dart';
import 'recipe_details_screen.dart';

class RecipesScreen extends StatelessWidget {
  final List<Product> pantry;

  RecipesScreen({super.key, required this.pantry});

  final RecipeRecommendationService _service = RecipeRecommendationService();

  Map<String, dynamic> _recommendationToMap(RecipeRecommendation recommendation) {
    return {
      'title': recommendation.recipe.title,
      'time': '${recommendation.recipe.cookingTimeMinutes} min',
      'difficulty': recommendation.recipe.difficulty,
      'image': '🍽️',
      'ingredients': recommendation.recipe.ingredients
          .map((ingredient) => '• $ingredient')
          .join('\n'),
      'instructions':
          'Această rețetă este recomandată pe baza produselor din frigider.\n\n'
          '${recommendation.reason}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = _service.recommendRecipes(pantry);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Ce gătim azi?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: recommendations.isEmpty
          ? const Center(
              child: Text(
                'Nu am găsit rețete potrivite momentan.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = recommendations[index];
                final recipe = recommendation.recipe;
                final recipeMap = _recommendationToMap(recommendation);

                final urgentText = recommendation.urgentProducts.isNotEmpty
                    ? recommendation.urgentProducts
                        .map((p) => p.daysUntilExpiry == 0
                            ? '${p.name} expiră azi'
                            : '${p.name} expiră în ${p.daysUntilExpiry} zile')
                        .join(', ')
                    : 'Se potrivește cu produsele din frigider';

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailsScreen(
                          recipe: recipeMap,
                          savedIngredient: recommendation.usedProducts.isNotEmpty
                              ? recommendation.usedProducts.first.name
                              : '',
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(
                              child: Text(
                                '🍽️',
                                style: TextStyle(fontSize: 35),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  urgentText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: recommendation.urgentProducts.isNotEmpty
                                        ? Colors.red.shade600
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.timer_outlined,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${recipe.cookingTimeMinutes} min',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.speed,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      recipe.difficulty,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}