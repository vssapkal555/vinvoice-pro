import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../company/providers/company_providers.dart';
import '../providers/site_providers.dart';
import '../widgets/master_data_ui.dart';

class SitesScreen extends ConsumerStatefulWidget {
  const SitesScreen({super.key});

  @override
  ConsumerState<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends ConsumerState<SitesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(sitesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Sites / Plants')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => MasterError(
          title: 'Unable to load sites',
          error: error.toString(),
          onRetry: () => ref.invalidate(sitesProvider),
        ),
        data: (records) {
          final q = _query.trim().toLowerCase();

          final filtered = records.where((record) {
            if (q.isEmpty) return true;

            return record.siteName.toLowerCase().contains(q) ||
                (record.siteCode ?? '').toLowerCase().contains(q);
          }).toList();

          final active = records.where((e) => e.isActive).length;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(sitesProvider);
              await ref.read(sitesProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                MasterHero(
                  title: 'Sites / Plants',
                  subtitle: 'Customer sites and service locations',
                  icon: Icons.location_on_outlined,
                  total: records.length,
                  active: active,
                  onAdd: () => _openForm(context),
                ),
                const SizedBox(height: 16),
                MasterSearch(
                  controller: _searchController,
                  hint: 'Search site name or code',
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
                  title: 'Sites / Plants',
                  count: filtered.length,
                ),
                const SizedBox(height: 10),
                if (records.isEmpty)
                  MasterEmptyState(
                    icon: Icons.location_on_outlined,
                    title: 'No sites yet',
                    message:
                        'Add customer sites or plant locations used on invoices.',
                    buttonLabel: 'Add Site',
                    onAdd: () => _openForm(context),
                  )
                else if (filtered.isEmpty)
                  const MasterNoMatches()
                else
                  ...filtered.map(
                    (record) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: MasterRecordCard(
                        icon: Icons.location_on_outlined,
                        title: record.siteName,
                        subtitle: (record.siteCode ?? '').trim().isEmpty
                            ? 'No site code'
                            : 'Code: ${record.siteCode}',
                        active: record.isActive,
                        onTap: () => _openForm(context, site: record),
                        onActiveChanged: (value) async {
                          await ref
                              .read(appDatabaseProvider)
                              .updateSiteRecord(
                                SitesCompanion(
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

  Future<void> _openForm(BuildContext context, {Site? site}) async {
    final company = await ref.read(primaryCompanyProvider.future);

    if (company == null || !context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.surface,
      builder: (_) => _SiteForm(companyId: company.id, site: site),
    );

    ref.invalidate(sitesProvider);
  }
}

class _SiteForm extends ConsumerStatefulWidget {
  const _SiteForm({required this.companyId, this.site});

  final String companyId;
  final Site? site;

  @override
  ConsumerState<_SiteForm> createState() => _SiteFormState();
}

class _SiteFormState extends ConsumerState<_SiteForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _code;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(text: widget.site?.siteName ?? '');

    _code = TextEditingController(text: widget.site?.siteCode ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final db = ref.read(appDatabaseProvider);

      if (widget.site == null) {
        await db.insertSiteRecord(
          SitesCompanion.insert(
            companyId: widget.companyId,
            siteName: _name.text.trim(),
            siteCode: Value(_code.text.trim().toUpperCase()),
          ),
        );
      } else {
        await db.updateSiteRecord(
          SitesCompanion(
            id: Value(widget.site!.id),
            siteName: Value(_name.text.trim()),
            siteCode: Value(_code.text.trim().toUpperCase()),
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
      title: widget.site == null ? 'New Site / Plant' : 'Edit Site / Plant',
      subtitle: 'Location used for service billing',
      icon: Icons.location_on_outlined,
      saving: _saving,
      saveLabel: widget.site == null ? 'Save Site' : 'Update Site',
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Site / Plant Name',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Site name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Site Code',
                prefixIcon: Icon(Icons.qr_code_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
