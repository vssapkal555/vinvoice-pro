import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../company/providers/company_providers.dart';
import '../providers/vendor_code_providers.dart';

class VendorCodesScreen extends ConsumerWidget {
  const VendorCodesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codesAsync = ref.watch(vendorCodesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Codes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openForm(context, ref);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Vendor Code'),
      ),
      body: codesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Unable to load vendor codes.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (codes) {
          if (codes.isEmpty) {
            return const Center(child: Text('No vendor codes found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: codes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final code = codes[index];

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    child: Icon(Icons.numbers_rounded),
                  ),
                  title: Text(
                    code.vendorCode,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(code.description ?? 'No description'),
                  trailing: Switch(
                    value: code.isActive,
                    onChanged: (value) async {
                      final db = ref.read(appDatabaseProvider);

                      await db.updateVendorCodeRecord(
                        VendorCodesCompanion(
                          id: Value(code.id),
                          isActive: Value(value),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    _openForm(context, ref, vendorCode: code);
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
    VendorCode? vendorCode,
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
          _VendorCodeForm(companyId: company.id, vendorCode: vendorCode),
    );
  }
}

class _VendorCodeForm extends ConsumerStatefulWidget {
  final String companyId;
  final VendorCode? vendorCode;

  const _VendorCodeForm({required this.companyId, this.vendorCode});

  @override
  ConsumerState<_VendorCodeForm> createState() => _VendorCodeFormState();
}

class _VendorCodeFormState extends ConsumerState<_VendorCodeForm> {
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
    final value = _code.text.trim().toUpperCase();

    if (value.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vendor code is required')));

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final db = ref.read(appDatabaseProvider);

      if (widget.vendorCode == null) {
        await db.insertVendorCodeRecord(
          VendorCodesCompanion.insert(
            companyId: widget.companyId,
            vendorCode: value,
            description: Value(_description.text.trim()),
          ),
        );
      } else {
        await db.updateVendorCodeRecord(
          VendorCodesCompanion(
            id: Value(widget.vendorCode!.id),
            vendorCode: Value(value),
            description: Value(_description.text.trim()),
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
            widget.vendorCode == null ? 'Add Vendor Code' : 'Edit Vendor Code',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 18),

          TextField(
            controller: _code,
            decoration: const InputDecoration(labelText: 'Vendor Code'),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'Description'),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving...' : 'Save Vendor Code'),
          ),
        ],
      ),
    );
  }
}
