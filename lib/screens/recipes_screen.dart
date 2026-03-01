import 'package:flutter/material.dart';
import '../models/product.dart';
import 'recipe_details_screen.dart';

class RecipesScreen extends StatelessWidget {
  final List<Product> pantry;

  const RecipesScreen({super.key, required this.pantry});

  List<Map<String, dynamic>> _getRecipesForProduct(Product product) {
    if (product.name.toLowerCase().contains('iaurt')) {
      return [
        {
          'title': 'Sos Tzatziki Răcoros',
          'time': '10 min',
          'difficulty': 'Foarte ușor',
          'image': '🥒',
          'ingredients': '• Iaurt Grecesc\n• 1 Castravete mic\n• 2 Căței de usturoi\n• 1 lingură ulei de măsline\n• Mărar proaspăt\n• Sare și piper',
          'instructions': '1. Dă castravetele prin răzătoare și stoarce-l bine de zeamă în pumn.\n2. Pune iaurtul într-un bol și adaugă castravetele stors.\n3. Pisează usturoiul și adaugă-l în bol, împreună cu uleiul de măsline și mărarul tocat fin.\n4. Condimentează cu sare și piper după gust. Lasă la rece 10 minute înainte de servire.',
        },
        {
          'title': 'Parfait cu iaurt și ovăz',
          'time': '5 min',
          'difficulty': 'Ușor',
          'image': '🍨',
          'ingredients': '• Iaurt Grecesc\n• 3 linguri fulgi de ovăz\n• 1 linguriță de miere\n• Fructe proaspete sau nuci',
          'instructions': '1. Într-un pahar sau bol larg, pune un strat generos de iaurt la bază.\n2. Adaugă un strat de fulgi de ovăz și presară puțină miere.\n3. Adaugă un strat din fructele tale preferate.\n4. Repetă straturile până se umple paharul și servește imediat ca un mic dejun sau desert rapid.',
        }
      ];
    } else if (product.name.toLowerCase().contains('lapte')) {
      return [
        {
          'title': 'Clătite rapide de weekend',
          'time': '20 min',
          'difficulty': 'Mediu',
          'image': '🥞',
          'ingredients': '• 250ml Lapte\n• 150g Făină\n• 2 Ouă\n• Un praf de sare\n• Unt pentru prăjit',
          'instructions': '1. Bate ouăle spumă cu sarea.\n2. Adaugă laptele și amestecă bine.\n3. Încorporează făina treptat pentru a evita cocoloașele.\n4. Gătește pe rând în tigaia încinsă, unsă cu puțin unt, până se rumenesc pe ambele părți.',
        },
        {
          'title': 'Smoothie antioxidant',
          'time': '5 min',
          'difficulty': 'Ușor',
          'image': '🥤',
          'ingredients': '• 200ml Lapte\n• 1 Banană\n• 1 mână de fructe de pădure congelate',
          'instructions': '1. Curăță banana și taie-o felii.\n2. Pune toate ingredientele în blender.\n3. Mixează la viteză mare timp de 1 minut până obții o textură fină.',
        }
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final expiringProducts = pantry.where((p) => p.daysUntilExpiry >= 0 && p.daysUntilExpiry <= 5).toList();
    expiringProducts.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Ce gătim azi?', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: expiringProducts.isEmpty
          ? const Center(child: Text('Frigiderul tău e în siguranță! 🎉', style: TextStyle(fontSize: 18)))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: expiringProducts.length,
              itemBuilder: (context, index) {
                final product = expiringProducts[index];
                final recipes = _getRecipesForProduct(product);

                if (recipes.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Idei pentru a salva: ${product.name}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.daysUntilExpiry == 0 ? 'Produsul expiră AZI!' : 'Mai ai la dispoziție ${product.daysUntilExpiry} zile.',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.red.shade600),
                          ),
                        ],
                      ),
                    ),
                    
                    ...recipes.map((recipe) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailsScreen(
                                recipe: recipe,
                                savedIngredient: product.name, 
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 12.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                                  child: Center(child: Text(recipe['image']!, style: const TextStyle(fontSize: 35))),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recipe['title']!,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(recipe['time']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.speed, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(recipe['difficulty']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
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
                    }),
                    
                    const SizedBox(height: 25),
                  ],
                );
              },
            ),
    );
  }
}