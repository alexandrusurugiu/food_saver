import 'package:hive/hive.dart';
part 'product.g.dart';

@HiveType(typeId: 0)
enum FoodCategory {
  @HiveField(0) lactate,
  @HiveField(1) fructe,
  @HiveField(2) legume,
  @HiveField(3) carne,
  @HiveField(4) patiserie,
  @HiveField(5) altele 
}

@HiveType(typeId: 1)
class Product {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final DateTime expiryDate;
  
  @HiveField(3)
  final String imageUrl;
  
  @HiveField(4)
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
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }
}