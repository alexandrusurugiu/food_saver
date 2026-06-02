import 'package:flutter/material.dart';
import '../models/ai_recipe.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final AiRecipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        title: const Text('Detalii rețetă AI', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  const Text('🍽️', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  Text(recipe.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Text(recipe.description, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _InfoCard(icon: Icons.timer_outlined, title: 'Timp', value: '${recipe.cookingTime} min')),
                const SizedBox(width: 12),
                Expanded(child: _InfoCard(icon: Icons.speed, title: 'Dificultate', value: recipe.difficulty)),
              ],
            ),
            const SizedBox(height: 24),
            
            if (recipe.usedIngredients.isNotEmpty) ...[
              const Text('Din frigiderul tău', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: recipe.usedIngredients.map((ing) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                      const SizedBox(width: 6),
                      Text(ing, style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
            ],

            if (recipe.missingIngredients.isNotEmpty) ...[
              const Text('Îți lipsește', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: recipe.missingIngredients.map((ing) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 6),
                      Text(ing, style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
            ],

            const Text('Mod de preparare', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // MAPĂM LISTA DE INSTRUCȚIUNI AI AICI
                children: recipe.instructions.asMap().entries.map((entry) {
                  int stepNumber = entry.key + 1;
                  String instruction = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(radius: 12, backgroundColor: Colors.green.shade100, child: Text('$stepNumber', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade800))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(instruction, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87))),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Icon(icon, color: Colors.green.shade600),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}