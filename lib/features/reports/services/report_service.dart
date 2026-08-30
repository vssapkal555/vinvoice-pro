import '../models/report_date_range.dart';
import '../models/report_models.dart';

class ReportService {
  const ReportService._();

  static FinancialReportSummary financialSummary({
    required List<ReportInvoiceRecord> invoices,
    required List<ReportPaymentRecord> payments,
    required ReportDateRange range,
  }) {
    final invoicesInRange = invoices
        .where((invoice) => range.contains(invoice.invoiceDate))
        .toList();

    final issued = invoicesInRange
        .where((invoice) => invoice.isIssued)
        .toList();

    final allPaymentsByInvoice = <String, int>{};

    for (final payment in payments) {
      allPaymentsByInvoice.update(
        payment.invoiceId,
        (existing) => existing + payment.amountPaise,
        ifAbsent: () => payment.amountPaise,
      );
    }

    var invoicedPaise = 0;
    var outstandingPaise = 0;

    var taxablePaise = 0;
    var cgstPaise = 0;
    var sgstPaise = 0;
    var igstPaise = 0;

    var paidCount = 0;
    var partiallyPaidCount = 0;
    var unpaidCount = 0;

    for (final invoice in issued) {
      invoicedPaise += invoice.grandTotalPaise;

      taxablePaise += invoice.taxableAmountPaise;
      cgstPaise += invoice.cgstAmountPaise;
      sgstPaise += invoice.sgstAmountPaise;
      igstPaise += invoice.igstAmountPaise;

      final paid = allPaymentsByInvoice[invoice.id] ?? 0;

      final outstanding = (invoice.grandTotalPaise - paid).clamp(
        0,
        invoice.grandTotalPaise,
      );

      outstandingPaise += outstanding;

      final status = paymentStatus(
        invoiceTotalPaise: invoice.grandTotalPaise,
        paidPaise: paid,
      );

      switch (status) {
        case ReportPaymentStatus.paid:
          paidCount++;
          break;

        case ReportPaymentStatus.partiallyPaid:
          partiallyPaidCount++;
          break;

        case ReportPaymentStatus.unpaid:
          unpaidCount++;
          break;
      }
    }

    // Collections are intentionally filtered by PAYMENT DATE,
    // independently from invoice date.
    final collectedPaise = payments
        .where((payment) => range.contains(payment.paymentDate))
        .fold<int>(0, (total, payment) => total + payment.amountPaise);

    return FinancialReportSummary(
      invoicedPaise: invoicedPaise,
      collectedPaise: collectedPaise,
      outstandingPaise: outstandingPaise,
      taxablePaise: taxablePaise,
      cgstPaise: cgstPaise,
      sgstPaise: sgstPaise,
      igstPaise: igstPaise,
      issuedCount: issued.length,
      paidCount: paidCount,
      partiallyPaidCount: partiallyPaidCount,
      unpaidCount: unpaidCount,
      draftCount: invoicesInRange.where((e) => e.isDraft).length,
      cancelledCount: invoicesInRange.where((e) => e.isCancelled).length,
    );
  }

  static ReportPaymentStatus paymentStatus({
    required int invoiceTotalPaise,
    required int paidPaise,
  }) {
    if (invoiceTotalPaise <= 0 || paidPaise >= invoiceTotalPaise) {
      return ReportPaymentStatus.paid;
    }

    if (paidPaise > 0) {
      return ReportPaymentStatus.partiallyPaid;
    }

    return ReportPaymentStatus.unpaid;
  }
}
