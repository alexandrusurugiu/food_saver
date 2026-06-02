import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/ai_recipe.dart';
import '../services/ai_recipe_service.dart';
import 'recipe_details_screen.dart';

class RecipesScreen extends StatefulWidget {
  final List<Product> pantry;
  const RecipesScreen({super.key, required this.pantry});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final AiRecipeService _aiService = AiRecipeService();
  bool _isLoading = true;
  List<AiRecipe> _recipes = [];
  List<Product> _urgentItems = [];

  @override
  void initState() {
    super.initState();
    _urgentItems = widget.pantry.where((p) => p.daysUntilExpiry >= 0 && p.daysUntilExpiry <= 3).toList();
    _urgentItems.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
    _fetchAiRecipes();
  }

  Future<void> _fetchAiRecipes() async {
    final generated = await _aiService.generateRecipes(widget.pantry);
    if (mounted) {
      setState(() {
        _recipes = generated;
        _isLoading = false;
      });
    }
  }

  String _getRecipeIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('supă') || t.contains('ciorbă') || t.contains('cremă')) return '🥣';
    if (t.contains('salată')) return '🥗';
    if (t.contains('paste') || t.contains('spaghete') || t.contains('macaroane')) return '🍝';
    if (t.contains('pui') || t.contains('curcan')) return '🍗';
    if (t.contains('porc') || t.contains('vită') || t.contains('carne') || t.contains('friptură')) return '🥩';
    if (t.contains('pește') || t.contains('somon')) return '🐟';
    if (t.contains('omletă') || t.contains('ouă') || t.contains('ou')) return '🍳';
    if (t.contains('sandwich') || t.contains('sandviș') || t.contains('burger')) return '🍔';
    if (t.contains('pizza')) return '🍕';
    if (t.contains('prăjitură') || t.contains('tort') || t.contains('clătite') || t.contains('desert')) return '🍰';
    if (t.contains('smoothie') || t.contains('băutură') || t.contains('suc') || t.contains('shake')) return '🥤';
    if (t.contains('orez') || t.contains('pilaf') || t.contains('risotto')) return '🍚';
    if (t.contains('cartofi')) return '🍟';
    if (t.contains('brânză') || t.contains('cașcaval')) return '🧀';
    
    return '🍲';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        title: const Text('Rețete', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.green),
                  const SizedBox(height: 20),
                  Text('Generăm rețete unice pentru tine...', 
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text('Analizăm alimentele urgente 🍳', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                ],
              ),
            )
          : _recipes.isEmpty
              ? Center(child: Text('Nu am putut genera rețete. Verifică conexiunea.', style: TextStyle(color: Colors.grey.shade700)))
              : CustomScrollView(
                  slivers: [
                    if (_urgentItems.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.shade200)),
                            child: Row(
                              children: [
                                const Text('🚨', style: TextStyle(fontSize: 24)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text('AI-ul s-a concentrat pe salvarea acestor produse: ${_urgentItems.map((e) => e.name).join(", ")}.',
                                    style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final recipe = _recipes[index];
                            final recipeIcon = _getRecipeIcon(recipe.title);

                            return InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeDetailsScreen(recipe: recipe)));
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 65, height: 65,
                                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(16)),
                                        child: Center(child: Text(recipeIcon, style: const TextStyle(fontSize: 30))),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(recipe.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                            const SizedBox(height: 6),
                                            Text('${recipe.usedIngredients.length} ingrediente din frigider', style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text('${recipe.cookingTime} min', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                                                const SizedBox(width: 12),
                                                const Icon(Icons.speed, size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(recipe.difficulty, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
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
                          childCount: _recipes.length,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}