import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'invoice_import_columns.dart';

class InvoiceImportTemplateService {
  const InvoiceImportTemplateService._();

  static Future<void> createAndShare() async {
    final workbook = Excel.createExcel();

    final sheet = workbook['Invoice Import'];

    for (
      var column = 0;
      column < InvoiceImportColumns.headers.length;
      column++
    ) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 0))
          .value = TextCellValue(
        InvoiceImportColumns.headers[column],
      );
    }

    final example = <String>[
      'Example Customer Pvt. Ltd.',
      'Address Line 1',
      'Address Line 2',
      'Pune, Maharashtra, 411001',
      'ABCDE1234F',
      '27ABCDE1234F1Z5',
      'OLD/2025-26/0001',
      '31-03-2026',
      'PO-001',
      'VEN001',
      'Pune Plant',
      '01-03-2026',
      '31-03-2026',
      'Transportation Service',
      '996511',
      '2',
      'Days',
      '5000',
      '10000',
      '10000',
      '900',
      '900',
      '0',
      '11800',
    ];

    for (var column = 0; column < example.length; column++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: column, rowIndex: 1))
          .value = TextCellValue(
        example[column],
      );
    }

    if (workbook.tables.containsKey('Sheet1')) {
      workbook.delete('Sheet1');
    }

    final encoded = workbook.encode();

    if (encoded == null) {
      throw StateError('Unable to generate Excel template.');
    }

    final directory = await getTemporaryDirectory();

    final file = File('${directory.path}/VInvoice_Import_Template.xlsx');

    await file.writeAsBytes(encoded, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        title: 'VInvoice Excel Import Template',
        text: 'VInvoice Pro canonical 24-column invoice data template.',
        files: [XFile(file.path)],
      ),
    );
  }
}
