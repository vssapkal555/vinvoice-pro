import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportPdfExportService {
  const ReportPdfExportService._();

  static const PdfColor _brandBlue = PdfColor.fromInt(0xFF3B82F6);

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
  }) async {
    final document = pw.Document();

    final format = landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

    document.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(24),
        header: (context) => _buildHeader(reportTitle, metadata),
        footer: (context) =>
            _buildFooter(context.pageNumber, context.pagesCount),
        build: (context) => [
          pw.SizedBox(height: 10),
          _buildTable(headers: headers, rows: rows, totalsRow: totalsRow),
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
  }) async {
    final bytes = await build(
      reportTitle: reportTitle,
      headers: headers,
      rows: rows,
      metadata: metadata,
      totalsRow: totalsRow,
      landscape: landscape,
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
  }) async {
    final bytes = await build(
      reportTitle: reportTitle,
      headers: headers,
      rows: rows,
      metadata: metadata,
      totalsRow: totalsRow,
      landscape: landscape,
    );

    await Printing.layoutPdf(onLayout: (_) async => bytes, name: reportTitle);
  }

  static pw.Widget _buildHeader(
    String reportTitle,
    List<List<String>> metadata,
  ) {
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
          child: pw.Text(
            reportTitle,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
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
            color: const PdfColor.fromInt(0xFF1D4ED8),
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

  static pw.Widget _buildFooter(int pageNumber, int pageCount) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _border, width: .5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by VInvoice Pro',
            style: const pw.TextStyle(color: _mutedText, fontSize: 7),
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
