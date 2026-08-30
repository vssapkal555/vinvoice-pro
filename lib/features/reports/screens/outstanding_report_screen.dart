import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../models/report_date_range.dart';
import '../services/report_excel_export_service.dart';
import '../services/report_pdf_export_service.dart';

class OutstandingReportScreen extends StatefulWidget {
  const OutstandingReportScreen({
    super.key,
    required this.invoices,
    required this.payments,
    required this.range,
  });

  final List<Invoice> invoices;
  final List<Payment> payments;
  final ReportDateRange range;

  @override
  State<OutstandingReportScreen> createState() =>
      _OutstandingReportScreenState();
}

class _OutstandingReportScreenState extends State<OutstandingReportScreen> {
  String _search = '';

  List<_OutstandingRow> get _rows {
    final paymentTotals = <String, int>{};

    for (final payment in widget.payments) {
      paymentTotals.update(
        payment.invoiceId,
        (value) => value + payment.amountPaise,
        ifAbsent: () => payment.amountPaise,
      );
    }

    final result = <_OutstandingRow>[];

    for (final invoice in widget.invoices) {
      if (invoice.status.toLowerCase() != 'issued') {
        continue;
      }

      if (!widget.range.contains(invoice.invoiceDate)) {
        continue;
      }

      final paid = paymentTotals[invoice.id] ?? 0;

      final outstanding = (invoice.grandTotalPaise - paid).clamp(
        0,
        invoice.grandTotalPaise,
      );

      if (outstanding <= 0) {
        continue;
      }

      result.add(
        _OutstandingRow(
          invoice: invoice,
          paidPaise: paid,
          outstandingPaise: outstanding,
        ),
      );
    }

    result.sort((a, b) => b.outstandingPaise.compareTo(a.outstandingPaise));

    final search = _search.trim().toLowerCase();

    if (search.isEmpty) {
      return result;
    }

    return result.where((row) {
      return row.invoice.invoiceNumber.toLowerCase().contains(search) ||
          row.invoice.partyNameSnapshot.toLowerCase().contains(search);
    }).toList();
  }

  Future<void> _exportExcel(List<_OutstandingRow> rows) async {
    final period = widget.range.start == null || widget.range.end == null
        ? 'All Time'
        : '${DateFormat('dd MMM yyyy').format(widget.range.start!)} - '
              '${DateFormat('dd MMM yyyy').format(widget.range.end!)}';

    final totalInvoice = rows.fold<int>(
      0,
      (sum, row) => sum + row.invoice.grandTotalPaise,
    );

    final totalPaid = rows.fold<int>(0, (sum, row) => sum + row.paidPaise);

    final totalOutstanding = rows.fold<int>(
      0,
      (sum, row) => sum + row.outstandingPaise,
    );

    try {
      await ReportExcelExportService.exportAndShare(
        reportTitle: 'Outstanding Report',
        fileName: 'outstanding_report',
        metadata: [
          ['Report Period', period],
          ['Generated', DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())],
          ['Search', _search.trim().isEmpty ? 'All' : _search.trim()],
        ],
        numericColumns: const {3, 4, 5},
        headers: const [
          'Invoice No',
          'Invoice Date',
          'Party',
          'Invoice Value',
          'Paid',
          'Outstanding',
          'Payment Status',
        ],
        rows: rows.map((row) {
          return [
            row.invoice.invoiceNumber,
            DateFormat('dd-MM-yyyy').format(row.invoice.invoiceDate),
            row.invoice.partyNameSnapshot,
            MoneyUtils.paiseToRupeesText(row.invoice.grandTotalPaise),
            MoneyUtils.paiseToRupeesText(row.paidPaise),
            MoneyUtils.paiseToRupeesText(row.outstandingPaise),
            row.paidPaise > 0 ? 'PARTIAL' : 'UNPAID',
          ];
        }).toList(),
        totalsRow: [
          'TOTAL',
          '',
          '',
          MoneyUtils.paiseToRupeesText(totalInvoice),
          MoneyUtils.paiseToRupeesText(totalPaid),
          MoneyUtils.paiseToRupeesText(totalOutstanding),
          '',
        ],
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Excel export failed: $error')));
    }
  }

