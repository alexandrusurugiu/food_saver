// import 'package:hive/hive.dart';
// part 'product.g.dart';

// @HiveType(typeId: 0)
// enum FoodCategory {
//   @HiveField(0) lactate,
//   @HiveField(1) fructe,
//   @HiveField(2) legume,
//   @HiveField(3) carne,
//   @HiveField(4) patiserie,
//   @HiveField(5) altele

// }

// @HiveType(typeId: 1)
// class Product {
//   @HiveField(0)
//   final String id;

//   @HiveField(1)
//   final String name;

//   @HiveField(2)
//   final DateTime expiryDate;

//   @HiveField(3)
//   final String imageUrl;

//   @HiveField(4)
//   final FoodCategory category;

//   Product({
//     required this.id,
//     required this.name,
//     required this.expiryDate,
//     required this.imageUrl,
//     required this.category,
//   });

//   int get daysUntilExpiry {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
//     return expiry.difference(today).inDays;
//   }
// }

import 'package:hive/hive.dart';
part 'product.g.dart';

@HiveType(typeId: 0)
enum FoodCategory {
  @HiveField(0)
  lactate,
  @HiveField(1)
  fructe,
  @HiveField(2)
  legume,
  @HiveField(3)
  carne,
  @HiveField(4)
  patiserie,
  @HiveField(5)
  altele,
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

  // Câmpuri noi pentru gestionarea cantităților flexibile
  @HiveField(5)
  final double? quantity; // double permite și valori ca 0.5 kg sau 1.5 litri

  @HiveField(6)
  final String? unit; // Ex: 'kg', 'g', 'L', 'buc', 'sticle', 'doze', 'cutii'

  // Product({
  //   required this.id,
  //   required this.name,
  //   required this.expiryDate,
  //   required this.imageUrl,
  //   required this.category,
  //   this.quantity = 1.0, // Valoare implicită 1
  //   this.unit = 'buc', // Valoare implicită 'buc' (bucăți)
  // });

  Product({
    required this.id,
    required this.name,
    required this.expiryDate,
    required this.imageUrl,
    required this.category,
    double? quantity,
    String? unit,
  }) : this.quantity = quantity ?? 1.0, // Dacă e null la citire, devine 1.0
       this.unit = unit ?? 'buc'; // Dacă e null la citire, devine 'buc'

  int get daysUntilExpiry {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  // Metodă ajutătoare pentru a edita ușor produsul în ecranul de detalii
  Product copyWith({
    String? id,
    String? name,
    DateTime? expiryDate,
    String? imageUrl,
    FoodCategory? category,
    double? quantity,
    String? unit,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      expiryDate: expiryDate ?? this.expiryDate,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}
