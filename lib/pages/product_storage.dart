import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'class_Product.dart';

class ProductStorage {
  static const String _key = 'products';

  static Future<List<Product>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productList = prefs.getStringList(_key) ?? [];
    return productList.map((p) => Product.fromJson(jsonDecode(p))).toList();
  }

  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final productList = products.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_key, productList);
  }
}
