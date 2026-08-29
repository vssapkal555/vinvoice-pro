import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/money_utils.dart';
import '../models/invoice_import_models.dart';
import 'invoice_import_columns.dart';

class InvoiceExcelParser {
  final AppDatabase database;

  const InvoiceExcelParser(this.database);

  Future<InvoiceImportPreview> parse({
    required Uint8List bytes,
    required String fileName,
    required String companyId,
  }) async {
    final fileIssues = <ImportIssue>[];

    List<List<String>> rows;

    try {
      rows = _readFirstWorksheet(bytes);
    } catch (error) {
      return InvoiceImportPreview(
        fileName: fileName,
        invoices: const [],
        fileIssues: [
          ImportIssue(
            severity: ImportIssueSeverity.error,
            message:
                'The selected file could not be read as an Excel .xlsx file. Details: $error',
          ),
        ],
      );
    }

    if (rows.isEmpty) {
      return InvoiceImportPreview(
        fileName: fileName,
        invoices: const [],
        fileIssues: const [
          ImportIssue(
            severity: ImportIssueSeverity.error,
            message: 'The worksheet is empty.',
          ),
        ],
      );
    }

    final headerRow = rows.first;

    final headerIssues = _validateHeaders(headerRow);

    fileIssues.addAll(headerIssues);

    if (headerIssues.any(
      (issue) => issue.severity == ImportIssueSeverity.error,
    )) {
      return InvoiceImportPreview(
        fileName: fileName,
        invoices: const [],
        fileIssues: fileIssues,
      );
    }

    final parsedRows = <ParsedInvoiceImportRow>[];

    final rejectedRows = <String, List<ImportIssue>>{};

    for (var index = 1; index < rows.length; index++) {
      final excelRow = index + 1;

      final cells = List<String>.generate(InvoiceImportColumns.columnCount, (
        column,
      ) {
        if (column >= rows[index].length) {
          return '';
        }

        return rows[index][column].trim();
      });

      if (cells.every((value) => value.isEmpty)) {
        continue;
      }

      final issues = <ImportIssue>[];

      final invoiceNumber = cells[InvoiceImportColumns.invoiceNumber].trim();

      final partyName = cells[InvoiceImportColumns.partyName].trim();

      final description = cells[InvoiceImportColumns.description].trim();

      if (invoiceNumber.isEmpty) {
        issues.add(
          ImportIssue(
            severity: ImportIssueSeverity.error,
            excelRow: excelRow,
            message: 'Invoice No. is required.',
          ),
        );
      }

      if (partyName.isEmpty) {
        issues.add(
          ImportIssue(
            severity: ImportIssueSeverity.error,
            excelRow: excelRow,
            message: 'Party Name is required.',
          ),
        );
      }

      if (description.isEmpty) {
        issues.add(
          ImportIssue(
            severity: ImportIssueSeverity.error,
            excelRow: excelRow,
            message: 'DESCRIPTION OF SERVICE is required.',
          ),
        );
      }

      final invoiceDate = _parseDate(cells[InvoiceImportColumns.invoiceDate]);

      if (invoiceDate == null) {
        issues.add(
          ImportIssue(
            severity: ImportIssueSeverity.error,
            excelRow: excelRow,
            message: 'Invalid Invoice Date.',
          ),
        );
      }

      final quantity = _parseDouble(cells[InvoiceImportColumns.quantity]);

      if (quantity == null || quantity <= 0) {
        issues.add(
          ImportIssue(
            severity: ImportIssueSeverity.error,
            excelRow: excelRow,
            message: 'QTY must be greater than zero.',
          ),
        );
      }

      final ratePaise = _parseMoney(cells[InvoiceImportColumns.rate]);

      var amountPaise = _parseMoney(cells[InvoiceImportColumns.amount]);

      if (amountPaise == 0 && quantity != null && ratePaise > 0) {
        amountPaise = (quantity * ratePaise).round();
      }

      if (issues.any((issue) => issue.severity == ImportIssueSeverity.error)) {
        final key = invoiceNumber.isEmpty ? '__ROW_$excelRow' : invoiceNumber;

        rejectedRows.putIfAbsent(key, () => []).addAll(issues);

        continue;
      }

      parsedRows.add(
        ParsedInvoiceImportRow(
          excelRow: excelRow,
          partyName: partyName,
          address1: cells[InvoiceImportColumns.address1].trim(),
          address2: cells[InvoiceImportColumns.address2].trim(),
          address3: cells[InvoiceImportColumns.address3].trim(),
          pan: cells[InvoiceImportColumns.pan].trim().toUpperCase(),
          gst: cells[InvoiceImportColumns.gst].trim().toUpperCase(),
          invoiceNumber: invoiceNumber,
          invoiceDate: invoiceDate!,
          poNumber: cells[InvoiceImportColumns.poNumber].trim(),
          vendorCode: cells[InvoiceImportColumns.vendorCode].trim(),
          sitePlant: cells[InvoiceImportColumns.sitePlant].trim(),
          serviceFrom: _parseDate(cells[InvoiceImportColumns.serviceFrom]),
          serviceTo: _parseDate(cells[InvoiceImportColumns.serviceTo]),
          description: description,
          hsnSac: cells[InvoiceImportColumns.hsnSac].trim(),
          quantity: quantity!,
          unit: cells[InvoiceImportColumns.unit].trim(),
          ratePaise: ratePaise,
          amountPaise: amountPaise,
          taxableAmountPaise: _parseMoney(
            cells[InvoiceImportColumns.taxableAmount],
          ),
          cgstAmountPaise: _parseMoney(cells[InvoiceImportColumns.cgst]),
          sgstAmountPaise: _parseMoney(cells[InvoiceImportColumns.sgst]),
          igstAmountPaise: _parseMoney(cells[InvoiceImportColumns.igst]),
          grandTotalPaise: _parseMoney(cells[InvoiceImportColumns.grandTotal]),
        ),
      );
    }

    final grouped = <String, List<ParsedInvoiceImportRow>>{};

    for (final row in parsedRows) {
      grouped.putIfAbsent(row.invoiceNumber, () => []).add(row);
    }

    final groups = <ImportInvoiceGroup>[];

    for (final entry in grouped.entries) {
      final groupIssues = <ImportIssue>[...?rejectedRows[entry.key]];

      final invoiceRows = entry.value;
      final first = invoiceRows.first;

      _validateGroupConsistency(invoiceRows, groupIssues);

      final basicAmount = invoiceRows.fold<int>(
        0,
        (total, row) => total + row.amountPaise,
      );

      final taxable = _firstNonZero(
        invoiceRows.map((row) => row.taxableAmountPaise),
      );

      final cgst = _firstNonZero(invoiceRows.map((row) => row.cgstAmountPaise));

      final sgst = _firstNonZero(invoiceRows.map((row) => row.sgstAmountPaise));

      final igst = _firstNonZero(invoiceRows.map((row) => row.igstAmountPaise));

      final grandTotal = _firstNonZero(
        invoiceRows.map((row) => row.grandTotalPaise),
      );

      if (cgst > 0 && sgst == 0) {
        groupIssues.add(
          const ImportIssue(
            severity: ImportIssueSeverity.error,
            message: 'CGST cannot be imported without SGST.',
          ),
        );
      }

      if (sgst > 0 && cgst == 0) {
        groupIssues.add(
          const ImportIssue(
            severity: ImportIssueSeverity.error,
            message: 'SGST cannot be imported without CGST.',
          ),
        );
      }

      if (igst > 0 && (cgst > 0 || sgst > 0)) {
        groupIssues.add(
          const ImportIssue(
            severity: ImportIssueSeverity.error,
            message: 'IGST cannot be combined with CGST/SGST.',
          ),
        );
      }

      final expectedTotal = basicAmount + cgst + sgst + igst;

      if (grandTotal > 0 && (grandTotal - expectedTotal).abs() > 1) {
        groupIssues.add(
          const ImportIssue(
            severity: ImportIssueSeverity.error,
            message: 'Grand Total does not match item amount plus taxes.',
          ),
        );
      }

      if (taxable > 0 && (taxable - basicAmount).abs() > 1) {
        groupIssues.add(
          const ImportIssue(
            severity: ImportIssueSeverity.warning,
            message:
                'TAXABLE AMOUNT differs from the sum of line-item amounts.',
          ),
        );
      }

      final existingInvoice = await database.getInvoiceByCompanyAndNumber(
        companyId: companyId,
        invoiceNumber: first.invoiceNumber,
      );

      final party = await database.findPartyForImport(
        companyId: companyId,
        gstin: first.gst,
        pan: first.pan,
        partyName: first.partyName,
      );

      if (party == null) {
        groupIssues.add(
          const ImportIssue(
            severity: ImportIssueSeverity.warning,
            message:
                'No matching Party master was found. A new Party will be created automatically when this invoice is imported.',
          ),
        );
      }

      groups.add(
        ImportInvoiceGroup(
          invoiceNumber: first.invoiceNumber,
          rows: invoiceRows,
          duplicate: existingInvoice != null,
          missingParty: party == null,
          issues: groupIssues,
        ),
      );
    }

    groups.sort((a, b) => b.first.invoiceDate.compareTo(a.first.invoiceDate));

    return InvoiceImportPreview(
      fileName: fileName,
      invoices: groups,
      fileIssues: fileIssues,
    );
  }

