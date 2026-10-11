
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart' show Color;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/Invoice Template Model/invoice_template_model.dart';
import '../models/business_model.dart';
import '../models/invoice_model.dart';
import 'Invoice Template Storage Service/invoice_template_storage_service.dart';
import 'business_storage_service.dart';

class PdfService {
  static Future<Uint8List> generateInvoicePdf(
      InvoiceModel invoice,
      ) async {
    final pdf = pw.Document();

    final BusinessModel? business =
    await BusinessStorageService.getBusiness();

    final InvoiceTemplateModel template = await InvoiceTemplateStorageService
        .getSelectedTemplate();

    final primaryColor = _toPdfColor(
      template.primaryColor,
    );

    final accentColor = _toPdfColor(
      template.accentColor,
    );

    final backgroundColor = _toPdfColor(
      template.backgroundColor,
    );

    pw.MemoryImage? logoImage;

    if (business?.logoPath != null &&
        business!.logoPath!.isNotEmpty) {
      final logoFile = File(business.logoPath!);

      if (await logoFile.exists()) {
        final logoBytes = await logoFile.readAsBytes();
        logoImage = pw.MemoryImage(logoBytes);
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            // Business information and logo
            if (business != null) ...[
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius:
                  pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
                  children: [
                    if (logoImage != null) ...[
                      pw.Container(
                        width: 70,
                        height: 70,
                        padding:
                        const pw.EdgeInsets.all(5),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius:
                          pw.BorderRadius.circular(6),
                        ),
                        child: pw.Image(
                          logoImage,
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                      pw.SizedBox(width: 14),
                    ],
                    pw.Expanded(
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
                            _businessDetail(
                              business.phone,
                            ),
                          if (business.email.isNotEmpty)
                            _businessDetail(
                              business.email,
                            ),
                          if (business.address.isNotEmpty)
                            _businessDetail(
                              business.address,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
            ],

            // Invoice heading and dates
            pw.Container(
              padding: const pw.EdgeInsets.only(
                bottom: 12,
              ),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: accentColor,
                    width: 2,
                  ),
                ),
              ),
              child: pw.Row(
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
                          color: primaryColor,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        invoice.invoiceNumber,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding:
                        const pw.EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: pw.BoxDecoration(
                          color: backgroundColor,
                          borderRadius:
                          pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          'Status: ${invoice.status}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: primaryColor,
                            fontWeight:
                            pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment:
                    pw.CrossAxisAlignment.end,
                    children: [
                      _dateLabel('Invoice Date'),
                      pw.Text(
                        _formatDate(invoice.invoiceDate),
                        style: pw.TextStyle(
                          fontWeight:
                          pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      _dateLabel('Due Date'),
                      pw.Text(
                        _formatDate(invoice.dueDate),
                        style: pw.TextStyle(
                          fontWeight:
                          pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Customer information
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: backgroundColor,
                borderRadius:
                pw.BorderRadius.circular(8),
                border: pw.Border.all(
                  color: accentColor,
                  width: 0.8,
                ),
              ),
              child: pw.Column(
                crossAxisAlignment:
                pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'BILL TO',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    invoice.customerName,
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (invoice.customerEmail.isNotEmpty)
                    _customerDetail(
                      invoice.customerEmail,
                    ),
                  if (invoice.customerPhone.isNotEmpty)
                    _customerDetail(
                      invoice.customerPhone,
                    ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Invoice items table
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
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 10,
              ),
              headerDecoration: pw.BoxDecoration(
                color: primaryColor,
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey800,
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

            // Invoice totals
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 230,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: backgroundColor,
                  borderRadius:
                  pw.BorderRadius.circular(8),
                  border: pw.Border.all(
                    color: accentColor,
                    width: 0.8,
                  ),
                ),
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
                    pw.SizedBox(height: 4),
                    pw.Divider(
                      color: accentColor,
                    ),
                    pw.SizedBox(height: 4),
                    _summaryRow(
                      'Total',
                      '${invoice.currency} '
                          '${invoice.total.toStringAsFixed(2)}',
                      isTotal: true,
                      totalColor: primaryColor,
                    ),
                  ],
                ),
              ),
            ),

            // Notes
            if (invoice.notes.isNotEmpty) ...[
              pw.SizedBox(height: 24),
              pw.Text(
                'NOTES',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                invoice.notes,
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ],

            pw.SizedBox(height: 30),
            pw.Divider(
              color: accentColor,
            ),
            pw.SizedBox(height: 8),

            pw.Center(
              child: pw.Text(
                'Thank you for your business!',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _businessDetail(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          color: PdfColors.white,
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.Widget _customerDetail(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey700,
        ),
      ),
    );
  }

  static pw.Widget _dateLabel(String text) {
    return pw.Text(
      text,
      style: const pw.TextStyle(
        fontSize: 10,
        color: PdfColors.grey700,
      ),
    );
  }

  static pw.Widget _summaryRow(
      String title,
      String value, {
        bool isTotal = false,
        PdfColor? totalColor,
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
            color: isTotal
                ? (totalColor ?? PdfColors.black)
                : PdfColors.grey800,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isTotal ? 14 : 10,
            fontWeight: pw.FontWeight.bold,
            color: isTotal
                ? (totalColor ?? PdfColors.black)
                : PdfColors.grey800,
          ),
        ),
      ],
    );
  }

  static PdfColor _toPdfColor(Color color) {
    return PdfColor(
      color.red / 255.0,
      color.green / 255.0,
      color.blue / 255.0,
    );
  }

  static Future<String> saveInvoicePdf(
      InvoiceModel invoice,
      ) async {
    final pdfBytes = await generateInvoicePdf(invoice);

    final directory =
    await getApplicationDocumentsDirectory();

    final fileName =
        '${invoice.invoiceNumber.replaceAll(' ', '_')}.pdf';

    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(
      pdfBytes,
      flush: true,
    );

    return file.path;
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
