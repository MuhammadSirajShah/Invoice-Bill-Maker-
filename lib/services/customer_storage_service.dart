import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer_model.dart';

class CustomerStorageService {
  static const String _customersKey = 'saved_customers';

  static Future<List<CustomerModel>> getCustomers() async {
    final prefs = await SharedPreferences.getInstance();

    final customersJson =
    prefs.getStringList(_customersKey);

    if (customersJson == null || customersJson.isEmpty) {
      return [];
    }

    return customersJson.map((customerJson) {
      final Map<String, dynamic> json =
      jsonDecode(customerJson);

      return CustomerModel.fromJson(json);
    }).toList();
  }

  static Future<void> saveCustomer(
      CustomerModel customer,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final customers = await getCustomers();

    customers.insert(0, customer);

    final customersJson = customers.map((customer) {
      return jsonEncode(customer.toJson());
    }).toList();

    await prefs.setStringList(
      _customersKey,
      customersJson,
    );
  }

  static Future<void> deleteCustomer(
      String customerId,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final customers = await getCustomers();

    customers.removeWhere(
          (customer) => customer.id == customerId,
    );

    final customersJson = customers.map((customer) {
      return jsonEncode(customer.toJson());
    }).toList();

    await prefs.setStringList(
      _customersKey,
      customersJson,
    );
  }

  static Future<void> clearCustomers() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_customersKey);
  }
}