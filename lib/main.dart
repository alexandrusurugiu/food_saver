import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/product.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(FoodCategoryAdapter());
  Hive.registerAdapter(ProductAdapter());

  await Hive.openBox<Product>('pantryBox');

  runApp(const FoodInventoryApp());
}

class FoodInventoryApp extends StatelessWidget {
  const FoodInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Saver',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}