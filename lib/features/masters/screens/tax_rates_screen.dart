import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../company/providers/company_providers.dart';
import '../../auth/providers/entitlement_write_guard.dart';
import '../providers/tax_rate_providers.dart';
import '../widgets/master_data_ui.dart';

class TaxRatesScreen extends ConsumerStatefulWidget {
  const TaxRatesScreen({super.key});

  @override
  ConsumerState<TaxRatesScreen> createState() => _TaxRatesScreenState();
}

class _TaxRatesScreenState extends ConsumerState<TaxRatesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(taxRatesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('GST & Tax')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => MasterError(
          title: 'Unable to load tax rates',
          error: error.toString(),
          onRetry: () => ref.invalidate(taxRatesProvider),
        ),
        data: (records) {
          final q = _query.trim().toLowerCase();

          final filtered = records.where((record) {
            if (q.isEmpty) return true;

            return record.taxName.toLowerCase().contains(q) ||
                record.percentage.toString().contains(q);
          }).toList();

          final active = records.where((e) => e.isActive).length;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(taxRatesProvider);
              await ref.read(taxRatesProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                MasterHero(
                  title: 'GST & Tax',
                  subtitle: 'Tax rates available during invoicing',
                  icon: Icons.percent_rounded,
                  total: records.length,
                  active: active,
                  onAdd: () => _openForm(context),
                ),
                const SizedBox(height: 16),
                MasterSearch(
                  controller: _searchController,
                  hint: 'Search tax name or percentage',
                  query: _query,
                  onChanged: (value) {
                    setState(() => _query = value);
                  },
                  onClear: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
                const SizedBox(height: 18),
                MasterResultHeader(title: 'Tax Rates', count: filtered.length),
                const SizedBox(height: 10),
                if (records.isEmpty)
                  MasterEmptyState(
                    icon: Icons.percent_rounded,
                    title: 'No tax rates yet',
                    message: 'Add GST rates used for invoice tax calculations.',
                    buttonLabel: 'Add Tax Rate',
                    onAdd: () => _openForm(context),
                  )
                else if (filtered.isEmpty)
                  const MasterNoMatches()
                else
                  ...filtered.map((record) {
                    final builtIn = record.companyId == null;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: MasterRecordCard(
                        icon: Icons.percent_rounded,
                        title: record.taxName,
                        subtitle: '${record.percentage.toStringAsFixed(2)}%',
                        badge: builtIn ? 'DEFAULT' : null,
                        active: record.isActive,
                        onTap: () => _openForm(context, taxRate: record),
                        onActiveChanged: (value) async {
                          if (!await requireEntitlementWriteAccess(
                            context,
                            ref,
                            action: 'change a tax rate',
                          )) {
                            return;
                          }
                          if (!context.mounted) {
                            return;
                          }
                          await ref
                              .read(appDatabaseProvider)
                              .updateTaxRateRecord(
                                TaxRatesCompanion(
                                  id: Value(record.id),
                                  isActive: Value(value),
                                ),
                              );
                        },
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {TaxRate? taxRate}) async {
    if (!await requireEntitlementWriteAccess(
      context,
      ref,
      action: taxRate == null ? 'create a tax rate' : 'edit a tax rate',
    )) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    final company = await ref.read(primaryCompanyProvider.future);

    if (company == null || !context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.surface,
      builder: (_) => _TaxRateForm(companyId: company.id, taxRate: taxRate),
    );

    ref.invalidate(taxRatesProvider);
  }
}

class _TaxRateForm extends ConsumerStatefulWidget {
  const _TaxRateForm({required this.companyId, this.taxRate});

  final String companyId;
  final TaxRate? taxRate;

  @override
  ConsumerState<_TaxRateForm> createState() => _TaxRateFormState();
}

class _TaxRateFormState extends ConsumerState<_TaxRateForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _percentage;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(text: widget.taxRate?.taxName ?? '');

    _percentage = TextEditingController(
      text: widget.taxRate == null ? '' : widget.taxRate!.percentage.toString(),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _percentage.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!await requireEntitlementWriteAccess(
      context,
      ref,
      action: widget.taxRate == null ? 'create a tax rate' : 'edit a tax rate',
    )) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    if (_saving || !_formKey.currentState!.validate()) return;

    final percentage = double.tryParse(_percentage.text.trim());

    if (percentage == null) return;

    setState(() => _saving = true);

    try {
      final db = ref.read(appDatabaseProvider);

      final name = _name.text.trim().toUpperCase();

      if (widget.taxRate == null) {
        await db.insertTaxRateRecord(
          TaxRatesCompanion.insert(
            companyId: Value(widget.companyId),
            taxName: name,
            percentage: percentage,
          ),
        );
      } else {
        await db.updateTaxRateRecord(
          TaxRatesCompanion(
            id: Value(widget.taxRate!.id),
            taxName: Value(name),
            percentage: Value(percentage),
          ),
        );
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterFormShell(
      title: widget.taxRate == null ? 'New Tax Rate' : 'Edit Tax Rate',
      subtitle: 'GST rate used during invoice calculation',
      icon: Icons.percent_rounded,
      saving: _saving,
      saveLabel: widget.taxRate == null ? 'Save Tax Rate' : 'Update Tax Rate',
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Tax Name',
                hintText: 'CGST',
                prefixIcon: Icon(Icons.receipt_long_outlined),
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Tax name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _percentage,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Percentage',
                prefixIcon: Icon(Icons.percent_rounded),
                suffixText: '%',
              ),
              validator: (value) {
                final percentage = double.tryParse((value ?? '').trim());

                if (percentage == null || percentage < 0 || percentage > 100) {
                  return 'Enter a percentage from 0 to 100';
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
