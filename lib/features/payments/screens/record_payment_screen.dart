import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/utils/money_utils.dart';
import '../../invoices/providers/invoice_list_providers.dart';
import '../models/payment_models.dart';
import '../providers/payment_providers.dart';

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

    if (picked == null) {
      return;
    }

    setState(() {
      _paymentDate = picked;
    });
  }

  Future<void> _save(int outstandingPaise) async {
    if (!_formKey.currentState!.validate()) {
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

      if (!mounted) {
        return;
      }

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
      appBar: AppBar(title: const Text('Record Payment')),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Unable to load invoice payment details.\n$error'),
          ),
        ),
        data: (summary) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'Invoice Total',
                          value:
                              '\u20B9${MoneyUtils.paiseToRupeesText(summary.invoiceTotalPaise)}',
                        ),
                        _SummaryRow(
                          label: 'Paid',
                          value:
                              '\u20B9${MoneyUtils.paiseToRupeesText(summary.paidPaise)}',
                        ),
                        _SummaryRow(
                          label: 'Outstanding',
                          value:
                              '\u20B9${MoneyUtils.paiseToRupeesText(summary.outstandingPaise)}',
                          emphasize: true,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Payment Amount',
                    prefixText: '\u20B9 ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final parsed = MoneyUtils.parseRupeesToPaise(value ?? '');

                    if (parsed <= 0) {
                      return 'Enter a valid amount.';
                    }

                    if (parsed > summary.outstandingPaise) {
                      return 'Amount exceeds outstanding balance.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                InkWell(
                  onTap: _saving ? null : _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Payment Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month_outlined),
                    ),
                    child: Text(DateFormat('dd-MM-yyyy').format(_paymentDate)),
                  ),
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<PaymentMode>(
                  initialValue: _paymentMode,
                  decoration: const InputDecoration(
                    labelText: 'Payment Mode',
                    border: OutlineInputBorder(),
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

                const SizedBox(height: 14),

                TextFormField(
                  controller: _referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Reference No.',
                    hintText: 'UTR / Cheque No. / Transaction ID',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _receivedByController,
                  decoration: const InputDecoration(
                    labelText: 'Received By',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                FilledButton.icon(
                  onPressed: _saving || summary.outstandingPaise <= 0
                      ? null
                      : () => _save(summary.outstandingPaise),
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.payments_outlined),
                  label: Text(_saving ? 'Saving...' : 'Record Payment'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
