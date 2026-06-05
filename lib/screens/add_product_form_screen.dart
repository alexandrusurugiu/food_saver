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

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(
        const Duration(days: 30),
      ),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade600,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _saveProductToPantry() async {
    if (!_formKey.currentState!.validate() || _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Te rog selectează data de expirare!', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final pantryBox = Hive.box<Product>('pantryBox');
    final cacheBox = Hive.box<String>('cachedBarcodes');

    await cacheBox.put(widget.barcode, _nameController.text.trim());

    final newProduct = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _selectedCategory,
      expiryDate: _expiryDate!,
      imageUrl: '',
      quantity: _quantity,
      unit: _selectedUnit,
    );

    await pantryBox.add(newProduct);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Produs adăugat cu succes!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  InputDecoration _customInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade700),
      prefixIcon: Icon(icon, color: Colors.green.shade600),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.green.shade400, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Confirmare Produs', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E9),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  Card(
                    elevation: 2,
                    shadowColor: Colors.green.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.qr_code, color: Colors.grey.shade500, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Cod: ${widget.barcode}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nameController,
                            decoration: _customInputDecoration('Nume Produs', Icons.shopping_bag_outlined),
                            validator: (value) => value == null || value.isEmpty ? 'Introdu numele produsului' : null,
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<FoodCategory>(
                            value: _selectedCategory,
                            decoration: _customInputDecoration('Categorie', Icons.category_outlined),
                            icon: const Icon(Icons.expand_more, color: Colors.grey),
                            items: FoodCategory.values.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w500)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) setState(() => _selectedCategory = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    elevation: 2,
                    shadowColor: Colors.green.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dată expirare', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () => _selectExpiryDate(context),
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: _expiryDate == null ? Colors.orange.shade50 : Colors.green.shade50,
                                border: Border.all(color: _expiryDate == null ? Colors.orange.shade200 : Colors.green.shade200),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _expiryDate == null ? 'Alege data de pe ambalaj' : formatter.format(_expiryDate!),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _expiryDate == null ? Colors.orange.shade800 : Colors.green.shade800,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_month_rounded, 
                                    color: _expiryDate == null ? Colors.orange.shade600 : Colors.green.shade600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    elevation: 2,
                    shadowColor: Colors.green.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gestiune Stoc', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove, color: Colors.green.shade700),
                                      onPressed: () {
                                        if (_quantity > 0.5) {
                                          setState(() => _quantity -= (_selectedUnit == 'kg' || _selectedUnit == 'L' || _selectedUnit == 'g' ? 0.5 : 1.0));
                                        }
                                      },
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        _quantity % 1 == 0 ? _quantity.toInt().toString() : _quantity.toString(),
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add, color: Colors.green.shade700),
                                      onPressed: () {
                                        setState(() => _quantity += (_selectedUnit == 'kg' || _selectedUnit == 'L' || _selectedUnit == 'g' ? 0.5 : 1.0));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  border: Border.all(color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: DropdownButton<String>(
                                  value: _selectedUnit,
                                  underline: const SizedBox(),
                                  icon: const Icon(Icons.expand_more, size: 20),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
                                  items: <String>['buc', 'kg', 'g', 'L', 'ml', 'sticle', 'doze', 'cutii']
                                      .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) setState(() => _selectedUnit = value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ]
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      onPressed: _saveProductToPantry,
                      icon: const Icon(Icons.add_shopping_cart, size: 24),
                      label: const Text(
                        'Adaugă în Cămară',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}