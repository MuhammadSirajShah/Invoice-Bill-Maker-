import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/business_model.dart';
import '../models/invoice_model.dart';
import '../services/business_storage_service.dart';
import '../services/pdf_service.dart';

class InvoicePreviewScreen extends StatefulWidget {
  final InvoiceModel invoice;

  const InvoicePreviewScreen({
    super.key,
    required this.invoice,
  });

  @override
  State<InvoicePreviewScreen> createState() =>
      _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState
    extends State<InvoicePreviewScreen> {
  BusinessModel? business;

  bool isLoadingBusiness = true;

  @override
  void initState() {
    super.initState();

    _loadBusiness();
  }

  Future<void> _loadBusiness() async {
    final savedBusiness =
    await BusinessStorageService.getBusiness();

    if (!mounted) {
      return;
    }

    setState(() {
      business = savedBusiness;
      isLoadingBusiness = false;
    });
  }

  Future<void> _generatePdf() async {
    try {
      final filePath =
      await PdfService.saveInvoicePdf(
        widget.invoice,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'PDF saved successfully.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to generate PDF: $e',
          ),
        ),
      );
    }
  }

  Future<void> _shareInvoice() async {
    try {
      final filePath =
      await PdfService.saveInvoicePdf(
        widget.invoice,
      );

      if (!mounted) {
        return;
      }

      final result =
      await SharePlus.instance.share(
        ShareParams(
          title: 'Share Invoice',
          subject:
          'Invoice ${widget.invoice.invoiceNumber}',
          text:
          'Invoice ${widget.invoice.invoiceNumber}',
          files: [
            XFile(filePath),
          ],
        ),
      );

      if (!mounted) {
        return;
      }

      if (result.status ==
          ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invoice shared successfully.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to share invoice: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invoice Preview',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoadingBusiness
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _BusinessSection(
              business: business,
            ),

            const SizedBox(height: 16),

            _InvoiceHeader(
              invoice: invoice,
            ),

            const SizedBox(height: 16),

            _CustomerSection(
              invoice: invoice,
            ),

            const SizedBox(height: 16),

            _ItemsSection(
              invoice: invoice,
            ),

            const SizedBox(height: 16),

            _SummarySection(
              invoice: invoice,
            ),

            if (invoice.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              _NotesSection(
                invoice: invoice,
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _generatePdf,
                icon: const Icon(
                  Icons.picture_as_pdf_outlined,
                ),
                label: const Text(
                  'Generate PDF',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: _shareInvoice,
                icon: const Icon(
                  Icons.share_outlined,
                ),
                label: const Text(
                  'Share Invoice',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _BusinessSection extends StatelessWidget {
  final BusinessModel? business;

  const _BusinessSection({
    required this.business,
  });

  @override
  Widget build(BuildContext context) {
    if (business == null) {
      return _SectionCard(
        title: 'Business Information',
        icon: Icons.business_outlined,
        child: const Text(
          'No business profile added yet.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }

    final hasPhone =
        business!.phone.isNotEmpty;

    final hasEmail =
        business!.email.isNotEmpty;

    final hasAddress =
        business!.address.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: 0.15),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Business Information',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            business!.businessName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (hasPhone) ...[
            const SizedBox(height: 10),
            _BusinessInfoRow(
              icon: Icons.phone_outlined,
              text: business!.phone,
            ),
          ],

          if (hasEmail) ...[
            const SizedBox(height: 8),
            _BusinessInfoRow(
              icon: Icons.email_outlined,
              text: business!.email,
            ),
          ],

          if (hasAddress) ...[
            const SizedBox(height: 8),
            _BusinessInfoRow(
              icon: Icons.location_on_outlined,
              text: business!.address,
            ),
          ],
        ],
      ),
    );
  }
}

class _BusinessInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BusinessInfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: Colors.white70,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _InvoiceHeader extends StatelessWidget {
  final InvoiceModel invoice;

  const _InvoiceHeader({
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 14),
          const Text(
            'INVOICE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            invoice.invoiceNumber,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerSection extends StatelessWidget {
  final InvoiceModel invoice;

  const _CustomerSection({
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Customer Information',
      icon: Icons.person_outline_rounded,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            invoice.customerName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (invoice.customerEmail.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.email_outlined,
              text: invoice.customerEmail,
            ),
          ],
          if (invoice.customerPhone.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.phone_outlined,
              text: invoice.customerPhone,
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateInfo(
                  title: 'Invoice Date',
                  date: _formatDate(
                    invoice.invoiceDate,
                  ),
                ),
              ),
              Expanded(
                child: _DateInfo(
                  title: 'Due Date',
                  date: _formatDate(
                    invoice.dueDate,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemsSection extends StatelessWidget {
  final InvoiceModel invoice;

  const _ItemsSection({
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Items',
      icon: Icons.shopping_bag_outlined,
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                flex: 3,
                child: Text(
                  'Item',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'Qty',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  'Total',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...invoice.items.map(
                (item) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.quantity.toString(),
                        textAlign:
                        TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${invoice.currency} '
                            '${item.total.toStringAsFixed(2)}',
                        textAlign:
                        TextAlign.end,
                        style: const TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final InvoiceModel invoice;

  const _SummarySection({
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Summary',
      icon: Icons.calculate_outlined,
      child: Column(
        children: [
          _SummaryRow(
            title: 'Subtotal',
            value:
            '${invoice.currency} '
                '${invoice.subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            title: 'Discount',
            value:
            '-${invoice.currency} '
                '${invoice.discount.toStringAsFixed(2)}',
          ),
          const Divider(height: 28),
          _SummaryRow(
            title: 'Total',
            value:
            '${invoice.currency} '
                '${invoice.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  final InvoiceModel invoice;

  const _NotesSection({
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Notes',
      icon: Icons.notes_outlined,
      child: Text(
        invoice.notes,
        style: TextStyle(
          color: Colors.grey.shade700,
          height: 1.5,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 21,
                color: Colors.indigo,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateInfo extends StatelessWidget {
  final String title;
  final String date;

  const _DateInfo({
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          date,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
            fontSize: isTotal ? 17 : 15,
            fontWeight: isTotal
                ? FontWeight.bold
                : FontWeight.normal,
            color: isTotal
                ? Colors.black
                : Colors.grey.shade700,
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

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}