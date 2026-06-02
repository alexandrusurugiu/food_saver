import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryProductsScreen({super.key, required this.categoryName});

  Color _getExpiryColor(int days) {
    if (days < 0) return Colors.grey;
    if (days <= 2) return Colors.redAccent;
    if (days <= 5) return Colors.orangeAccent;
    return Colors.green;
  }

  FoodCategory? _getEnumFromName(String name) {
    switch (name.toLowerCase()) {
      case 'lactate':
        return FoodCategory.lactate;
      case 'fructe':
        return FoodCategory.fructe;
      case 'legume':
        return FoodCategory.legume;
      case 'carne':
        return FoodCategory.carne;
      case 'patiserie':
        return FoodCategory.patiserie;
      case 'altele':
        return FoodCategory.altele;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentEnumCategory = _getEnumFromName(categoryName);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text(categoryName), elevation: 0),
      body: ValueListenableBuilder<Box<Product>>(
        valueListenable: Hive.box<Product>('pantryBox').listenable(),
        builder: (context, box, _) {
          final filteredProducts = box.values
              .where((p) => p.category == currentEnumCategory)
              .toList();

          filteredProducts.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

          if (filteredProducts.isEmpty) {
            return const Center(
              child: Text(
                'Nu ai produse în această categorie 🤷‍♂️',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final item = filteredProducts[index];
              final daysLeft = item.daysUntilExpiry;

              final displayQuantity = item.quantity! % 1 == 0
                  ? item.quantity?.toInt().toString()
                  : item.quantity.toString();

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 25,
                    child: Text(
                      item.imageUrl,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Stoc: $displayQuantity ${item.unit}',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        daysLeft < 0
                            ? 'Expirat de ${daysLeft.abs()} zile'
                            : daysLeft == 0
                            ? 'Expiră ASTĂZI!'
                            : 'Expiră în $daysLeft zile',
                        style: TextStyle(
                          color: _getExpiryColor(daysLeft),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.circle,
                    color: _getExpiryColor(daysLeft),
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          product: item,
                          productIndex: index,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
