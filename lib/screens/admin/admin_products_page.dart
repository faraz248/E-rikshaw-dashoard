import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  final _nameController = TextEditingController();
  final _partNoController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String _selectedCategory = 'Spare Parts';
  bool _isSaving = false;

  final List<String> _categories = [
    'Batteries',
    'Chargers',
    'Motors & Controllers',
    'Tyres & Rims',
    'Spare Parts',
    'Accessories',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _partNoController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _openProductDialog({String? docId, Map<String, dynamic>? existingData}) {
    final bool isEdit = docId != null;

    if (isEdit) {
      _nameController.text = existingData?['name']?.toString() ?? '';
      _partNoController.text = existingData?['partNumber']?.toString() ?? '';
      _priceController.text = existingData?['price']?.toString() ?? '0';
      _stockController.text = existingData?['stock']?.toString() ?? '0';
      _selectedCategory =
          existingData?['category']?.toString() ?? 'Spare Parts';
    } else {
      _nameController.clear();
      _partNoController.clear();
      _priceController.clear();
      _stockController.clear();
      _selectedCategory = 'Spare Parts';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEdit ? 'Edit Item Details' : 'Add New Inventory Item',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => _selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Part / Product Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _partNoController,
                  decoration: InputDecoration(
                    labelText: 'Part Number / Model Code (Optional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Selling Price (₹)',
                          prefixIcon:
                              const Icon(Icons.currency_rupee, size: 18),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Stock Units',
                          prefixIcon: const Icon(Icons.inventory, size: 18),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
              ),
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (_nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Item name bharna zaroori hai')),
                        );
                        return;
                      }

                      final double price =
                          double.tryParse(_priceController.text.trim()) ?? 0.0;
                      final int stock =
                          int.tryParse(_stockController.text.trim()) ?? 0;

                      setDialogState(() => _isSaving = true);
                      Navigator.pop(ctx);

                      final payload = {
                        'name': _nameController.text.trim(),
                        'category': _selectedCategory,
                        'partNumber': _partNoController.text.trim(),
                        'price': price,
                        'stock': stock,
                        'updatedAt': FieldValue.serverTimestamp(),
                      };

                      if (isEdit) {
                        await FirebaseFirestore.instance
                            .collection('Products')
                            .doc(docId)
                            .update(payload);
                      } else {
                        payload['createdAt'] = FieldValue.serverTimestamp();
                        await FirebaseFirestore.instance
                            .collection('Products')
                            .add(payload);
                      }

                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF0F766E),
                          content: Text(isEdit
                              ? 'Item updated!'
                              : 'Item inventory me add ho gaya!'),
                        ),
                      );
                    },
              child: Text(isEdit ? 'Update' : 'Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _adjustStock(String docId, int currentStock, int change) async {
    final int updatedStock = (currentStock + change).clamp(0, 999999);
    await FirebaseFirestore.instance.collection('Products').doc(docId).update({
      'stock': updatedStock,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Inventory & Spare Parts'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F766E),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Item',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _openProductDialog(),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('Products')
            .orderBy('category')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data?.docs ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 54, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Inventory khali hai. Naya samaan add karein.',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final doc = items[index];
              final data = doc.data();
              final String name = data['name'] ?? 'Item';
              final String category = data['category'] ?? 'General';
              final String partNo = data['partNumber'] ?? '';
              final double price =
                  double.tryParse((data['price'] ?? 0).toString()) ?? 0.0;
              final int stock =
                  int.tryParse((data['stock'] ?? 0).toString()) ?? 0;
              final bool isLowStock = stock <= 2;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        isLowStock ? Colors.red.shade300 : Colors.grey.shade300,
                    width: isLowStock ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isLowStock
                          ? Colors.red.shade50
                          : const Color(0xFFF1F5F9),
                      child: Icon(
                        category == 'Batteries'
                            ? Icons.battery_full
                            : category == 'Chargers'
                                ? Icons.electrical_services
                                : Icons.handyman,
                        color:
                            isLowStock ? Colors.red : const Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 3),
                          Text(
                            '$category ${partNo.isNotEmpty ? "• $partNo" : ""}',
                            style: const TextStyle(
                                fontSize: 11.5, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Price: ₹${price.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF0F766E)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isLowStock
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isLowStock ? 'Low Stock: $stock' : 'Stock: $stock',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isLowStock
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 20, color: Colors.grey),
                              onPressed: stock > 0
                                  ? () => _adjustStock(doc.id, stock, -1)
                                  : null,
                              visualDensity: VisualDensity.compact,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  size: 20, color: Color(0xFF0F766E)),
                              onPressed: () => _adjustStock(doc.id, stock, 1),
                              visualDensity: VisualDensity.compact,
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  size: 18, color: Colors.blueGrey),
                              onPressed: () => _openProductDialog(
                                  docId: doc.id, existingData: data),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
