import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../company/providers/company_providers.dart';
import '../providers/tax_rate_providers.dart';

class TaxRatesScreen extends ConsumerWidget {
  const TaxRatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taxesAsync = ref.watch(taxRatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('GST & Tax')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openForm(context, ref);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Tax Rate'),
      ),
      body: taxesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Unable to load tax rates.\n$error',
            textAlign: TextAlign.center,
          ),
        ),
        data: (taxes) {
          if (taxes.isEmpty) {
            return const Center(child: Text('No tax rates found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: taxes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final tax = taxes[index];

              final builtIn = tax.companyId == null;

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    child: Icon(Icons.percent_rounded),
                  ),
                  title: Text(
                    tax.taxName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${tax.percentage.toStringAsFixed(2)}%'
                    '${builtIn ? ' â€¢ Default' : ''}',
                  ),
                  trailing: Switch(
                    value: tax.isActive,
                    onChanged: (value) async {
                      final db = ref.read(appDatabaseProvider);

                      await db.updateTaxRateRecord(
                        TaxRatesCompanion(
                          id: Value(tax.id),
                          isActive: Value(value),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    _openForm(context, ref, taxRate: tax);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    TaxRate? taxRate,
  }) async {
    final company = await ref.read(primaryCompanyProvider.future);

    if (company == null || !context.mounted) {
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) =>
          _TaxRateForm(companyId: company.id, taxRate: taxRate),
    );
  }
}

class _TaxRateForm extends ConsumerStatefulWidget {
  final String companyId;
  final TaxRate? taxRate;

  const _TaxRateForm({required this.companyId, this.taxRate});

  @override
  ConsumerState<_TaxRateForm> createState() => _TaxRateFormState();
}

class _TaxRateFormState extends ConsumerState<_TaxRateForm> {
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
    final taxName = _name.text.trim().toUpperCase();

    final percentage = double.tryParse(_percentage.text.trim());

    if (taxName.isEmpty ||
        percentage == null ||
        percentage < 0 ||
        percentage > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid tax name and percentage')),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final db = ref.read(appDatabaseProvider);

      if (widget.taxRate == null) {
        await db.insertTaxRateRecord(
          TaxRatesCompanion.insert(
            companyId: Value(widget.companyId),
            taxName: taxName,
            percentage: percentage,
          ),
        );
      } else {
        await db.updateTaxRateRecord(
          TaxRatesCompanion(
            id: Value(widget.taxRate!.id),
            taxName: Value(taxName),
            percentage: Value(percentage),
          ),
        );
      }

      if (!mounted) return;

      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.taxRate == null ? 'Add Tax Rate' : 'Edit Tax Rate',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Tax Name',
              hintText: 'CGST',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _percentage,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: const InputDecoration(
              labelText: 'Percentage',
              suffixText: '%',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving...' : 'Save Tax Rate'),
          ),
        ],
      ),
    );
  }
}
