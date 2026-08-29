enum PaymentMode { cash, bankTransfer, upi, cheque, card, other }

extension PaymentModeLabel on PaymentMode {
  String get storageValue {
    switch (this) {
      case PaymentMode.cash:
        return 'cash';
      case PaymentMode.bankTransfer:
        return 'bankTransfer';
      case PaymentMode.upi:
        return 'upi';
      case PaymentMode.cheque:
        return 'cheque';
      case PaymentMode.card:
        return 'card';
      case PaymentMode.other:
        return 'other';
    }
  }

  String get label {
    switch (this) {
      case PaymentMode.cash:
        return 'Cash';
      case PaymentMode.bankTransfer:
        return 'Bank Transfer';
      case PaymentMode.upi:
        return 'UPI';
      case PaymentMode.cheque:
        return 'Cheque';
      case PaymentMode.card:
        return 'Card';
      case PaymentMode.other:
        return 'Other';
    }
  }
}

enum InvoicePaymentState { unpaid, partiallyPaid, paid }

class InvoicePaymentSummary {
  final int invoiceTotalPaise;
  final int paidPaise;
  final int outstandingPaise;
  final InvoicePaymentState state;

  const InvoicePaymentSummary({
    required this.invoiceTotalPaise,
    required this.paidPaise,
    required this.outstandingPaise,
    required this.state,
  });
}
