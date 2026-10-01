import 'invoice_item_model.dart';

class InvoiceModel {
  final String invoiceNumber;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String currency;
  final String notes;
  final List<InvoiceItem> items;
  final double discount;

  InvoiceModel({
    required this.invoiceNumber,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.invoiceDate,
    required this.dueDate,
    required this.currency,
    required this.notes,
    required this.items,
    required this.discount,
  });

  double get subtotal {
    return items.fold(
      0,
          (sum, item) => sum + item.total,
    );
  }

  double get total {
    final result = subtotal - discount;
    return result < 0 ? 0 : result;
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceNumber': invoiceNumber,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'invoiceDate': invoiceDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'currency': currency,
      'notes': notes,
      'discount': discount,
      'items': items.map((item) {
        return {
          'name': item.name,
          'quantity': item.quantity,
          'price': item.price,
        };
      }).toList(),
    };
  }

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invoiceNumber: json['invoiceNumber'] ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      invoiceDate: DateTime.parse(
        json['invoiceDate'],
      ),
      dueDate: DateTime.parse(
        json['dueDate'],
      ),
      currency: json['currency'] ?? 'USD',
      notes: json['notes'] ?? '',
      discount: (json['discount'] ?? 0).toDouble(),
      items: (json['items'] as List? ?? []).map((item) {
        return InvoiceItem(
          name: item['name'] ?? '',
          quantity: (item['quantity'] ?? 0).toDouble(),
          price: (item['price'] ?? 0).toDouble(),
        );
      }).toList(),
    );
  }
}