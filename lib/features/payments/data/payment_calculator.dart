import '../models/payment_models.dart';

class PaymentCalculator {
  const PaymentCalculator._();

  static InvoicePaymentSummary summarize({
    required int invoiceTotalPaise,
    required Iterable<int> payments,
  }) {
    final paid = payments.fold<int>(0, (total, payment) => total + payment);

    final outstanding = invoiceTotalPaise - paid;

    final normalizedOutstanding = outstanding < 0 ? 0 : outstanding;

    InvoicePaymentState state;

    if (paid <= 0) {
      state = InvoicePaymentState.unpaid;
    } else if (paid >= invoiceTotalPaise) {
      state = InvoicePaymentState.paid;
    } else {
      state = InvoicePaymentState.partiallyPaid;
    }

    return InvoicePaymentSummary(
      invoiceTotalPaise: invoiceTotalPaise,
      paidPaise: paid,
      outstandingPaise: normalizedOutstanding,
      state: state,
    );
  }
}
