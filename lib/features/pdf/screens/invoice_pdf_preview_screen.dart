import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../invoices/providers/invoice_list_providers.dart';
import '../data/invoice_pdf_service.dart';

class InvoicePdfPreviewScreen extends ConsumerWidget {
  final String invoiceId;

  const InvoicePdfPreviewScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(invoiceDetailProvider(invoiceId));

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice PDF')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to prepare PDF.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (detail) {
          return PdfPreview(
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowPrinting: true,
            allowSharing: true,
            initialPageFormat: PdfPageFormat.a4,
            pdfFileName: '${_safeFileName(detail.invoice.invoiceNumber)}.pdf',
            build: (format) {
              return InvoicePdfService.buildPdf(
                invoice: detail.invoice,
                items: detail.items,
                pageFormat: format,
              );
            },
          );
        },
      ),
    );
  }

  String _safeFileName(String invoiceNumber) {
    return invoiceNumber
        .replaceAll('/', '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '');
  }
}
