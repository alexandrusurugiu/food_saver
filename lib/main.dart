// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'models/product.dart';
// import 'screens/splash_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Hive.initFlutter();

//   Hive.registerAdapter(FoodCategoryAdapter());
//   Hive.registerAdapter(ProductAdapter());

//   await Hive.openBox<Product>('pantryBox');
//   await Hive.openBox<String>('cachedBarcodes');

//   runApp(const FoodInventoryApp());
// }

// class FoodInventoryApp extends StatelessWidget {
//   const FoodInventoryApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Food Saver',
//       theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
//       home: const SplashScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import necesar pentru gestionarea barierelor de sistem
import 'package:hive_flutter/hive_flutter.dart';
import 'models/product.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forțează aplicația să respecte marginile fizice ale ecranului (fără suprapuneri)
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Configurăm aspectul barei de navigare de jos a telefonului
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor:
          Colors.white, // Fundal alb pentru bara cu butoanele Home/Back
      systemNavigationBarIconBrightness:
          Brightness.dark, // Iconițe închise la culoare pe fundal alb
      statusBarColor:
          Colors.transparent, // Lasă bara de sus (notificările) transparentă
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