  List<List<String>> _readFirstWorksheet(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);

    String readText(String name) {
      final file = archive.findFile(name);

      if (file == null) {
        throw StateError('Missing $name in workbook.');
      }

      return utf8.decode(file.content as List<int>);
    }

    final sharedStrings = <String>[];

    final sharedFile = archive.findFile('xl/sharedStrings.xml');

    if (sharedFile != null) {
      final document = XmlDocument.parse(
        utf8.decode(sharedFile.content as List<int>),
      );

      for (final si in document.findAllElements('si')) {
        final text = si
            .findAllElements('t')
            .map((element) => element.innerText)
            .join();

        sharedStrings.add(text);
      }
    }

    final workbook = XmlDocument.parse(readText('xl/workbook.xml'));

    final relations = XmlDocument.parse(readText('xl/_rels/workbook.xml.rels'));

    final firstSheet = workbook.findAllElements('sheet').firstOrNull;

    if (firstSheet == null) {
      throw StateError('Workbook contains no worksheets.');
    }

    final relationId =
        firstSheet.getAttribute('r:id') ??
        firstSheet.getAttribute(
          'id',
          namespace:
              'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
        );

    if (relationId == null) {
      throw StateError('Unable to resolve worksheet relationship.');
    }

    String? worksheetTarget;

