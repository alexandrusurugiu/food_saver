// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:hive/hive.dart';
// import '../models/product.dart';

// class ProductDetailScreen extends StatefulWidget {
//   final Product product;
//   final int
//   productIndex; // Indexul din listă pentru a ști ce rând edităm în Hive

//   const ProductDetailScreen({
//     super.key,
//     required this.product,
//     required this.productIndex,
//   });

//   @override
//   State<ProductDetailScreen> createState() => _ProductDetailScreenState();
// }

// class _ProductDetailScreenState extends State<ProductDetailScreen> {
//   late double currentQuantity;
//   late String currentUnit;

//   @override
//   void initState() {
//     super.initState();
//     // Inițializăm starea ecranului cu datele actuale ale produsului
//     currentQuantity = widget.product.quantity!;
//     currentUnit = widget.product.unit!;
//   }

//   // Funcție care salvează modificările direct în Hive
//   Future<void> _saveChanges() async {
//     final box = Hive.box<Product>('pantryBox');

//     // Creăm un obiect nou actualizat folosind copyWith
//     final updatedProduct = widget.product.copyWith(
//       quantity: currentQuantity,
//       unit: currentUnit,
//     );

//     // Înlocuim produsul vechi la indexul lui din Hive
//     await box.putAt(widget.productIndex, updatedProduct);

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Modificările au fost salvate!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//       Navigator.pop(context); // Ne întoarcem la listă
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final formatter = DateFormat('dd/MM/yyyy');
//     final zileRamase = widget.product.daysUntilExpiry;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Detalii Produs'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check, size: 28),
//             onPressed: _saveChanges,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header: Nume și Categorie
//             Center(
//               child: Column(
//                 children: [
//                   const Icon(Icons.fastfood, size: 80, color: Colors.green),
//                   const SizedBox(height: 12),
//                   Text(
//                     widget.product.name,
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   Text(
//                     'Categorie: ${widget.product.category.name.toUpperCase()}',
//                     style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),

//             // Card Status Expirare
//             Card(
//               color: zileRamase < 3 ? Colors.red.shade50 : Colors.green.shade50,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: ListTile(
//                 leading: Icon(
//                   Icons.calendar_month,
//                   color: zileRamase < 3 ? Colors.red : Colors.green,
//                 ),
//                 title: const Text(
//                   'Dată expirare',
//                   style: TextStyle(fontWeight: FontWeight.w500),
//                 ),
//                 subtitle: Text(formatter.format(widget.product.expiryDate)),
//                 trailing: Text(
//                   zileRamase >= 0 ? '$zileRamase zile rămase' : 'Expirat!',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: zileRamase < 3 ? Colors.red : Colors.green,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),

//             // Secțiune Editare Cantitate
//             const Text(
//               'Gestionare Stoc',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Butoane modificare cantitate
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(
//                         Icons.remove_circle_outline,
//                         size: 36,
//                         color: Colors.red,
//                       ),
//                       onPressed: () {
//                         if (currentQuantity > 0) {
//                           setState(() {
//                             // Scădem cu 0.5 pentru kg/L, sau cu 1 dacă e număr întreg
//                             if (currentUnit == 'kg' ||
//                                 currentUnit == 'L' ||
//                                 currentUnit == 'g') {
//                               currentQuantity -= 0.5;
//                             } else {
//                               currentQuantity -= 1.0;
//                             }
//                             if (currentQuantity < 0) currentQuantity = 0;
//                           });
//                         }
//                       },
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 10,
//                       ),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         currentQuantity % 1 == 0
//                             ? currentQuantity.toInt().toString()
//                             : currentQuantity.toString(),
//                         style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(
//                         Icons.add_circle_outline,
//                         size: 36,
//                         color: Colors.green,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           if (currentUnit == 'kg' ||
//                               currentUnit == 'L' ||
//                               currentUnit == 'g') {
//                             currentQuantity += 0.5;
//                           } else {
//                             currentQuantity += 1.0;
//                           }
//                         });
//                       },
//                     ),
//                   ],
//                 ),

//                 // Dropdown pentru alegerea unității de măsură
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: DropdownButton<String>(
//                     value: currentUnit,
//                     underline: const SizedBox(),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       color: Colors.black,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     items:
//                         <String>[
//                           'buc',
//                           'kg',
//                           'g',
//                           'L',
//                           'ml',
//                           'sticle',
//                           'doze',
//                           'cutii',
//                         ].map<DropdownMenuItem<String>>((String value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(value),
//                           );
//                         }).toList(),
//                     onChanged: (String? newValue) {
//                       if (newValue != null) {
//                         setState(() {
//                           currentUnit = newValue;
//                         });
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),

//             const Spacer(),

//             // Butonul mare de salvare de jos
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: _saveChanges,
//                 icon: const Icon(Icons.save, color: Colors.white),
//                 label: const Text(
//                   'Salvează modificările',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final int
  productIndex; // Indexul din listă pentru a ști ce rând edităm/ștergem în Hive

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.productIndex,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late double currentQuantity;
  late String currentUnit;

  @override
  void initState() {
    super.initState();
    // Inițializăm starea ecranului cu datele actuale ale produsului
    currentQuantity = widget.product.quantity!;
    currentUnit = widget.product.unit!;
  }

  // Funcție care salvează modificările direct în Hive
  // Future<void> _saveChanges() async {
  //   final box = Hive.box<Product>('pantryBox');

  //   // Creăm un obiect nou actualizat folosind copyWith
  //   final updatedProduct = widget.product.copyWith(
  //     quantity: currentQuantity,
  //     unit: currentUnit,
  //   );

  //   // Înlocuim produsul vechi la indexul lui din Hive
  //   await box.putAt(widget.productIndex, updatedProduct);

  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Modificările au fost salvate!'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //     Navigator.pop(context); // Ne întoarcem la listă
  //   }
  // }

  // Funcție care salvează modificările direct la cheia corectă din Hive
  Future<void> _saveChanges() async {
    final box = Hive.box<Product>('pantryBox');

    // Găsim cheia reală din Hive după ID
    final cheieHive = box.keys.firstWhere(
      (k) => box.get(k)?.id == widget.product.id,
      orElse: () => null,
    );

    if (cheieHive != null) {
      final updatedProduct = widget.product.copyWith(
        quantity: currentQuantity,
        unit: currentUnit,
      );

      // Salvăm direct peste cheia corectă, nu la index arbitrar
      await box.put(cheieHive, updatedProduct);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Modificările au fost salvate!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  // Funcție care șterge produsul din Hive
  // Future<void> _deleteProduct() async {
  //   final box = Hive.box<Product>('pantryBox');

  //   // Ștergem elementul de la indexul specificat
  //   await box.deleteAt(widget.productIndex);

  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Produsul a fost șters din inventar!'),
  //         backgroundColor: Colors.redAccent,
  //       ),
  //     );
  //     Navigator.pop(context); // Ne întoarcem la listă după ștergere
  //   }
  // }

  // Funcție care șterge produsul corect din Hive pe baza ID-ului unic
  Future<void> _deleteProduct() async {
    final box = Hive.box<Product>('pantryBox');

    // 1. Găsim cheia reală din Hive unde se află produsul cu acest ID
    final cheieHive = box.keys.firstWhere(
      (k) => box.get(k)?.id == widget.product.id,
      orElse: () => null,
    );

    // 2. Dacă am găsit produsul în baza de date, îl ștergem doar pe el
    if (cheieHive != null) {
      await box.delete(cheieHive);
      print("[HIVE] Produsul a fost sters cu succes folosind cheia stabila.");
    } else {
      print(
        "[HIVE ERROR] Nu s-a putut gasi cheia pentru ID-ul: ${widget.product.id}",
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produsul a fost șters din inventar!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.pop(context); // Ne întoarcem la listă
    }
  }

  // Dialog de confirmare pentru ștergere (pentru a preveni atingerile accidentale)
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmare ștergere'),
          content: const Text(
            'Ești sigur că vrei să elimini acest produs din cămară?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Anulează',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Închide dialogul
                _deleteProduct(); // Execută ștergerea
              },
              child: const Text('Șterge', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    final zileRamase = widget.product.daysUntilExpiry;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalii Produs'),
        centerTitle: true,
        actions: [
          // Butonul de ștergere adăugat în bara de sus
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 28,
            ),
            tooltip: 'Șterge produs',
            onPressed: _showDeleteConfirmation,
          ),
          IconButton(
            icon: const Icon(Icons.check, size: 28),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Previne eventualele probleme de overflow pe ecrane mai mici
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Nume și Categorie
            Center(
              child: Column(
                children: [
                  const Icon(Icons.fastfood, size: 80, color: Colors.green),
                  const SizedBox(height: 12),
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Categorie: ${widget.product.category.name.toUpperCase()}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Card Status Expirare
            Card(
              color: zileRamase < 3 ? Colors.red.shade50 : Colors.green.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.calendar_month,
                  color: zileRamase < 3 ? Colors.red : Colors.green,
                ),
                title: const Text(
                  'Dată expirare',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(formatter.format(widget.product.expiryDate)),
                trailing: Text(
                  zileRamase >= 0 ? '$zileRamase zile rămase' : 'Expirat!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: zileRamase < 3 ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Secțiune Editare Cantitate
            const Text(
              'Gestionare Stoc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Butoane modificare cantitate
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        size: 36,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        if (currentQuantity > 0) {
                          setState(() {
                            if (currentUnit == 'kg' ||
                                currentUnit == 'L' ||
                                currentUnit == 'g') {
                              currentQuantity -= 0.5;
                            } else {
                              currentQuantity -= 1.0;
                            }
                            if (currentQuantity < 0) currentQuantity = 0;
                          });
                        }
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        currentQuantity % 1 == 0
                            ? currentQuantity.toInt().toString()
                            : currentQuantity.toString(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        size: 36,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        setState(() {
                          if (currentUnit == 'kg' ||
                              currentUnit == 'L' ||
                              currentUnit == 'g') {
                            currentQuantity += 0.5;
                          } else {
                            currentQuantity += 1.0;
                          }
                        });
                      },
                    ),
                  ],
                ),

                // Dropdown pentru alegerea unității de măsură
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: currentUnit,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    items:
                        <String>[
                          'buc',
                          'kg',
                          'g',
                          'L',
                          'ml',
                          'sticle',
                          'doze',
                          'cutii',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          currentUnit = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40), // Spațiu controlat deasupra butonului
            // Butonul de salvare a fost mutat aici sus, eliminând const Spacer()
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveChanges,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Salvează modificările',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
