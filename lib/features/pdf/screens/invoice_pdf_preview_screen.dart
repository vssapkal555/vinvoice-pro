import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../invoices/providers/invoice_list_providers.dart';
import '../data/invoice_pdf_service.dart';

class InvoicePdfPreviewScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoicePdfPreviewScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoicePdfPreviewScreen> createState() =>
      _InvoicePdfPreviewScreenState();
}

class _InvoicePdfPreviewScreenState
    extends ConsumerState<InvoicePdfPreviewScreen> {
  bool _usePreprintedLetterhead = false;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(invoiceDetailProvider(widget.invoiceId));
    final scheme = Theme.of(context).colorScheme;

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
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        _usePreprintedLetterhead
                            ? Icons.print_outlined
                            : Icons.description_outlined,
                        color: scheme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preprinted Letterhead',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Reserve ~35 mm on page 1 and hide company header',
                            style: TextStyle(fontSize: 9.5),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _usePreprintedLetterhead,
                      onChanged: (value) {
                        setState(() {
                          _usePreprintedLetterhead = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PdfPreview(
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  allowPrinting: true,
                  allowSharing: true,
                  initialPageFormat: PdfPageFormat.a4,
                  pdfFileName:
                      '${_safeFileName(detail.invoice.invoiceNumber)}.pdf',
                  build: (format) {
                    return InvoicePdfService.buildPdf(
                      invoice: detail.invoice,
                      items: detail.items,
                      pageFormat: format,
                      includeCompanyHeader: !_usePreprintedLetterhead,
                    );
                  },
                ),
              ),
            ],
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