    for (final relation in relations.findAllElements('Relationship')) {
      if (relation.getAttribute('Id') == relationId) {
        worksheetTarget = relation.getAttribute('Target');
        break;
      }
    }

    if (worksheetTarget == null) {
      throw StateError('Worksheet relationship target was not found.');
    }

    var worksheetPath = worksheetTarget;

    if (worksheetPath.startsWith('/')) {
      worksheetPath = worksheetPath.substring(1);
    } else if (!worksheetPath.startsWith('xl/')) {
      worksheetPath = 'xl/$worksheetPath';
    }

    final worksheet = XmlDocument.parse(readText(worksheetPath));

    final result = <List<String>>[];

    for (final row in worksheet.findAllElements('row')) {
      final values = <int, String>{};

      var maxColumn = -1;

      for (final cell in row.findElements('c')) {
        final reference = cell.getAttribute('r') ?? '';

        final column = _columnIndex(reference);

        if (column < 0) {
          continue;
        }

        if (column > maxColumn) {
          maxColumn = column;
        }

        final type = cell.getAttribute('t');

        String value = '';

        if (type == 'inlineStr') {
          value = cell
              .findAllElements('t')
              .map((element) => element.innerText)
              .join();
        } else {
          final valueNode = cell.findElements('v').firstOrNull;

          final raw = valueNode?.innerText ?? '';

          if (type == 's') {
            final index = int.tryParse(raw);

            if (index != null && index >= 0 && index < sharedStrings.length) {
              value = sharedStrings[index];
            }
          } else {
            value = raw;
          }
        }

        values[column] = value;
      }

      if (maxColumn < 0) {
        result.add(const []);
        continue;
      }

      result.add(
        List<String>.generate(maxColumn + 1, (index) => values[index] ?? ''),
      );
    }

