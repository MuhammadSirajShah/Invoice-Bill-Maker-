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
}