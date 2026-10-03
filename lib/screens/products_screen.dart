import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_storage_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];

  final TextEditingController searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadProducts();

    searchController.addListener(
      _filterProducts,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final savedProducts =
    await ProductStorageService.getProducts();

    if (!mounted) {
      return;
    }

    setState(() {
      products = savedProducts;
      filteredProducts = savedProducts;
    });
  }

  void _filterProducts() {
    final query =
    searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((product) {
          return product.name
              .toLowerCase()
              .contains(query) ||
              product.description
                  .toLowerCase()
                  .contains(query);
        }).toList();
      }
    });
  }

  Future<void> _showAddProductDialog() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Add Product / Service',
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(
                        Icons.inventory_2_outlined,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Enter product name';
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
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixIcon: Icon(
                        Icons.attach_money,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Enter price';
                      }

                      final price = double.tryParse(
                        value.trim(),
                      );

                      if (price == null || price < 0) {
                        return 'Enter a valid price';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(
                        Icons.description_outlined,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final product = ProductModel(
                  id: DateTime.now()
                      .millisecondsSinceEpoch
                      .toString(),
                  name: nameController.text.trim(),
                  price: double.parse(
                    priceController.text.trim(),
                  ),
                  description:
                  descriptionController.text.trim(),
                );

                await ProductStorageService.saveProduct(
                  product,
                );

                if (!mounted) {
                  return;
                }

                Navigator.pop(dialogContext);

                await _loadProducts();
              },
              child: const Text(
                'Save',
              ),
            ),
          ],
        );
      },
    );

    // Dialog ko completely remove hone ka time dete hain.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nameController.dispose();
      priceController.dispose();
      descriptionController.dispose();
    });
  }

  Future<void> _deleteProduct(
      ProductModel product,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Product?',
          ),
          content: Text(
            'Are you sure you want to delete '
                '${product.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
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

    await ProductStorageService.deleteProduct(
      product.id,
    );

    await _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products & Services',
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
                hintText:
                'Search products or services...',
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
            child: filteredProducts.isEmpty
                ? const _EmptyProducts()
                : ListView.builder(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              itemCount:
              filteredProducts.length,
              itemBuilder: (
                  context,
                  index,
                  ) {
                final product =
                filteredProducts[index];

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
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration:
                      BoxDecoration(
                        color: Colors.indigo
                            .withValues(
                          alpha: 0.1,
                        ),
                        borderRadius:
                        BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.indigo,
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    subtitle:
                    product.description
                        .isNotEmpty
                        ? Padding(
                      padding:
                      const EdgeInsets
                          .only(
                        top: 4,
                      ),
                      child: Text(
                        product
                            .description,
                        maxLines: 2,
                        overflow:
                        TextOverflow
                            .ellipsis,
                      ),
                    )
                        : null,
                    trailing: Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Text(
                          product.price
                              .toStringAsFixed(
                            2,
                          ),
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _deleteProduct(
                              product,
                            );
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
          ),
        ],
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        icon: const Icon(
          Icons.add_box_outlined,
        ),
        label: const Text(
          'Add Product',
        ),
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

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
              Icons.inventory_2_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No products yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your products or services to use them later.',
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