import 'package:flutter/services.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/money_utils.dart';

class InvoicePdfService {
  const InvoicePdfService._();

  static const PdfColor _navy = PdfColor.fromInt(0xFF101828);
  static const PdfColor _blue = PdfColor.fromInt(0xFF2563EB);
  static const PdfColor _blueSoft = PdfColor.fromInt(0xFFEFF6FF);
  static const PdfColor _surfaceSoft = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor _border = PdfColor.fromInt(0xFFD8E0EA);
  static const PdfColor _muted = PdfColor.fromInt(0xFF64748B);

  static Future<Uint8List> buildPdf({
    required Invoice invoice,
    required List<InvoiceItem> items,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    bool includeCompanyHeader = true,
  }) async {
    final regularFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final appLogo = (await rootBundle.load(
      'assets/branding/vinvoice_pro_logo.png',
    )).buffer.asUint8List();
    final document = pw.Document(
      title: invoice.invoiceNumber,
      author: invoice.companyNameSnapshot,
      subject: 'Tax Invoice',
      creator: 'VInvoice Pro',
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
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
        header: (context) {
          if (includeCompanyHeader) {
            return _buildHeader(invoice);
          }
          return _buildPreprintedLetterheadSpace(context);
        },
        footer: (context) => _buildFooter(context, invoice, appLogo),
        build: (context) => [
          pw.SizedBox(height: 8),
          _invoiceTitle(),
          pw.SizedBox(height: 14),
          _partyAndInvoiceDetails(invoice),
          pw.SizedBox(height: 18),
          _itemsTable(items),
          pw.SizedBox(height: 16),
          _taxSummary(invoice),
          pw.SizedBox(height: 20),
          _declaration(invoice),
        ],
      ),
    );

    return document.save();
  }

  /// Reserves about 35 mm for a client's preprinted letterhead.
  /// The extra blank area is applied on page 1 only.
  static pw.Widget _buildPreprintedLetterheadSpace(pw.Context context) {
    if (context.pageNumber != 1) {
      return pw.SizedBox();
    }

    return pw.SizedBox(height: 100);
  }

  static pw.Widget _buildHeader(Invoice invoice) {
    final companyAddress = _joinNonEmpty([
      invoice.companyAddress1Snapshot,
      invoice.companyAddress2Snapshot,
      invoice.companyAddress3Snapshot,
    ]);

    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: pw.BoxDecoration(
        color: _surfaceSoft,
        border: pw.Border.all(color: _border, width: 0.7),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (invoice.companyLogoSnapshot != null &&
              invoice.companyLogoSnapshot!.isNotEmpty) ...[
            pw.Container(
              width: 72,
              height: 64,
              padding: const pw.EdgeInsets.all(4),
              alignment: pw.Alignment.center,
              child: pw.Image(
                pw.MemoryImage(invoice.companyLogoSnapshot!),
                fit: pw.BoxFit.contain,
              ),
            ),
            pw.SizedBox(width: 10),
          ],
          pw.Container(
            width: 5,
            height: 64,
            decoration: const pw.BoxDecoration(
              color: _blue,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
            ),
          ),
          pw.SizedBox(width: 11),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  invoice.companyNameSnapshot,
                  style: pw.TextStyle(
                    color: _navy,
                    fontSize: 19,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (companyAddress.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    companyAddress,
                    style: const pw.TextStyle(
                      color: _muted,
                      fontSize: 8.5,
                      height: 1.35,
                    ),
                  ),
                ],
                pw.SizedBox(height: 4),
                pw.Wrap(
                  spacing: 12,
                  runSpacing: 3,
                  children: [
                    if (_hasValue(invoice.companyGstinSnapshot))
                      pw.Text(
                        'GSTIN: ${invoice.companyGstinSnapshot}',
                        style: pw.TextStyle(
                          color: _navy,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    if (_hasValue(invoice.companyPanSnapshot))
                      pw.Text(
                        'PAN: ${invoice.companyPanSnapshot}',
                        style: pw.TextStyle(
                          color: _muted,
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _invoiceTitle() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: const pw.BoxDecoration(
        color: _blueSoft,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Text(
        'TAX INVOICE',
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: _navy,
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  static pw.Widget _partyAndInvoiceDetails(Invoice invoice) {
    return pw.Table(
      border: pw.TableBorder.all(color: _border, width: 0.7),
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
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          if (_hasValue(invoice.partyPanSnapshot))
            pw.Text(
              'PAN: ${invoice.partyPanSnapshot}',
              style: pw.TextStyle(
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold,
              ),
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
      border: pw.TableBorder.all(color: _border, width: 0.55),
      headerDecoration: const pw.BoxDecoration(color: _navy),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 7.5,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(color: _navy, fontSize: 7.5),
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
    final rows = <pw.Widget>[];

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
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(child: _amountInWords(invoice)),
        pw.SizedBox(width: 12),
        pw.SizedBox(
          width: 235,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _surfaceSoft,
              border: pw.Border.all(color: _border, width: 0.8),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
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
      decoration: pw.BoxDecoration(
        color: _blueSoft,
        border: pw.Border.all(color: _border, width: 0.7),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
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
    final showDigitalSignature =
        invoice.signatureAppliedSnapshot &&
        invoice.signatureImageSnapshot != null &&
        invoice.signatureImageSnapshot!.isNotEmpty;

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Container(
          width: 235,
          padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 9),
          decoration: pw.BoxDecoration(
            color: _surfaceSoft,
            border: pw.Border.all(color: _border, width: 0.7),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
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
              pw.SizedBox(height: 5),
              if (showDigitalSignature) ...[
                pw.Container(
                  height: 43,
                  alignment: pw.Alignment.center,
                  child: pw.Image(
                    pw.MemoryImage(invoice.signatureImageSnapshot!),
                    fit: pw.BoxFit.contain,
                  ),
                ),
                if ((invoice.signatoryNameSnapshot ?? '').trim().isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 3),
                    child: pw.Text(
                      invoice.signatoryNameSnapshot!.trim(),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                if ((invoice.signatoryDesignationSnapshot ?? '')
                    .trim()
                    .isNotEmpty)
                  pw.Text(
                    invoice.signatoryDesignationSnapshot!.trim(),
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 7, color: _muted),
                  ),
              ] else ...[
                pw.SizedBox(height: 43),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.only(top: 4),
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(width: 0.6)),
                  ),
                  child: pw.Text(
                    'Authorised Signatory',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(
    pw.Context context,
    Invoice invoice,
    Uint8List appLogo,
  ) {
    final taxType = invoice.taxType == 'nonTaxable'
        ? 'Non-Taxable'
        : invoice.gstMode == 'igst'
        ? 'Taxable - IGST'
        : 'Taxable - CGST + SGST';

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 0.5, color: _border)),
      ),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 90,
            height: 14,
            child: pw.Image(
              pw.MemoryImage(appLogo),
              fit: pw.BoxFit.contain,
              alignment: pw.Alignment.centerLeft,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              'Tax Type: $taxType | This is a computer generated invoice',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),
          ),
          pw.SizedBox(
            width: 90,
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              textAlign: pw.TextAlign.right,
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );
  }

  static String _money(int paise) {
    final value = MoneyUtils.paiseToRupees(paise);

    return _formatIndianNumber(value);
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
