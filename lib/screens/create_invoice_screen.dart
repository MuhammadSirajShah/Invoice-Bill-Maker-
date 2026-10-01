import 'package:flutter/material.dart';
import '../models/invoice_item_model.dart';
import '../models/invoice_model.dart';
import '../services/invoice_storage_service.dart';
import 'invoice_preview_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController invoiceNumberController = TextEditingController();

  final TextEditingController customerNameController = TextEditingController();

  final TextEditingController customerEmailController = TextEditingController();

  final TextEditingController customerPhoneController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

  final TextEditingController discountController = TextEditingController(text: '0');

  DateTime invoiceDate = DateTime.now();

  DateTime dueDate = DateTime.now().add(
    const Duration(days: 7),
  );

  String selectedCurrency = 'USD';

  final List<InvoiceItem> items = [];

  double get subtotal {
    return items.fold(
      0,
          (sum, item) => sum + item.total,
    );
  }

  double get discount {
    return double.tryParse(discountController.text) ?? 0;
  }

  double get total {
    final result = subtotal - discount;
    return result < 0 ? 0 : result;
  }

  void addItem() {
    _showItemDialog();
  }

  void editItem(int index) {
    _showItemDialog(
      existingItem: items[index],
      index: index,
    );
  }

  void deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void _showItemDialog({
    InvoiceItem? existingItem,
    int? index,
  }) {
    final itemNameController = TextEditingController(
      text: existingItem?.name ?? '',
    );

    final quantityController = TextEditingController(
      text: existingItem?.quantity.toString() ?? '1',
    );

    final priceController = TextEditingController(
      text: existingItem?.price.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            existingItem == null ? 'Add Item' : 'Edit Item',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: itemNameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'e.g. Flutter App Development',
                    prefixIcon: Icon(
                      Icons.shopping_bag_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantityController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    prefixIcon: Icon(
                      Icons.numbers_rounded,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixIcon: Icon(
                      Icons.attach_money_rounded,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = itemNameController.text.trim();

                final quantity =
                    double.tryParse(quantityController.text) ?? 0;

                final price =
                    double.tryParse(priceController.text) ?? 0;

                if (name.isEmpty) {
                  return;
                }

                if (quantity <= 0 || price < 0) {
                  return;
                }

                final newItem = InvoiceItem(
                  name: name,
                  quantity: quantity,
                  price: price,
                );

                setState(() {
                  if (index == null) {
                    items.add(newItem);
                  } else {
                    items[index] = newItem;
                  }
                });

                Navigator.pop(dialogContext);
              },
              child: Text(
                existingItem == null ? 'Add' : 'Update',
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> selectInvoiceDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: invoiceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        invoiceDate = selectedDate;

        if (dueDate.isBefore(invoiceDate)) {
          dueDate = invoiceDate.add(
            const Duration(days: 7),
          );
        }
      });
    }
  }

  Future<void> selectDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: dueDate.isBefore(invoiceDate)
          ? invoiceDate
          : dueDate,
      firstDate: invoiceDate,
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        dueDate = selectedDate;
      });
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void generateInvoice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add at least one item.',
          ),
        ),
      );

      return;
    }

    final discount =
        double.tryParse(discountController.text.trim()) ?? 0;

    final invoice = InvoiceModel(
      invoiceNumber: invoiceNumberController.text.trim(),
      customerName: customerNameController.text.trim(),
      customerEmail: customerEmailController.text.trim(),
      customerPhone: customerPhoneController.text.trim(),
      invoiceDate: invoiceDate,
      dueDate: dueDate,
      currency: selectedCurrency,
      notes: notesController.text.trim(),
      items: List.from(items),
      discount: discount,
    );

    try {
      await InvoiceStorageService.saveInvoice(
        invoice,
      );

      if (!mounted) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InvoicePreviewScreen(
            invoice: invoice,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save invoice: $e',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    invoiceNumberController.dispose();
    customerNameController.dispose();
    customerEmailController.dispose();
    customerPhoneController.dispose();
    notesController.dispose();
    discountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Invoice',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Invoice Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: invoiceNumberController,
                decoration: const InputDecoration(
                  labelText: 'Invoice Number',
                  hintText: 'e.g. INV-001',
                  prefixIcon: Icon(
                    Icons.receipt_long_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter invoice number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      title: 'Invoice Date',
                      date: formatDate(invoiceDate),
                      icon: Icons.calendar_today_outlined,
                      onTap: selectInvoiceDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      title: 'Due Date',
                      date: formatDate(dueDate),
                      icon: Icons.event_outlined,
                      onTap: selectDueDate,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  prefixIcon: Icon(
                    Icons.currency_exchange_rounded,
                  ),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'USD',
                    child: Text('USD - US Dollar'),
                  ),
                  DropdownMenuItem(
                    value: 'EUR',
                    child: Text('EUR - Euro'),
                  ),
                  DropdownMenuItem(
                    value: 'GBP',
                    child: Text('GBP - British Pound'),
                  ),
                  DropdownMenuItem(
                    value: 'PKR',
                    child: Text('PKR - Pakistani Rupee'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCurrency = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 28),

              const Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  hintText: 'Enter customer name',
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: customerEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'customer@example.com',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: customerPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: 'Enter phone number',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: addItem,
                    icon: const Icon(
                      Icons.add_rounded,
                    ),
                    label: const Text('Add Item'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (items.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 45,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'No items added',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap "Add Item" to add a product or service.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

              if (items.isNotEmpty)
                ...List.generate(
                  items.length,
                      (index) {
                    final item = items[index];

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.indigo.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${item.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => editItem(index),
                            icon: const Icon(
                              Icons.edit_outlined,
                            ),
                          ),
                          IconButton(
                            onPressed: () => deleteItem(index),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 18),

              const Text(
                'Discount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: discountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) {
                  setState(() {});
                },
                decoration: const InputDecoration(
                  labelText: 'Discount',
                  hintText: '0',
                  prefixIcon: Icon(
                    Icons.discount_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Thank you for your business...',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(
                      bottom: 55,
                    ),
                    child: Icon(
                      Icons.notes_outlined,
                    ),
                  ),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Invoice Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      title: 'Subtotal',
                      value:
                      '$selectedCurrency ${subtotal.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      title: 'Discount',
                      value:
                      '-$selectedCurrency ${discount.toStringAsFixed(2)}',
                    ),
                    const Divider(
                      height: 24,
                    ),
                    _SummaryRow(
                      title: 'Total',
                      value:
                      '$selectedCurrency ${total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: generateInvoice,
                  icon: const Icon(
                    Icons.receipt_long_rounded,
                  ),
                  label: const Text(
                    'Generate Invoice',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final VoidCallback onTap;

  const _DateField({
    required this.title,
    required this.date,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: title,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          date,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 17 : 15,
            fontWeight:
            isTotal ? FontWeight.bold : FontWeight.normal,
            color:
            isTotal ? Colors.black : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 19 : 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}