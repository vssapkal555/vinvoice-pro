class ReportInvoiceRecord {
  const ReportInvoiceRecord({
    required this.id,
    required this.invoiceDate,
    required this.status,
    required this.grandTotalPaise,
    required this.taxableAmountPaise,
    required this.cgstAmountPaise,
    required this.sgstAmountPaise,
    required this.igstAmountPaise,
    required this.partyName,
  });

  final String id;
  final DateTime invoiceDate;
  final String status;

  final int grandTotalPaise;
  final int taxableAmountPaise;

  final int cgstAmountPaise;
  final int sgstAmountPaise;
  final int igstAmountPaise;

  final String partyName;

  bool get isIssued => status.toLowerCase() == 'issued';

  bool get isDraft => status.toLowerCase() == 'draft';

  bool get isCancelled => status.toLowerCase() == 'cancelled';
}

class ReportPaymentRecord {
  const ReportPaymentRecord({
    required this.invoiceId,
    required this.paymentDate,
    required this.amountPaise,
  });

  final String invoiceId;
  final DateTime paymentDate;
  final int amountPaise;
}

enum ReportPaymentStatus { paid, partiallyPaid, unpaid }

class FinancialReportSummary {
  const FinancialReportSummary({
    required this.invoicedPaise,
    required this.collectedPaise,
    required this.outstandingPaise,
    required this.taxablePaise,
    required this.cgstPaise,
    required this.sgstPaise,
    required this.igstPaise,
    required this.issuedCount,
    required this.paidCount,
    required this.partiallyPaidCount,
    required this.unpaidCount,
    required this.draftCount,
    required this.cancelledCount,
  });

  final int invoicedPaise;
  final int collectedPaise;
  final int outstandingPaise;

  final int taxablePaise;
  final int cgstPaise;
  final int sgstPaise;
  final int igstPaise;

  final int issuedCount;
  final int paidCount;
  final int partiallyPaidCount;
  final int unpaidCount;

  final int draftCount;
  final int cancelledCount;

  double get collectionPercentage {
    if (invoicedPaise <= 0) return 0;

    final paidAgainstSelectedInvoices = (invoicedPaise - outstandingPaise)
        .clamp(0, invoicedPaise);

    return (paidAgainstSelectedInvoices / invoicedPaise) * 100;
  }
}
