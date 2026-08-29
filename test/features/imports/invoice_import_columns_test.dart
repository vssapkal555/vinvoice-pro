import 'package:flutter_test/flutter_test.dart';
import 'package:vinvoice_pro/features/imports/data/invoice_import_columns.dart';

void main() {
  test('historical invoice template has exactly 24 columns', () {
    expect(InvoiceImportColumns.headers.length, 24);
  });

  test('important historical column positions remain fixed', () {
    expect(InvoiceImportColumns.headers[0], 'Party Name');

    expect(InvoiceImportColumns.headers[6], 'Invoice No.');

    expect(InvoiceImportColumns.headers[13], 'DESCRIPTION OF SERVICE');

    expect(InvoiceImportColumns.headers[19], 'TAXABLE AMOUNT');

    expect(InvoiceImportColumns.headers[23], 'GRAND TOTAL');
  });
}
