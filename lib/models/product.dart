enum FoodCategory { lactate, fructe, legume, carne, patiserie, altele }

class Product {
  final String id;
  final String name;
  final DateTime expiryDate;
  final String imageUrl;
  final FoodCategory category;
  
  Product({
    required this.id,
    required this.name,
    required this.expiryDate,
    required this.imageUrl,
    required this.category,
  });

  int get daysUntilExpiry {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    
    return difference.inDays;
  }
}