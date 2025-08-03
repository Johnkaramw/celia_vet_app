import 'dart:ui';

import 'package:celia_vet/class/CustomerClass.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  late Box<Customer> customerBox;
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();
  Widget _buildAmount(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${value.toStringAsFixed(2)} ج.م",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    customerBox = Hive.box<Customer>('customers');
    loadCustomers();
    _searchController.addListener(_filterCustomers);
  }

  void loadCustomers() {
    setState(() {
      customers = customerBox.values.toList();
      filteredCustomers = customers;
    });
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCustomers = customers.where((customer) {
        final nameMatch = customer.name.toLowerCase().contains(query);
        final phoneMatch = customer.phone.contains(query);
        return nameMatch || phoneMatch;
      }).toList();
    });
  }

  void addCustomer(Customer customer) {
    customerBox.add(customer);
    loadCustomers();
  }

  void updateCustomer(int index, Customer customer) {
    customerBox.putAt(index, customer);
    loadCustomers();
  }

  void deleteCustomer(int index) {
    customerBox.deleteAt(index);
    loadCustomers();
  }

  void shareOnWhatsApp(Customer customer) async {
    final msg =
        '''
فاتورة العميل:
الاسم: ${customer.name}
رقم الهاتف: ${customer.phone}
اشترى بـ: ${customer.totalAmount}
دفع: ${customer.paidAmount}
المتبقي: ${customer.remaining}
    ''';

    void shareToWhatsApp(BuildContext context, String msg) async {
      final url = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(msg)}");

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تعذر فتح واتساب"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showCustomerDialog({Customer? existing, int? index}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final totalController = TextEditingController(
      text: existing?.totalAmount.toString() ?? '',
    );
    final paidController = TextEditingController(
      text: existing?.paidAmount.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  width: 350,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          existing == null
                              ? "إضافة عميل"
                              : "تعديل بيانات العميل",
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCustomerField(nameController, "اسم العميل"),
                        const SizedBox(height: 12),
                        _buildCustomerField(phoneController, "رقم الهاتف"),
                        const SizedBox(height: 12),
                        _buildCustomerField(
                          totalController,
                          "اشترى بـ كام",
                          isNumber: true,
                        ),
                        const SizedBox(height: 12),
                        _buildCustomerField(
                          paidController,
                          "دفع كام",
                          isNumber: true,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            final name = nameController.text.trim();
                            final phone = phoneController.text.trim();
                            final total =
                                double.tryParse(totalController.text) ?? 0;
                            final paid =
                                double.tryParse(paidController.text) ?? 0;

                            if (name.isEmpty || phone.isEmpty || total <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("من فضلك أدخل بيانات صحيحة"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final customer = Customer(
                              name: name,
                              phone: phone,
                              totalAmount: total,
                              paidAmount: paid,
                            );

                            if (existing == null) {
                              addCustomer(customer);
                            } else if (index != null) {
                              updateCustomer(index, customer);
                            }

                            Navigator.pop(context);
                          },
                          child: Text(existing == null ? "إضافة" : "حفظ"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerField(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("العملاء"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showCustomerDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 خانة البحث
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'ابحث بالاسم أو رقم الهاتف',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 📋 قائمة العملاء
          Expanded(
            child: filteredCustomers.isEmpty
                ? const Center(child: Text("لا يوجد عملاء مطابقين"))
                : ListView.builder(
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.teal,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Text(
                                customer.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        color: Colors.teal,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(customer.phone),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildAmount(
                                          "إجمالي",
                                          customer.totalAmount,
                                          Colors.blue,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildAmount(
                                          "مدفوع",
                                          customer.paidAmount,
                                          Colors.green,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildAmount(
                                          "الباقي",
                                          customer.remaining,
                                          Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => showCustomerDialog(
                                          existing: customer,
                                          index: index,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => deleteCustomer(index),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.share,
                                          color: Colors.green,
                                        ),
                                        onPressed: () =>
                                            shareOnWhatsApp(customer),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
