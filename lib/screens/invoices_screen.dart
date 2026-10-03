import 'package:flutter/material.dart';

import '../models/invoice_model.dart';
import '../services/invoice_storage_service.dart';
import 'invoice_preview_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() =>
      _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  List<InvoiceModel> invoices = [];
  List<InvoiceModel> filteredInvoices = [];

  final TextEditingController searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadInvoices();

    searchController.addListener(
      _filterInvoices,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    final savedInvoices =
    await InvoiceStorageService.getInvoices();

    if (!mounted) {
      return;
    }

    setState(() {
      invoices = savedInvoices;
      filteredInvoices = savedInvoices;
    });
  }

  void _filterInvoices() {
    final query =
    searchController.text.trim().toLowerCase();

    if (!mounted) {
      return;
    }

    setState(() {
      if (query.isEmpty) {
        filteredInvoices = invoices;
      } else {
        filteredInvoices = invoices.where((invoice) {
          return invoice.invoiceNumber
              .toLowerCase()
              .contains(query) ||
              invoice.customerName
                  .toLowerCase()
                  .contains(query);
        }).toList();
      }
    });
  }

  Future<void> _changeInvoiceStatus(
      InvoiceModel invoice,
      ) async {
    final newStatus =
    invoice.status == 'Paid' ? 'Pending' : 'Paid';

    await InvoiceStorageService.updateInvoiceStatus(
      invoice.invoiceNumber,
      newStatus,
    );

    await _loadInvoices();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus == 'Paid'
              ? 'Invoice marked as Paid.'
              : 'Invoice marked as Pending.',
        ),
      ),
    );
  }

  Future<void> _deleteInvoice(
      InvoiceModel invoice,
      ) async {
    await InvoiceStorageService.deleteInvoice(
      invoice.invoiceNumber,
    );

    await _loadInvoices();
  }

  Future<void> _showInvoiceOptions(
      InvoiceModel invoice,
      ) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        final isPaid = invoice.status == 'Paid';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    isPaid
                        ? Icons.pending_actions
                        : Icons.check_circle_outline,
                  ),
                  title: Text(
                    isPaid
                        ? 'Mark as Pending'
                        : 'Mark as Paid',
                  ),
                  onTap: () async {
                    Navigator.pop(context);

                    await _changeInvoiceStatus(
                      invoice,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Delete Invoice',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);

                    await _deleteInvoice(
                      invoice,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invoices',
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
                'Search invoice or customer...',
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

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filteredInvoices.length} Invoice(s)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: filteredInvoices.isEmpty
                ? const _EmptyInvoiceHistory()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount:
              filteredInvoices.length,
              itemBuilder: (
                  context,
                  index,
                  ) {
                final invoice =
                filteredInvoices[index];

                final isPaid =
                    invoice.status == 'Paid';

                return Dismissible(
                  key: ValueKey(
                    invoice.invoiceNumber,
                  ),
                  direction:
                  DismissDirection.endToStart,
                  background: Container(
                    margin:
                    const EdgeInsets.only(
                      bottom: 12,
                    ),
                    padding:
                    const EdgeInsets.only(
                      right: 20,
                    ),
                    alignment:
                    Alignment.centerRight,
                    decoration:
                    BoxDecoration(
                      color: Colors.red,
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            'Delete Invoice?',
                          ),
                          content: Text(
                            'Are you sure you want to delete '
                                '${invoice.invoiceNumber}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                  false,
                                );
                              },
                              child:
                              const Text(
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
                              child:
                              const Text(
                                'Delete',
                                style:
                                TextStyle(
                                  color:
                                  Colors.red,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ) ??
                        false;
                  },
                  onDismissed: (_) {
                    _deleteInvoice(invoice);
                  },
                  child: Card(
                    margin:
                    const EdgeInsets.only(
                      bottom: 12,
                    ),
                    elevation: 0,
                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                InvoicePreviewScreen(
                                  invoice: invoice,
                                ),
                          ),
                        );
                      },
                      child: Padding(
                        padding:
                        const EdgeInsets.all(
                          14,
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .center,
                          children: [
                            // Invoice icon
                            Container(
                              width: 46,
                              height: 46,
                              decoration:
                              BoxDecoration(
                                color: Colors
                                    .indigo
                                    .withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  12,
                                ),
                              ),
                              child: const Icon(
                                Icons.receipt_long,
                                color:
                                Colors.indigo,
                              ),
                            ),

                            const SizedBox(
                              width: 14,
                            ),

                            // Invoice information
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                mainAxisSize:
                                MainAxisSize.min,
                                children: [
                                  Text(
                                    invoice
                                        .invoiceNumber,
                                    style:
                                    const TextStyle(
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    invoice
                                        .customerName,
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow
                                        .ellipsis,
                                    style:
                                    const TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  Row(
                                    children: [
                                      Container(
                                        padding:
                                        const EdgeInsets
                                            .symmetric(
                                          horizontal:
                                          8,
                                          vertical:
                                          4,
                                        ),
                                        decoration:
                                        BoxDecoration(
                                          color: isPaid
                                              ? Colors
                                              .green
                                              .withValues(
                                            alpha:
                                            0.1,
                                          )
                                              : Colors
                                              .orange
                                              .withValues(
                                            alpha:
                                            0.1,
                                          ),
                                          borderRadius:
                                          BorderRadius
                                              .circular(
                                            20,
                                          ),
                                        ),
                                        child:
                                        Text(
                                          invoice
                                              .status,
                                          style:
                                          TextStyle(
                                            color: isPaid
                                                ? Colors
                                                .green
                                                : Colors
                                                .orange,
                                            fontSize:
                                            11,
                                            fontWeight:
                                            FontWeight
                                                .bold,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 8,
                                      ),

                                      Flexible(
                                        child:
                                        Text(
                                          _formatDate(
                                            invoice
                                                .invoiceDate,
                                          ),
                                          style:
                                          const TextStyle(
                                            color:
                                            Colors.grey,
                                            fontSize:
                                            12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            // Amount + menu
                            Column(
                              mainAxisSize:
                              MainAxisSize.min,
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .end,
                              children: [
                                Text(
                                  '${invoice.currency} '
                                      '${invoice.total.toStringAsFixed(2)}',
                                  style:
                                  const TextStyle(
                                    fontWeight:
                                    FontWeight
                                        .bold,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(
                                  height: 4,
                                ),

                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child:
                                  IconButton(
                                    padding:
                                    EdgeInsets
                                        .zero,
                                    constraints:
                                    const BoxConstraints(),
                                    visualDensity:
                                    VisualDensity
                                        .compact,
                                    onPressed: () {
                                      _showInvoiceOptions(
                                        invoice,
                                      );
                                    },
                                    icon:
                                    const Icon(
                                      Icons
                                          .more_vert,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyInvoiceHistory
    extends StatelessWidget {
  const _EmptyInvoiceHistory();

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
              Icons.receipt_long_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No invoices found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your saved invoices will appear here.',
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