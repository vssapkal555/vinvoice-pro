import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../company/providers/company_providers.dart';
import '../../auth/providers/entitlement_write_guard.dart';
import '../providers/unit_providers.dart';
import '../widgets/master_data_ui.dart';

class UnitsScreen extends ConsumerStatefulWidget {
  const UnitsScreen({super.key});

  @override
  ConsumerState<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends ConsumerState<UnitsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(unitsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Units')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => MasterError(
          title: 'Unable to load units',
          error: error.toString(),
          onRetry: () => ref.invalidate(unitsProvider),
        ),
        data: (records) {
          final q = _query.trim().toLowerCase();

          final filtered = records.where((record) {
            if (q.isEmpty) return true;

            return record.unitCode.toLowerCase().contains(q) ||
                record.unitName.toLowerCase().contains(q);
          }).toList();

          final active = records.where((e) => e.isActive).length;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(unitsProvider);
              await ref.read(unitsProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                MasterHero(
                  title: 'Units',
                  subtitle: 'Quantity units used in invoice services',
                  icon: Icons.straighten_rounded,
                  total: records.length,
                  active: active,
                  onAdd: () => _openForm(context),
                ),
                const SizedBox(height: 16),
                MasterSearch(
                  controller: _searchController,
                  hint: 'Search unit code or name',
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
                MasterResultHeader(title: 'Units', count: filtered.length),
                const SizedBox(height: 10),
                if (records.isEmpty)
                  MasterEmptyState(
                    icon: Icons.straighten_rounded,
                    title: 'No units yet',
                    message:
                        'Create quantity units such as EA, Days, Months or KM.',
                    buttonLabel: 'Add Unit',
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
                        icon: Icons.straighten_rounded,
                        title: record.unitCode,
                        subtitle: record.unitName,
                        badge: builtIn ? 'DEFAULT' : null,
                        active: record.isActive,
                        onTap: () => _openForm(context, unit: record),
                        onActiveChanged: (value) async {
                          if (!await requireEntitlementWriteAccess(
                            context,
                            ref,
                            action: 'change a unit',
                          )) {
                            return;
                          }
                          if (!context.mounted) {
                            return;
                          }
                          await ref
                              .read(appDatabaseProvider)
                              .updateUnitRecord(
                                UnitsCompanion(
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

  Future<void> _openForm(BuildContext context, {Unit? unit}) async {
    if (!await requireEntitlementWriteAccess(
      context,
      ref,
      action: unit == null ? 'create a unit' : 'edit a unit',
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
      builder: (_) => _UnitForm(companyId: company.id, unit: unit),
    );

    ref.invalidate(unitsProvider);
  }
}

class _UnitForm extends ConsumerStatefulWidget {
  const _UnitForm({required this.companyId, this.unit});

  final String companyId;
  final Unit? unit;

  @override
  ConsumerState<_UnitForm> createState() => _UnitFormState();
}

class _UnitFormState extends ConsumerState<_UnitForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _code;
  late final TextEditingController _name;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _code = TextEditingController(text: widget.unit?.unitCode ?? '');

    _name = TextEditingController(text: widget.unit?.unitName ?? '');
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!await requireEntitlementWriteAccess(
      context,
      ref,
      action: widget.unit == null ? 'create a unit' : 'edit a unit',
    )) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    if (_saving || !_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final db = ref.read(appDatabaseProvider);

      final code = _code.text.trim().toUpperCase();
      final name = _name.text.trim();

      if (widget.unit == null) {
        await db.insertUnitRecord(
          UnitsCompanion.insert(
            companyId: Value(widget.companyId),
            unitCode: code,
            unitName: name,
          ),
        );
      } else {
        await db.updateUnitRecord(
          UnitsCompanion(
            id: Value(widget.unit!.id),
            unitCode: Value(code),
            unitName: Value(name),
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
      title: widget.unit == null ? 'New Unit' : 'Edit Unit',
      subtitle: 'Quantity unit used for invoice items',
      icon: Icons.straighten_rounded,
      saving: _saving,
      saveLabel: widget.unit == null ? 'Save Unit' : 'Update Unit',
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Unit Code',
                hintText: 'EA',
                prefixIcon: Icon(Icons.code_rounded),
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Unit code is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Unit Name',
                hintText: 'Each',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Unit name is required' : null,
            ),
          ],
        ),
      ),
    );
  }
}
