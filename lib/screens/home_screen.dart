import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';
import 'add_product_form_screen.dart';
import 'products_category_screen.dart';
import 'recipes_screen.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<FoodCategory, Map<String, dynamic>> categoryConfig = {
    FoodCategory.lactate: {
      'name': 'Lactate',
      'icon': '🧀',
      'color': Color(0xFFE3F2FD),
    },
    FoodCategory.fructe: {
      'name': 'Fructe',
      'icon': '🍎',
      'color': Color(0xFFFFEBEE),
    },
    FoodCategory.legume: {
      'name': 'Legume',
      'icon': '🥦',
      'color': Color(0xFFE8F5E9),
    },
    FoodCategory.carne: {
      'name': 'Carne',
      'icon': '🥩',
      'color': Color(0xFFFCE4EC),
    },
    FoodCategory.patiserie: {
      'name': 'Patiserie',
      'icon': '🥐',
      'color': Color(0xFFFFF3E0),
    },
    FoodCategory.altele: {
      'name': 'Altele',
      'icon': '🥫',
      'color': Color(0xFFF1F3F4),
    },
  };

  Future<Map<String, dynamic>?> fetchProductFromAPI(String barcode) async {
    final url = Uri.parse(
      'https://world.openfoodfacts.org/api/v2/product/$barcode.json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);

      if (data['status'] != 1 || data['product'] == null) return null;

      final product = data['product'];

      final name =
          product['product_name_ro'] ??
          product['product_name'] ??
          product['product_name_en'] ??
          'Produs necunoscut';

      final categoriesTags =
          (product['categories_tags'] ?? []).toString().toLowerCase();

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

      return {
        'name': name,
        'category': category,
      };
    } catch (_) {
      return null;
    }
  }

  Future<void> scanAndAddProduct(String barcode) async {
    final cacheBox = await Hive.openBox<String>('cachedBarcodes');

    final cachedName = cacheBox.get(barcode);

    String productName = 'Produs necunoscut';
    FoodCategory productCategory = FoodCategory.altele;

    if (cachedName != null && cachedName.isNotEmpty) {
      productName = cachedName;
    } else {
      final apiResult = await fetchProductFromAPI(barcode);

      if (apiResult != null) {
        productName = apiResult['name'];
        productCategory = apiResult['category'];
      }
    }

    if (!mounted) return;

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

  void _openManualAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductFormScreen(
          barcode: 'manual',
          initialName: '',
          initialCategory: FoodCategory.altele,
        ),
      ),
    );
  }

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerScreen(
          onBarcodeScanned: (barcode) async {
            await scanAndAddProduct(barcode);

            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cod detectat: $barcode'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openRecipes(List<Product> pantry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipesScreen(pantry: pantry),
      ),
    );
  }

  void _openCategory(String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryProductsScreen(
          categoryName: categoryName,
        ),
      ),
    );
  }

  int _expiringSoonCount(List<Product> products) {
    return products
        .where((product) =>
            product.daysUntilExpiry >= 0 && product.daysUntilExpiry <= 3)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      body: SafeArea(
        child: ValueListenableBuilder<Box<Product>>(
          valueListenable: Hive.box<Product>('pantryBox').listenable(),
          builder: (context, box, _) {
            final pantry = box.values.toList();
            final expiringSoon = _expiringSoonCount(pantry);

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Food Saver',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black87,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Organizează alimentele și redu risipa',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: () => _openRecipes(pantry),
                              icon: const Icon(Icons.restaurant_menu_rounded),
                              tooltip: 'Idei de rețete',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.16),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.eco_rounded,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${pantry.length} produse în cămară',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      expiringSoon == 0
                                          ? 'Nu ai produse care expiră urgent.'
                                          : '$expiringSoon produse expiră în maximum 3 zile.',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _openScanner,
                                icon: const Icon(Icons.qr_code_scanner_rounded),
                                label: const Text('Scanează'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _openManualAdd,
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Adaugă manual'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green.shade800,
                                  side: BorderSide(
                                    color: Colors.green.shade300,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Categorii alimente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.crossAxisExtent;

                      final crossAxisCount = width < 420 ? 2 : 3;
                      final aspectRatio = width < 360 ? 0.95 : 1.08;

                      return SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = FoodCategory.values[index];
                            final config = categoryConfig[category]!;
                            final categoryProducts = pantry
                                .where((product) => product.category == category)
                                .toList();

                            return InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () => _openCategory(config['name']),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: config['color'],
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      config['icon'],
                                      style: const TextStyle(fontSize: 38),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      config['name'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${categoryProducts.length} produse',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.58),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: FoodCategory.values.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: aspectRatio,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openManualAdd,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Produs nou',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}