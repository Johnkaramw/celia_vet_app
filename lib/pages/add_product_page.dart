import 'dart:ui';

import 'package:celia_vet/pages/class_Product.dart';
import 'package:flutter/material.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController buyPriceController = TextEditingController();
  final TextEditingController sellPriceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? expiryDate;

  void _saveProduct() {
    final name = nameController.text;
    final buyPrice = double.tryParse(buyPriceController.text) ?? 0.0;
    final sellPrice = double.tryParse(sellPriceController.text) ?? 0.0;
    final description = descriptionController.text;

    if (name.isEmpty || buyPrice <= 0.0 || sellPrice <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("من فضلك أدخل بيانات صحيحة"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newProduct = Product(
      name: name,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      quantityBought: 0,
      quantitySold: 0,
      soldQuantity: 0,
      createdAt: DateTime.now(),
      description: description,
      expiryDate: expiryDate,
    );

    Navigator.pop(context, newProduct);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم إضافة المنتج بنجاح ✅"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        expiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF283E51), Color(0xFF485563)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "إضافة منتج جديد",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(nameController, "اسم المنتج"),
                        const SizedBox(height: 12),
                        _buildTextField(
                          buyPriceController,
                          "سعر الشراء",
                          isNumber: true,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          sellPriceController,
                          "سعر البيع",
                          isNumber: true,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(descriptionController, "وصف المنتج"),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white38),
                              color: Colors.white.withOpacity(0.1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  expiryDate == null
                                      ? "تاريخ الصلاحية"
                                      : "${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent[700],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text("إضافة المنتج"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white38),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
