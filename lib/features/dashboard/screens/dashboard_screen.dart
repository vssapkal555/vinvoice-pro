import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../../invoices/providers/invoice_list_providers.dart';
import '../../parties/providers/party_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(allInvoicesProvider);

    final partiesAsync = ref.watch(partiesProvider);

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

          await Future.wait([
            ref.read(allInvoicesProvider.future),
            ref.read(partiesProvider.future),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Good day',
                        style: TextStyle(color: AppTheme.secondaryText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'VInvoice Pro',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.darkText,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 34,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Create a new invoice',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Create GST or non-taxable service invoices quickly.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                    ),
                    onPressed: () {
                      context.push('/invoices/new');
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New Invoice'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkText,
              ),
            ),

            const SizedBox(height: 14),

            invoicesAsync.when(
              loading: () => const _OverviewLoading(),
              error: (_, _) => const _OverviewError(),
              data: (invoices) {
                final dashboardInvoices = invoices
                    .where((invoice) => invoice.status != 'cancelled')
                    .toList();

                final totalPaise = dashboardInvoices.fold<int>(
                  0,
                  (total, invoice) => total + invoice.grandTotalPaise,
                );

                final partyCount = partiesAsync.maybeWhen(
                  data: (parties) => parties.length,
                  orElse: () => 0,
                );

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Invoices',
                            value: '${dashboardInvoices.length}',
                            icon: Icons.receipt_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Parties',
                            value: '$partyCount',
                            icon: Icons.business_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _WideStatCard(
                      title: 'Total Invoice Value',
                      value: currency.format(
                        MoneyUtils.paiseToRupees(totalPaise),
                      ),
                      icon: Icons.currency_rupee,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recent Invoices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkText,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Invoice list is available
                    // from bottom navigation.
                  },
                  child: const Text('Latest'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            invoicesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, _) => const Text('Unable to load recent invoices.'),
              data: (invoices) {
                if (invoices.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 34,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 42,
                          color: AppTheme.secondaryText,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Saved invoices will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.secondaryText),
                        ),
                      ],
                    ),
                  );
                }

                final recent = invoices.take(5);

                return Column(
                  children: [
                    for (final invoice in recent)
                      Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          onTap: () {
                            context.push('/invoices/${invoice.id}');
                          },
                          leading: const CircleAvatar(
                            child: Icon(Icons.receipt_long_outlined),
                          ),
                          title: Text(
                            invoice.invoiceNumber,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(invoice.partyNameSnapshot),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                currency.format(
                                  MoneyUtils.paiseToRupees(
                                    invoice.grandTotalPaise,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'dd MMM',
                                ).format(invoice.invoiceDate),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 3),
          Text(title, style: const TextStyle(color: AppTheme.secondaryText)),
        ],
      ),
    );
  }
}

class _WideStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _WideStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppTheme.secondaryText),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
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

class _OverviewLoading extends StatelessWidget {
  const _OverviewLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 110,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _OverviewError extends StatelessWidget {
  const _OverviewError();

  @override
  Widget build(BuildContext context) {
    return const Text('Unable to load dashboard statistics.');
  }
}
