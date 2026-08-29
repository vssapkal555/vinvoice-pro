import 'package:flutter_test/flutter_test.dart';
import 'package:vinvoice_pro/features/payments/data/payment_calculator.dart';
import 'package:vinvoice_pro/features/payments/models/payment_models.dart';

void main() {
  test('invoice with no payments is unpaid', () {
    final result = PaymentCalculator.summarize(
      invoiceTotalPaise: 100000,
      payments: const [],
    );

    expect(result.paidPaise, 0);

    expect(result.outstandingPaise, 100000);

    expect(result.state, InvoicePaymentState.unpaid);
  });

  test('partial payment calculates outstanding', () {
    final result = PaymentCalculator.summarize(
      invoiceTotalPaise: 100000,
      payments: const [25000, 15000],
    );

    expect(result.paidPaise, 40000);

    expect(result.outstandingPaise, 60000);

    expect(result.state, InvoicePaymentState.partiallyPaid);
  });

  test('full payment marks invoice paid', () {
    final result = PaymentCalculator.summarize(
      invoiceTotalPaise: 100000,
      payments: const [60000, 40000],
    );

    expect(result.paidPaise, 100000);

    expect(result.outstandingPaise, 0);

    expect(result.state, InvoicePaymentState.paid);
  });

  test('outstanding never becomes negative', () {
    final result = PaymentCalculator.summarize(
      invoiceTotalPaise: 100000,
      payments: const [110000],
    );

    expect(result.outstandingPaise, 0);

    expect(result.state, InvoicePaymentState.paid);
  });
}
