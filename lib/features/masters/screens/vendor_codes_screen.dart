import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../company/providers/company_providers.dart';
import '../providers/vendor_code_providers.dart';
import '../widgets/master_data_ui.dart';

class VendorCodesScreen extends ConsumerStatefulWidget {
  const VendorCodesScreen({super.key});

  @override
  ConsumerState<VendorCodesScreen> createState() => _VendorCodesScreenState();
}

class _VendorCodesScreenState extends ConsumerState<VendorCodesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(vendorCodesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Vendor Codes')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => MasterError(
          title: 'Unable to load vendor codes',
          error: error.toString(),
          onRetry: () => ref.invalidate(vendorCodesProvider),
        ),
        data: (records) {
          final q = _query.trim().toLowerCase();

          final filtered = records.where((record) {
            if (q.isEmpty) return true;

            return record.vendorCode.toLowerCase().contains(q) ||
                (record.description ?? '').toLowerCase().contains(q);
          }).toList();

          final active = records.where((e) => e.isActive).length;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(vendorCodesProvider);
              await ref.read(vendorCodesProvider.future);
            },
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                MasterHero(
                  title: 'Vendor Codes',
                  subtitle: 'Customer billing reference codes',
                  icon: Icons.numbers_rounded,
                  total: records.length,
                  active: active,
                  onAdd: () => _openForm(context),
                ),
                const SizedBox(height: 16),
                MasterSearch(
                  controller: _searchController,
                  hint: 'Search code or description',
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
                MasterResultHeader(
                  title: 'Vendor Codes',
                  count: filtered.length,
                ),
                const SizedBox(height: 10),
                if (records.isEmpty)
                  MasterEmptyState(
                    icon: Icons.numbers_rounded,
                    title: 'No vendor codes yet',
                    message:
                        'Add vendor codes supplied by customers for invoice billing.',
                    buttonLabel: 'Add Vendor Code',
                    onAdd: () => _openForm(context),
                  )
                else if (filtered.isEmpty)
                  const MasterNoMatches()
                else
                  ...filtered.map(
                    (record) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: MasterRecordCard(
                        icon: Icons.numbers_rounded,
                        title: record.vendorCode,
                        subtitle: (record.description ?? '').trim().isEmpty
                            ? 'No description'
                            : record.description!.trim(),
                        active: record.isActive,
                        onTap: () => _openForm(context, vendorCode: record),
                        onActiveChanged: (value) async {
                          await ref
                              .read(appDatabaseProvider)
                              .updateVendorCodeRecord(
                                VendorCodesCompanion(
                                  id: Value(record.id),
                                  isActive: Value(value),
                                ),
                              );
                        },
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

  Future<void> _openForm(BuildContext context, {VendorCode? vendorCode}) async {
    final company = await ref.read(primaryCompanyProvider.future);

    if (company == null || !context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.surface,
      builder: (_) =>
          _VendorCodeForm(companyId: company.id, vendorCode: vendorCode),
    );

    ref.invalidate(vendorCodesProvider);
  }
}

class _VendorCodeForm extends ConsumerStatefulWidget {
  const _VendorCodeForm({required this.companyId, this.vendorCode});

  final String companyId;
  final VendorCode? vendorCode;

  @override
  ConsumerState<_VendorCodeForm> createState() => _VendorCodeFormState();
}

class _VendorCodeFormState extends ConsumerState<_VendorCodeForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _code;
  late final TextEditingController _description;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _code = TextEditingController(text: widget.vendorCode?.vendorCode ?? '');

    _description = TextEditingController(
      text: widget.vendorCode?.description ?? '',
    );
  }

  @override
  void dispose() {
    _code.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final db = ref.read(appDatabaseProvider);
      final code = _code.text.trim().toUpperCase();

      if (widget.vendorCode == null) {
        await db.insertVendorCodeRecord(
          VendorCodesCompanion.insert(
            companyId: widget.companyId,
            vendorCode: code,
            description: Value(_description.text.trim()),
          ),
        );
      } else {
        await db.updateVendorCodeRecord(
          VendorCodesCompanion(
            id: Value(widget.vendorCode!.id),
            vendorCode: Value(code),
            description: Value(_description.text.trim()),
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
      title: widget.vendorCode == null ? 'New Vendor Code' : 'Edit Vendor Code',
      subtitle: 'Customer-specific billing reference',
      icon: Icons.numbers_rounded,
      saving: _saving,
      saveLabel: widget.vendorCode == null
          ? 'Save Vendor Code'
          : 'Update Vendor Code',
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Vendor Code',
                prefixIcon: Icon(Icons.numbers_rounded),
              ),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'Vendor code is required'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
