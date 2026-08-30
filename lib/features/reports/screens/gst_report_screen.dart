import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../models/report_date_range.dart';

class GstReportScreen extends StatefulWidget {
  const GstReportScreen({
    super.key,
    required this.invoices,
    required this.range,
  });

  final List<Invoice> invoices;
  final ReportDateRange range;

  @override
  State<GstReportScreen> createState() => _GstReportScreenState();
}

class _GstReportScreenState extends State<GstReportScreen> {
  String _search = '';

  List<Invoice> get _rows {
    final rows = widget.invoices.where((invoice) {
      if (invoice.status.toLowerCase() != 'issued') {
        return false;
      }

      if (!widget.range.contains(invoice.invoiceDate)) {
        return false;
      }

      final search = _search.trim().toLowerCase();

      if (search.isEmpty) {
        return true;
      }

      return invoice.invoiceNumber.toLowerCase().contains(search) ||
          invoice.partyNameSnapshot.toLowerCase().contains(search);
    }).toList();

    rows.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;

    final taxable = rows.fold<int>(
      0,
      (sum, invoice) => sum + invoice.taxableAmountPaise,
    );

    final cgst = rows.fold<int>(
      0,
      (sum, invoice) => sum + invoice.cgstAmountPaise,
    );

    final sgst = rows.fold<int>(
      0,
      (sum, invoice) => sum + invoice.sgstAmountPaise,
    );

    final igst = rows.fold<int>(
      0,
      (sum, invoice) => sum + invoice.igstAmountPaise,
    );

    final totalGst = cgst + sgst + igst;

    final invoiceValue = rows.fold<int>(
      0,
      (sum, invoice) => sum + invoice.grandTotalPaise,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('GST Report'),
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _GstHero(
              taxablePaise: taxable,
              totalGstPaise: totalGst,
              invoiceValuePaise: invoiceValue,
              invoiceCount: rows.length,
            ),
            const SizedBox(height: 16),
            _TaxBreakdown(
              cgstPaise: cgst,
              sgstPaise: sgst,
              igstPaise: igst,
              totalGstPaise: totalGst,
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() => _search = value);
              },
              decoration: const InputDecoration(
                hintText: 'Search invoice or party',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'GST Invoice Detail',
                    style: TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${rows.length} invoice${rows.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (rows.isEmpty)
              const _GstEmpty()
            else
              ...rows.map(
                (invoice) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _GstInvoiceCard(invoice: invoice),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GstHero extends StatelessWidget {
  const _GstHero({
    required this.taxablePaise,
    required this.totalGstPaise,
    required this.invoiceValuePaise,
    required this.invoiceCount,
  });

  final int taxablePaise;
  final int totalGstPaise;
  final int invoiceValuePaise;
  final int invoiceCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primary],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_outlined, color: Colors.white),
              SizedBox(width: 9),
              Text(
                'GST Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '\u20B9${MoneyUtils.paiseToRupeesText(totalGstPaise)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Total GST',
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _GstHeroStat(
                  label: 'Taxable',
                  value: '\u20B9${MoneyUtils.paiseToRupeesText(taxablePaise)}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _GstHeroStat(
                  label: 'Invoice Value',
                  value:
                      '\u20B9${MoneyUtils.paiseToRupeesText(invoiceValuePaise)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            '$invoiceCount issued invoice${invoiceCount == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.white70, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _GstHeroStat extends StatelessWidget {
  const _GstHeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 9),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxBreakdown extends StatelessWidget {
  const _TaxBreakdown({
    required this.cgstPaise,
    required this.sgstPaise,
    required this.igstPaise,
    required this.totalGstPaise,
  });

  final int cgstPaise;
  final int sgstPaise;
  final int igstPaise;
  final int totalGstPaise;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _TaxRow(label: 'CGST', amountPaise: cgstPaise),
          const SizedBox(height: 9),
          _TaxRow(label: 'SGST', amountPaise: sgstPaise),
          const SizedBox(height: 9),
          _TaxRow(label: 'IGST', amountPaise: igstPaise),
          const Divider(height: 22),
          _TaxRow(label: 'Total GST', amountPaise: totalGstPaise, strong: true),
        ],
      ),
    );
  }
}

class _TaxRow extends StatelessWidget {
  const _TaxRow({
    required this.label,
    required this.amountPaise,
    this.strong = false,
  });

  final String label;
  final int amountPaise;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: strong ? AppTheme.darkText : AppTheme.secondaryText,
              fontSize: strong ? 12 : 10,
              fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          '\u20B9${MoneyUtils.paiseToRupeesText(amountPaise)}',
          style: TextStyle(
            color: AppTheme.darkText,
            fontSize: strong ? 13 : 11,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _GstInvoiceCard extends StatelessWidget {
  const _GstInvoiceCard({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final totalGst =
        invoice.cgstAmountPaise +
        invoice.sgstAmountPaise +
        invoice.igstAmountPaise;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      invoice.partyNameSnapshot,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\u20B9${MoneyUtils.paiseToRupeesText(invoice.grandTotalPaise)}',
                style: const TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            DateFormat('dd MMM yyyy').format(invoice.invoiceDate),
            style: const TextStyle(color: AppTheme.secondaryText, fontSize: 9),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 11),
          Row(
            children: [
              _GstDetail(
                label: 'Taxable',
                amountPaise: invoice.taxableAmountPaise,
              ),
              _GstDetail(label: 'CGST', amountPaise: invoice.cgstAmountPaise),
              _GstDetail(label: 'SGST', amountPaise: invoice.sgstAmountPaise),
              _GstDetail(label: 'IGST', amountPaise: invoice.igstAmountPaise),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              const Text(
                'GST',
                style: TextStyle(color: AppTheme.secondaryText, fontSize: 9),
              ),
              const Spacer(),
              Text(
                '\u20B9${MoneyUtils.paiseToRupeesText(totalGst)}',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GstDetail extends StatelessWidget {
  const _GstDetail({required this.label, required this.amountPaise});

  final String label;
  final int amountPaise;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.secondaryText, fontSize: 7),
          ),
          const SizedBox(height: 2),
          Text(
            '\u20B9${MoneyUtils.paiseToRupeesText(amountPaise)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.darkText,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GstEmpty extends StatelessWidget {
  const _GstEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 36,
            color: AppTheme.secondaryText,
          ),
          SizedBox(height: 10),
          Text(
            'No issued invoices in this period',
            style: TextStyle(
              color: AppTheme.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
