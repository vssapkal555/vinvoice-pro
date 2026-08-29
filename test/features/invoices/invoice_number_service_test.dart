import 'package:flutter_test/flutter_test.dart';
import 'package:vinvoice_pro/features/invoices/data/invoice_number_service.dart';

void main() {
  group('InvoiceNumberService', () {
    test('April starts new financial year', () {
      expect(
        InvoiceNumberService.financialYearFor(DateTime(2026, 4, 1)),
        '2026-27',
      );
    });

    test('March belongs to previous financial year', () {
      expect(
        InvoiceNumberService.financialYearFor(DateTime(2027, 3, 31)),
        '2026-27',
      );
    });

    test('first invoice starts at 0001', () {
      final result = InvoiceNumberService.buildNextInvoiceNumber(
        existingNumbers: const [],
        date: DateTime(2026, 8, 29),
      );

      expect(result, 'INV/2026-27/0001');
    });

    test('increments current financial year', () {
      final result = InvoiceNumberService.buildNextInvoiceNumber(
        existingNumbers: const [
          'INV/2026-27/0001',
          'INV/2026-27/0002',
          'INV/2025-26/0050',
        ],
        date: DateTime(2026, 8, 29),
      );

      expect(result, 'INV/2026-27/0003');
    });
  });
}
