import 'dart:ui';
import 'package:celia_vet/pages/class_Product.dart';
import 'package:flutter/material.dart';

class EditProductPage extends StatefulWidget {
  final Product product;
  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController nameController;
  late TextEditingController buyPriceController;
  late TextEditingController sellPriceController;
  late TextEditingController descriptionController;
  DateTime? expiryDate;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    buyPriceController = TextEditingController(
      text: widget.product.buyPrice.toString(),
    );
    sellPriceController = TextEditingController(
      text: widget.product.sellPrice.toString(),
    );
    descriptionController = TextEditingController(
      text: widget.product.description ?? '',
    );
    expiryDate = widget.product.expiryDate;
  }

  void saveChanges() {
    final name = nameController.text;
    final buyPrice = double.tryParse(buyPriceController.text) ?? 0.0;
    final sellPrice = double.tryParse(sellPriceController.text) ?? 0.0;
    final description = descriptionController.text;

    if (name.isEmpty || buyPrice <= 0.0 || sellPrice <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("من فضلك أكمل البيانات بشكل صحيح"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final updatedProduct = Product(
      name: name,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      quantityBought: widget.product.quantityBought,
      quantitySold: widget.product.quantitySold,
      soldQuantity: widget.product.soldQuantity,
      createdAt: widget.product.createdAt,
      description: description,
      expiryDate: expiryDate,
    );

    Navigator.pop(context, updatedProduct);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("تم تعديل المنتج بنجاح ✅"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }

  void _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: expiryDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
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
                colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                          "تعديل بيانات المنتج",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                          onPressed: saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent[700],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text("حفظ التعديلات"),
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
