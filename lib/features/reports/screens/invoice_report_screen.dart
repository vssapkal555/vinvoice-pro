import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../models/report_date_range.dart';

class InvoiceReportScreen extends StatefulWidget {
  const InvoiceReportScreen({
    super.key,
    required this.invoices,
    required this.payments,
    required this.range,
  });

  final List<Invoice> invoices;
  final List<Payment> payments;
  final ReportDateRange range;

  @override
  State<InvoiceReportScreen> createState() => _InvoiceReportScreenState();
}

class _InvoiceReportScreenState extends State<InvoiceReportScreen> {
  String _status = 'All';
  String _paymentStatus = 'All';
  String _search = '';

  List<_InvoiceReportRow> get _rows {
    final paymentTotals = <String, int>{};

    for (final payment in widget.payments) {
      paymentTotals.update(
        payment.invoiceId,
        (value) => value + payment.amountPaise,
        ifAbsent: () => payment.amountPaise,
      );
    }

    final rows = <_InvoiceReportRow>[];

    for (final invoice in widget.invoices) {
      if (!widget.range.contains(invoice.invoiceDate)) {
        continue;
      }

      final issued = invoice.status.toLowerCase() == 'issued';

      final paid = issued ? paymentTotals[invoice.id] ?? 0 : 0;

      final outstanding = issued
          ? (invoice.grandTotalPaise - paid).clamp(0, invoice.grandTotalPaise)
          : 0;

      final paymentStatus = !issued
          ? 'N/A'
          : outstanding == 0
          ? 'Paid'
          : paid > 0
          ? 'Partial'
          : 'Unpaid';

      rows.add(
        _InvoiceReportRow(
          invoice: invoice,
          paidPaise: paid,
          outstandingPaise: outstanding,
          paymentStatus: paymentStatus,
        ),
      );
    }

    rows.sort((a, b) => b.invoice.invoiceDate.compareTo(a.invoice.invoiceDate));

    return rows.where((row) {
      if (_status != 'All' &&
          row.invoice.status.toLowerCase() != _status.toLowerCase()) {
        return false;
      }

      if (_paymentStatus != 'All' && row.paymentStatus != _paymentStatus) {
        return false;
      }

      final search = _search.trim().toLowerCase();

      if (search.isNotEmpty) {
        final haystack = [
          row.invoice.invoiceNumber,
          row.invoice.partyNameSnapshot,
          row.invoice.status,
          row.paymentStatus,
        ].join(' ').toLowerCase();

        if (!haystack.contains(search)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;

    final issuedRows = rows.where(
      (e) => e.invoice.status.toLowerCase() == 'issued',
    );

    final total = issuedRows.fold<int>(
      0,
      (sum, row) => sum + row.invoice.grandTotalPaise,
    );

    final paid = issuedRows.fold<int>(0, (sum, row) => sum + row.paidPaise);

    final outstanding = issuedRows.fold<int>(
      0,
      (sum, row) => sum + row.outstandingPaise,
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Invoice Report'),
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _SummaryCard(
              totalPaise: total,
              paidPaise: paid,
              outstandingPaise: outstanding,
              count: rows.length,
            ),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Invoices',
                    style: TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${rows.length} result${rows.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (rows.isEmpty)
              const _EmptyState()
            else
              ...rows.map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _InvoiceCard(row: row),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() => _search = value);
            },
            decoration: const InputDecoration(
              hintText: 'Search invoice or party',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Invoice status',
                  ),
                  items: const ['All', 'Issued', 'Draft', 'Cancelled']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _status = value;

                      if (_status != 'Issued') {
                        _paymentStatus = 'All';
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _paymentStatus,
                  decoration: const InputDecoration(labelText: 'Payment'),
                  items: const ['All', 'Paid', 'Partial', 'Unpaid']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _paymentStatus = value;

                      if (value != 'All') {
                        _status = 'Issued';
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvoiceReportRow {
  const _InvoiceReportRow({
    required this.invoice,
    required this.paidPaise,
    required this.outstandingPaise,
    required this.paymentStatus,
  });

  final Invoice invoice;
  final int paidPaise;
  final int outstandingPaise;
  final String paymentStatus;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalPaise,
    required this.paidPaise,
    required this.outstandingPaise,
    required this.count,
  });

  final int totalPaise;
  final int paidPaise;
  final int outstandingPaise;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Icon(Icons.receipt_long_outlined, color: Colors.white),
              SizedBox(width: 9),
              Text(
                'Invoice Summary',
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
            '\u20B9${MoneyUtils.paiseToRupeesText(totalPaise)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$count filtered invoice${count == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _MiniSummary(
                  title: 'Paid',
                  value: '\u20B9${MoneyUtils.paiseToRupeesText(paidPaise)}',
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _MiniSummary(
                  title: 'Outstanding',
                  value:
                      '\u20B9${MoneyUtils.paiseToRupeesText(outstandingPaise)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniSummary extends StatelessWidget {
  const _MiniSummary({required this.title, required this.value});

  final String title;
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
            title,
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

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.row});

  final _InvoiceReportRow row;

  @override
  Widget build(BuildContext context) {
    final invoice = row.invoice;
    final issued = invoice.status.toLowerCase() == 'issued';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
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
              const SizedBox(width: 8),
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
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('dd MMM yyyy').format(invoice.invoiceDate),
                  style: const TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 9,
                  ),
                ),
              ),
              _StatusPill(
                text: invoice.status.toUpperCase(),
                type: invoice.status.toLowerCase(),
              ),
              if (issued) ...[
                const SizedBox(width: 6),
                _StatusPill(
                  text: row.paymentStatus.toUpperCase(),
                  type: row.paymentStatus.toLowerCase(),
                ),
              ],
            ],
          ),
          if (issued) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _AmountDetail(label: 'Paid', amount: row.paidPaise),
                ),
                Expanded(
                  child: _AmountDetail(
                    label: 'Outstanding',
                    amount: row.outstandingPaise,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AmountDetail extends StatelessWidget {
  const _AmountDetail({required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.secondaryText, fontSize: 8),
        ),
        const SizedBox(height: 2),
        Text(
          '\u20B9${MoneyUtils.paiseToRupeesText(amount)}',
          style: const TextStyle(
            color: AppTheme.darkText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.type});

  final String text;
  final String type;

  @override
  Widget build(BuildContext context) {
    Color foreground;
    Color background;

    switch (type) {
      case 'paid':
        foreground = AppTheme.success;
        background = AppTheme.successSoft;
        break;

      case 'partial':
      case 'partiallypaid':
        foreground = AppTheme.warning;
        background = AppTheme.warningSoft;
        break;

      case 'unpaid':
      case 'cancelled':
        foreground = AppTheme.danger;
        background = AppTheme.danger.withValues(alpha: .07);
        break;

      case 'issued':
        foreground = AppTheme.primary;
        background = AppTheme.primarySoft;
        break;

      default:
        foreground = AppTheme.secondaryText;
        background = AppTheme.surfaceMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontSize: 7,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
            Icons.search_off_rounded,
            size: 34,
            color: AppTheme.secondaryText,
          ),
          SizedBox(height: 9),
          Text(
            'No invoices match these filters',
            style: TextStyle(
              color: AppTheme.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
