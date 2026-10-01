class InvoiceItem {
  final String name;
  final double quantity;
  final double price;

  InvoiceItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;
}