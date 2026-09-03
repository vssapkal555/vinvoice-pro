import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../invoices/providers/invoice_list_providers.dart';
import 'invoice_pdf_service.dart';

class InvoicePdfActions {
  const InvoicePdfActions._();

  static Future<bool?> chooseCompanyHeaderMode(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose invoice paper',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              Text(
                'Choose how the company header should appear on this PDF.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              _PdfPaperModeTile(
                icon: Icons.description_outlined,
                title: 'VInvoice / Company Header',
                subtitle: 'Print logo, company name, address, GSTIN and PAN.',
                accent: scheme.primary,
                onTap: () => Navigator.pop(context, true),
              ),
              const SizedBox(height: 9),
              _PdfPaperModeTile(
                icon: Icons.print_outlined,
                title: 'Preprinted Letterhead',
                subtitle:
                    'Hide the company header and reserve about 35 mm at the top of page 1.',
                accent: scheme.secondary,
                onTap: () => Navigator.pop(context, false),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> printOrSave(
    InvoiceDetailData detail, {
    bool includeCompanyHeader = true,
  }) async {
    await Printing.layoutPdf(
      name: _fileName(detail.invoice.invoiceNumber),
      onLayout: (format) {
        return InvoicePdfService.buildPdf(
          invoice: detail.invoice,
          items: detail.items,
          pageFormat: format,
          includeCompanyHeader: includeCompanyHeader,
        );
      },
    );
  }

  static Future<bool> share(
    InvoiceDetailData detail, {
    bool includeCompanyHeader = true,
  }) async {
    final bytes = await InvoicePdfService.buildPdf(
      invoice: detail.invoice,
      items: detail.items,
      includeCompanyHeader: includeCompanyHeader,
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

class _PdfPaperModeTile extends StatelessWidget {
  const _PdfPaperModeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
