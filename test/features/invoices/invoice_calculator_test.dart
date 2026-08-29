import 'package:flutter_test/flutter_test.dart';
import 'package:vinvoice_pro/features/invoices/data/invoice_calculator.dart';
import 'package:vinvoice_pro/features/invoices/models/invoice_form_models.dart';

void main() {
  group('InvoiceCalculator', () {
    test('calculates CGST and SGST correctly', () {
      const items = [
        InvoiceLineInput(description: 'Service', quantity: 2, ratePaise: 50000),
      ];

      final result = InvoiceCalculator.calculate(
        items: items,
        taxType: InvoiceTaxType.taxable,
        gstMode: InvoiceGstMode.cgstSgst,
        cgstRate: 9,
        sgstRate: 9,
      );

      expect(result.basicAmountPaise, 100000);

      expect(result.taxableAmountPaise, 100000);

      expect(result.cgstAmountPaise, 9000);

      expect(result.sgstAmountPaise, 9000);

      expect(result.igstAmountPaise, 0);

      expect(result.grandTotalPaise, 118000);
    });

    test('calculates IGST correctly', () {
      const items = [
        InvoiceLineInput(
          description: 'Service',
          quantity: 1,
          ratePaise: 100000,
        ),
      ];

      final result = InvoiceCalculator.calculate(
        items: items,
        taxType: InvoiceTaxType.taxable,
        gstMode: InvoiceGstMode.igst,
        igstRate: 18,
      );

      expect(result.cgstAmountPaise, 0);

      expect(result.sgstAmountPaise, 0);

      expect(result.igstAmountPaise, 18000);

      expect(result.grandTotalPaise, 118000);
    });

    test('non taxable invoice has zero GST', () {
      const items = [InvoiceLineInput(quantity: 1, ratePaise: 100000)];

      final result = InvoiceCalculator.calculate(
        items: items,
        taxType: InvoiceTaxType.nonTaxable,
        gstMode: InvoiceGstMode.cgstSgst,
      );

      expect(result.taxableAmountPaise, 0);

      expect(result.cgstAmountPaise, 0);

      expect(result.sgstAmountPaise, 0);

      expect(result.igstAmountPaise, 0);

      expect(result.grandTotalPaise, 100000);
    });

    test('supports decimal quantities', () {
      const item = InvoiceLineInput(quantity: 2.5, ratePaise: 10000);

      expect(item.amountPaise, 25000);
    });

    test('default draft contains five rows', () {
      final draft = InvoiceDraftModel();

      expect(draft.items.length, 5);
    });
  });
}
