import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../company/providers/company_providers.dart';
import '../providers/unit_providers.dart';

class UnitsScreen extends ConsumerWidget {
  const UnitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(unitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Units')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openForm(context, ref);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Unit'),
      ),
      body: unitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Unable to load units.\n$error',
            textAlign: TextAlign.center,
          ),
        ),
        data: (units) {
          if (units.isEmpty) {
            return const Center(child: Text('No units found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: units.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final unit = units[index];
              final builtIn = unit.companyId == null;

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    child: Icon(Icons.straighten_rounded),
                  ),
                  title: Text(
                    unit.unitCode,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    builtIn ? '${unit.unitName} â€¢ Default' : unit.unitName,
                  ),
                  trailing: Switch(
                    value: unit.isActive,
                    onChanged: (value) async {
                      final db = ref.read(appDatabaseProvider);

                      await db.updateUnitRecord(
                        UnitsCompanion(
                          id: Value(unit.id),
                          isActive: Value(value),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    _openForm(context, ref, unit: unit);
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
    Unit? unit,
  }) async {
    final company = await ref.read(primaryCompanyProvider.future);

    if (company == null || !context.mounted) {
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _UnitForm(companyId: company.id, unit: unit),
    );
  }
}

class _UnitForm extends ConsumerStatefulWidget {
  final String companyId;
  final Unit? unit;

  const _UnitForm({required this.companyId, this.unit});

  @override
  ConsumerState<_UnitForm> createState() => _UnitFormState();
}

class _UnitFormState extends ConsumerState<_UnitForm> {
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
    final code = _code.text.trim();

    final name = _name.text.trim();

    if (code.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unit code and unit name are required')),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final db = ref.read(appDatabaseProvider);

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
            widget.unit == null ? 'Add Unit' : 'Edit Unit',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _code,
            decoration: const InputDecoration(
              labelText: 'Unit Code',
              hintText: 'EA',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Unit Name',
              hintText: 'Each',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving...' : 'Save Unit'),
          ),
        ],
      ),
    );
  }
}
