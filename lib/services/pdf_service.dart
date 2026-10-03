import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/business_model.dart';
import '../models/invoice_model.dart';
import 'business_storage_service.dart';

class PdfService {
  static Future<Uint8List> generateInvoicePdf(
      InvoiceModel invoice,
      ) async {
    final pdf = pw.Document();

    final BusinessModel? business =
    await BusinessStorageService.getBusiness();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            // Business Information
            if (business != null) ...[
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.indigo,
                  borderRadius:
                  pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      business.businessName,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 20,
                        fontWeight:
                        pw.FontWeight.bold,
                      ),
                    ),
                    if (business.phone.isNotEmpty)
                      pw.Padding(
                        padding:
                        const pw.EdgeInsets.only(
                          top: 5,
                        ),
                        child: pw.Text(
                          business.phone,
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    if (business.email.isNotEmpty)
                      pw.Padding(
                        padding:
                        const pw.EdgeInsets.only(
                          top: 4,
                        ),
                        child: pw.Text(
                          business.email,
                          style:
                          const pw.TextStyle(
                            color:
                            PdfColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    if (business.address.isNotEmpty)
                      pw.Padding(
                        padding:
                        const pw.EdgeInsets.only(
                          top: 4,
                        ),
                        child: pw.Text(
                          business.address,
                          style:
                          const pw.TextStyle(
                            color:
                            PdfColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
            ],

            // Invoice Header
            pw.Row(
              mainAxisAlignment:
              pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
              pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight:
                        pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      invoice.invoiceNumber,
                      style:
                      const pw.TextStyle(
                        fontSize: 12,
                        color:
                        PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment:
                  pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Invoice Date',
                      style:
                      const pw.TextStyle(
                        fontSize: 10,
                        color:
                        PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      _formatDate(
                        invoice.invoiceDate,
                      ),
                      style: pw.TextStyle(
                        fontWeight:
                        pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Due Date',
                      style:
                      const pw.TextStyle(
                        fontSize: 10,
                        color:
                        PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      _formatDate(
                        invoice.dueDate,
                      ),
                      style: pw.TextStyle(
                        fontWeight:
                        pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // Customer
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius:
                pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment:
                pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Bill To',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight:
                      pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    invoice.customerName,
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight:
                      pw.FontWeight.bold,
                    ),
                  ),
                  if (invoice.customerEmail
                      .isNotEmpty)
                    pw.Padding(
                      padding:
                      const pw.EdgeInsets.only(
                        top: 4,
                      ),
                      child: pw.Text(
                        invoice.customerEmail,
                        style:
                        const pw.TextStyle(
                          fontSize: 10,
                          color:
                          PdfColors.grey700,
                        ),
                      ),
                    ),
                  if (invoice.customerPhone
                      .isNotEmpty)
                    pw.Padding(
                      padding:
                      const pw.EdgeInsets.only(
                        top: 4,
                      ),
                      child: pw.Text(
                        invoice.customerPhone,
                        style:
                        const pw.TextStyle(
                          fontSize: 10,
                          color:
                          PdfColors.grey700,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Items
            pw.TableHelper.fromTextArray(
              headers: [
                'Item',
                'Quantity',
                'Price',
                'Total',
              ],
              data: invoice.items.map((item) {
                return [
                  item.name,
                  item.quantity.toString(),
                  '${invoice.currency} '
                      '${item.price.toStringAsFixed(2)}',
                  '${invoice.currency} '
                      '${item.total.toStringAsFixed(2)}',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontWeight:
                pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration:
              const pw.BoxDecoration(
                color: PdfColors.indigo,
              ),
              cellStyle:
              const pw.TextStyle(
                fontSize: 10,
              ),
              cellPadding:
              const pw.EdgeInsets.all(8),
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1.2),
                2: const pw.FlexColumnWidth(1.8),
                3: const pw.FlexColumnWidth(1.8),
              },
            ),

            pw.SizedBox(height: 24),

            // Summary
            pw.Align(
              alignment:
              pw.Alignment.centerRight,
              child: pw.Container(
                width: 220,
                padding:
                const pw.EdgeInsets.all(14),
                child: pw.Column(
                  children: [
                    _summaryRow(
                      'Subtotal',
                      '${invoice.currency} '
                          '${invoice.subtotal.toStringAsFixed(2)}',
                    ),
                    pw.SizedBox(height: 8),
                    _summaryRow(
                      'Discount',
                      '-${invoice.currency} '
                          '${invoice.discount.toStringAsFixed(2)}',
                    ),
                    pw.Divider(),
                    _summaryRow(
                      'Total',
                      '${invoice.currency} '
                          '${invoice.total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            // Notes
            if (invoice.notes.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text(
                'Notes',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                invoice.notes,
                style:
                const pw.TextStyle(
                  fontSize: 10,
                  color:
                  PdfColors.grey700,
                ),
              ),
            ],

            pw.SizedBox(height: 30),

            pw.Divider(),

            pw.SizedBox(height: 8),

            pw.Center(
              child: pw.Text(
                'Thank you for your business!',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static Future<String> saveInvoicePdf(
      InvoiceModel invoice,
      ) async {
    final pdfBytes =
    await generateInvoicePdf(invoice);

    final directory =
    await getApplicationDocumentsDirectory();

    final fileName =
        '${invoice.invoiceNumber.replaceAll(' ', '_')}.pdf';

    final file = File(
      '${directory.path}/$fileName',
    );

    await file.writeAsBytes(pdfBytes);

    return file.path;
  }

  static pw.Widget _summaryRow(
      String title,
      String value, {
        bool isTotal = false,
      }) {
    return pw.Row(
      mainAxisAlignment:
      pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: isTotal ? 13 : 10,
            fontWeight: isTotal
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isTotal ? 14 : 10,
            fontWeight:
            pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}