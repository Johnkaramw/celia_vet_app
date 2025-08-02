import 'package:celia_vet/pages/CustomerPage.dart';
import 'package:celia_vet/pages/ExpensesPage.dart';
import 'package:flutter/material.dart';

import 'add_product_page.dart';
import 'class_Product.dart';
import 'edit_product_page.dart';
import 'product_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final loaded = await ProductStorage.loadProducts();
    setState(() => products = loaded);
  }

  Future<void> saveData() async {
    await ProductStorage.saveProducts(products);
  }

  void addProduct(Product newProduct) async {
    setState(() => products.add(newProduct));
    await saveData();
  }

  void updateProduct(int index, Product updated) async {
    setState(() => products[index] = updated);
    await saveData();
  }

  void deleteProduct(int index) async {
    setState(() => products.removeAt(index));
    await saveData();
  }

  Future<void> sellProductDialog(int index) async {
    int? quantity = await showQuantityDialog(context, 'بيع');
    if (quantity != null &&
        quantity > 0 &&
        products[index].quantityInStock >= quantity) {
      setState(() {
        products[index].quantitySold += quantity;
        products[index].soldQuantity += quantity;
      });
      await saveData();
    }
  }

  Future<void> buyProductDialog(int index) async {
    int? quantity = await showQuantityDialog(context, 'شراء');
    if (quantity != null && quantity > 0) {
      setState(() {
        products[index].quantityBought += quantity;
      });
      await saveData();
    }
  }

  Future<int?> showQuantityDialog(BuildContext context, String action) async {
    TextEditingController controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('أدخل الكمية للـ $action'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'مثال: 3'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: const Text('تم'),
          ),
        ],
      ),
    );
  }

  Color getCardColor(int quantity) {
    if (quantity < 5) return Colors.red[100]!;
    if (quantity < 10) return Colors.yellow[100]!;
    return Colors.green[100]!;
  }

  List<Product> get filteredProducts {
    if (searchQuery.isEmpty) return products;
    return products
        .where(
          (product) =>
              product.name.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنتجات'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'customers') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CustomerPage()),
                );
              } else if (value == 'expenses') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ExpensesPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'customers',
                child: Text('إدارة العملاء'),
              ),
              const PopupMenuItem<String>(
                value: 'expenses',
                child: Text('صفحة المصاريف'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'بحث عن منتج',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                final quantityInStock =
                    product.quantityBought - product.quantitySold;
                final profit =
                    (product.sellPrice - product.buyPrice) *
                    product.quantitySold;

                return ProductCard(
                  product: product,
                  quantityInStock: quantityInStock,
                  profit: profit,
                  onSell: () => sellProductDialog(products.indexOf(product)),
                  onBuy: () => buyProductDialog(products.indexOf(product)),
                  onEdit: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProductPage(product: product),
                      ),
                    );
                    if (updated != null)
                      updateProduct(products.indexOf(product), updated);
                  },
                  onDelete: () => deleteProduct(products.indexOf(product)),
                  cardColor: getCardColor(quantityInStock),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newProduct = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
          if (newProduct != null) addProduct(newProduct);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final int quantityInStock;
  final double profit;
  final VoidCallback onSell;
  final VoidCallback onBuy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color cardColor;

  const ProductCard({
    super.key,
    required this.product,
    required this.quantityInStock,
    required this.profit,
    required this.onSell,
    required this.onBuy,
    required this.onEdit,
    required this.onDelete,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final descriptionText = (product.description?.isNotEmpty ?? false)
        ? product.description!
        : "لا يوجد";

    final expiryText = product.expiryDate != null
        ? "${product.expiryDate!.day}/${product.expiryDate!.month}/${product.expiryDate!.year}"
        : "غير محدد";

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          'اسم المنتج: ${product.name}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          // الصف الأول: وصف وصلاحية + كمية
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //const Icon(Icons.description, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'الوصف: $descriptionText',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 6),
                        Text('الصلاحية: $expiryText'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        //const Icon(Icons.inventory, size: 18),
                        const SizedBox(width: 6),
                        Text('المتوفر: $quantityInStock'),
                      ],
                    ),
                    Row(
                      children: [
                        //const Icon(Icons.shopping_bag, size: 18),
                        const SizedBox(width: 6),
                        Text('تم بيع: ${product.quantitySold}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // الصف الثاني: الأسعار والربح
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        //const Icon(Icons.attach_money, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'شراء: ${product.buyPrice.toStringAsFixed(2)} ج.م',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        //const Icon(Icons.shopping_cart, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'بيع: ${product.sellPrice.toStringAsFixed(2)} ج.م',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // const Icon(Icons.local_offer, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'بيع جملة: ${(product.sellPrice * product.quantitySold).toStringAsFixed(2)} ج.م',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // const Icon(Icons.trending_up, size: 18),
                        const SizedBox(width: 6),
                        Text('الربح: ${profit.toStringAsFixed(2)} ج.م'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: onBuy,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('شراء'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                ),
              ),
              ElevatedButton.icon(
                onPressed: onSell,
                icon: const Icon(Icons.sell),
                label: const Text('بيع'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
              IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
            ],
          ),
        ],
      ),
    );
  }
}
