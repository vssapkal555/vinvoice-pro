import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../../invoices/providers/invoice_list_providers.dart';
import '../../parties/providers/party_providers.dart';
import '../../payments/providers/payment_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(allInvoicesProvider);

    final partiesAsync = ref.watch(partiesProvider);

    final paymentsAsync = ref.watch(allPaymentsProvider);

    final paidByInvoice = ref.watch(paidAmountByInvoiceProvider);

    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 2,
    );

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allInvoicesProvider);
          ref.invalidate(partiesProvider);
          ref.invalidate(allPaymentsProvider);

          await Future.wait([
            ref.read(allInvoicesProvider.future),
            ref.read(partiesProvider.future),
            ref.read(allPaymentsProvider.future),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            110,
          ),
          children: [
            const _DashboardHeader(),

            const SizedBox(height: AppSpacing.xl),

            if (invoicesAsync.isLoading || paymentsAsync.isLoading)
              const _FinanceCardLoading()
            else
              invoicesAsync.when(
                loading: () => const _FinanceCardLoading(),
                error: (_, _) => const _DashboardErrorCard(),
                data: (invoices) {
                  final activeInvoices = invoices
                      .where((invoice) => invoice.status != 'cancelled')
                      .toList();

                  // Receivable/payment accounting
                  // applies only to issued invoices.
                  final issuedInvoices = invoices
                      .where((invoice) => invoice.status == 'issued')
                      .toList();

                  final totalInvoicedPaise = issuedInvoices.fold<int>(
                    0,
                    (total, invoice) => total + invoice.grandTotalPaise,
                  );

                  final collectedPaise = issuedInvoices.fold<int>(0, (
                    total,
                    invoice,
                  ) {
                    final paid = paidByInvoice[invoice.id] ?? 0;

                    final safePaid = paid > invoice.grandTotalPaise
                        ? invoice.grandTotalPaise
                        : paid;

                    return total + safePaid;
                  });

                  final outstandingPaise = totalInvoicedPaise - collectedPaise;

                  var unpaidCount = 0;
                  var partialCount = 0;
                  var paidCount = 0;

                  for (final invoice in issuedInvoices) {
                    final paid = paidByInvoice[invoice.id] ?? 0;

                    if (paid <= 0) {
                      unpaidCount++;
                    } else if (paid >= invoice.grandTotalPaise) {
                      paidCount++;
                    } else {
                      partialCount++;
                    }
                  }

                  final partyCount = partiesAsync.maybeWhen(
                    data: (parties) => parties.length,
                    orElse: () => 0,
                  );

                  final collectionRatio = totalInvoicedPaise == 0
                      ? 0.0
                      : collectedPaise / totalInvoicedPaise;

                  return Column(
                    children: [
                      _FinanceSummaryCard(
                        totalInvoiced: currency.format(
                          MoneyUtils.paiseToRupees(totalInvoicedPaise),
                        ),
                        collected: currency.format(
                          MoneyUtils.paiseToRupees(collectedPaise),
                        ),
                        outstanding: currency.format(
                          MoneyUtils.paiseToRupees(outstandingPaise),
                        ),
                        collectionRatio: collectionRatio,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      _PaymentStatusStrip(
                        unpaid: unpaidCount,
                        partial: partialCount,
                        paid: paidCount,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      Row(
                        children: [
                          Expanded(
                            child: _MiniMetric(
                              icon: Icons.receipt_long_outlined,
                              label: 'Active invoices',
                              value: '${activeInvoices.length}',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _MiniMetric(
                              icon: Icons.business_outlined,
                              label: 'Parties',
                              value: '$partyCount',
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

            const SizedBox(height: AppSpacing.xxl),

            const _SectionHeader(
              title: 'Quick actions',
              subtitle: 'Common tasks at your fingertips',
            ),

            const SizedBox(height: AppSpacing.sm),

            _QuickActions(
              onNewInvoice: () {
                context.push('/invoices/new');
              },
            ),

            const SizedBox(height: AppSpacing.xxl),

            const _SectionHeader(
              title: 'Recent invoices',
              subtitle: 'Your latest billing activity',
            ),

            const SizedBox(height: AppSpacing.sm),

            invoicesAsync.when(
              loading: () => const _RecentInvoicesLoading(),
              error: (_, _) => const _RecentInvoicesError(),
              data: (invoices) {
                if (invoices.isEmpty) {
                  return const _EmptyInvoices();
                }

                final recent = invoices.take(5).toList();

                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      for (var index = 0; index < recent.length; index++) ...[
                        _RecentInvoiceTile(
                          invoice: recent[index],
                          paidPaise: paidByInvoice[recent[index].id] ?? 0,
                          currency: currency,
                          onTap: () {
                            context.push('/invoices/${recent[index].id}');
                          },
                        ),
                        if (index < recent.length - 1)
                          const Divider(indent: 72, height: 1),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// HEADER
// =================================================================

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business overview',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'VInvoice Pro',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),

        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: AppTheme.primary,
            size: 25,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// FINANCIAL SUMMARY
// =================================================================

class _FinanceSummaryCard extends StatelessWidget {
  final String totalInvoiced;
  final String collected;
  final String outstanding;
  final double collectionRatio;

  const _FinanceSummaryCard({
    required this.totalInvoiced,
    required this.collected,
    required this.outstanding,
    required this.collectionRatio,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (collectionRatio * 100).clamp(0, 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x292563EB),
            blurRadius: 28,
            offset: Offset(0, 14),
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
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Outstanding',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.86),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            outstanding,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1.1,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _FinanceValue(label: 'Collected', value: collected),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _FinanceValue(label: 'Invoiced', value: totalInvoiced),
              ),
            ],
          ),

          const SizedBox(height: 22),

          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: collectionRatio.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Collection progress',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.76),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinanceValue extends StatelessWidget {
  final String label;
  final String value;

  const _FinanceValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.68),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// =================================================================
// PAYMENT STATUS
// =================================================================

class _PaymentStatusStrip extends StatelessWidget {
  final int unpaid;
  final int partial;
  final int paid;

  const _PaymentStatusStrip({
    required this.unpaid,
    required this.partial,
    required this.paid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PaymentStatusItem(
              icon: Icons.schedule_rounded,
              value: '$unpaid',
              label: 'Unpaid',
              foreground: AppTheme.danger,
              background: AppTheme.dangerSoft,
            ),
          ),
          Expanded(
            child: _PaymentStatusItem(
              icon: Icons.timelapse_rounded,
              value: '$partial',
              label: 'Partial',
              foreground: AppTheme.warning,
              background: AppTheme.warningSoft,
            ),
          ),
          Expanded(
            child: _PaymentStatusItem(
              icon: Icons.check_circle_rounded,
              value: '$paid',
              label: 'Paid',
              foreground: AppTheme.success,
              background: AppTheme.successSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStatusItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color foreground;
  final Color background;

  const _PaymentStatusItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: foreground),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.darkText,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.secondaryText,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// MINI METRICS
// =================================================================

class _MiniMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 19, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// QUICK ACTIONS
// =================================================================

class _QuickActions extends StatelessWidget {
  final VoidCallback onNewInvoice;

  const _QuickActions({required this.onNewInvoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.border),
      ),
      child: InkWell(
        onTap: onNewInvoice,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New invoice',
                      style: TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Create a GST or non-taxable invoice',
                      style: TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppTheme.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// SECTION HEADER
// =================================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 3),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// =================================================================
// RECENT INVOICE
// =================================================================

class _RecentInvoiceTile extends StatelessWidget {
  final Invoice invoice;
  final int paidPaise;
  final NumberFormat currency;
  final VoidCallback onTap;

  const _RecentInvoiceTile({
    required this.invoice,
    required this.paidPaise,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final amount = currency.format(
      MoneyUtils.paiseToRupees(invoice.grandTotalPaise),
    );

    final lifecycle = invoice.status.toUpperCase();

    String? paymentLabel;
    Color paymentColor = AppTheme.secondaryText;
    Color paymentBackground = AppTheme.surfaceMuted;

    if (invoice.status == 'issued') {
      if (paidPaise <= 0) {
        paymentLabel = 'UNPAID';
        paymentColor = AppTheme.danger;
        paymentBackground = AppTheme.dangerSoft;
      } else if (paidPaise >= invoice.grandTotalPaise) {
        paymentLabel = 'PAID';
        paymentColor = AppTheme.success;
        paymentBackground = AppTheme.successSoft;
      } else {
        paymentLabel = 'PARTIAL';
        paymentColor = AppTheme.warning;
        paymentBackground = AppTheme.warningSoft;
      }
    }

    if (invoice.status == 'cancelled') {
      paymentLabel = 'CANCELLED';
      paymentColor = AppTheme.danger;
      paymentBackground = AppTheme.dangerSoft;
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primarySoft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.receipt_outlined,
                color: AppTheme.primary,
                size: 20,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    invoice.partyNameSnapshot,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(invoice.invoiceDate),
                        style: const TextStyle(
                          color: AppTheme.tertiaryText,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lifecycle,
                        style: const TextStyle(
                          color: AppTheme.tertiaryText,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppTheme.darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (paymentLabel != null) ...[
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: paymentBackground,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      paymentLabel,
                      style: TextStyle(
                        color: paymentColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// LOADING / ERROR / EMPTY
// =================================================================

class _FinanceCardLoading extends StatelessWidget {
  const _FinanceCardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 255,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _DashboardErrorCard extends StatelessWidget {
  const _DashboardErrorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.dangerSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppTheme.danger),
          SizedBox(width: 12),
          Expanded(child: Text('Unable to load dashboard statistics.')),
        ],
      ),
    );
  }
}

class _RecentInvoicesLoading extends StatelessWidget {
  const _RecentInvoicesLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _RecentInvoicesError extends StatelessWidget {
  const _RecentInvoicesError();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        'Unable to load recent invoices.',
        style: TextStyle(color: AppTheme.secondaryText),
      ),
    );
  }
}

class _EmptyInvoices extends StatelessWidget {
  const _EmptyInvoices();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 42,
            color: AppTheme.tertiaryText,
          ),
          SizedBox(height: 12),
          Text(
            'No invoices yet',
            style: TextStyle(
              color: AppTheme.darkText,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Your recent billing activity will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.secondaryText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
