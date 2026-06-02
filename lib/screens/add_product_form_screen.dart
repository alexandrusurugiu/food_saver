import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../models/product.dart';

class AddProductFormScreen extends StatefulWidget {
  final String barcode;
  final String initialName;
  final FoodCategory initialCategory;

  const AddProductFormScreen({
    super.key,
    required this.barcode,
    required this.initialName,
    required this.initialCategory,
  });

  @override
  State<AddProductFormScreen> createState() => _AddProductFormScreenState();
}

class _AddProductFormScreenState extends State<AddProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late FoodCategory _selectedCategory;
  late double _quantity;
  late String _selectedUnit;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedCategory = widget.initialCategory;
    _quantity = 1.0;
    _selectedUnit = 'buc';
  }

  // Funcție pentru deschiderea calendarului nativ Android/Samsung
  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(
        const Duration(days: 30),
      ), // Permite stocarea produselor cumpărate recent
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  // Salvarea finală în bazele de date locală
  Future<void> _saveProductToPantry() async {
    if (!_formKey.currentState!.validate() || _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Te rog selectează data de expirare!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final pantryBox = Hive.box<Product>('pantryBox');
    final cacheBox = Hive.box<String>('cachedBarcodes');

    // 1. Salvăm codul de bare în cache-ul local împreună cu numele ales/editat de user
    await cacheBox.put(widget.barcode, _nameController.text.trim());

    // 2. Creăm obiectul final de tip Product
    final newProduct = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _selectedCategory,
      expiryDate: _expiryDate!,
      imageUrl: '', // Poți adăuga un URL de imagine dacă dorești pe viitor
      quantity: _quantity,
      unit: _selectedUnit,
    );

    // 3. Salvăm în cămară (pantryBox)
    await pantryBox.add(newProduct);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produs adăugat cu succes în cămară!'),
          backgroundColor: Colors.green,
        ),
      );
      // Ne întoarcem direct la HomeScreen (eliminăm ecranele intermediare de scanare)
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmare Produs Scanat'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cod bare: ${widget.barcode}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // 1. Câmp text pentru Nume Produs (Precompletat, editabil)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nume Produs',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Introdu numele produsului'
                    : null,
              ),
              const SizedBox(height: 20),

              // 2. Dropdown pentru Categorie
              DropdownButtonFormField<FoodCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categorie',
                  border: OutlineInputBorder(),
                ),
                items: FoodCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 25),

              // 3. Selector Dată de Expirare (Calendar)
              const Text(
                'Dată expirare',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectExpiryDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _expiryDate == null
                            ? 'Alege data de pe ambalaj'
                            : formatter.format(_expiryDate!),
                        style: TextStyle(
                          fontSize: 16,
                          color: _expiryDate == null
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.green),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // 4. Gestiune Cantitate & Unitate de măsură
              const Text(
                'Gestiune Stoc inițial',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          size: 32,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          if (_quantity > 0.5) {
                            setState(
                              () => _quantity -=
                                  (_selectedUnit == 'kg' ||
                                      _selectedUnit == 'L' ||
                                      _selectedUnit == 'g'
                                  ? 0.5
                                  : 1.0),
                            );
                          }
                        },
                      ),
                      Text(
                        _quantity % 1 == 0
                            ? _quantity.toInt().toString()
                            : _quantity.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          size: 32,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          setState(
                            () => _quantity +=
                                (_selectedUnit == 'kg' ||
                                    _selectedUnit == 'L' ||
                                    _selectedUnit == 'g'
                                ? 0.5
                                : 1.0),
                          );
                        },
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedUnit,
                      underline: const SizedBox(),
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
                              ]
                              .map(
                                (val) => DropdownMenuItem(
                                  value: val,
                                  child: Text(val),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _selectedUnit = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Butonul de adăugare finală
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: _saveProductToPantry,
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Adaugă în Cămară',
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
      ),
    );
  }
}
