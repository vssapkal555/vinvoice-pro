import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../../expenses/providers/expense_providers.dart';
import '../../invoices/providers/invoice_list_providers.dart';
import '../../payments/providers/payment_providers.dart';
import '../models/report_date_range.dart';
import '../models/report_models.dart';
import '../services/report_service.dart';
import 'invoice_report_screen.dart';
import 'outstanding_report_screen.dart';
import 'payment_report_screen.dart';
import 'gst_report_screen.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportDatePreset _preset = ReportDatePreset.thisFinancialYear;

  ReportDateRange get _range => ReportDateRange.fromPreset(_preset);

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(allInvoicesProvider);
    final paymentsAsync = ref.watch(allPaymentsProvider);
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: invoicesAsync.when(
          loading: () => const _ReportLoading(),
          error: (error, stack) => _ReportError(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(allInvoicesProvider);
              ref.invalidate(allPaymentsProvider);
              ref.invalidate(expensesProvider);
            },
          ),
          data: (invoices) {
            return paymentsAsync.when(
              loading: () => const _ReportLoading(),
              error: (error, stack) => _ReportError(
                message: error.toString(),
                onRetry: () {
                  ref.invalidate(allInvoicesProvider);
                  ref.invalidate(allPaymentsProvider);
                },
              ),
              data: (payments) {
                return expensesAsync.when(
                  loading: () => const _ReportLoading(),
                  error: (error, stack) => _ReportError(
                    message: error.toString(),
                    onRetry: () {
                      ref.invalidate(expensesProvider);
                    },
                  ),
                  data: (expenses) {
                    return _buildReport(context, invoices, payments, expenses);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildReport(
    BuildContext context,
    List<Invoice> invoices,
    List<Payment> payments,
    List<Expense> expenses,
  ) {
    final invoiceRecords = invoices
        .map(
          (invoice) => ReportInvoiceRecord(
            id: invoice.id,
            invoiceDate: invoice.invoiceDate,
            status: invoice.status,
            grandTotalPaise: invoice.grandTotalPaise,
            taxableAmountPaise: invoice.taxableAmountPaise,
            cgstAmountPaise: invoice.cgstAmountPaise,
            sgstAmountPaise: invoice.sgstAmountPaise,
            igstAmountPaise: invoice.igstAmountPaise,
            partyName: invoice.partyNameSnapshot,
          ),
        )
        .toList();

    final paymentRecords = payments
        .map(
          (payment) => ReportPaymentRecord(
            invoiceId: payment.invoiceId,
            paymentDate: payment.paymentDate,
            amountPaise: payment.amountPaise,
          ),
        )
        .toList();

    final expenseRecords = expenses
        .map(
          (expense) => ReportExpenseRecord(
            id: expense.id,
            expenseDate: expense.expenseDate,
            category: expense.category,
            baseAmountPaise: expense.baseAmountPaise,
            gstAmountPaise: expense.gstAmountPaise,
            totalAmountPaise: expense.totalAmountPaise,
          ),
        )
        .toList();

    final summary = ReportService.financialSummary(
      invoices: invoiceRecords,
      payments: paymentRecords,
      range: _range,
    );

    final profitability = ReportService.profitabilitySummary(
      invoices: invoiceRecords,
      expenses: expenseRecords,
      range: _range,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: _ReportHero(summary: summary, range: _range),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(allInvoicesProvider);
              ref.invalidate(allPaymentsProvider);
              ref.invalidate(expensesProvider);

              await Future.wait([
                ref.read(allInvoicesProvider.future),
                ref.read(allPaymentsProvider.future),
                ref.read(expensesProvider.future),
              ]);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
              children: [
                _DatePresetSelector(
                  selected: _preset,
                  onChanged: (preset) {
                    setState(() {
                      _preset = preset;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const _SectionHeading(
                  title: 'Financial Overview',
                  subtitle: 'Issued invoices and payment collections',
                ),
                const SizedBox(height: 9),
                _FinancialMetrics(summary: summary),
                const SizedBox(height: 17),
                const _SectionHeading(
                  title: 'Profitability',
                  subtitle: 'Issued revenue compared with business expenses',
                ),
                const SizedBox(height: 9),
                _ProfitabilityCard(summary: profitability),
                const SizedBox(height: 17),
                const _SectionHeading(
                  title: 'Collection Status',
                  subtitle: 'Payment position of issued invoices',
                ),
                const SizedBox(height: 9),
                _PaymentStatusCard(summary: summary),
                const SizedBox(height: 17),
                const _SectionHeading(
                  title: 'GST & Tax',
                  subtitle: 'Tax values from issued invoices in this period',
                ),
                const SizedBox(height: 9),
                _TaxSummaryCard(summary: summary),
                const SizedBox(height: 17),
                const _SectionHeading(
                  title: 'Invoice Lifecycle',
                  subtitle: 'Operational invoices retained in the period',
                ),
                const SizedBox(height: 9),
                _LifecycleCard(summary: summary),
                const SizedBox(height: 17),
                const _SectionHeading(
                  title: 'Detailed Reports',
                  subtitle: 'Open focused invoice, payment and tax reports',
                ),
                const SizedBox(height: 9),
                _DetailedReports(
                  invoices: invoices,
                  payments: payments,
                  range: _range,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfitabilityCard extends StatelessWidget {
  const _ProfitabilityCard({required this.summary});

  final ProfitabilityReportSummary summary;

  String _money(int paise) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 2,
    ).format(MoneyUtils.paiseToRupees(paise));
  }

  @override
  Widget build(BuildContext context) {
    final profitPositive = summary.operatingProfitPaise >= 0;

    return Container(
      padding: const EdgeInsets.all(18),
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
                child: _ProfitMetric(
                  label: 'Revenue',
                  value: _money(summary.revenuePaise),
                  icon: Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProfitMetric(
                  label: 'Expenses',
                  value: _money(summary.expensePaise),
                  icon: Icons.receipt_long_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ProfitMetric(
                  label: profitPositive ? 'Operating Profit' : 'Operating Loss',
                  value: _money(summary.operatingProfitPaise),
                  icon: profitPositive
                      ? Icons.account_balance_wallet_outlined
                      : Icons.trending_down_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProfitMetric(
                  label: 'Net Margin',
                  value: '${summary.netMarginPercentage.toStringAsFixed(1)}%',
                  icon: Icons.percent_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Expense breakdown',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${summary.expenseCount} '
                '${summary.expenseCount == 1 ? 'record' : 'records'}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (summary.categoryBreakdown.isEmpty)
            Text(
              'No expenses recorded in this period.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryText),
            )
          else
            ...summary.categoryBreakdown
                .take(5)
                .map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            category.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${category.count} ×',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.secondaryText),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _money(category.totalPaise),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
          if (summary.expensePaise > 0) ...[
            const SizedBox(height: 6),
            Text(
              'Expense GST included: '
              '${_money(summary.expenseGstPaise)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.secondaryText),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfitMetric extends StatelessWidget {
  const _ProfitMetric({
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
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(height: 9),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.secondaryText),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ReportHero extends StatelessWidget {
  const _ReportHero({required this.summary, required this.range});

  final FinancialReportSummary summary;
  final ReportDateRange range;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.secondary, 0.58)!,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: .13),
            blurRadius: 17,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Financial Reports',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Billing, payments and outstanding',
                      style: TextStyle(color: Colors.white70, fontSize: 9.5),
                    ),
                  ],
                ),
              ),
              Text(
                '\u20B9${MoneyUtils.paiseToRupeesText(summary.invoicedPaise)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: 'Collected',
                  value:
                      '\u20B9${MoneyUtils.paiseToRupeesText(summary.collectedPaise)}',
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _HeroMetric(
                  label: 'Outstanding',
                  value:
                      '\u20B9${MoneyUtils.paiseToRupeesText(summary.outstandingPaise)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _rangeText(range),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static String _rangeText(ReportDateRange range) {
    if (range.start == null || range.end == null) {
      return 'All-time report';
    }

    final formatter = DateFormat('dd MMM yyyy');
    return '${formatter.format(range.start!)} \u2022 ${formatter.format(range.end!)}';
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 9),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePresetSelector extends StatelessWidget {
  const _DatePresetSelector({required this.selected, required this.onChanged});

  final ReportDatePreset selected;
  final ValueChanged<ReportDatePreset> onChanged;

  static const presets = [
    ReportDatePreset.today,
    ReportDatePreset.thisWeek,
    ReportDatePreset.thisMonth,
    ReportDatePreset.thisFinancialYear,
    ReportDatePreset.last30Days,
    ReportDatePreset.last90Days,
    ReportDatePreset.allTime,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 37,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: presets.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final preset = presets[index];
          final active = preset == selected;

          return ChoiceChip(
            selected: active,
            label: Text(_label(preset)),
            onSelected: (_) => onChanged(preset),
          );
        },
      ),
    );
  }

  String _label(ReportDatePreset preset) {
    switch (preset) {
      case ReportDatePreset.today:
        return 'Today';
      case ReportDatePreset.thisWeek:
        return 'Week';
      case ReportDatePreset.thisMonth:
        return 'Month';
      case ReportDatePreset.thisFinancialYear:
        return 'FY';
      case ReportDatePreset.last30Days:
        return '30 Days';
      case ReportDatePreset.last90Days:
        return '90 Days';
      case ReportDatePreset.allTime:
        return 'All Time';
      case ReportDatePreset.custom:
        return 'Custom';
    }
  }
}

class _FinancialMetrics extends StatelessWidget {
  const _FinancialMetrics({required this.summary});

  final FinancialReportSummary summary;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 9,
      crossAxisSpacing: 9,
      childAspectRatio: 1.72,
      children: [
        _MetricCard(
          icon: Icons.receipt_long_outlined,
          title: 'Invoiced',
          value: '\u20B9${MoneyUtils.paiseToRupeesText(summary.invoicedPaise)}',
          semantic: _MetricSemantic.primary,
        ),
        _MetricCard(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Payments Received',
          value:
              '\u20B9${MoneyUtils.paiseToRupeesText(summary.collectedPaise)}',
          semantic: _MetricSemantic.success,
        ),
        _MetricCard(
          icon: Icons.pending_actions_outlined,
          title: 'Outstanding',
          value:
              '\u20B9${MoneyUtils.paiseToRupeesText(summary.outstandingPaise)}',
          semantic: summary.outstandingPaise > 0
              ? _MetricSemantic.warning
              : _MetricSemantic.normal,
        ),
        _MetricCard(
          icon: Icons.percent_rounded,
          title: 'Collection Ratio',
          value: '${summary.collectionPercentage.toStringAsFixed(1)}%',
          semantic: _MetricSemantic.normal,
        ),
      ],
    );
  }
}

enum _MetricSemantic { normal, primary, success, warning }

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.semantic,
  });

  final IconData icon;
  final String title;
  final String value;
  final _MetricSemantic semantic;

  @override
  Widget build(BuildContext context) {
    late Color background;
    late Color foreground;

    switch (semantic) {
      case _MetricSemantic.primary:
        background = Theme.of(context).colorScheme.primaryContainer;
        foreground = Theme.of(context).colorScheme.primary;

      case _MetricSemantic.success:
        background = AppTheme.successSoft;
        foreground = AppTheme.success;

      case _MetricSemantic.warning:
        background = AppTheme.warningSoft;
        foreground = AppTheme.warning;

      case _MetricSemantic.normal:
        background = AppTheme.surface;
        foreground = AppTheme.secondaryText;
    }

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: semantic == _MetricSemantic.normal
              ? AppTheme.border
              : foreground.withValues(alpha: .12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground, size: 19),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.darkText,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: AppTheme.secondaryText, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusCard extends StatelessWidget {
  const _PaymentStatusCard({required this.summary});

  final FinancialReportSummary summary;

  @override
  Widget build(BuildContext context) {
    return _ReportCard(
      child: Row(
        children: [
          Expanded(
            child: _StatusMetric(
              value: summary.paidCount,
              label: 'Paid',
              foreground: AppTheme.success,
              background: AppTheme.successSoft,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatusMetric(
              value: summary.partiallyPaidCount,
              label: 'Partial',
              foreground: AppTheme.warning,
              background: AppTheme.warningSoft,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatusMetric(
              value: summary.unpaidCount,
              label: 'Unpaid',
              foreground: AppTheme.danger,
              background: AppTheme.danger.withValues(alpha: .07),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMetric extends StatelessWidget {
  const _StatusMetric({
    required this.value,
    required this.label,
    required this.foreground,
    required this.background,
  });

  final int value;
  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: value == 0 ? AppTheme.surfaceMuted : background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: value == 0 ? AppTheme.secondaryText : foreground,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxSummaryCard extends StatelessWidget {
  const _TaxSummaryCard({required this.summary});

  final FinancialReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final totalTax = summary.cgstPaise + summary.sgstPaise + summary.igstPaise;

    return _ReportCard(
      child: Column(
        children: [
          _AmountRow(
            label: 'Taxable Value',
            value: summary.taxablePaise,
            strong: true,
          ),
          const Divider(height: 22),
          _AmountRow(label: 'CGST', value: summary.cgstPaise),
          const SizedBox(height: 8),
          _AmountRow(label: 'SGST', value: summary.sgstPaise),
          const SizedBox(height: 8),
          _AmountRow(label: 'IGST', value: summary.igstPaise),
          const Divider(height: 22),
          _AmountRow(label: 'Total GST', value: totalTax, strong: true),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final int value;
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
              fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          '\u20B9${MoneyUtils.paiseToRupeesText(value)}',
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

class _LifecycleCard extends StatelessWidget {
  const _LifecycleCard({required this.summary});

  final FinancialReportSummary summary;

  @override
  Widget build(BuildContext context) {
    return _ReportCard(
      child: Row(
        children: [
          Expanded(
            child: _LifecycleMetric(
              label: 'Issued',
              value: summary.issuedCount,
              icon: Icons.verified_outlined,
            ),
          ),
          Expanded(
            child: _LifecycleMetric(
              label: 'Draft',
              value: summary.draftCount,
              icon: Icons.edit_note_rounded,
            ),
          ),
          Expanded(
            child: _LifecycleMetric(
              label: 'Cancelled',
              value: summary.cancelledCount,
              icon: Icons.block_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _LifecycleMetric extends StatelessWidget {
  const _LifecycleMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 19, color: AppTheme.secondaryText),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: const TextStyle(
            color: AppTheme.darkText,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppTheme.secondaryText, fontSize: 9),
        ),
      ],
    );
  }
}

class _DetailedReports extends StatelessWidget {
  const _DetailedReports({
    required this.invoices,
    required this.payments,
    required this.range,
  });

  final List<Invoice> invoices;
  final List<Payment> payments;
  final ReportDateRange range;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailedReportTile(
          icon: Icons.receipt_long_outlined,
          title: 'Invoice Report',
          subtitle: 'Invoices, lifecycle and payment status',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => InvoiceReportScreen(
                  invoices: invoices,
                  payments: payments,
                  range: range,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 9),

        _DetailedReportTile(
          icon: Icons.pending_actions_outlined,
          title: 'Outstanding Report',
          subtitle: 'Open invoices and unpaid balances',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => OutstandingReportScreen(
                  invoices: invoices,
                  payments: payments,
                  range: range,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 9),

        _DetailedReportTile(
          icon: Icons.payments_outlined,
          title: 'Payment Report',
          subtitle: 'Payments received during this period',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PaymentReportScreen(
                  invoices: invoices,
                  payments: payments,
                  range: range,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 9),

        _DetailedReportTile(
          icon: Icons.account_balance_outlined,
          title: 'GST Report',
          subtitle: 'Taxable value and GST breakdown',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    GstReportScreen(invoices: invoices, range: range),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DetailedReportTile extends StatelessWidget {
  const _DetailedReportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.darkText,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(color: AppTheme.secondaryText, fontSize: 9),
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppTheme.border),
      ),
      child: child,
    );
  }
}

class _ReportLoading extends StatelessWidget {
  const _ReportLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ReportError extends StatelessWidget {
  const _ReportError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppTheme.danger,
              size: 38,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load reports',
              style: TextStyle(
                color: AppTheme.darkText,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
