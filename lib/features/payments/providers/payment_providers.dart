import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../invoices/providers/invoice_list_providers.dart';
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

final allPaymentsProvider = StreamProvider<List<Payment>>((ref) async* {
  final db = ref.watch(appDatabaseProvider);

  final invoices = await ref.watch(allInvoicesProvider.future);

  if (invoices.isEmpty) {
    yield const <Payment>[];
    return;
  }

  final allowedInvoiceIds = invoices.map((invoice) => invoice.id).toSet();

  await for (final payments in db.watchAllPayments()) {
    yield payments
        .where((payment) => allowedInvoiceIds.contains(payment.invoiceId))
        .toList();
  }
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
