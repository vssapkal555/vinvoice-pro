import '../../../core/utils/amount_in_words.dart';
import '../models/invoice_form_models.dart';

class InvoiceCalculationResult {
  final int basicAmountPaise;
  final int taxableAmountPaise;

  final double cgstRate;
  final int cgstAmountPaise;

  final double sgstRate;
  final int sgstAmountPaise;

  final double igstRate;
  final int igstAmountPaise;

  final int grandTotalPaise;

  final String amountInWords;

  const InvoiceCalculationResult({
    required this.basicAmountPaise,
    required this.taxableAmountPaise,
    required this.cgstRate,
    required this.cgstAmountPaise,
    required this.sgstRate,
    required this.sgstAmountPaise,
    required this.igstRate,
    required this.igstAmountPaise,
    required this.grandTotalPaise,
    required this.amountInWords,
  });
}

class InvoiceCalculator {
  const InvoiceCalculator._();

  static InvoiceCalculationResult calculate({
    required List<InvoiceLineInput> items,
    required InvoiceTaxType taxType,
    required InvoiceGstMode gstMode,
    double cgstRate = 9,
    double sgstRate = 9,
    double igstRate = 18,
  }) {
    final basicAmountPaise = items.fold<int>(
      0,
      (total, item) => total + item.amountPaise,
    );

    final isTaxable = taxType == InvoiceTaxType.taxable;

    final taxableAmountPaise = isTaxable ? basicAmountPaise : 0;

    var effectiveCgstRate = 0.0;
    var effectiveSgstRate = 0.0;
    var effectiveIgstRate = 0.0;

    var cgstAmountPaise = 0;
    var sgstAmountPaise = 0;
    var igstAmountPaise = 0;

    if (isTaxable) {
      switch (gstMode) {
        case InvoiceGstMode.cgstSgst:
          effectiveCgstRate = cgstRate;
          effectiveSgstRate = sgstRate;

          cgstAmountPaise = _calculateTax(taxableAmountPaise, cgstRate);

          sgstAmountPaise = _calculateTax(taxableAmountPaise, sgstRate);

          break;

        case InvoiceGstMode.igst:
          effectiveIgstRate = igstRate;

          igstAmountPaise = _calculateTax(taxableAmountPaise, igstRate);

          break;

        case InvoiceGstMode.none:
          break;
      }
    }

    final grandTotalPaise =
        basicAmountPaise + cgstAmountPaise + sgstAmountPaise + igstAmountPaise;

    return InvoiceCalculationResult(
      basicAmountPaise: basicAmountPaise,
      taxableAmountPaise: taxableAmountPaise,
      cgstRate: effectiveCgstRate,
      cgstAmountPaise: cgstAmountPaise,
      sgstRate: effectiveSgstRate,
      sgstAmountPaise: sgstAmountPaise,
      igstRate: effectiveIgstRate,
      igstAmountPaise: igstAmountPaise,
      grandTotalPaise: grandTotalPaise,
      amountInWords: AmountInWords.fromPaise(grandTotalPaise),
    );
  }

  static int _calculateTax(int taxableAmountPaise, double percentage) {
    if (taxableAmountPaise <= 0 || percentage <= 0) {
      return 0;
    }

    return (taxableAmountPaise * percentage / 100).round();
  }
}