    return result;
  }

  int _columnIndex(String cellReference) {
    final letters = RegExp(r'^[A-Z]+').stringMatch(cellReference.toUpperCase());

    if (letters == null) {
      return -1;
    }

    var result = 0;

    for (final code in letters.codeUnits) {
      result = result * 26 + (code - 64);
    }

    return result - 1;
  }

  List<ImportIssue> _validateHeaders(List<String> actual) {
    final issues = <ImportIssue>[];

    if (actual.length < InvoiceImportColumns.columnCount) {
      issues.add(
        ImportIssue(
          severity: ImportIssueSeverity.error,
          message:
              'Expected ${InvoiceImportColumns.columnCount} columns but found ${actual.length}.',
        ),
      );

      return issues;
    }

    for (var i = 0; i < InvoiceImportColumns.columnCount; i++) {
      final expected = _normalizeHeader(InvoiceImportColumns.headers[i]);

      final found = _normalizeHeader(actual[i]);

      if (expected != found) {
        issues.add(
          ImportIssue(
            severity: ImportIssueSeverity.error,
            message:
                'Column ${i + 1} must be "${InvoiceImportColumns.headers[i]}", but found "${actual[i]}".',
          ),
        );
      }
    }

    return issues;
  }

  void _validateGroupConsistency(
    List<ParsedInvoiceImportRow> rows,
    List<ImportIssue> issues,
  ) {
    final first = rows.first;

    for (final row in rows.skip(1)) {
      if (row.partyName.trim().toLowerCase() !=
          first.partyName.trim().toLowerCase()) {
        issues.add(
          ImportIssue(
            severity: ImportIssueSeverity.error,
            excelRow: row.excelRow,
            message: 'Repeated invoice number has different Party Name values.',
          ),
        );
      }

      if (!_sameDate(row.invoiceDate, first.invoiceDate)) {
        issues.add(
          ImportIssue(
            severity: ImportIssueSeverity.error,
            excelRow: row.excelRow,
            message:
                'Repeated invoice number has different Invoice Date values.',
          ),
        );
      }
    }
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _normalizeHeader(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
  }

  double? _parseDouble(String value) {
    final cleaned = value.replaceAll(',', '').trim();

    if (cleaned.isEmpty) {
      return null;
    }

    return double.tryParse(cleaned);
  }

  int _parseMoney(String value) {
    final cleaned = value
        .replaceAll('INR', '')
        .replaceAll('\u20B9', '')
        .replaceAll(',', '')
        .trim();

    if (cleaned.isEmpty) {
      return 0;
    }

    final parsed = double.tryParse(cleaned);

    if (parsed == null) {
      return 0;
    }

    return MoneyUtils.rupeesToPaise(parsed);
  }

  DateTime? _parseDate(String value) {
    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    final normalized = text.replaceAll(RegExp(r'[^0-9/\-: T.]'), '').trim();

    final formats = [
      DateFormat('dd-MM-yyyy'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('yyyy-MM-dd'),
      DateFormat('d-M-yyyy'),
      DateFormat('d/M/yyyy'),
      DateFormat('yyyy-MM-dd HH:mm:ss.SSS'),
      DateFormat('yyyy-MM-dd HH:mm:ss'),
    ];

    for (final format in formats) {
      try {
        return format.parseStrict(normalized);
      } catch (_) {}
    }

    final serial = double.tryParse(normalized);

    if (serial != null && serial > 1 && serial < 100000) {
      final base = DateTime(1899, 12, 30);

      return base.add(Duration(days: serial.floor()));
    }

    return null;
  }

  int _firstNonZero(Iterable<int> values) {
    for (final value in values) {
      if (value != 0) {
        return value;
      }
    }

    return 0;
  }
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) {
      return null;
    }

    return first;
  }
}
