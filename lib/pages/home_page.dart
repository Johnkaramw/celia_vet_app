import 'package:celia_vet/pages/CustomerPage.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنتجات'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'other') {
                // بعدين هنا نحط صفحة جديدة
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CustomerPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'other',
                child: Text('صفحة إضافية'),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final quantityInStock = product.quantityBought - product.quantitySold;
          final profit =
              (product.sellPrice - product.buyPrice) * product.quantitySold;

          return ProductCard(
            product: product,
            quantityInStock: quantityInStock,
            profit: profit,
            onSell: () => sellProductDialog(index),
            onBuy: () => buyProductDialog(index),
            onEdit: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProductPage(product: product),
                ),
              );
              if (updated != null) updateProduct(index, updated);
            },
            onDelete: () => deleteProduct(index),
            cardColor: getCardColor(quantityInStock),
          );
        },
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
    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اسم المنتج: ${product.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('الكمية المتوفرة: $quantityInStock'),
            Text('سعر الشراء: ${product.buyPrice.toStringAsFixed(2)} ج.م'),
            Text('سعر البيع: ${product.sellPrice.toStringAsFixed(2)} ج.م'),
            Text('الربح: ${profit.toStringAsFixed(2)} ج.م'),
            Text('تم بيع: ${product.quantitySold} هذا الشهر'),
            const SizedBox(height: 8),
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
      ),
    );
  }
}

// صفحة مؤقتة (هنستبدلها بعدين)
class PlaceholderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('صفحة إضافية')),
      body: const Center(
        child: Text('دي صفحة تجريبية. ابعتلي محتوى الصفحة اللي عايز تبنيها.'),
      ),
    );
  }
}
