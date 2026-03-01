import 'package:flutter/material.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final String savedIngredient;

  const RecipeDetailsScreen({
    super.key,
    required this.recipe,
    required this.savedIngredient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      extendBodyBehindAppBar: true, 
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
              ),
              child: Center(
                child: Text(recipe['image']!, style: const TextStyle(fontSize: 100)),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['title']!,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.grey, size: 20),
                      const SizedBox(width: 5),
                      Text(recipe['time']!, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(width: 20),
                      const Icon(Icons.speed, color: Colors.grey, size: 20),
                      const SizedBox(width: 5),
                      Text(recipe['difficulty']!, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.eco, color: Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Gătind asta, salvezi: $savedIngredient',
                            style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text('Ingrediente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    recipe['ingredients']!,
                    style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  const Text('Mod de preparare', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    recipe['instructions']!,
                    style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}