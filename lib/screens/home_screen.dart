import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product.dart';
import 'products_category_screen.dart';
import 'recipes_screen.dart';
import 'scanner_screen.dart';
import 'add_product_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<FoodCategory, Map<String, dynamic>> categoryConfig = {
    FoodCategory.lactate: {
      'nume': 'Lactate',
      'icon': '🧀',
      'culoare': Colors.blue.shade100,
    },
    FoodCategory.fructe: {
      'nume': 'Fructe',
      'icon': '🍎',
      'culoare': Colors.red.shade100,
    },
    FoodCategory.legume: {
      'nume': 'Legume',
      'icon': '🥦',
      'culoare': Colors.green.shade100,
    },
    FoodCategory.carne: {
      'nume': 'Carne',
      'icon': '🥩',
      'culoare': Colors.pink.shade100,
    },
    FoodCategory.patiserie: {
      'nume': 'Patiserie',
      'icon': '🥐',
      'culoare': Colors.orange.shade100,
    },
    FoodCategory.altele: {
      'nume': 'Altele',
      'icon': '🥫',
      'culoare': Colors.grey.shade200,
    },
  };

  Future<Map<String, dynamic>?> fetchProductFromAPI(String barcode) async {
    final url = Uri.parse(
      'https://world.openfoodfacts.org/api/v2/product/$barcode.json',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final p = data['product'];

          String name =
              p['product_name_ro'] ??
              p['product_name'] ??
              p['product_name_en'] ??
              "Produs Necunoscut";

          String categoriesTags = (p['categories_tags'] ?? [])
              .toString()
              .toLowerCase();
          FoodCategory category = FoodCategory.altele;

          if (categoriesTags.contains('dairy') ||
              categoriesTags.contains('cheeses') ||
              categoriesTags.contains('milk')) {
            category = FoodCategory.lactate;
          } else if (categoriesTags.contains('fruits')) {
            category = FoodCategory.fructe;
          } else if (categoriesTags.contains('vegetables')) {
            category = FoodCategory.legume;
          } else if (categoriesTags.contains('meats') ||
              categoriesTags.contains('fish')) {
            category = FoodCategory.carne;
          } else if (categoriesTags.contains('bakery') ||
              categoriesTags.contains('biscuits') ||
              categoriesTags.contains('pastries')) {
            category = FoodCategory.patiserie;
          }

          return {'name': name, 'category': category};
        }
      }
    } catch (e) {
      print('Eroare la apelul API: $e');
    }
    return null; 
  }

  
  Future<void> scanAndAddProduct(String barcode) async {
    final cacheBox = await Hive.openBox<String>('cachedBarcodes');

    String? cachedName = cacheBox.get(barcode);

    String productName = "Produs Necunoscut";
    FoodCategory productCategory = FoodCategory.altele;

    if (cachedName != null && cachedName.isNotEmpty) {
      productName = cachedName;
      print("[HIVE CACHE] S-a găsit produsul salvat local: $productName");
    } else {
      print("[API FETCH] Codul nu e în cache, apelăm API-ul global...");
      final apiResult = await fetchProductFromAPI(barcode);
      if (apiResult != null) {
        productName = apiResult['name'];
        productCategory = apiResult['category'];
      }
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddProductFormScreen(
            barcode: barcode,
            initialName: productName,
            initialCategory: productCategory,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Categorii alimente',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E9), Colors.white, Colors.white],
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

                  final productsInCategory = myPantry
                      .where((p) => p.category == category)
                      .toList();

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryProductsScreen(
                            categoryName: config['nume'],
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Card(
                      color: config['culoare'],
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            config['icon'],
                            style: const TextStyle(fontSize: 45),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            config['nume'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${productsInCategory.length} produse',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScannerScreen(
                onBarcodeScanned: (barcode) async {
                  await scanAndAddProduct(barcode);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Cod detectat: $barcode. Verifică categoria!',
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scanează'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
