import 'package:flutter/services.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportPdfExportService {
  const ReportPdfExportService._();

  static const PdfColor _brandBlue = PdfColor.fromInt(0xFF101828);

  static const PdfColor _accentBlue = PdfColor.fromInt(0xFF2563EB);

  static const PdfColor _darkText = PdfColor.fromInt(0xFF0F172A);

  static const PdfColor _mutedText = PdfColor.fromInt(0xFF64748B);

  static const PdfColor _softBackground = PdfColor.fromInt(0xFFF8FAFC);

  static const PdfColor _border = PdfColor.fromInt(0xFFE2E8F0);

  static Future<Uint8List> build({
    required String reportTitle,
    required List<String> headers,
    required List<List<String>> rows,
    List<List<String>> metadata = const [],
    List<String>? totalsRow,
    bool landscape = false,
    Uint8List? companyLogo,
    String? companyName,
  }) async {
    final document = pw.Document();
    final appLogo = (await rootBundle.load(
      'assets/branding/vinvoice_pro_logo.png',
    )).buffer.asUint8List();

    final cleanHeaders = headers.map(_cleanPdfText).toList();
    final cleanRows = rows
        .map((row) => row.map(_cleanPdfText).toList())
        .toList();
    final cleanMetadata = metadata
        .map((row) => row.map(_cleanPdfText).toList())
        .toList();
    final cleanTotals = totalsRow?.map(_cleanPdfText).toList();

    final format = landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

    document.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(24),
        header: (context) => _buildHeader(
          reportTitle,
          cleanMetadata,
          companyLogo: companyLogo,
          companyName: companyName,
        ),
        footer: (context) =>
            _buildFooter(context.pageNumber, context.pagesCount, appLogo),
        build: (context) => [
          pw.SizedBox(height: 10),
          _buildTable(
            headers: cleanHeaders,
            rows: cleanRows,
            totalsRow: cleanTotals,
          ),
        ],
      ),
    );

    return document.save();
  }

  static Future<void> share({
    required String reportTitle,
    required String fileName,
    required List<String> headers,
    required List<List<String>> rows,
    List<List<String>> metadata = const [],
    List<String>? totalsRow,
    bool landscape = false,
    Uint8List? companyLogo,
    String? companyName,
  }) async {
    final bytes = await build(
      reportTitle: reportTitle,
      headers: headers,
      rows: rows,
      metadata: metadata,
      totalsRow: totalsRow,
      landscape: landscape,
      companyLogo: companyLogo,
      companyName: companyName,
    );

    await Printing.sharePdf(bytes: bytes, filename: '$fileName.pdf');
  }

  static Future<void> printReport({
    required String reportTitle,
    required List<String> headers,
    required List<List<String>> rows,
    List<List<String>> metadata = const [],
    List<String>? totalsRow,
    bool landscape = false,
    Uint8List? companyLogo,
    String? companyName,
  }) async {
    final bytes = await build(
      reportTitle: reportTitle,
      headers: headers,
      rows: rows,
      metadata: metadata,
      totalsRow: totalsRow,
      landscape: landscape,
      companyLogo: companyLogo,
      companyName: companyName,
    );

    await Printing.layoutPdf(onLayout: (_) async => bytes, name: reportTitle);
  }

  static pw.Widget _buildHeader(
    String reportTitle,
    List<List<String>> metadata, {
    Uint8List? companyLogo,
    String? companyName,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: pw.BoxDecoration(
            color: _brandBlue,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Row(
            children: [
              pw.Container(
                width: 4,
                height: 28,
                decoration: const pw.BoxDecoration(
                  color: _accentBlue,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
              ),
              pw.SizedBox(width: 10),
              if (companyLogo != null && companyLogo.isNotEmpty) ...[
                pw.Container(
                  width: 42,
                  height: 30,
                  padding: const pw.EdgeInsets.all(2),
                  decoration: const pw.BoxDecoration(color: PdfColors.white),
                  child: pw.Image(
                    pw.MemoryImage(companyLogo),
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.SizedBox(width: 10),
              ],
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (companyName != null && companyName.trim().isNotEmpty)
                      pw.Text(
                        companyName.trim(),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    pw.Text(
                      reportTitle,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (metadata.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _softBackground,
              border: pw.Border.all(color: _border, width: .6),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Column(
              children: metadata.map((row) {
                final label = row.isNotEmpty ? row[0] : '';
                final value = row.length > 1 ? row[1] : '';

                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(
                        width: 95,
                        child: pw.Text(
                          label,
                          style: pw.TextStyle(
                            color: _darkText,
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          value,
                          style: const pw.TextStyle(
                            color: _mutedText,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildTable({
    required List<String> headers,
    required List<List<String>> rows,
    required List<String>? totalsRow,
  }) {
    final data = <List<String>>[...rows, ?totalsRow];

    final totalRowIndex = totalsRow == null ? -1 : data.length - 1;

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: _border, width: .5),
      headerDecoration: const pw.BoxDecoration(color: _brandBlue),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 7.5,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(color: _darkText, fontSize: 7),
      textStyleBuilder: (index, value, rowNum) {
        if (rowNum == totalRowIndex) {
          return pw.TextStyle(
            color: _accentBlue,
            fontSize: 7,
            fontWeight: pw.FontWeight.bold,
          );
        }

        return null;
      },
      cellDecoration: (index, value, rowNum) {
        if (rowNum == totalRowIndex) {
          return const pw.BoxDecoration(color: PdfColor.fromInt(0xFFDBEAFE));
        }

        if (rowNum.isOdd) {
          return const pw.BoxDecoration(color: _softBackground);
        }

        return const pw.BoxDecoration(color: PdfColors.white);
      },
      headerAlignment: pw.Alignment.center,
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    );
  }

  static String _cleanPdfText(String value) {
    // PDF preference: monetary values are shown without a rupee symbol.
    // App UI and Excel output remain unchanged.
    return value.replaceAll(String.fromCharCode(0x20B9), '').trim();
  }

  static pw.Widget _buildFooter(
    int pageNumber,
    int pageCount,
    Uint8List appLogo,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _border, width: .5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.SizedBox(
            width: 88,
            height: 14,
            child: pw.Image(
              pw.MemoryImage(appLogo),
              fit: pw.BoxFit.contain,
              alignment: pw.Alignment.centerLeft,
            ),
          ),
          pw.Text(
            'Page $pageNumber of $pageCount',
            style: const pw.TextStyle(color: _mutedText, fontSize: 7),
          ),
        ],
      ),
    );
  }
}
