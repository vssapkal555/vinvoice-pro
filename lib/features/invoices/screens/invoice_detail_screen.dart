import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../payments/providers/payment_providers.dart';
import '../../payments/data/payment_formatters.dart';
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
    final paymentsAsync = ref.watch(invoicePaymentsProvider(invoiceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        actions: [
          detailAsync.maybeWhen(
            data: (detail) {
              final status = detail.invoice.status.toLowerCase();
              if (status != 'draft' && status != 'issued') {
                return const SizedBox.shrink();
              }

              final hasPayments = paymentsAsync.when<bool?>(
                loading: () => null,
                error: (error, stack) => null,
                data: (payments) => payments.isNotEmpty,
              );
              if (status == 'issued' && hasPayments == null) {
                return const SizedBox.shrink();
              }
              final paymentLocked = hasPayments ?? false;

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
                          'The invoice will be marked as Issued. It can still be corrected until payment activity is recorded.',
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
                itemBuilder: (context) => [
                  if (!paymentLocked)
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: const Icon(Icons.edit_outlined),
                        title: Text(
                          status == 'issued' ? 'Edit Invoice' : 'Edit Draft',
                        ),
                      ),
                    ),
                  if (status == 'draft')
                    const PopupMenuItem(
                      value: 'issue',
                      child: ListTile(
                        leading: Icon(Icons.check_circle_outline),
                        title: Text('Issue Invoice'),
                      ),
                    ),
                  if (!paymentLocked)
                    const PopupMenuItem(
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _HeaderCard(invoice: invoice, currency: currency),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: _InvoicePdfActionsBar(detail: detail),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
            children: [
              _Section(
                title: 'Party Details',
                icon: Icons.business_outlined,
                initiallyExpanded: false,
                collapsedChild: _DetailRow(
                  label: 'Party Name',
                  value: invoice.partyNameSnapshot,
                ),
                children: [
                  _DetailRow(
                    label: 'Party Name',
                    value: invoice.partyNameSnapshot,
                  ),
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
                initiallyExpanded: false,
                collapsedChild: _DetailRow(
                  label: 'Invoice No.',
                  value: invoice.invoiceNumber,
                ),
                children: [
                  _DetailRow(
                    label: 'Invoice No.',
                    value: invoice.invoiceNumber,
                  ),
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
                      value: DateFormat(
                        'dd-MM-yyyy',
                      ).format(invoice.serviceFrom!),
                    ),
                  if (invoice.serviceTo != null)
                    _DetailRow(
                      label: 'Service To',
                      value: DateFormat(
                        'dd-MM-yyyy',
                      ).format(invoice.serviceTo!),
                    ),
                ],
              ),
              _ItemsSection(items: detail.items, currency: currency),
              _TaxSummary(invoice: invoice, currency: currency),
              _InvoicePaymentCard(
                invoiceId: invoice.id,
                invoiceStatus: invoice.status,
              ),
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
                initiallyExpanded: false,
                collapsedChild: _DetailRow(
                  label: 'Company',
                  value: invoice.companyNameSnapshot,
                ),
                children: [
                  _DetailRow(
                    label: 'Company',
                    value: invoice.companyNameSnapshot,
                  ),
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
          ),
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
    final scheme = Theme.of(context).colorScheme;
    final status = invoice.status.toLowerCase();

    final statusLabel = switch (status) {
      'issued' => 'ISSUED',
      'cancelled' => 'CANCELLED',
      _ => 'DRAFT',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.secondary, 0.60)!,
          ],
        ),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.13),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        invoice.invoiceNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        statusLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  invoice.partyNameSnapshot,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Grand Total',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  currency.format(
                    MoneyUtils.paiseToRupees(invoice.grandTotalPaise),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('dd MMM yyyy').format(invoice.invoiceDate),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
      title: 'Services',
      icon: Icons.list_alt_rounded,
      children: [
        if (items.isEmpty)
          const Text(
            'No invoice items found.',
            style: TextStyle(color: AppTheme.secondaryText),
          )
        else
          for (var index = 0; index < items.length; index++) ...[
            _ServiceDetailTile(item: items[index], currency: currency),
            if (index < items.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _ServiceDetailTile extends StatelessWidget {
  const _ServiceDetailTile({required this.item, required this.currency});

  final InvoiceItem item;
  final NumberFormat currency;

  String _formatQty(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final amount = currency.format(MoneyUtils.paiseToRupees(item.amountPaise));

    final rate = currency.format(MoneyUtils.paiseToRupees(item.ratePaise));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  item.serialNo.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Text(
                amount,
                style: const TextStyle(
                  color: AppTheme.primaryDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if ((item.hsnSac ?? '').trim().isNotEmpty)
                _ServiceMetaChip(label: 'HSN/SAC', value: item.hsnSac!),

              _ServiceMetaChip(label: 'Qty', value: _formatQty(item.quantity)),

              if ((item.unitCodeSnapshot ?? '').trim().isNotEmpty)
                _ServiceMetaChip(label: 'Unit', value: item.unitCodeSnapshot!),

              _ServiceMetaChip(label: 'Rate', value: rate),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceMetaChip extends StatelessWidget {
  const _ServiceMetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 10, color: AppTheme.secondaryText),
          children: [
            TextSpan(text: '$label  '),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: AppTheme.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaxSummary extends StatelessWidget {
  final Invoice invoice;
  final NumberFormat currency;

  const _TaxSummary({required this.invoice, required this.currency});

  String _money(int paise) {
    return currency.format(MoneyUtils.paiseToRupees(paise));
  }

  @override
  Widget build(BuildContext context) {
    final taxable = invoice.taxType == 'taxable';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Color.lerp(
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              0.60,
            )!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            blurRadius: 17,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  color: Colors.white,
                  size: 19,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Text(
                  'Invoice Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  taxable ? 'TAXABLE' : 'NON-TAXABLE',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          _DarkInvoiceRow(
            label: 'Basic Amount',
            value: _money(invoice.basicAmountPaise),
          ),

          if (taxable)
            _DarkInvoiceRow(
              label: 'Taxable Amount',
              value: _money(invoice.taxableAmountPaise),
            ),

          if (invoice.cgstAmountPaise > 0)
            _DarkInvoiceRow(
              label: 'CGST @ ${_rate(invoice.cgstRate)}%',
              value: _money(invoice.cgstAmountPaise),
            ),

          if (invoice.sgstAmountPaise > 0)
            _DarkInvoiceRow(
              label: 'SGST @ ${_rate(invoice.sgstRate)}%',
              value: _money(invoice.sgstAmountPaise),
            ),

          if (invoice.igstAmountPaise > 0)
            _DarkInvoiceRow(
              label: 'IGST @ ${_rate(invoice.igstRate)}%',
              value: _money(invoice.igstAmountPaise),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white.withValues(alpha: 0.14)),
          ),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Grand Total',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _money(invoice.grandTotalPaise),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _rate(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }
}

class _DarkInvoiceRow extends StatelessWidget {
  const _DarkInvoiceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),

          const SizedBox(width: 12),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool initiallyExpanded;
  final Widget? collapsedChild;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
    this.initiallyExpanded = true,
    this.collapsedChild,
  });

  @override
  State<_Section> createState() => _SectionState();
}

class _SectionState extends State<_Section> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Color.lerp(AppTheme.border, scheme.primary, 0.07)!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(17),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: scheme.primary, size: 17),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: scheme.primary,
                    size: 21,
                  ),
                ],
              ),
            ),
          ),
          if (!_expanded && widget.collapsedChild != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 0, 13, 9),
              child: widget.collapsedChild!,
            ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 0, 13, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.children,
              ),
            ),
        ],
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

