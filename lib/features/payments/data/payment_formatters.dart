import '../models/payment_models.dart';

String paymentStateLabel(InvoicePaymentState state) {
  switch (state) {
    case InvoicePaymentState.unpaid:
      return 'UNPAID';
    case InvoicePaymentState.partiallyPaid:
      return 'PARTIALLY PAID';
    case InvoicePaymentState.paid:
      return 'PAID';
  }
}

String paymentModeLabel(String value) {
  switch (value) {
    case 'cash':
      return 'Cash';
    case 'bankTransfer':
      return 'Bank Transfer';
    case 'upi':
      return 'UPI';
    case 'cheque':
      return 'Cheque';
    case 'card':
      return 'Card';
    default:
      return 'Other';
  }
}
