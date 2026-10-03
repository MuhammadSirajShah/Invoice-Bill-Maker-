import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_model.dart';

class ProductStorageService {
  static const String _productsKey = 'saved_products';

  static Future<List<ProductModel>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();

    final productsJson =
    prefs.getStringList(_productsKey);

    if (productsJson == null || productsJson.isEmpty) {
      return [];
    }

    return productsJson.map((productJson) {
      final Map<String, dynamic> json =
      jsonDecode(productJson);

      return ProductModel.fromJson(json);
    }).toList();
  }

  static Future<void> saveProduct(
      ProductModel product,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final products = await getProducts();

    products.insert(0, product);

    final productsJson = products.map((product) {
      return jsonEncode(product.toJson());
    }).toList();

    await prefs.setStringList(
      _productsKey,
      productsJson,
    );
  }

  static Future<void> deleteProduct(
      String productId,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final products = await getProducts();

    products.removeWhere(
          (product) => product.id == productId,
    );

    final productsJson = products.map((product) {
      return jsonEncode(product.toJson());
    }).toList();

    await prefs.setStringList(
      _productsKey,
      productsJson,
    );
  }

  static Future<void> clearProducts() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_productsKey);
  }
}