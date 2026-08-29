import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../providers/invoice_list_providers.dart';
import '../../payments/providers/payment_providers.dart';

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

  _InvoiceFilter _filter = _InvoiceFilter.all;

  _PaymentFilter _paymentFilter = _PaymentFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Invoice> _applyFilters(
    List<Invoice> invoices,
    Map<String, int> paidByInvoice,
  ) {
    final query = _search.trim().toLowerCase();

    return invoices.where((invoice) {
      final matchesStatus = switch (_filter) {
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoices',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.darkText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Search and manage your invoices.',
                        style: TextStyle(color: AppTheme.secondaryText),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    context.push('/invoices/new');
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New'),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search invoice, party, PO or vendor code',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _search = '';
                          });
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
              onChanged: (value) {
                setState(() {
                  _search = value;
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == _InvoiceFilter.all,
                  onTap: () {
                    setState(() {
                      _filter = _InvoiceFilter.all;
                    });
                  },
                ),
                _FilterChip(
                  label: 'Draft',
                  selected: _filter == _InvoiceFilter.draft,
                  onTap: () {
                    setState(() {
                      _filter = _InvoiceFilter.draft;
                    });
                  },
                ),
                _FilterChip(
                  label: 'Issued',
                  selected: _filter == _InvoiceFilter.issued,
                  onTap: () {
                    setState(() {
                      _filter = _InvoiceFilter.issued;
                    });
                  },
                ),
                _FilterChip(
                  label: 'Cancelled',
                  selected: _filter == _InvoiceFilter.cancelled,
                  onTap: () {
                    setState(() {
                      _filter = _InvoiceFilter.cancelled;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Center(
                    child: Text(
                      'Payment:',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                _FilterChip(
                  label: 'All',
                  selected: _paymentFilter == _PaymentFilter.all,
                  onTap: () {
                    setState(() {
                      _paymentFilter = _PaymentFilter.all;
                    });
                  },
                ),
                _FilterChip(
                  label: 'Unpaid',
                  selected: _paymentFilter == _PaymentFilter.unpaid,
                  onTap: () {
                    setState(() {
                      _paymentFilter = _PaymentFilter.unpaid;
                    });
                  },
                ),
                _FilterChip(
                  label: 'Partial',
                  selected: _paymentFilter == _PaymentFilter.partial,
                  onTap: () {
                    setState(() {
                      _paymentFilter = _PaymentFilter.partial;
                    });
                  },
                ),
                _FilterChip(
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
          ),
          const SizedBox(height: 6),

          Expanded(
            child: invoicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Unable to load invoices.\n$error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (invoices) {
                final filtered = _applyFilters(invoices, paidByInvoice);

                if (filtered.isEmpty) {
                  return _EmptyInvoices(
                    hasSearch:
                        _search.isNotEmpty ||
                        _filter != _InvoiceFilter.all ||
                        _paymentFilter != _PaymentFilter.all,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allInvoicesProvider);

                    await ref.read(allInvoicesProvider.future);
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _InvoiceCard(invoice: filtered[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceCard extends ConsumerWidget {
  final Invoice invoice;

  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateFormat('dd MMM yyyy').format(invoice.invoiceDate);

    final amount = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 2,
    ).format(MoneyUtils.paiseToRupees(invoice.grandTotalPaise));

    final paidByInvoice = ref.watch(paidAmountByInvoiceProvider);

    final paid = paidByInvoice[invoice.id] ?? 0;

    final paymentLabel = invoice.status == 'cancelled'
        ? null
        : paid <= 0
        ? 'UNPAID'
        : paid >= invoice.grandTotalPaise
        ? 'PAID'
        : 'PARTIAL';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/invoices/${invoice.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                          invoice.invoiceNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invoice.partyNameSnapshot,
                          style: const TextStyle(color: AppTheme.secondaryText),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _StatusBadge(status: invoice.status),
                      if (paymentLabel != null) ...[
                        const SizedBox(height: 6),
                        _PaymentBadge(label: paymentLabel),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 15,
                    color: AppTheme.secondaryText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: const TextStyle(color: AppTheme.secondaryText),
                  ),
                  const Spacer(),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'draft' => 'DRAFT',
      'issued' => 'ISSUED',
      'cancelled' => 'CANCELLED',
      _ => status.toUpperCase(),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String label;

  const _PaymentBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    IconData icon;

    switch (label) {
      case 'PAID':
        icon = Icons.check_circle_outline;
        break;
      case 'PARTIAL':
        icon = Icons.timelapse_rounded;
        break;
      default:
        icon = Icons.schedule_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          onTap();
        },
      ),
    );
  }
}

class _EmptyInvoices extends StatelessWidget {
  final bool hasSearch;

  const _EmptyInvoices({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppTheme.secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch ? 'No matching invoices found' : 'No invoices yet',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              hasSearch
                  ? 'Try another search or filter.'
                  : 'Create your first invoice from the New button.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
