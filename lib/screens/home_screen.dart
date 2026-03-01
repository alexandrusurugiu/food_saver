import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import 'products_category_screen.dart';
import 'recipes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<FoodCategory, Map<String, dynamic>> categoryConfig = {
    FoodCategory.lactate: {'nume': 'Lactate', 'icon': '🧀', 'culoare': Colors.blue.shade100},
    FoodCategory.fructe: {'nume': 'Fructe', 'icon': '🍎', 'culoare': Colors.red.shade100},
    FoodCategory.legume: {'nume': 'Legume', 'icon': '🥦', 'culoare': Colors.green.shade100},
    FoodCategory.carne: {'nume': 'Carne', 'icon': '🥩', 'culoare': Colors.pink.shade100},
    FoodCategory.patiserie: {'nume': 'Patiserie', 'icon': '🥐', 'culoare': Colors.orange.shade100},
    FoodCategory.altele: {'nume': 'Altele', 'icon': '🥫', 'culoare': Colors.grey.shade200},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text('Categorii alimente', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent, 
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu, color: Colors.black87),
            tooltip: 'Idei de rețete',
            onPressed: () {
              final bazaDeDate = Hive.box<Product>('pantryBox').values.toList();
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipesScreen(pantry: bazaDeDate), 
                ),
              );
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E9), 
              Colors.white,     
              Colors.white,      
            ],
          ),
        ),
        child: SafeArea(
          child: ValueListenableBuilder<Box<Product>>(
            valueListenable: Hive.box<Product>('pantryBox').listenable(),
            builder: (context, box, _) {
              final myPantry = box.values.toList();

              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: FoodCategory.values.length,
                itemBuilder: (context, index) {
                  final category = FoodCategory.values[index];
                  final config = categoryConfig[category]!;
                  
                  final productsInCategory = myPantry.where((p) => p.category == category).toList();

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryProductsScreen(
                            categoryName: config['nume'],
                            products: productsInCategory,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Card(
                      color: config['culoare'],
                      elevation: 2, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(config['icon'], style: const TextStyle(fontSize: 45)),
                          const SizedBox(height: 10),
                          Text(
                            config['nume'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${productsInCategory.length} produse',
                            style: TextStyle(color: Colors.black.withOpacity(0.6), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print('Deschide camera!');
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scanează'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}