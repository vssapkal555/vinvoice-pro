import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_shell_navigation.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/money_utils.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/providers/entitlement_write_guard.dart';
import '../../company/providers/company_providers.dart';
import '../../expenses/providers/expense_providers.dart';
import '../../invoices/providers/invoice_list_providers.dart';
import '../../parties/providers/party_providers.dart';
import '../../payments/providers/payment_providers.dart';
import '../../reports/models/report_date_range.dart';
import '../../reports/models/report_models.dart';
import '../../reports/services/report_service.dart';

const String _apkShareUrl = String.fromEnvironment('APK_SHARE_URL');

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(allInvoicesProvider);

    final partiesAsync = ref.watch(partiesProvider);

    final paymentsAsync = ref.watch(allPaymentsProvider);

    final expensesAsync = ref.watch(expensesProvider);

    final paidByInvoice = ref.watch(paidAmountByInvoiceProvider);

    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 2,
    );

    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: const Border(bottom: BorderSide(color: AppTheme.border)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brandNavy.withValues(alpha: 0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const _DashboardHeader(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(allInvoicesProvider);
                ref.invalidate(partiesProvider);
                ref.invalidate(allPaymentsProvider);
                ref.invalidate(expensesProvider);

                await Future.wait([
                  ref.read(allInvoicesProvider.future),
                  ref.read(partiesProvider.future),
                  ref.read(allPaymentsProvider.future),
                  ref.read(expensesProvider.future),
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

                        final outstandingPaise =
                            totalInvoicedPaise - collectedPaise;

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

                        final expenseRecords = expensesAsync.maybeWhen(
                          data: (expenses) => expenses
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
                              .toList(),
                          orElse: () => const <ReportExpenseRecord>[],
                        );

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

                        final profitability =
                            ReportService.profitabilitySummary(
                              invoices: invoiceRecords,
                              expenses: expenseRecords,
                              range: ReportDateRange.fromPreset(
                                ReportDatePreset.thisFinancialYear,
                              ),
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
                              invoiceCount: issuedInvoices.length,
                            ),

                            const SizedBox(height: AppSpacing.md),

                            _DashboardProfitabilityCard(
                              expenses: currency.format(
                                MoneyUtils.paiseToRupees(
                                  profitability.expensePaise,
                                ),
                              ),
                              profit: currency.format(
                                MoneyUtils.paiseToRupees(
                                  profitability.operatingProfitPaise,
                                ),
                              ),
                              margin:
                                  '${profitability.netMarginPercentage.toStringAsFixed(1)}%',
                              profitable: profitability.isProfitable,
                            ),

                            const SizedBox(height: AppSpacing.md),

                            _PaymentStatusStrip(
                              unpaid: unpaidCount,
                              partial: partialCount,
                              paid: paidCount,
                            ),

                            const SizedBox(height: AppSpacing.md),

                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 360,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _MiniMetric(
                                        icon: Icons.receipt_long_outlined,
                                        label: 'Active invoices',
                                        value: '${activeInvoices.length}',
                                        onTap: () => openAppShellTab(1),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: _MiniMetric(
                                        icon: Icons.business_outlined,
                                        label: 'Parties',
                                        value: '$partyCount',
                                        onTap: () => openAppShellTab(2),
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

                  const SizedBox(height: AppSpacing.xxl),

                  const _SectionHeader(
                    title: 'Quick actions',
                    subtitle: 'Common tasks at your fingertips',
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  _QuickActions(
                    onNewInvoice: () async {
                      if (!await requireEntitlementWriteAccess(
                        context,
                        ref,
                        action: 'create an invoice',
                      )) {
                        return;
                      }
                      if (!context.mounted) {
                        return;
                      }
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
                            for (
                              var index = 0;
                              index < recent.length;
                              index++
                            ) ...[
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
          ),
        ],
      ),
    );
  }
}

// =================================================================
// HEADER
// =================================================================

class _DashboardHeader extends ConsumerStatefulWidget {
  const _DashboardHeader();

  @override
  ConsumerState<_DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends ConsumerState<_DashboardHeader> {
  final MenuController _accountMenuController = MenuController();

  Future<void> _handleMenuAction(String value) async {
    if (value == 'share') {
      if (_apkShareUrl.trim().isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('APK download link is not configured yet.'),
          ),
        );
        return;
      }

      await SharePlus.instance.share(
        ShareParams(
          subject: 'VInvoice Pro',
          text:
              'Try VInvoice Pro - Simple, smart and professional invoicing for businesses.\n\n'
              'Download the latest testing APK:\n'
              '$_apkShareUrl',
        ),
      );
      return;
    }

    if (value == 'theme') {
      if (!mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Theme / Appearance',
                    style: Theme.of(sheetContext).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose the accent style used across VInvoice Pro.',
                    style: TextStyle(
                      color: Theme.of(
                        sheetContext,
                      ).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final option in VInvoiceTheme.values)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: option.soft,
                        radius: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 10,
                              height: 18,
                              decoration: BoxDecoration(
                                color: option.primary,
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(8),
                                ),
                              ),
                            ),
                            Container(
                              width: 10,
                              height: 18,
                              decoration: BoxDecoration(
                                color: option.secondary,
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      title: Text(option.label),
                      trailing: appThemeController.theme == option
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: option.primary,
                            )
                          : null,
                      onTap: () async {
                        await appThemeController.setTheme(option);
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                    ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    if (value == 'help') {
      if (!mounted) return;
      context.push('/help');
      return;
    }

    if (value == 'subscription') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Purchase and subscription options are being connected next.',
          ),
        ),
      );
      return;
    }

    if (value != 'logout') return;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text(
            'Your local business data will remain safely stored on this device and will be available again when you sign back in with this account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      await ref.read(authServiceProvider).signOut();
      ref.invalidate(currentUserProvider);
      ref.invalidate(entitlementProvider);
      ref.invalidate(primaryCompanyProvider);
      ref.invalidate(allInvoicesProvider);
      ref.invalidate(partiesProvider);
      ref.invalidate(allPaymentsProvider);
      ref.invalidate(expensesProvider);

      if (!mounted) return;
      context.go('/login');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to log out: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final entitlementAsync = ref.watch(entitlementProvider);
    final companyAsync = ref.watch(primaryCompanyProvider);
    final scheme = Theme.of(context).colorScheme;

    final email = user?.email?.trim().isNotEmpty == true
        ? user!.email!
        : 'Signed-in user';

    final profileName = user?.userMetadata?['full_name']?.toString().trim();
    final emailName = email.contains('@') ? email.split('@').first : email;
    final rawDisplayName = profileName?.isNotEmpty == true
        ? profileName!
        : emailName;
    final displayName = rawDisplayName.isEmpty
        ? 'there'
        : '${rawDisplayName[0].toUpperCase()}${rawDisplayName.substring(1)}';

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    final companyName = companyAsync.maybeWhen(
      data: (company) {
        final name = company?.companyName.trim();
        return name?.isNotEmpty == true ? name! : 'Your Company';
      },
      orElse: () => 'Your Company',
    );

    final entitlement = entitlementAsync.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );

    final statusText =
        entitlement?.displayStatus ??
        (entitlementAsync.isLoading ? 'Checking plan...' : 'Plan unavailable');

    final trialText = entitlement?.isTrial == true
        ? '${entitlement!.trialDaysRemaining} days remaining'
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                'assets/branding/vinvoice_pro_logo.png',
                height: 78,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(width: 12),
            MenuAnchor(
              controller: _accountMenuController,
              alignmentOffset: const Offset(-184, 4),
              style: MenuStyle(
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 7),
                ),
                backgroundColor: WidgetStatePropertyAll(scheme.surface),
                surfaceTintColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
                elevation: const WidgetStatePropertyAll(8),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: scheme.outlineVariant),
                  ),
                ),
              ),
              menuChildren: [
                SizedBox(
                  width: 220,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 7, 14, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (trialText != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            trialText,
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Divider(height: 9, color: scheme.outlineVariant),
                _AccountMenuItem(
                  icon: Icons.palette_outlined,
                  label: 'Theme / Appearance',
                  onPressed: () => _handleMenuAction('theme'),
                ),
                const SizedBox(height: 3),
                _AccountMenuItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Help / User Guide',
                  onPressed: () => _handleMenuAction('help'),
                ),
                const SizedBox(height: 3),
                _AccountMenuItem(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Purchase / Subscription',
                  onPressed: () => _handleMenuAction('subscription'),
                ),
                const SizedBox(height: 3),
                _AccountMenuItem(
                  icon: Icons.share_rounded,
                  label: 'Share VInvoice Pro',
                  onPressed: () => _handleMenuAction('share'),
                ),
                const SizedBox(height: 3),
                _AccountMenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Log out',
                  onPressed: () => _handleMenuAction('logout'),
                ),
              ],
              builder: (context, controller, child) {
                return Tooltip(
                  message: 'Account',
                  child: InkWell(
                    onTap: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(
                        Icons.person_rounded,
                        color: scheme.primary,
                        size: 30,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 15, 16, 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primaryContainer.withValues(alpha: .92),
                Color.lerp(
                  scheme.primaryContainer,
                  scheme.secondaryContainer,
                  .60,
                )!,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.primary.withValues(alpha: .10)),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: .08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: .92),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.waving_hand_outlined,
                  color: scheme.primary,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $displayName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 13.8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.18,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.apartment_rounded,
                          color: scheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            companyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                constraints: const BoxConstraints(minWidth: 80),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: .94),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: .12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dashboard_customize_outlined,
                      color: scheme.primary,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'BUSINESS\nOVERVIEW',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 8.3,
                        fontWeight: FontWeight.w900,
                        height: 1.04,
                        letterSpacing: .5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountMenuItem extends StatelessWidget {
  const _AccountMenuItem({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 220,
      child: MenuItemButton(
        onPressed: onPressed,
        leadingIcon: Icon(icon, size: 19, color: scheme.primary),
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
          visualDensity: VisualDensity.compact,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// =================================================================
// FINANCIAL SUMMARY
// =================================================================

class _DashboardProfitabilityCard extends StatelessWidget {
  const _DashboardProfitabilityCard({
    required this.expenses,
    required this.profit,
    required this.margin,
    required this.profitable,
  });

  final String expenses;
  final String profit;
  final String margin;
  final bool profitable;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkText.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'FY Profitability',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  'This Financial Year',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DashboardProfitMetric(
                  icon: Icons.trending_down_rounded,
                  iconColor: AppTheme.danger,
                  iconBackground: AppTheme.dangerSoft,
                  label: 'Expenses',
                  value: expenses,
                ),
              ),
              const _DashboardMetricDivider(),
              Expanded(
                child: _DashboardProfitMetric(
                  icon: profitable
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  iconColor: profitable ? AppTheme.success : AppTheme.danger,
                  iconBackground: profitable
                      ? AppTheme.successSoft
                      : AppTheme.dangerSoft,
                  label: profitable ? 'Operating Profit' : 'Operating Loss',
                  value: profit,
                ),
              ),
              const _DashboardMetricDivider(),
              Expanded(
                child: _DashboardProfitMetric(
                  icon: Icons.percent_rounded,
                  iconColor: scheme.primary,
                  iconBackground: scheme.primaryContainer,
                  label: 'Margin',
                  value: margin,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardMetricDivider extends StatelessWidget {
  const _DashboardMetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 92,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      color: AppTheme.border,
    );
  }
}

class _DashboardProfitMetric extends StatelessWidget {
  const _DashboardProfitMetric({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(height: 9),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.secondaryText,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.darkText,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _FinanceSummaryCard extends StatelessWidget {
  final String totalInvoiced;
  final String collected;
  final String outstanding;
  final double collectionRatio;
  final int invoiceCount;

  const _FinanceSummaryCard({
    required this.totalInvoiced,
    required this.collected,
    required this.outstanding,
    required this.collectionRatio,
    required this.invoiceCount,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = (collectionRatio * 100).clamp(0, 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.secondary, 0.48)!,
            scheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -32,
            top: -42,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: -58,
            bottom: -72,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Outstanding',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.90),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 7),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            outstanding,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Across $invoiceCount issued '
                          '${invoiceCount == 1 ? 'invoice' : 'invoices'}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.76),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const _RupeeHeroMark(),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _FinanceValue(
                      label: 'Collected',
                      value: collected,
                      dotColor: Color(0xFF86EFAC),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: _FinanceValue(
                      label: 'Invoiced',
                      value: totalInvoiced,
                      dotColor: Color(0xFFBFDBFE),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: collectionRatio.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.22),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                'You have collected $percent% of the total invoiced amount.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.74),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RupeeHeroMark extends StatelessWidget {
  const _RupeeHeroMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 78,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.12,
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(6, 6),
            child: Transform.rotate(
              angle: 0.07,
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.currency_rupee_rounded,
              size: 29,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceValue extends StatelessWidget {
  final String label;
  final String value;
  final Color dotColor;

  const _FinanceValue({
    required this.label,
    required this.value,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.74),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkText.withValues(alpha: 0.028),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _PaymentStatusItem(
              icon: Icons.error_outline_rounded,
              value: '$unpaid',
              label: 'Unpaid',
              foreground: AppTheme.warning,
              background: AppTheme.warningSoft,
            ),
          ),
          const _StatusDivider(),
          Expanded(
            child: _PaymentStatusItem(
              icon: Icons.timelapse_rounded,
              value: '$partial',
              label: 'Partial',
              foreground: Theme.of(context).colorScheme.primary,
              background: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
          const _StatusDivider(),
          Expanded(
            child: _PaymentStatusItem(
              icon: Icons.check_rounded,
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

class _StatusDivider extends StatelessWidget {
  const _StatusDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 50, color: AppTheme.border);
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: foreground),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.secondaryText,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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
  final VoidCallback onTap;

  const _MiniMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.lerp(AppTheme.border, scheme.primary, 0.08)!,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.darkText.withValues(alpha: 0.025),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 17, color: scheme.primary),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: scheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.darkText,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  height: 1.1,
                  color: AppTheme.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onNewInvoice,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primaryContainer.withValues(alpha: 0.88),
                Color.lerp(
                  scheme.primaryContainer,
                  scheme.secondaryContainer,
                  0.55,
                )!,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.10)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primary, scheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 25,
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
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Create a GST or non-taxable invoice',
                      style: TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: scheme.primary,
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
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.secondaryText),
        ),
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
    final scheme = Theme.of(context).colorScheme;
    final amount = currency.format(
      MoneyUtils.paiseToRupees(invoice.grandTotalPaise),
    );

    String paymentLabel = invoice.status.toUpperCase();
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
    } else if (invoice.status == 'cancelled') {
      paymentLabel = 'CANCELLED';
      paymentColor = AppTheme.danger;
      paymentBackground = AppTheme.dangerSoft;
    } else {
      paymentLabel = 'DRAFT';
      paymentColor = AppTheme.warning;
      paymentBackground = AppTheme.warningSoft;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: scheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            invoice.invoiceNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          amount,
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            invoice.partyNameSnapshot,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.secondaryText,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: paymentBackground,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            paymentLabel,
                            style: TextStyle(
                              color: paymentColor,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.primary,
                size: 20,
              ),
            ],
          ),
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
