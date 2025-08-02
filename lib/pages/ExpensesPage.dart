import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../class/ExpenseClass.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final Box<Expense> expensesBox = Hive.box<Expense>('expenses');

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String selectedCategory = 'شخصية';

  final List<String> categories = ['شخصية', 'بنزين', 'تصليح', 'أخرى'];

  void addExpense() {
    final description = descriptionController.text.trim();
    final amount = double.tryParse(amountController.text) ?? 0;

    if (description.isEmpty || amount <= 0) return;

    final newExpense = Expense(
      description: description,
      amount: amount,
      date: DateTime.now(),
      category: selectedCategory,
      isPaid: false,
    );

    expensesBox.add(newExpense);
    descriptionController.clear();
    amountController.clear();

    setState(() {});
  }

  void markAsPaid(int index) {
    final expense = expensesBox.getAt(index);
    if (expense != null && !expense.isPaid!) {
      expense.isPaid = true;
      expense.save();
      setState(() {});
    }
  }

  double getTotalExpenses() {
    return expensesBox.values
        .where((e) => e.isPaid == false)
        .fold(0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل المصاريف')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // نموذج الإدخال
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'الوصف',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'المبلغ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.money),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      onChanged: (value) =>
                          setState(() => selectedCategory = value!),
                      decoration: InputDecoration(
                        labelText: 'الفئة',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: addExpense,
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة مصروف'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // إجمالي المصاريف
            ValueListenableBuilder(
              valueListenable: expensesBox.listenable(),
              builder: (context, Box<Expense> box, _) {
                double total = getTotalExpenses();

                return Text(
                  "إجمالي المصاريف المتبقية: ${total.toStringAsFixed(2)} ج.م",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // قائمة المصاريف
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: expensesBox.listenable(),
                builder: (context, Box<Expense> box, _) {
                  if (box.isEmpty) {
                    return const Center(child: Text('لا يوجد مصاريف مسجلة'));
                  }

                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final expense = box.getAt(index);

                      if (expense == null) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(
                            expense.description,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${expense.category} • ${expense.date.toLocal().toString().split(' ')[0]}",
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${expense.amount.toStringAsFixed(2)} ج.م",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: expense.isPaid!
                                      ? Colors.grey
                                      : Colors.green,
                                  decoration: expense.isPaid!
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (!expense.isPaid!)
                                GestureDetector(
                                  onTap: () => markAsPaid(index),
                                  child: const Text(
                                    "تم الدفع؟",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 13,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                )
                              else
                                const Text(
                                  "مدفوع",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
