import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ReportExcelExportService {
  const ReportExcelExportService._();

  static Future<File> export({
    required String reportTitle,
    required String fileName,
    required List<String> headers,
    required List<List<String>> rows,
    List<List<String>> metadata = const [],
    Set<int> numericColumns = const {},
    List<String>? totalsRow,
  }) async {
    final workbook = Excel.createExcel();

    final defaultSheet = workbook.getDefaultSheet();
    final sheetName = _safeSheetName(reportTitle);
    final sheet = workbook[sheetName];

    if (defaultSheet != null && defaultSheet != sheetName) {
      workbook.delete(defaultSheet);
    }

    // VInvoice export brand color.
    const navyHex = '#3B82F6';

    final navy = ExcelColor.fromHexString(navyHex);

    final white = ExcelColor.white;

    final darkText = ExcelColor.fromHexString('#0F172A');

    final mutedText = ExcelColor.fromHexString('#475569');

    final softBackground = ExcelColor.fromHexString('#F8FAFC');

    // --------------------------------------------------------
    // STYLES
    // --------------------------------------------------------

    final titleStyle = CellStyle(
      bold: true,
      fontSize: 18,
      fontColorHex: white,
      backgroundColorHex: navy,
      horizontalAlign: HorizontalAlign.Left,
      verticalAlign: VerticalAlign.Center,
    );

    final metadataLabelStyle = CellStyle(
      bold: true,
      fontColorHex: navy,
      backgroundColorHex: softBackground,
      verticalAlign: VerticalAlign.Center,
    );

    final metadataValueStyle = CellStyle(
      fontColorHex: darkText,
      backgroundColorHex: softBackground,
      verticalAlign: VerticalAlign.Center,
    );

    final headerStyle = CellStyle(
      bold: true,
      fontColorHex: white,
      backgroundColorHex: navy,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      textWrapping: TextWrapping.WrapText,
    );

    final textCellStyle = CellStyle(
      fontColorHex: darkText,
      verticalAlign: VerticalAlign.Center,
    );

    final alternateTextStyle = CellStyle(
      fontColorHex: darkText,
      backgroundColorHex: softBackground,
      verticalAlign: VerticalAlign.Center,
    );

    final numericCellStyle = CellStyle(
      fontColorHex: darkText,
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      numberFormat: CustomNumericNumFormat(formatCode: '#,##0.00'),
    );

    final alternateNumericStyle = CellStyle(
      fontColorHex: darkText,
      backgroundColorHex: softBackground,
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      numberFormat: CustomNumericNumFormat(formatCode: '#,##0.00'),
    );

    final totalTextStyle = CellStyle(
      bold: true,
      fontColorHex: white,
      backgroundColorHex: navy,
      verticalAlign: VerticalAlign.Center,
    );

    final totalNumericStyle = CellStyle(
      bold: true,
      fontColorHex: white,
      backgroundColorHex: navy,
      horizontalAlign: HorizontalAlign.Right,
      verticalAlign: VerticalAlign.Center,
      numberFormat: CustomNumericNumFormat(formatCode: '#,##0.00'),
    );

    // --------------------------------------------------------
    // TITLE
    // --------------------------------------------------------

    final lastColumn = headers.isEmpty ? 0 : headers.length - 1;

    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      TextCellValue(reportTitle),
      cellStyle: titleStyle,
    );

    if (lastColumn > 0) {
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: lastColumn, rowIndex: 0),
      );

      sheet.setMergedCellStyle(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        titleStyle,
      );
    }

    sheet.setRowHeight(0, 30);

    // --------------------------------------------------------
    // METADATA
    // --------------------------------------------------------

    var rowIndex = 1;

    for (final metadataRow in metadata) {
      if (metadataRow.isEmpty) {
        continue;
      }

      for (
        var columnIndex = 0;
        columnIndex < metadataRow.length;
        columnIndex++
      ) {
        sheet.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: columnIndex,
            rowIndex: rowIndex,
          ),
          TextCellValue(metadataRow[columnIndex]),
          cellStyle: columnIndex == 0 ? metadataLabelStyle : metadataValueStyle,
        );
      }

      sheet.setRowHeight(rowIndex, 20);
      rowIndex++;
    }

    // Genuine empty visual spacer.
    sheet.setRowHeight(rowIndex, 8);
    rowIndex++;

    // --------------------------------------------------------
    // TABLE HEADER
    // --------------------------------------------------------

    for (var columnIndex = 0; columnIndex < headers.length; columnIndex++) {
      sheet.updateCell(
        CellIndex.indexByColumnRow(
          columnIndex: columnIndex,
          rowIndex: rowIndex,
        ),
        TextCellValue(headers[columnIndex]),
        cellStyle: headerStyle,
      );
    }

    sheet.setRowHeight(rowIndex, 28);
    rowIndex++;

    // --------------------------------------------------------
    // DATA
    // --------------------------------------------------------

    for (var sourceRow = 0; sourceRow < rows.length; sourceRow++) {
      final row = rows[sourceRow];
      final alternate = sourceRow.isOdd;

      for (var columnIndex = 0; columnIndex < row.length; columnIndex++) {
        final value = row[columnIndex];

        if (numericColumns.contains(columnIndex)) {
          final numeric = _parseNumeric(value);

          sheet.updateCell(
            CellIndex.indexByColumnRow(
              columnIndex: columnIndex,
              rowIndex: rowIndex,
            ),
            numeric == null ? TextCellValue(value) : DoubleCellValue(numeric),
            cellStyle: numeric == null
                ? (alternate ? alternateTextStyle : textCellStyle)
                : (alternate ? alternateNumericStyle : numericCellStyle),
          );
        } else {
          sheet.updateCell(
            CellIndex.indexByColumnRow(
              columnIndex: columnIndex,
              rowIndex: rowIndex,
            ),
            TextCellValue(value),
            cellStyle: alternate ? alternateTextStyle : textCellStyle,
          );
        }
      }

      sheet.setRowHeight(rowIndex, 21);
      rowIndex++;
    }

    // --------------------------------------------------------
    // TOTAL ROW
    // --------------------------------------------------------

    if (totalsRow != null && totalsRow.isNotEmpty) {
      for (var columnIndex = 0; columnIndex < headers.length; columnIndex++) {
        final value = columnIndex < totalsRow.length
            ? totalsRow[columnIndex]
            : '';

        final numeric = numericColumns.contains(columnIndex)
            ? _parseNumeric(value)
            : null;

        sheet.updateCell(
          CellIndex.indexByColumnRow(
            columnIndex: columnIndex,
            rowIndex: rowIndex,
          ),
          numeric != null
              ? DoubleCellValue(numeric)
              : TextCellValue(value.trim().isEmpty ? ' ' : value),
          cellStyle: numeric != null ? totalNumericStyle : totalTextStyle,
        );
      }

      sheet.setRowHeight(rowIndex, 25);
      rowIndex++;
    }

    // --------------------------------------------------------
    // FOOTNOTE
    // --------------------------------------------------------

    sheet.setRowHeight(rowIndex, 8);
    rowIndex++;

    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
      TextCellValue('Generated by VInvoice Pro'),
      cellStyle: CellStyle(italic: true, fontColorHex: mutedText, fontSize: 9),
    );

    // --------------------------------------------------------
    // COLUMN WIDTHS
    // --------------------------------------------------------

    for (var columnIndex = 0; columnIndex < headers.length; columnIndex++) {
      final header = headers[columnIndex];

      var maxLength = header.length;

      for (final row in rows) {
        if (columnIndex < row.length && row[columnIndex].length > maxLength) {
          maxLength = row[columnIndex].length;
        }
      }

      double width;

      if (_looksLikePartyColumn(header)) {
        width = 30;
      } else if (_looksLikeInvoiceColumn(header)) {
        width = 22;
      } else if (_looksLikeDateColumn(header)) {
        width = 16;
      } else if (_looksLikeMoneyColumn(header)) {
        width = 17;
      } else if (header.toLowerCase().contains('status')) {
        width = 16;
      } else if (header.toLowerCase().contains('reference')) {
        width = 20;
      } else {
        width = (maxLength + 3).clamp(11, 25).toDouble();
      }

      sheet.setColumnWidth(columnIndex, width);
    }

    // --------------------------------------------------------
    // SAVE
    // --------------------------------------------------------

    final bytes = workbook.encode();

    if (bytes == null) {
      throw StateError('Unable to generate Excel workbook.');
    }

    final directory = await getTemporaryDirectory();

    final safeFileName = _safeFileName(fileName);

    final file = File(
      '${directory.path}'
      '${Platform.pathSeparator}'
      '$safeFileName.xlsx',
    );

    await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);

    return file;
  }

  static Future<void> exportAndShare({
    required String reportTitle,
    required String fileName,
    required List<String> headers,
    required List<List<String>> rows,
    List<List<String>> metadata = const [],
    Set<int> numericColumns = const {},
    List<String>? totalsRow,
  }) async {
    final file = await export(
      reportTitle: reportTitle,
      fileName: fileName,
      headers: headers,
      rows: rows,
      metadata: metadata,
      numericColumns: numericColumns,
      totalsRow: totalsRow,
    );

    await SharePlus.instance.share(
      ShareParams(
        text: reportTitle,
        subject: reportTitle,
        files: [XFile(file.path)],
      ),
    );
  }

  static double? _parseNumeric(String value) {
    final cleaned = value.replaceAll(',', '').replaceAll('\u20B9', '').trim();

    return double.tryParse(cleaned);
  }

  static bool _looksLikeMoneyColumn(String header) {
    final value = header.toLowerCase();

    return value.contains('amount') ||
        value.contains('total') ||
        value.contains('paid') ||
        value.contains('outstanding') ||
        value.contains('taxable') ||
        value == 'cgst' ||
        value == 'sgst' ||
        value == 'igst' ||
        value.contains('invoice value');
  }

  static bool _looksLikePartyColumn(String header) =>
      header.toLowerCase().contains('party');

  static bool _looksLikeInvoiceColumn(String header) =>
      header.toLowerCase().contains('invoice no');

  static bool _looksLikeDateColumn(String header) =>
      header.toLowerCase().contains('date');

  static String _safeSheetName(String value) {
    var result = value.replaceAll(RegExp(r'[\\/*?:\[\]]'), ' ');

    result = result.trim();

    if (result.isEmpty) {
      result = 'Report';
    }

    if (result.length > 31) {
      result = result.substring(0, 31);
    }

    return result;
  }

  static String _safeFileName(String value) {
    final cleaned = value
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();

    return cleaned.isEmpty ? 'vinvoice_report' : cleaned;
  }
}
