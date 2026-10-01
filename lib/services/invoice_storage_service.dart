import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/invoice_model.dart';

class InvoiceStorageService {
  static const String _invoicesKey = 'saved_invoices';

  static Future<List<InvoiceModel>> getInvoices() async {
    final prefs = await SharedPreferences.getInstance();

    final invoicesJson = prefs.getStringList(_invoicesKey);

    if (invoicesJson == null || invoicesJson.isEmpty) {
      return [];
    }

    return invoicesJson.map((invoiceJson) {
      final Map<String, dynamic> json =
      jsonDecode(invoiceJson);

      return InvoiceModel.fromJson(json);
    }).toList();
  }

  static Future<void> saveInvoice(
      InvoiceModel invoice,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final invoices = await getInvoices();

    invoices.insert(0, invoice);

    final invoicesJson = invoices.map((invoice) {
      return jsonEncode(invoice.toJson());
    }).toList();

    await prefs.setStringList(
      _invoicesKey,
      invoicesJson,
    );
  }

  static Future<void> deleteInvoice(
      String invoiceNumber,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final invoices = await getInvoices();

    invoices.removeWhere(
          (invoice) =>
      invoice.invoiceNumber == invoiceNumber,
    );

    final invoicesJson = invoices.map((invoice) {
      return jsonEncode(invoice.toJson());
    }).toList();

    await prefs.setStringList(
      _invoicesKey,
      invoicesJson,
    );
  }

  static Future<void> clearInvoices() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_invoicesKey);
  }
}