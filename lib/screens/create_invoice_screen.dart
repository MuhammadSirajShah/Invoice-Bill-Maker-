import 'package:flutter/material.dart';

import '../models/customer_model.dart';
import '../models/invoice_item_model.dart';
import '../models/invoice_model.dart';
import '../services/customer_storage_service.dart';
import '../services/invoice_storage_service.dart';
import 'invoice_preview_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() =>
      _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState
    extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final invoiceNumberController =
  TextEditingController();

  final customerNameController =
  TextEditingController();

  final customerEmailController =
  TextEditingController();

  final customerPhoneController =
  TextEditingController();

  final notesController =
  TextEditingController();

  final discountController =
  TextEditingController(text: '0');

  DateTime invoiceDate = DateTime.now();

  DateTime dueDate =
  DateTime.now().add(const Duration(days: 7));

  String selectedCurrency = 'USD';

  List<InvoiceItem> items = [];

  List<CustomerModel> savedCustomers = [];

  @override
  void initState() {
    super.initState();

    _loadCustomers();
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

  Future<void> _loadCustomers() async {
    final customers =
    await CustomerStorageService.getCustomers();

    if (!mounted) {
      return;
    }

    setState(() {
      savedCustomers = customers;
    });
  }

  double get subtotal {
    return items.fold(
      0,
          (sum, item) => sum + item.total,
    );
  }

  double get discount {
    return double.tryParse(
      discountController.text.trim(),
    ) ??
        0;
  }

  double get total {
    final result = subtotal - discount;

    return result < 0 ? 0 : result;
  }

  Future<void> _selectCustomer() async {
    final customer =
    await showModalBottomSheet<CustomerModel>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              shrinkWrap: true,
              children: [
                const Text(
                  'Select Customer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                ...savedCustomers.map(
                      (customer) {
                    return ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        child: Text(
                          customer.name
                              .trim()
                              .isNotEmpty
                              ? customer.name
                              .trim()[0]
                              .toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(
                        customer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        customer.email.isNotEmpty
                            ? customer.email
                            : customer.phone,
                      ),
                      onTap: () {
                        Navigator.pop(
                          context,
                          customer,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (customer == null) {
      return;
    }

    setState(() {
      customerNameController.text =
          customer.name;

      customerEmailController.text =
          customer.email;

      customerPhoneController.text =
          customer.phone;
    });
  }

  Future<void> _selectInvoiceDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: invoiceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      invoiceDate = selectedDate;
    });
  }

  Future<void> _selectDueDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: dueDate,
      firstDate: invoiceDate,
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      dueDate = selectedDate;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _showItemDialog({
    InvoiceItem? existingItem,
    int? index,
  }) async {
    final nameController = TextEditingController(
      text: existingItem?.name ?? '',
    );

    final quantityController =
    TextEditingController(
      text: existingItem?.quantity
          .toString() ??
          '1',
    );

    final priceController =
    TextEditingController(
      text: existingItem?.price
          .toString() ??
          '',
    );

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            existingItem == null
                ? 'Add Item'
                : 'Edit Item',
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    textInputAction:
                    TextInputAction.next,
                    decoration:
                    const InputDecoration(
                      labelText: 'Item / Service Name',
                      prefixIcon: Icon(
                        Icons.inventory_2_outlined,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Enter item name';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller:
                    quantityController,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction:
                    TextInputAction.next,
                    decoration:
                    const InputDecoration(
                      labelText: 'Quantity',
                      prefixIcon: Icon(
                        Icons.numbers,
                      ),
                    ),
                    validator: (value) {
                      final quantity =
                      double.tryParse(
                        value?.trim() ?? '',
                      );

                      if (quantity == null ||
                          quantity <= 0) {
                        return 'Enter valid quantity';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: priceController,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                    const InputDecoration(
                      labelText: 'Price',
                      prefixIcon: Icon(
                        Icons.attach_money,
                      ),
                    ),
                    validator: (value) {
                      final price =
                      double.tryParse(
                        value?.trim() ?? '',
                      );

                      if (price == null ||
                          price < 0) {
                        return 'Enter valid price';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!
                    .validate()) {
                  return;
                }

                final item = InvoiceItem(
                  name: nameController.text.trim(),
                  quantity: double.parse(
                    quantityController.text.trim(),
                  ),
                  price: double.parse(
                    priceController.text.trim(),
                  ),
                );

                setState(() {
                  if (index != null) {
                    items[index] = item;
                  } else {
                    items.add(item);
                  }
                });

                Navigator.pop(context);
              },
              child: Text(
                existingItem == null
                    ? 'Add'
                    : 'Update',
              ),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
  }

  void _deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  Future<void> _generateInvoice() async {
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

    final invoice = InvoiceModel(
      invoiceNumber:
      invoiceNumberController.text.trim(),
      customerName:
      customerNameController.text.trim(),
      customerEmail:
      customerEmailController.text.trim(),
      customerPhone:
      customerPhoneController.text.trim(),
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
          builder: (context) =>
              InvoicePreviewScreen(
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Invoice Details
            const Text(
              'Invoice Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: invoiceNumberController,
              decoration: const InputDecoration(
                labelText: 'Invoice Number',
                prefixIcon: Icon(
                  Icons.receipt_long_outlined,
                ),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Enter invoice number';
                }

                return null;
              },
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Invoice Date',
                    value:
                    _formatDate(invoiceDate),
                    onTap: _selectInvoiceDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Due Date',
                    value:
                    _formatDate(dueDate),
                    onTap: _selectDueDate,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedCurrency,
              decoration:
              const InputDecoration(
                labelText: 'Currency',
                prefixIcon: Icon(
                  Icons.currency_exchange,
                ),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'USD',
                  child: Text('USD'),
                ),
                DropdownMenuItem(
                  value: 'EUR',
                  child: Text('EUR'),
                ),
                DropdownMenuItem(
                  value: 'GBP',
                  child: Text('GBP'),
                ),
                DropdownMenuItem(
                  value: 'PKR',
                  child: Text('PKR'),
                ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  selectedCurrency = value;
                });
              },
            ),

            const SizedBox(height: 28),

            // Customer Information
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customer Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (savedCustomers.isNotEmpty)
                  TextButton.icon(
                    onPressed: _selectCustomer,
                    icon: const Icon(
                      Icons.person_search,
                    ),
                    label: const Text(
                      'Select Saved',
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: customerNameController,
              textInputAction:
              TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Enter customer name';
                }

                return null;
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: customerEmailController,
              keyboardType:
              TextInputType.emailAddress,
              textInputAction:
              TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Customer Email',
                prefixIcon: Icon(
                  Icons.email_outlined,
                ),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: customerPhoneController,
              keyboardType:
              TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Customer Phone',
                prefixIcon: Icon(
                  Icons.phone_outlined,
                ),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 28),

            // Items
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Items / Services',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    _showItemDialog();
                  },
                  icon: const Icon(
                    Icons.add,
                  ),
                  label: const Text(
                    'Add Item',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (items.isEmpty)
              Card(
                elevation: 0,
                child: Padding(
                  padding:
                  const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons
                            .shopping_cart_outlined,
                        size: 48,
                        color:
                        Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No items added',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...items.asMap().entries.map(
                    (entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Card(
                    elevation: 0,
                    margin:
                    const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: ListTile(
                      title: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${item.quantity} × '
                            '${selectedCurrency} '
                            '${item.price.toStringAsFixed(2)}',
                      ),
                      trailing: Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: [
                          Text(
                            '$selectedCurrency '
                                '${item.total.toStringAsFixed(2)}',
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _showItemDialog(
                                existingItem:
                                item,
                                index: index,
                              );
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _deleteItem(index);
                            },
                            icon: const Icon(
                              Icons
                                  .delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),

            // Discount
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
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Discount',
                prefixText:
                '$selectedCurrency ',
                prefixIcon: const Icon(
                  Icons.discount_outlined,
                ),
                border:
                const OutlineInputBorder(),
              ),
              validator: (value) {
                final discountValue =
                double.tryParse(
                  value?.trim() ?? '',
                );

                if (discountValue == null ||
                    discountValue < 0) {
                  return 'Enter valid discount';
                }

                return null;
              },
            ),

            const SizedBox(height: 28),

            // Notes
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
                hintText:
                'Add notes or payment terms...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 28),

            // Invoice Summary
            Card(
              elevation: 0,
              child: Padding(
                padding:
                const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Align(
                      alignment:
                      Alignment.centerLeft,
                      child: Text(
                        'Invoice Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _SummaryRow(
                      title: 'Subtotal',
                      value:
                      '$selectedCurrency '
                          '${subtotal.toStringAsFixed(2)}',
                    ),

                    const SizedBox(height: 10),

                    _SummaryRow(
                      title: 'Discount',
                      value:
                      '-$selectedCurrency '
                          '${discount.toStringAsFixed(2)}',
                    ),

                    const Divider(
                      height: 24,
                    ),

                    _SummaryRow(
                      title: 'Total',
                      value:
                      '$selectedCurrency '
                          '${total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _generateInvoice,
                icon: const Icon(
                  Icons.receipt_long,
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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(
            Icons.calendar_today_outlined,
          ),
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
          ),
        ),
        child: Text(value),
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
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}