  Future<void> _exportPdf(List<_OutstandingRow> rows) async {
    final period = widget.range.start == null || widget.range.end == null
        ? 'All Time'
        : '${DateFormat('dd MMM yyyy').format(widget.range.start!)} - '
              '${DateFormat('dd MMM yyyy').format(widget.range.end!)}';

    final totalInvoice = rows.fold<int>(
      0,
      (sum, row) => sum + row.invoice.grandTotalPaise,
    );

    final totalPaid = rows.fold<int>(0, (sum, row) => sum + row.paidPaise);

    final totalOutstanding = rows.fold<int>(
      0,
      (sum, row) => sum + row.outstandingPaise,
    );

    await ReportPdfExportService.share(
      reportTitle: 'Outstanding Report',
      fileName: 'outstanding_report',
      landscape: true,
      metadata: [
        ['Report Period', period],
        ['Generated', DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())],
        ['Search', _search.trim().isEmpty ? 'All' : _search.trim()],
      ],
      headers: const [
        'Invoice No',
        'Date',
        'Party',
        'Invoice Value',
        'Paid',
        'Outstanding',
        'Payment Status',
      ],
      rows: rows.map((row) {
        return [
          row.invoice.invoiceNumber,
          DateFormat('dd-MM-yyyy').format(row.invoice.invoiceDate),
          row.invoice.partyNameSnapshot,
          MoneyUtils.paiseToRupeesText(row.invoice.grandTotalPaise),
          MoneyUtils.paiseToRupeesText(row.paidPaise),
          MoneyUtils.paiseToRupeesText(row.outstandingPaise),
          row.paidPaise > 0 ? 'PARTIAL' : 'UNPAID',
        ];
      }).toList(),
      totalsRow: [
        'TOTAL',
        '',
        '',
        MoneyUtils.paiseToRupeesText(totalInvoice),
        MoneyUtils.paiseToRupeesText(totalPaid),
        MoneyUtils.paiseToRupeesText(totalOutstanding),
        '',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;

    final billed = rows.fold<int>(
      0,
      (sum, row) => sum + row.invoice.grandTotalPaise,
    );

    final paid = rows.fold<int>(0, (sum, row) => sum + row.paidPaise);

    final outstanding = rows.fold<int>(
      0,
      (sum, row) => sum + row.outstandingPaise,
    );

    final partyCount = rows
        .map((row) => row.invoice.partyNameSnapshot)
        .toSet()
        .length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Outstanding Report'),
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Export Excel',
            onPressed: rows.isEmpty ? null : () => _exportExcel(rows),
            icon: const Icon(Icons.file_download_outlined),
          ),
          IconButton(
            tooltip: 'Export PDF',
            onPressed: rows.isEmpty ? null : () => _exportPdf(rows),
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _OutstandingHero(
              billedPaise: billed,
              paidPaise: paid,
              outstandingPaise: outstanding,
              invoiceCount: rows.length,
              partyCount: partyCount,
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
                    'Open Invoices',
                    style: TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${rows.length} open',
                  style: const TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (rows.isEmpty)
              const _OutstandingEmpty()
            else
              ...rows.map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _OutstandingInvoiceCard(row: row),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OutstandingRow {
  const _OutstandingRow({
    required this.invoice,
    required this.paidPaise,
    required this.outstandingPaise,
  });

  final Invoice invoice;
  final int paidPaise;
  final int outstandingPaise;
}

class _OutstandingHero extends StatelessWidget {
  const _OutstandingHero({
    required this.billedPaise,
    required this.paidPaise,
    required this.outstandingPaise,
    required this.invoiceCount,
    required this.partyCount,
  });

  final int billedPaise;
  final int paidPaise;
  final int outstandingPaise;
  final int invoiceCount;
  final int partyCount;

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
              Icon(Icons.pending_actions_outlined, color: Colors.white),
              SizedBox(width: 9),
              Text(
                'Total Outstanding',
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
            '\u20B9${MoneyUtils.paiseToRupeesText(outstandingPaise)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroInfo(
                  label: 'Billed',
                  value: '\u20B9${MoneyUtils.paiseToRupeesText(billedPaise)}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroInfo(
                  label: 'Paid',
                  value: '\u20B9${MoneyUtils.paiseToRupeesText(paidPaise)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$invoiceCount open invoice${invoiceCount == 1 ? '' : 's'} \u2022 '
            '$partyCount part${partyCount == 1 ? 'y' : 'ies'}',
            style: const TextStyle(color: Colors.white70, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _HeroInfo extends StatelessWidget {
  const _HeroInfo({required this.label, required this.value});

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

class _OutstandingInvoiceCard extends StatelessWidget {
  const _OutstandingInvoiceCard({required this.row});

  final _OutstandingRow row;

  @override
  Widget build(BuildContext context) {
    final invoice = row.invoice;

    final percentPaid = invoice.grandTotalPaise <= 0
        ? 0.0
        : (row.paidPaise / invoice.grandTotalPaise).clamp(0.0, 1.0);

    final status = row.paidPaise > 0 ? 'PARTIAL' : 'UNPAID';

    return Container(
      padding: const EdgeInsets.all(15),
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: row.paidPaise > 0
                      ? AppTheme.warningSoft
                      : AppTheme.danger.withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: row.paidPaise > 0
                        ? AppTheme.warning
                        : AppTheme.danger,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoColumn(
                label: 'Invoice',
                value:
                    '\u20B9${MoneyUtils.paiseToRupeesText(invoice.grandTotalPaise)}',
              ),
              _InfoColumn(
                label: 'Paid',
                value: '\u20B9${MoneyUtils.paiseToRupeesText(row.paidPaise)}',
              ),
              _InfoColumn(
                label: 'Outstanding',
                value:
                    '\u20B9${MoneyUtils.paiseToRupeesText(row.outstandingPaise)}',
                strong: true,
              ),
            ],
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: percentPaid,
              minHeight: 6,
              backgroundColor: AppTheme.surfaceMuted,
            ),
          ),
          const SizedBox(height: 8),
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
              Text(
                '${(percentPaid * 100).toStringAsFixed(0)}% paid',
                style: const TextStyle(
                  color: AppTheme.secondaryText,
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

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.secondaryText, fontSize: 8),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: strong ? AppTheme.warning : AppTheme.darkText,
              fontSize: 10,
              fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutstandingEmpty extends StatelessWidget {
  const _OutstandingEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppTheme.successSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 36,
            color: AppTheme.success,
          ),
          SizedBox(height: 10),
          Text(
            'No outstanding invoices',
            style: TextStyle(
              color: AppTheme.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 3),
          Text(
            'All issued invoices in this period are settled.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.secondaryText, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