class _InvoicePdfActionsBar extends StatelessWidget {
  final InvoiceDetailData detail;

  const _InvoicePdfActionsBar({required this.detail});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Color.lerp(AppTheme.border, scheme.primary, 0.07)!,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _DocumentAction(
              icon: Icons.visibility_outlined,
              label: 'Preview',
              onTap: () {
                context.push('/invoices/${detail.invoice.id}/pdf');
              },
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: _DocumentAction(
              icon: Icons.print_outlined,
              label: 'Print',
              onTap: () async {
                final includeHeader =
                    await InvoicePdfActions.chooseCompanyHeaderMode(context);
                if (includeHeader == null) {
                  return;
                }

                await InvoicePdfActions.printOrSave(
                  detail,
                  includeCompanyHeader: includeHeader,
                );
              },
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: _DocumentAction(
              icon: Icons.share_outlined,
              label: 'Share',
              primary: true,
              onTap: () async {
                final includeHeader =
                    await InvoicePdfActions.chooseCompanyHeaderMode(context);
                if (includeHeader == null) {
                  return;
                }

                await InvoicePdfActions.share(
                  detail,
                  includeCompanyHeader: includeHeader,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentAction extends StatelessWidget {
  const _DocumentAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final background = primary
        ? scheme.primary
        : scheme.primaryContainer.withValues(alpha: 0.55);

    final foreground = primary ? Colors.white : scheme.primary;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: foreground),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvoicePaymentCard extends ConsumerWidget {
  final String invoiceId;
  final String invoiceStatus;

  const _InvoicePaymentCard({
    required this.invoiceId,
    required this.invoiceStatus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(invoicePaymentSummaryProvider(invoiceId));

    final paymentsAsync = ref.watch(invoicePaymentsProvider(invoiceId));

    final issued = invoiceStatus.toLowerCase() == 'issued';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 19,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payments',
                      style: TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Collection and outstanding balance',
                      style: TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          summaryAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: LinearProgressIndicator(),
            ),

            error: (error, stack) => Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('Unable to load payment summary.\n$error'),
            ),

            data: (summary) {
              final state = paymentStateLabel(summary.state);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _PaymentMetric(
                          label: 'Invoice Total',
                          value:
                              '\u20B9${MoneyUtils.paiseToRupeesText(summary.invoiceTotalPaise)}',
                          icon: Icons.receipt_long_outlined,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: _PaymentMetric(
                          label: 'Paid',
                          value:
                              '\u20B9${MoneyUtils.paiseToRupeesText(summary.paidPaise)}',
                          icon: Icons.check_circle_outline_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: summary.outstandingPaise > 0
                          ? Theme.of(context).colorScheme.primaryContainer
                          : AppTheme.surfaceSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: summary.outstandingPaise > 0
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.18)
                            : AppTheme.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: summary.outstandingPaise > 0
                                ? Theme.of(context).colorScheme.primary
                                : AppTheme.success,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            summary.outstandingPaise > 0
                                ? Icons.account_balance_wallet_outlined
                                : Icons.check_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Outstanding',
                                style: TextStyle(
                                  color: AppTheme.secondaryText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '\u20B9${MoneyUtils.paiseToRupeesText(summary.outstandingPaise)}',
                                  style: const TextStyle(
                                    color: AppTheme.darkText,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        _PaymentStatusChip(label: state),
                      ],
                    ),
                  ),

                  if (issued && summary.outstandingPaise > 0) ...[
                    const SizedBox(height: 13),

                    FilledButton.icon(
                      onPressed: () async {
                        await context.push('/invoices/$invoiceId/payment');

                        ref.invalidate(
                          invoicePaymentSummaryProvider(invoiceId),
                        );

                        ref.invalidate(invoicePaymentsProvider(invoiceId));
                      },
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Record Payment'),
                    ),
                  ],

                  if (!issued && summary.outstandingPaise > 0) ...[
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 17,
                            color: AppTheme.secondaryText,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Payments become available after the invoice is issued.',
                              style: TextStyle(
                                color: AppTheme.secondaryText,
                                fontSize: 11,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 18),

          const Divider(height: 1),

          const SizedBox(height: 16),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Payment History',
                  style: TextStyle(
                    color: AppTheme.darkText,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              paymentsAsync.maybeWhen(
                data: (payments) => Text(
                  '${payments.length} record${payments.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),

          const SizedBox(height: 10),

          paymentsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(),
            ),

            error: (error, stack) =>
                Text('Unable to load payment history.\n$error'),

            data: (payments) {
              if (payments.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        color: AppTheme.tertiaryText,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'No payments recorded yet.',
                          style: TextStyle(
                            color: AppTheme.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  for (var index = 0; index < payments.length; index++) ...[
                    _PaymentHistoryTile(payment: payments[index]),

                    if (index < payments.length - 1) const SizedBox(height: 8),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PaymentMetric extends StatelessWidget {
  const _PaymentMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),

          const SizedBox(height: 9),

          Text(
            label,
            style: const TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 3),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.darkText,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusChip extends StatelessWidget {
  const _PaymentStatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final normalized = label.toLowerCase();

    final isPaid = normalized == 'paid';
    final isPartial = normalized.contains('partial');

    final background = isPaid
        ? AppTheme.successSoft
        : isPartial
        ? AppTheme.warningSoft
        : AppTheme.surface;

    final foreground = isPaid
        ? AppTheme.success
        : isPartial
        ? AppTheme.warning
        : AppTheme.secondaryText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _PaymentHistoryTile extends StatelessWidget {
  const _PaymentHistoryTile({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final reference = (payment.referenceNumber ?? '').trim();

    final receivedBy = (payment.receivedBy ?? '').trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.successSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.currency_rupee_rounded,
              color: AppTheme.success,
              size: 19,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u20B9${MoneyUtils.paiseToRupeesText(payment.amountPaise)}',
                  style: const TextStyle(
                    color: AppTheme.darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${DateFormat('dd MMM yyyy').format(payment.paymentDate)} • ${paymentModeLabel(payment.paymentMode)}',
                  style: const TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 10,
                  ),
                ),

                if (reference.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Ref: $reference',
                    style: const TextStyle(
                      color: AppTheme.secondaryText,
                      fontSize: 10,
                    ),
                  ),
                ],

                if (receivedBy.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Received by $receivedBy',
                    style: const TextStyle(
                      color: AppTheme.secondaryText,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
