import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../data/payment_calculator.dart';
import '../models/payment_models.dart';

final invoicePaymentsProvider = StreamProvider.family<List<Payment>, String>((
  ref,
  invoiceId,
) {
  final db = ref.watch(appDatabaseProvider);

  return db.watchPaymentsForInvoice(invoiceId);
});

final invoicePaymentSummaryProvider =
    FutureProvider.family<InvoicePaymentSummary, String>((
      ref,
      invoiceId,
    ) async {
      final db = ref.watch(appDatabaseProvider);

      final invoice = await db.getInvoiceById(invoiceId);

      if (invoice == null) {
        throw StateError('Invoice not found.');
      }

      final payments = await db.getPaymentsForInvoice(invoiceId);

      return PaymentCalculator.summarize(
        invoiceTotalPaise: invoice.grandTotalPaise,
        payments: payments.map((payment) => payment.amountPaise),
      );
    });

final allPaymentsProvider = StreamProvider<List<Payment>>((ref) {
  final db = ref.watch(appDatabaseProvider);

  return db.watchAllPayments();
});

final paidAmountByInvoiceProvider = Provider<Map<String, int>>((ref) {
  final paymentsAsync = ref.watch(allPaymentsProvider);

  return paymentsAsync.maybeWhen(
    data: (payments) {
      final totals = <String, int>{};

      for (final payment in payments) {
        totals.update(
          payment.invoiceId,
          (current) => current + payment.amountPaise,
          ifAbsent: () => payment.amountPaise,
        );
      }

      return totals;
    },
    orElse: () => const <String, int>{},
  );
});
