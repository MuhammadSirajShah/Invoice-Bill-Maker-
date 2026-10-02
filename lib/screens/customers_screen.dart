import 'package:flutter/material.dart';

import '../models/customer_model.dart';
import '../services/customer_storage_service.dart';
import 'add_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() =>
      _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<CustomerModel> customers = [];
  List<CustomerModel> filteredCustomers = [];

  final TextEditingController searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadCustomers();

    searchController.addListener(
      _filterCustomers,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    final savedCustomers =
    await CustomerStorageService.getCustomers();

    if (!mounted) {
      return;
    }

    setState(() {
      customers = savedCustomers;
      filteredCustomers = savedCustomers;
    });
  }

  void _filterCustomers() {
    final query =
    searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredCustomers = customers;
      } else {
        filteredCustomers = customers.where((customer) {
          return customer.name
              .toLowerCase()
              .contains(query) ||
              customer.email
                  .toLowerCase()
                  .contains(query) ||
              customer.phone
                  .toLowerCase()
                  .contains(query);
        }).toList();
      }
    });
  }

  Future<void> _addCustomer() async {
    final customer = await Navigator.push<CustomerModel>(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const AddCustomerScreen(),
      ),
    );

    if (customer == null) {
      return;
    }

    await CustomerStorageService.saveCustomer(
      customer,
    );

    await _loadCustomers();
  }

  Future<void> _deleteCustomer(
      CustomerModel customer,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Customer?',
          ),
          content: Text(
            'Are you sure you want to delete '
                '${customer.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await CustomerStorageService.deleteCustomer(
      customer.id,
    );

    await _loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(
                  Icons.search,
                ),
                suffixIcon:
                searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    searchController.clear();
                  },
                  icon: const Icon(
                    Icons.clear,
                  ),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          Expanded(
            child: filteredCustomers.isEmpty
                ? const _EmptyCustomers()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              itemCount:
              filteredCustomers.length,
              itemBuilder: (
                  context,
                  index,
                  ) {
                final customer =
                filteredCustomers[index];

                return Card(
                  margin:
                  const EdgeInsets.only(
                    bottom: 12,
                  ),
                  elevation: 0,
                  child: ListTile(
                    contentPadding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 24,
                      child: Text(
                        customer.name
                            .trim()
                            .isNotEmpty
                            ? customer.name
                            .trim()[0]
                            .toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      customer.name,
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding:
                      const EdgeInsets.only(
                        top: 4,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          if (customer
                              .email
                              .isNotEmpty)
                            Text(
                              customer.email,
                            ),
                          if (customer
                              .phone
                              .isNotEmpty)
                            Text(
                              customer.phone,
                            ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        _deleteCustomer(
                          customer,
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCustomer,
        icon: const Icon(
          Icons.person_add,
        ),
        label: const Text(
          'Add Customer',
        ),
      ),
    );
  }
}

class _EmptyCustomers extends StatelessWidget {
  const _EmptyCustomers();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No customers yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first customer to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}