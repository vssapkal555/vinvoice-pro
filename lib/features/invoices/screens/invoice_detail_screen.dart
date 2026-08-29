import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../providers/invoice_list_providers.dart';
import '../../pdf/data/invoice_pdf_actions.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(invoiceDetailProvider(invoiceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        actions: [
          detailAsync.maybeWhen(
            data: (detail) {
              if (detail.invoice.status != 'draft') {
                return const SizedBox.shrink();
              }

              return PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    await context.push('/invoices/$invoiceId/edit');

                    ref.invalidate(invoiceDetailProvider(invoiceId));

                    return;
                  }

                  if (value == 'issue') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Issue Invoice?'),
                        content: const Text(
                          'Once issued, this invoice will no longer be editable as a draft.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text('Issue Invoice'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed != true) {
                      return;
                    }

                    final db = ref.read(appDatabaseProvider);

                    await db.updateInvoiceStatus(
                      invoiceId: invoiceId,
                      status: 'issued',
                    );

                    ref.invalidate(invoiceDetailProvider(invoiceId));

                    ref.invalidate(allInvoicesProvider);

                    return;
                  }

                  if (value == 'cancel') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cancel Invoice?'),
                        content: const Text(
                          'The invoice will remain in records with Cancelled status.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text('Keep Invoice'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text('Cancel Invoice'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed != true) {
                      return;
                    }

                    final db = ref.read(appDatabaseProvider);

                    await db.updateInvoiceStatus(
                      invoiceId: invoiceId,
                      status: 'cancelled',
                    );

                    ref.invalidate(invoiceDetailProvider(invoiceId));

                    ref.invalidate(allInvoicesProvider);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit Draft'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'issue',
                    child: ListTile(
                      leading: Icon(Icons.check_circle_outline),
                      title: Text('Issue Invoice'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'cancel',
                    child: ListTile(
                      leading: Icon(Icons.cancel_outlined),
                      title: Text('Cancel Invoice'),
                    ),
                  ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load invoice.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (detail) => _InvoiceDetailContent(detail: detail),
      ),
    );
  }
}

class _InvoiceDetailContent extends StatelessWidget {
  final InvoiceDetailData detail;

  const _InvoiceDetailContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    final invoice = detail.invoice;

    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 2,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _InvoicePdfActionsBar(detail: detail),

        _HeaderCard(invoice: invoice, currency: currency),

        _Section(
          title: 'Party Details',
          icon: Icons.business_outlined,
          children: [
            _DetailRow(label: 'Party Name', value: invoice.partyNameSnapshot),
            _optionalRow('Address 1', invoice.partyAddress1Snapshot),
            _optionalRow('Address 2', invoice.partyAddress2Snapshot),
            _optionalRow(
              'Address 3',
              _cleanAddress(invoice.partyAddress3Snapshot),
            ),
            _optionalRow('PAN', invoice.partyPanSnapshot),
            _optionalRow('GSTIN', invoice.partyGstinSnapshot),
          ],
        ),

        _Section(
          title: 'Invoice Information',
          icon: Icons.description_outlined,
          children: [
            _DetailRow(label: 'Invoice No.', value: invoice.invoiceNumber),
            _DetailRow(
              label: 'Invoice Date',
              value: DateFormat('dd-MM-yyyy').format(invoice.invoiceDate),
            ),
            _optionalRow('PO No.', invoice.poNumber),
            _optionalRow('Vendor Code', invoice.vendorCodeSnapshot),
            _optionalRow('Site / Plant', invoice.siteNameSnapshot),
            _optionalRow('Service Entry', invoice.serviceEntry),
            if (invoice.serviceFrom != null)
              _DetailRow(
                label: 'Service From',
                value: DateFormat('dd-MM-yyyy').format(invoice.serviceFrom!),
              ),
            if (invoice.serviceTo != null)
              _DetailRow(
                label: 'Service To',
                value: DateFormat('dd-MM-yyyy').format(invoice.serviceTo!),
              ),
          ],
        ),

        _ItemsSection(items: detail.items, currency: currency),

        _TaxSummary(invoice: invoice, currency: currency),

