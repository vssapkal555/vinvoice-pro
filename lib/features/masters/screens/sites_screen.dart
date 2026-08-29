import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../company/providers/company_providers.dart';
import '../providers/site_providers.dart';

class SitesScreen extends ConsumerWidget {
  const SitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sitesAsync = ref.watch(sitesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sites / Plants')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openForm(context, ref);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Site'),
      ),
      body: sitesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Unable to load sites.\n$error',
            textAlign: TextAlign.center,
          ),
        ),
        data: (sites) {
          if (sites.isEmpty) {
            return const Center(child: Text('No sites found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: sites.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final site = sites[index];

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    child: Icon(Icons.location_on_outlined),
                  ),
                  title: Text(
                    site.siteName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    (site.siteCode ?? '').isEmpty
                        ? 'No site code'
                        : 'Code: ${site.siteCode}',
                  ),
                  trailing: Switch(
                    value: site.isActive,
                    onChanged: (value) async {
                      final db = ref.read(appDatabaseProvider);

                      await db.updateSiteRecord(
                        SitesCompanion(
                          id: Value(site.id),
                          isActive: Value(value),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    _openForm(context, ref, site: site);
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
    Site? site,
  }) async {
    final company = await ref.read(primaryCompanyProvider.future);

    if (company == null || !context.mounted) {
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _SiteForm(companyId: company.id, site: site),
    );
  }
}

class _SiteForm extends ConsumerStatefulWidget {
  final String companyId;
  final Site? site;

  const _SiteForm({required this.companyId, this.site});

  @override
  ConsumerState<_SiteForm> createState() => _SiteFormState();
}

class _SiteFormState extends ConsumerState<_SiteForm> {
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
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Site name is required')));
      return;
    }

    setState(() {
      _saving = true;
    });

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
            widget.site == null ? 'Add Site / Plant' : 'Edit Site / Plant',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Site / Plant Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _code,
            decoration: const InputDecoration(labelText: 'Site Code'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving...' : 'Save Site'),
          ),
        ],
      ),
    );
  }
}
