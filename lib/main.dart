import 'package:flutter/material.dart';

void main() {
  runApp(const FoodInventoryApp());
}

class FoodInventoryApp extends StatelessWidget {
  const FoodInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pantry App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frigiderul Meu'),
      ),
      body: const Center(
        child: Text('Aici vor apărea alimentele tale.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Deschide camera!');
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}