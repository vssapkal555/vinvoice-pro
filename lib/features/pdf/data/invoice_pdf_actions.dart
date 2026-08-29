import 'package:printing/printing.dart';

import '../../invoices/providers/invoice_list_providers.dart';
import 'invoice_pdf_service.dart';

class InvoicePdfActions {
  const InvoicePdfActions._();

  static Future<void> printOrSave(InvoiceDetailData detail) async {
    await Printing.layoutPdf(
      name: _fileName(detail.invoice.invoiceNumber),
      onLayout: (format) {
        return InvoicePdfService.buildPdf(
          invoice: detail.invoice,
          items: detail.items,
          pageFormat: format,
        );
      },
    );
  }

  static Future<bool> share(InvoiceDetailData detail) async {
    final bytes = await InvoicePdfService.buildPdf(
      invoice: detail.invoice,
      items: detail.items,
    );

    return Printing.sharePdf(
      bytes: bytes,
      filename: _fileName(detail.invoice.invoiceNumber),
    );
  }

  static String _fileName(String invoiceNumber) {
    final safe = invoiceNumber
        .replaceAll('/', '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '');

    return '$safe.pdf';
  }
}
