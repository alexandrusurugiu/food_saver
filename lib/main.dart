import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/product.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor:
          Colors.white,
      systemNavigationBarIconBrightness:
          Brightness.dark,
      statusBarColor:
          Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Hive.initFlutter();

  Hive.registerAdapter(FoodCategoryAdapter());
  Hive.registerAdapter(ProductAdapter());

  await Hive.openBox<Product>('pantryBox');
  await Hive.openBox<String>('cachedBarcodes');

  runApp(const FoodInventoryApp());
}

class FoodInventoryApp extends StatelessWidget {
  const FoodInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Saver',
      debugShowCheckedModeBanner: false, // Scoate eticheta de debug din colț
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}