        _Section(
          title: 'Amount in Words',
          icon: Icons.translate_rounded,
          children: [
            Text(
              invoice.amountInWords ?? '',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),

        _Section(
          title: 'Seller Details',
          icon: Icons.apartment_rounded,
          children: [
            _DetailRow(label: 'Company', value: invoice.companyNameSnapshot),
            _optionalRow('Address 1', invoice.companyAddress1Snapshot),
            _optionalRow('Address 2', invoice.companyAddress2Snapshot),
            _optionalRow(
              'Address 3',
              _cleanAddress(invoice.companyAddress3Snapshot),
            ),
            _optionalRow('PAN', invoice.companyPanSnapshot),
            _optionalRow('GSTIN', invoice.companyGstinSnapshot),
          ],
        ),
      ],
    );
  }

  String? _cleanAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return value;
    }

    final seen = <String>{};
    final parts = <String>[];

    for (final piece in value.split(',')) {
      final text = piece.trim();

      if (text.isEmpty) {
        continue;
      }

      if (seen.add(text.toLowerCase())) {
        parts.add(text);
      }
    }

    return parts.join(', ');
  }

  Widget _optionalRow(String label, String? value) {
    if ((value ?? '').trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return _DetailRow(label: label, value: value!);
  }
}

class _HeaderCard extends StatelessWidget {
  final Invoice invoice;
  final NumberFormat currency;

  const _HeaderCard({required this.invoice, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  invoice.invoiceNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  invoice.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            invoice.partyNameSnapshot,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 22),
          const Text('Grand Total', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 3),
          Text(
            currency.format(MoneyUtils.paiseToRupees(invoice.grandTotalPaise)),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsSection extends StatelessWidget {
  final List<InvoiceItem> items;
  final NumberFormat currency;

  const _ItemsSection({required this.items, required this.currency});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Description of Service',
      icon: Icons.list_alt_rounded,
      children: [
        if (items.isEmpty)
          const Text('No invoice items found.')
        else
          for (final item in items)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        child: Text(
                          '${item.serialNo}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.description,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if ((item.hsnSac ?? '').isNotEmpty)
                    _MiniRow(label: 'HSN/SAC', value: item.hsnSac!),
                  _MiniRow(label: 'QTY', value: _formatQty(item.quantity)),
                  _MiniRow(label: 'Unit', value: item.unitCodeSnapshot ?? ''),
                  _MiniRow(
                    label: 'Rate',
                    value: currency.format(
                      MoneyUtils.paiseToRupees(item.ratePaise),
                    ),
                  ),
                  _MiniRow(
                    label: 'Amount',
                    value: currency.format(
                      MoneyUtils.paiseToRupees(item.amountPaise),
                    ),
                    emphasize: true,
                  ),
                ],
              ),
            ),
      ],
    );
  }

  String _formatQty(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }
}

class _TaxSummary extends StatelessWidget {
  final Invoice invoice;
  final NumberFormat currency;

  const _TaxSummary({required this.invoice, required this.currency});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Invoice Summary',
      icon: Icons.calculate_outlined,
      children: [
        _DetailRow(
          label: 'Tax Type',
          value: invoice.taxType == 'nonTaxable' ? 'Non-Taxable' : 'Taxable',
        ),
        _MoneyRow(
          label: 'Basic Amount',
          paise: invoice.basicAmountPaise,
          currency: currency,
        ),
        if (invoice.taxType == 'taxable')
          _MoneyRow(
            label: 'Taxable Amount',
            paise: invoice.taxableAmountPaise,
            currency: currency,
          ),
        if (invoice.cgstAmountPaise > 0)
          _MoneyRow(
            label: 'CGST @ ${_rate(invoice.cgstRate)}%',
            paise: invoice.cgstAmountPaise,
            currency: currency,
          ),
        if (invoice.sgstAmountPaise > 0)
          _MoneyRow(
            label: 'SGST @ ${_rate(invoice.sgstRate)}%',
            paise: invoice.sgstAmountPaise,
            currency: currency,
          ),
        if (invoice.igstAmountPaise > 0)
          _MoneyRow(
            label: 'IGST @ ${_rate(invoice.igstRate)}%',
            paise: invoice.igstAmountPaise,
            currency: currency,
          ),
        const Divider(height: 26),
        _MoneyRow(
          label: 'Grand Total',
          paise: invoice.grandTotalPaise,
          currency: currency,
          emphasize: true,
        ),
      ],
    );
  }

  String _rate(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.secondaryText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final int paise;
  final NumberFormat currency;
  final bool emphasize;

  const _MoneyRow({
    required this.label,
    required this.paise,
    required this.currency,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: emphasize ? 18 : 15,
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(currency.format(MoneyUtils.paiseToRupees(paise)), style: style),
        ],
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _MiniRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.secondaryText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoicePdfActionsBar extends StatelessWidget {
  final InvoiceDetailData detail;

  const _InvoicePdfActionsBar({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/invoices/${detail.invoice.id}/pdf');
                },
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Preview'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await InvoicePdfActions.printOrSave(detail);
                },
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () async {
                  await InvoicePdfActions.share(detail);
                },
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
