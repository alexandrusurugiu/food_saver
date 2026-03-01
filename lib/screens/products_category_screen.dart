import 'package:flutter/material.dart';
import '../models/product.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;
  final List<Product> products;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
    required this.products,
  });

  Color _getExpiryColor(int days) {
    if (days < 0) return Colors.grey;
    if (days <= 2) return Colors.redAccent;
    if (days <= 5) return Colors.orangeAccent;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    products.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(categoryName),
        elevation: 0,
      ),
      body: products.isEmpty
          ? const Center(child: Text('Nu ai produse în această categorie 🤷‍♂️', style: TextStyle(fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];
                final daysLeft = item.daysUntilExpiry;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25,
                      child: Text(item.imageUrl, style: const TextStyle(fontSize: 24)),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      daysLeft < 0
                          ? 'Expirat de ${daysLeft.abs()} zile'
                          : daysLeft == 0 ? 'Expiră ASTĂZI!' : 'Expiră în $daysLeft zile',
                      style: TextStyle(
                        color: _getExpiryColor(daysLeft),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Icon(Icons.circle, color: _getExpiryColor(daysLeft), size: 16),
                  ),
                );
              },
            ),
    );
  }
}