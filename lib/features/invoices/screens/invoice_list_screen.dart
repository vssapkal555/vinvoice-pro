import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../../payments/providers/payment_providers.dart';
import '../providers/invoice_list_providers.dart';
import '../../auth/providers/entitlement_write_guard.dart';

enum _InvoiceFilter { all, draft, issued, cancelled }

enum _PaymentFilter { all, unpaid, partial, paid }

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  final _searchController = TextEditingController();

  String _search = '';
  _InvoiceFilter _invoiceFilter = _InvoiceFilter.all;
  _PaymentFilter _paymentFilter = _PaymentFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _search.trim().isNotEmpty ||
      _invoiceFilter != _InvoiceFilter.all ||
      _paymentFilter != _PaymentFilter.all;

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _search = '';
      _invoiceFilter = _InvoiceFilter.all;
      _paymentFilter = _PaymentFilter.all;
    });
  }

  List<Invoice> _applyFilters(
    List<Invoice> invoices,
    Map<String, int> paidByInvoice,
  ) {
    final query = _search.trim().toLowerCase();

    return invoices.where((invoice) {
      final matchesStatus = switch (_invoiceFilter) {
        _InvoiceFilter.all => true,
        _InvoiceFilter.draft => invoice.status == 'draft',
        _InvoiceFilter.issued => invoice.status == 'issued',
        _InvoiceFilter.cancelled => invoice.status == 'cancelled',
      };

      if (!matchesStatus) {
        return false;
      }

      final paid = paidByInvoice[invoice.id] ?? 0;

      final matchesPayment = switch (_paymentFilter) {
        _PaymentFilter.all => true,
        _PaymentFilter.unpaid => invoice.status == 'issued' && paid <= 0,
        _PaymentFilter.partial =>
          invoice.status == 'issued' &&
              paid > 0 &&
              paid < invoice.grandTotalPaise,
        _PaymentFilter.paid =>
          invoice.status == 'issued' && paid >= invoice.grandTotalPaise,
      };

      if (!matchesPayment) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      return invoice.invoiceNumber.toLowerCase().contains(query) ||
          invoice.partyNameSnapshot.toLowerCase().contains(query) ||
          (invoice.poNumber ?? '').toLowerCase().contains(query) ||
          (invoice.vendorCodeSnapshot ?? '').toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(allInvoicesProvider);
    final paidByInvoice = ref.watch(paidAmountByInvoiceProvider);

    return SafeArea(
      child: Column(
        children: [
          _Header(
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _SearchBox(
              controller: _searchController,
              value: _search,
              onChanged: (value) {
                setState(() {
                  _search = value;
                });
              },
              onClear: () {
                _searchController.clear();

                setState(() {
                  _search = '';
                });
              },
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          _FilterSection(
            title: 'Invoice status',
            children: [
              _FilterPill(
                label: 'All',
                selected: _invoiceFilter == _InvoiceFilter.all,
                onTap: () {
                  setState(() {
                    _invoiceFilter = _InvoiceFilter.all;
                  });
                },
              ),
              _FilterPill(
                label: 'Draft',
                selected: _invoiceFilter == _InvoiceFilter.draft,
                onTap: () {
                  setState(() {
                    _invoiceFilter = _InvoiceFilter.draft;
                  });
                },
              ),
              _FilterPill(
                label: 'Issued',
                selected: _invoiceFilter == _InvoiceFilter.issued,
                onTap: () {
                  setState(() {
                    _invoiceFilter = _InvoiceFilter.issued;
                  });
                },
              ),
              _FilterPill(
                label: 'Cancelled',
                selected: _invoiceFilter == _InvoiceFilter.cancelled,
                onTap: () {
                  setState(() {
                    _invoiceFilter = _InvoiceFilter.cancelled;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          _FilterSection(
            title: 'Payment',
            children: [
              _FilterPill(
                label: 'All',
                selected: _paymentFilter == _PaymentFilter.all,
                onTap: () {
                  setState(() {
                    _paymentFilter = _PaymentFilter.all;
                  });
                },
              ),
              _FilterPill(
                label: 'Unpaid',
                selected: _paymentFilter == _PaymentFilter.unpaid,
                onTap: () {
                  setState(() {
                    _paymentFilter = _PaymentFilter.unpaid;
                  });
                },
              ),
              _FilterPill(
                label: 'Partial',
                selected: _paymentFilter == _PaymentFilter.partial,
                onTap: () {
                  setState(() {
                    _paymentFilter = _PaymentFilter.partial;
                  });
                },
              ),
              _FilterPill(
                label: 'Paid',
                selected: _paymentFilter == _PaymentFilter.paid,
                onTap: () {
                  setState(() {
                    _paymentFilter = _PaymentFilter.paid;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 10),

          Expanded(
            child: invoicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorState(
                error: error,
                onRetry: () {
                  ref.invalidate(allInvoicesProvider);
                },
              ),
              data: (invoices) {
                final filtered = _applyFilters(invoices, paidByInvoice);

                return Column(
                  children: [
                    _ResultHeader(
                      count: filtered.length,
                      hasFilters: _hasFilters,
                      onClear: _clearFilters,
                    ),

                    Expanded(
                      child: filtered.isEmpty
                          ? _EmptyState(
                              filtered: _hasFilters,
                              onClearFilters: _hasFilters
                                  ? _clearFilters
                                  : null,
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
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                ref.invalidate(allInvoicesProvider);
                                ref.invalidate(allPaymentsProvider);

                                await Future.wait([
                                  ref.read(allInvoicesProvider.future),
                                  ref.read(allPaymentsProvider.future),
                                ]);
                              },
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final wide = constraints.maxWidth >= 760;

                                  if (wide) {
                                    return GridView.builder(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.fromLTRB(
                                        AppSpacing.lg,
                                        8,
                                        AppSpacing.lg,
                                        AppSpacing.xl,
                                      ),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 14,
                                            mainAxisSpacing: 14,
                                            mainAxisExtent: 164,
                                          ),
                                      itemCount: filtered.length,
                                      itemBuilder: (context, index) {
                                        final invoice = filtered[index];

                                        return _InvoiceTile(
                                          invoice: invoice,
                                          paidPaise:
                                              paidByInvoice[invoice.id] ?? 0,
                                        );
                                      },
                                    );
                                  }

                                  return ListView.separated(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                      AppSpacing.lg,
                                      8,
                                      AppSpacing.lg,
                                      AppSpacing.xl,
                                    ),
                                    itemCount: filtered.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final invoice = filtered[index];

                                      return _InvoiceTile(
                                        invoice: invoice,
                                        paidPaise:
                                            paidByInvoice[invoice.id] ?? 0,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================

class _Header extends StatelessWidget {
  const _Header({required this.onNewInvoice});
  final VoidCallback onNewInvoice;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
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
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: scheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invoices',
                    style: TextStyle(
                      color: AppTheme.darkText,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Manage billing and payment status',
                    style: TextStyle(
                      color: AppTheme.secondaryText,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onNewInvoice,
              icon: const Icon(Icons.add_rounded, size: 17),
              label: const Text('New'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 42),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SEARCH
// ============================================================================

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.value,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brandNavy.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Invoice, party, PO or vendor code',
          prefixIcon: const Icon(Icons.search_rounded, size: 21),
          suffixIcon: value.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 19),
                ),
        ),
      ),
    );
  }
}

// ============================================================================
// FILTERS
// ============================================================================

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppTheme.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: selected
                  ? scheme.primary.withValues(alpha: 0.28)
                  : AppTheme.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_rounded, size: 15, color: scheme.primary),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? scheme.primary : AppTheme.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// RESULT HEADER
// ============================================================================

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.count,
    required this.hasFilters,
    required this.onClear,
  });

  final int count;
  final bool hasFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? '1 invoice' : '$count invoices';

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 4, AppSpacing.lg, 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (hasFilters)
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.restart_alt_rounded, size: 16),
              label: const Text('Reset'),
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 34),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// INVOICE TILE
// ============================================================================

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice, required this.paidPaise});

  final Invoice invoice;
  final int paidPaise;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy').format(invoice.invoiceDate);

    final amount = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 2,
    ).format(MoneyUtils.paiseToRupees(invoice.grandTotalPaise));

    final paymentState = _paymentStateFor(invoice, paidPaise);

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: () {
          context.push('/invoices/${invoice.id}');
        },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppTheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _invoiceIconBackground(context, invoice.status),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        size: 18,
                        color: _invoiceIconColor(context, invoice.status),
                      ),
                    ),

                    const SizedBox(width: 12),

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
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            invoice.partyNameSnapshot,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.secondaryText,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    Text(
                      amount,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.25,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: AppTheme.tertiaryText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: const TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 11,
                      ),
                    ),

                    const Spacer(),

                    _LifecycleBadge(status: invoice.status),

                    if (paymentState != null) ...[
                      const SizedBox(width: 6),
                      _PaymentBadge(state: paymentState),
                    ],

                    const SizedBox(width: 2),

                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.tertiaryText,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _PaymentState? _paymentStateFor(Invoice invoice, int paid) {
    if (invoice.status != 'issued') {
      return null;
    }

    if (paid <= 0) {
      return _PaymentState.unpaid;
    }

    if (paid >= invoice.grandTotalPaise) {
      return _PaymentState.paid;
    }

    return _PaymentState.partial;
  }

  Color _invoiceIconBackground(BuildContext context, String status) {
    return switch (status) {
      'draft' => AppTheme.warningSoft,
      'cancelled' => AppTheme.dangerSoft,
      _ => Theme.of(context).colorScheme.primaryContainer,
    };
  }

  Color _invoiceIconColor(BuildContext context, String status) {
    return switch (status) {
      'draft' => AppTheme.warning,
      'cancelled' => AppTheme.danger,
      _ => Theme.of(context).colorScheme.primary,
    };
  }
}

// ============================================================================
// BADGES
// ============================================================================

enum _PaymentState { unpaid, partial, paid }

class _LifecycleBadge extends StatelessWidget {
  const _LifecycleBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final config = switch (status) {
      'draft' => (
        label: 'DRAFT',
        foreground: AppTheme.warning,
        background: AppTheme.warningSoft,
      ),
      'cancelled' => (
        label: 'CANCELLED',
        foreground: AppTheme.danger,
        background: AppTheme.dangerSoft,
      ),
      _ => (
        label: 'ISSUED',
        foreground: Theme.of(context).colorScheme.primary,
        background: Theme.of(context).colorScheme.primaryContainer,
      ),
    };

    return _Badge(
      label: config.label,
      foreground: config.foreground,
      background: config.background,
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.state});

  final _PaymentState state;

  @override
  Widget build(BuildContext context) {
    final config = switch (state) {
      _PaymentState.unpaid => (
        label: 'UNPAID',
        icon: Icons.schedule_rounded,
        foreground: AppTheme.danger,
        background: AppTheme.dangerSoft,
      ),
      _PaymentState.partial => (
        label: 'PARTIAL',
        icon: Icons.timelapse_rounded,
        foreground: AppTheme.warning,
        background: AppTheme.warningSoft,
      ),
      _PaymentState.paid => (
        label: 'PAID',
        icon: Icons.check_circle_rounded,
        foreground: AppTheme.success,
        background: AppTheme.successSoft,
      ),
    };

    return _Badge(
      label: config.label,
      icon: config.icon,
      foreground: config.foreground,
      background: config.background,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.foreground,
    required this.background,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: foreground),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 9,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EMPTY / ERROR
// ============================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.filtered,
    required this.onNewInvoice,
    this.onClearFilters,
  });

  final bool filtered;
  final VoidCallback onNewInvoice;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(21),
                        ),
                        child: Icon(
                          filtered
                              ? Icons.filter_alt_off_rounded
                              : Icons.receipt_long_outlined,
                          size: 30,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        filtered ? 'No matching invoices' : 'No invoices yet',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.darkText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        filtered
                            ? 'Try changing your search or filters.'
                            : 'Create your first invoice to start billing.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.secondaryText,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (filtered)
                        OutlinedButton.icon(
                          onPressed: onClearFilters,
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Reset filters'),
                        )
                      else
                        FilledButton.icon(
                          onPressed: onNewInvoice,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Create invoice'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.dangerSoft,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppTheme.danger,
                size: 32,
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load invoices',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$error',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.secondaryText,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
