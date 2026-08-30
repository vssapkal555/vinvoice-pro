import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../models/report_date_range.dart';

class PaymentReportScreen extends StatefulWidget {
  const PaymentReportScreen({
    super.key,
    required this.invoices,
    required this.payments,
    required this.range,
  });

  final List<Invoice> invoices;
  final List<Payment> payments;
  final ReportDateRange range;

  @override
  State<PaymentReportScreen> createState() => _PaymentReportScreenState();
}

class _PaymentReportScreenState extends State<PaymentReportScreen> {
  String _search = '';

  List<_PaymentReportRow> get _rows {
    final invoiceMap = <String, Invoice>{
      for (final invoice in widget.invoices) invoice.id: invoice,
    };

    final rows = <_PaymentReportRow>[];

    for (final payment in widget.payments) {
      if (!widget.range.contains(payment.paymentDate)) {
        continue;
      }

      final invoice = invoiceMap[payment.invoiceId];

      if (invoice == null) {
        continue;
      }

      if (invoice.status.toLowerCase() != 'issued') {
        continue;
      }

      rows.add(_PaymentReportRow(payment: payment, invoice: invoice));
    }

    rows.sort((a, b) => b.payment.paymentDate.compareTo(a.payment.paymentDate));

    final search = _search.trim().toLowerCase();

    if (search.isEmpty) {
      return rows;
    }

    return rows.where((row) {
      final haystack = [
        row.invoice.invoiceNumber,
        row.invoice.partyNameSnapshot,
        row.payment.paymentMode,
        row.payment.referenceNumber ?? '',
      ].join(' ').toLowerCase();

      return haystack.contains(search);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;

    final totalCollected = rows.fold<int>(
      0,
      (sum, row) => sum + row.payment.amountPaise,
    );

    final partyCount = rows
        .map((row) => row.invoice.partyNameSnapshot)
        .toSet()
        .length;

    final invoiceCount = rows.map((row) => row.invoice.id).toSet().length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Payment Report'),
        backgroundColor: AppTheme.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _PaymentHero(
              totalCollectedPaise: totalCollected,
              paymentCount: rows.length,
              invoiceCount: invoiceCount,
              partyCount: partyCount,
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() => _search = value);
              },
              decoration: const InputDecoration(
                hintText: 'Search invoice, party, mode or reference',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Payments Received',
                    style: TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${rows.length} payment${rows.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppTheme.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (rows.isEmpty)
              const _PaymentEmpty()
            else
              ...rows.map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PaymentCard(row: row),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentReportRow {
  const _PaymentReportRow({required this.payment, required this.invoice});

  final Payment payment;
  final Invoice invoice;
}

class _PaymentHero extends StatelessWidget {
  const _PaymentHero({
    required this.totalCollectedPaise,
    required this.paymentCount,
    required this.invoiceCount,
    required this.partyCount,
  });

  final int totalCollectedPaise;
  final int paymentCount;
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
              Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
              SizedBox(width: 9),
              Text(
                'Payments Received',
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
            '\u20B9${MoneyUtils.paiseToRupeesText(totalCollectedPaise)}',
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
                child: _HeroStat(label: 'Payments', value: '$paymentCount'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroStat(label: 'Invoices', value: '$invoiceCount'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroStat(label: 'Parties', value: '$partyCount'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 8),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.row});

  final _PaymentReportRow row;

  @override
  Widget build(BuildContext context) {
    final payment = row.payment;
    final invoice = row.invoice;

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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.successSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: AppTheme.success,
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
              Text(
                '\u20B9${MoneyUtils.paiseToRupeesText(payment.amountPaise)}',
                style: const TextStyle(
                  color: AppTheme.success,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
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
                child: _PaymentInfo(
                  label: 'Date',
                  value: DateFormat('dd MMM yyyy').format(payment.paymentDate),
                ),
              ),
              Expanded(
                child: _PaymentInfo(label: 'Mode', value: payment.paymentMode),
              ),
            ],
          ),
          if ((payment.referenceNumber ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 9),
            _PaymentInfo(
              label: 'Reference',
              value: payment.referenceNumber!.trim(),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentInfo extends StatelessWidget {
  const _PaymentInfo({required this.label, required this.value});

  final String label;
  final String value;

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
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.darkText,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PaymentEmpty extends StatelessWidget {
  const _PaymentEmpty();

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
            Icons.payments_outlined,
            size: 36,
            color: AppTheme.secondaryText,
          ),
          SizedBox(height: 10),
          Text(
            'No payments in this period',
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
