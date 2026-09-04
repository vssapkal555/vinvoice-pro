import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../../invoices/providers/invoice_list_providers.dart';
import '../models/payment_models.dart';
import '../providers/payment_providers.dart';
import '../../auth/providers/entitlement_write_guard.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const RecordPaymentScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<RecordPaymentScreen> createState() =>
      _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _receivedByController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  PaymentMode _paymentMode = PaymentMode.bankTransfer;

  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _receivedByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _paymentDate = picked;
    });
  }

  Future<void> _save(int outstandingPaise) async {
    if (!await requireEntitlementWriteAccess(
      context,
      ref,
      action: 'record a payment',
    )) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    if (_saving || !_formKey.currentState!.validate()) {
      return;
    }

    final amountPaise = MoneyUtils.parseRupeesToPaise(_amountController.text);

    if (amountPaise <= 0) {
      _message('Enter a valid payment amount.');
      return;
    }

    if (amountPaise > outstandingPaise) {
      _message('Payment cannot exceed outstanding amount.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await ref
          .read(appDatabaseProvider)
          .recordInvoicePayment(
            invoiceId: widget.invoiceId,
            amountPaise: amountPaise,
            paymentDate: _paymentDate,
            paymentMode: _paymentMode.storageValue,
            referenceNumber: _referenceController.text,
            receivedBy: _receivedByController.text,
            notes: _notesController.text,
          );

      ref.invalidate(invoicePaymentSummaryProvider(widget.invoiceId));

      ref.invalidate(invoicePaymentsProvider(widget.invoiceId));

      ref.invalidate(allInvoicesProvider);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        _message(error.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(
      invoicePaymentSummaryProvider(widget.invoiceId),
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Record Payment')),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _PaymentError(
          error: error.toString(),
          onRetry: () {
            ref.invalidate(invoicePaymentSummaryProvider(widget.invoiceId));
          },
        ),
        data: (summary) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    children: [
                      _PaymentHero(
                        invoiceTotalPaise: summary.invoiceTotalPaise,
                        paidPaise: summary.paidPaise,
                        outstandingPaise: summary.outstandingPaise,
                      ),

                      const SizedBox(height: 16),

                      _PaymentSection(
                        icon: Icons.currency_rupee_rounded,
                        title: 'Payment Amount',
                        subtitle: 'Enter the amount received from the customer',
                        child: TextFormField(
                          controller: _amountController,
                          enabled: !_saving,
                          autofocus: false,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Amount Received',
                            prefixText: '\u20B9 ',
                            prefixIcon: Icon(Icons.payments_outlined),
                          ),
                          validator: (value) {
                            final parsed = MoneyUtils.parseRupeesToPaise(
                              value ?? '',
                            );

                            if (parsed <= 0) {
                              return 'Enter a valid amount.';
                            }

                            if (parsed > summary.outstandingPaise) {
                              return 'Amount exceeds outstanding balance.';
                            }

                            return null;
                          },
                        ),
                      ),

                      _PaymentSection(
                        icon: Icons.event_outlined,
                        title: 'Payment Details',
                        subtitle: 'Date and payment method',
                        child: Column(
                          children: [
                            InkWell(
                              onTap: _saving ? null : _pickDate,
                              borderRadius: BorderRadius.circular(14),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Payment Date',
                                  prefixIcon: Icon(
                                    Icons.calendar_month_outlined,
                                  ),
                                  suffixIcon: Icon(Icons.chevron_right_rounded),
                                ),
                                child: Text(
                                  DateFormat(
                                    'dd MMM yyyy',
                                  ).format(_paymentDate),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            DropdownButtonFormField<PaymentMode>(
                              initialValue: _paymentMode,
                              decoration: const InputDecoration(
                                labelText: 'Payment Mode',
                                prefixIcon: Icon(
                                  Icons.account_balance_wallet_outlined,
                                ),
                              ),
                              items: PaymentMode.values
                                  .map(
                                    (mode) => DropdownMenuItem(
                                      value: mode,
                                      child: Text(mode.label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _saving
                                  ? null
                                  : (value) {
                                      if (value == null) {
                                        return;
                                      }

                                      setState(() {
                                        _paymentMode = value;
                                      });
                                    },
                            ),
                          ],
                        ),
                      ),

                      _PaymentSection(
                        icon: Icons.receipt_long_outlined,
                        title: 'Reference',
                        subtitle: 'Optional transaction information',
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _referenceController,
                              enabled: !_saving,
                              decoration: const InputDecoration(
                                labelText: 'Reference No.',
                                hintText: 'UTR / Cheque No. / Transaction ID',
                                prefixIcon: Icon(Icons.tag_rounded),
                              ),
                            ),

                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _receivedByController,
                              enabled: !_saving,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Received By',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                            ),
                          ],
                        ),
                      ),

                      _PaymentSection(
                        icon: Icons.notes_outlined,
                        title: 'Notes',
                        subtitle: 'Optional internal payment note',
                        child: TextFormField(
                          controller: _notesController,
                          enabled: !_saving,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      border: const Border(
                        top: BorderSide(color: AppTheme.border),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.brandNavy.withValues(alpha: .05),
                          blurRadius: 18,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Outstanding',
                                style: TextStyle(
                                  color: AppTheme.secondaryText,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '\u20B9${MoneyUtils.paiseToRupeesText(summary.outstandingPaise)}',
                                style: const TextStyle(
                                  color: AppTheme.darkText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: _saving || summary.outstandingPaise <= 0
                                ? null
                                : () => _save(summary.outstandingPaise),
                            icon: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_circle_outline_rounded,
                                  ),
                            label: Text(
                              _saving ? 'Recording...' : 'Record Payment',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaymentHero extends StatelessWidget {
  const _PaymentHero({
    required this.invoiceTotalPaise,
    required this.paidPaise,
    required this.outstandingPaise,
  });

  final int invoiceTotalPaise;
  final int paidPaise;
  final int outstandingPaise;

  @override
  Widget build(BuildContext context) {
    final progress = invoiceTotalPaise <= 0
        ? 0.0
        : (paidPaise / invoiceTotalPaise).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: .15),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payments_outlined, color: Colors.white),
              SizedBox(width: 9),
              Text(
                'Collection Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _HeroAmount(
                  label: 'Invoice',
                  amountPaise: invoiceTotalPaise,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroAmount(label: 'Paid', amountPaise: paidPaise),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Outstanding',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
                Text(
                  '\u20B9${MoneyUtils.paiseToRupeesText(outstandingPaise)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: .18),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '${(progress * 100).toStringAsFixed(0)}% collected',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroAmount extends StatelessWidget {
  const _HeroAmount({required this.label, required this.amountPaise});

  final String label;
  final int amountPaise;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(14),
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
            '\u20B9${MoneyUtils.paiseToRupeesText(amountPaise)}',
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

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }
}

class _PaymentError extends StatelessWidget {
  const _PaymentError({required this.error, required this.onRetry});

  final String error;
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
              'Unable to load payment details',
              style: TextStyle(
                color: AppTheme.darkText,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 16),
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
