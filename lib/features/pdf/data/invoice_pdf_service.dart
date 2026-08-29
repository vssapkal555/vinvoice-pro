import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/database/app_database.dart';
import '../../../core/utils/money_utils.dart';

class InvoicePdfService {
  const InvoicePdfService._();

  static Future<Uint8List> buildPdf({
    required Invoice invoice,
    required List<InvoiceItem> items,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final document = pw.Document(
      title: invoice.invoiceNumber,
      author: invoice.companyNameSnapshot,
      subject: 'Tax Invoice',
      creator: 'VInvoice Pro',
    );

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(28),
          buildBackground: (context) {
            return _buildStatusWatermark(invoice);
          },
        ),
        header: (context) => _buildHeader(invoice),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 8),
          _invoiceTitle(),
          pw.SizedBox(height: 14),
          _partyAndInvoiceDetails(invoice),
          pw.SizedBox(height: 18),
          _itemsTable(items),
          pw.SizedBox(height: 16),
          _taxSummary(invoice),
          pw.SizedBox(height: 16),
          _amountInWords(invoice),
          pw.SizedBox(height: 20),
          _declaration(invoice),
        ],
      ),
    );

    return document.save();
  }

  static pw.Widget _buildHeader(Invoice invoice) {
    final companyAddress = _joinNonEmpty([
      invoice.companyAddress1Snapshot,
      invoice.companyAddress2Snapshot,
      invoice.companyAddress3Snapshot,
    ]);

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 1.2)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  invoice.companyNameSnapshot,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (companyAddress.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    companyAddress,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
                if (_hasValue(invoice.companyGstinSnapshot))
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 3),
                    child: pw.Text(
                      'GSTIN: ${invoice.companyGstinSnapshot}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                if (_hasValue(invoice.companyPanSnapshot))
                  pw.Text(
                    'PAN: ${invoice.companyPanSnapshot}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _invoiceTitle() {
    return pw.Center(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
        child: pw.Text(
          'TAX INVOICE',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
      ),
    );
  }

  static pw.Widget _partyAndInvoiceDetails(Invoice invoice) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.7),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.25),
        1: pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(children: [_partyBox(invoice), _invoiceInfoBox(invoice)]),
      ],
    );
  }

  static pw.Widget _partyBox(Invoice invoice) {
    final partyAddress = _joinNonEmpty([
      invoice.partyAddress1Snapshot,
      invoice.partyAddress2Snapshot,
      invoice.partyAddress3Snapshot,
    ]);

    return pw.Padding(
      padding: const pw.EdgeInsets.all(9),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Bill To / Party',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            invoice.partyNameSnapshot,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          if (partyAddress.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(partyAddress, style: const pw.TextStyle(fontSize: 8.5)),
          ],
          if (_hasValue(invoice.partyGstinSnapshot))
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(
                'GSTIN: ${invoice.partyGstinSnapshot}',
                style: const pw.TextStyle(fontSize: 8.5),
              ),
            ),
          if (_hasValue(invoice.partyPanSnapshot))
            pw.Text(
              'PAN: ${invoice.partyPanSnapshot}',
              style: const pw.TextStyle(fontSize: 8.5),
            ),
        ],
      ),
    );
  }

  static pw.Widget _invoiceInfoBox(Invoice invoice) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(9),
      child: pw.Column(
        children: [
          _infoRow('Invoice No.', invoice.invoiceNumber),
          _infoRow('Invoice Date', _formatDate(invoice.invoiceDate)),
          if (_hasValue(invoice.poNumber))
            _infoRow('PO No.', invoice.poNumber!),
          if (_hasValue(invoice.vendorCodeSnapshot))
            _infoRow('Vendor Code', invoice.vendorCodeSnapshot!),
          if (_hasValue(invoice.siteNameSnapshot))
            _infoRow('Site / Plant', invoice.siteNameSnapshot!),
          if (_hasValue(invoice.serviceEntry))
            _infoRow('Service Entry', invoice.serviceEntry!),
          if (invoice.serviceFrom != null)
            _infoRow('Service From', _formatDate(invoice.serviceFrom!)),
          if (invoice.serviceTo != null)
            _infoRow('Service To', _formatDate(invoice.serviceTo!)),
        ],
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 72,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 8)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _itemsTable(List<InvoiceItem> items) {
    final rows = <List<String>>[];

    for (final item in items) {
      rows.add([
        '${item.serialNo}',
        item.description,
        item.hsnSac ?? '',
        _formatQuantity(item.quantity),
        item.unitCodeSnapshot ?? '',
        _money(item.ratePaise),
        _money(item.amountPaise),
      ]);
    }

    if (rows.isEmpty) {
      rows.add(['', 'No items', '', '', '', '', '']);
    }

    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(width: 0.6),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(fontSize: 7.5),
      cellPadding: const pw.EdgeInsets.all(5),
      columnWidths: const {
        0: pw.FixedColumnWidth(24),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(1),
        3: pw.FixedColumnWidth(34),
        4: pw.FixedColumnWidth(38),
        5: pw.FlexColumnWidth(1),
        6: pw.FlexColumnWidth(1.15),
      },
      headers: const [
        'Sr.',
        'Description of Service',
        'HSN/SAC',
        'QTY',
        'UNIT',
        'RATE',
        'AMOUNT',
      ],
      data: rows,
      cellAlignments: const {
        0: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.center,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _taxSummary(Invoice invoice) {
    final rows = <pw.Widget>[
      _summaryRow('Basic Amount', _money(invoice.basicAmountPaise)),
    ];

    if (invoice.taxType == 'taxable') {
      rows.add(
        _summaryRow('Taxable Amount', _money(invoice.taxableAmountPaise)),
      );

      if (invoice.gstMode == 'cgstSgst') {
        rows.add(
          _summaryRow(
            'CGST @ ${_formatRate(invoice.cgstRate)}%',
            _money(invoice.cgstAmountPaise),
          ),
        );

        rows.add(
          _summaryRow(
            'SGST @ ${_formatRate(invoice.sgstRate)}%',
            _money(invoice.sgstAmountPaise),
          ),
        );
      }

      if (invoice.gstMode == 'igst') {
        rows.add(
          _summaryRow(
            'IGST @ ${_formatRate(invoice.igstRate)}%',
            _money(invoice.igstAmountPaise),
          ),
        );
      }
    }

    rows.add(
      pw.Container(
        margin: const pw.EdgeInsets.only(top: 5),
        padding: const pw.EdgeInsets.only(top: 6),
        decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(width: 1)),
        ),
        child: _summaryRow(
          'GRAND TOTAL',
          _money(invoice.grandTotalPaise),
          bold: true,
        ),
      ),
    );

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: pw.Container()),
        pw.SizedBox(
          width: 235,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.8)),
            child: pw.Column(children: rows),
          ),
        ),
      ],
    );
  }

  static pw.Widget _summaryRow(
    String label,
    String amount, {
    bool bold = false,
  }) {
    final style = pw.TextStyle(
      fontSize: bold ? 10 : 8.5,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(label, style: style)),
          pw.SizedBox(width: 12),
          pw.Text(amount, style: style),
        ],
      ),
    );
  }

  static pw.Widget _amountInWords(Invoice invoice) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(9),
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.7)),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: 'Amount in Words: ',
              style: pw.TextStyle(
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.TextSpan(
              text: invoice.amountInWords ?? '',
              style: const pw.TextStyle(fontSize: 8.5),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _declaration(Invoice invoice) {
    final taxType = invoice.taxType == 'nonTaxable'
        ? 'Non-Taxable'
        : invoice.gstMode == 'igst'
        ? 'Taxable - IGST'
        : 'Taxable - CGST + SGST';

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Tax Type: $taxType',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'This is a computer-generated invoice.',
                style: const pw.TextStyle(
                  fontSize: 7.5,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 30),
        pw.SizedBox(
          width: 170,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'For ${invoice.companyNameSnapshot}',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 45),
              pw.Container(
                width: double.infinity,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(width: 0.6)),
                ),
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  'Authorised Signatory',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(width: 0.5, color: PdfColors.grey600),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              'Generated by VInvoice Pro',
              style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static String _money(int paise) {
    final value = MoneyUtils.paiseToRupees(paise);

    return 'INR ${_formatIndianNumber(value)}';
  }

  static String _formatIndianNumber(double value) {
    final fixed = value.toStringAsFixed(2);

    final parts = fixed.split('.');

    var whole = parts[0];
    final decimal = parts[1];

    final negative = whole.startsWith('-');

    if (negative) {
      whole = whole.substring(1);
    }

    if (whole.length > 3) {
      final lastThree = whole.substring(whole.length - 3);

      var remaining = whole.substring(0, whole.length - 3);

      final groups = <String>[];

      while (remaining.length > 2) {
        groups.insert(0, remaining.substring(remaining.length - 2));

        remaining = remaining.substring(0, remaining.length - 2);
      }

      if (remaining.isNotEmpty) {
        groups.insert(0, remaining);
      }

      whole = '${groups.join(',')},$lastThree';
    }

    return '${negative ? '-' : ''}$whole.$decimal';
  }

  static String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  static String _formatRate(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  static String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');

    final month = value.month.toString().padLeft(2, '0');

    return '$day-$month-${value.year}';
  }

  static pw.Widget _buildStatusWatermark(Invoice invoice) {
    final status = invoice.status.toLowerCase();

    if (status == 'issued') {
      return pw.SizedBox();
    }

    final text = switch (status) {
      'cancelled' => 'CANCELLED',
      'draft' => 'DRAFT',
      _ => status.toUpperCase(),
    };

    return pw.FullPage(
      ignoreMargins: true,
      child: pw.Center(
        child: pw.Transform.rotate(
          angle: -0.55,
          child: pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 70,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey300,
            ),
          ),
        ),
      ),
    );
  }

  static String _joinNonEmpty(Iterable<String?> values) {
    final output = <String>[];
    final seen = <String>{};

    for (final value in values) {
      if (value == null) {
        continue;
      }

      final raw = value.trim();

      if (raw.isEmpty) {
        continue;
      }

      for (final piece in raw.split(',')) {
        final clean = piece.trim();

        if (clean.isEmpty) {
          continue;
        }

        final normalized = clean.toLowerCase();

        if (seen.add(normalized)) {
          output.add(clean);
        }
      }
    }

    return output.join(', ');
  }

  static bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
