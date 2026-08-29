import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../company/providers/company_providers.dart';
import '../providers/party_providers.dart';

class PartiesScreen extends ConsumerWidget {
  const PartiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partiesAsync = ref.watch(partiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Parties')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openPartyForm(context, ref);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Party'),
      ),
      body: partiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Unable to load parties.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (parties) {
          if (parties.isEmpty) {
            return const Center(child: Text('No parties found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: parties.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final party = parties[index];

              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    child: Text(
                      party.partyName.isEmpty
                          ? '?'
                          : party.partyName[0].toUpperCase(),
                    ),
                  ),
                  title: Text(
                    party.partyName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((party.gstin ?? '').isNotEmpty)
                        Text('GSTIN: ${party.gstin}'),
                      if ((party.phone ?? '').isNotEmpty)
                        Text('Phone: ${party.phone}'),
                    ],
                  ),
                  trailing: Switch(
                    value: party.isActive,
                    onChanged: (value) async {
                      final db = ref.read(appDatabaseProvider);

                      await db.updatePartyRecord(
                        PartiesCompanion(
                          id: Value(party.id),
                          isActive: Value(value),
                          updatedAt: Value(DateTime.now()),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    _openPartyForm(context, ref, party: party);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openPartyForm(
    BuildContext context,
    WidgetRef ref, {
    Party? party,
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
          _PartyFormSheet(companyId: company.id, party: party),
    );
  }
}

class _PartyFormSheet extends ConsumerStatefulWidget {
  final String companyId;
  final Party? party;

  const _PartyFormSheet({required this.companyId, this.party});

  @override
  ConsumerState<_PartyFormSheet> createState() => _PartyFormSheetState();
}

class _PartyFormSheetState extends ConsumerState<_PartyFormSheet> {
  late final TextEditingController _name;
  late final TextEditingController _address1;
  late final TextEditingController _address2;
  late final TextEditingController _address3;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _pincode;
  late final TextEditingController _pan;
  late final TextEditingController _gstin;
  late final TextEditingController _phone;
  late final TextEditingController _email;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final party = widget.party;

    _name = TextEditingController(text: party?.partyName ?? '');

    _address1 = TextEditingController(text: party?.address1 ?? '');

    _address2 = TextEditingController(text: party?.address2 ?? '');

    _address3 = TextEditingController(text: party?.address3 ?? '');

    _city = TextEditingController(text: party?.city ?? '');

    _state = TextEditingController(text: party?.state ?? '');

    _pincode = TextEditingController(text: party?.pincode ?? '');

    _pan = TextEditingController(text: party?.pan ?? '');

    _gstin = TextEditingController(text: party?.gstin ?? '');

    _phone = TextEditingController(text: party?.phone ?? '');

    _email = TextEditingController(text: party?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _address1.dispose();
    _address2.dispose();
    _address3.dispose();
    _city.dispose();
    _state.dispose();
    _pincode.dispose();
    _pan.dispose();
    _gstin.dispose();
    _phone.dispose();
    _email.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Party name is required')));
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final db = ref.read(appDatabaseProvider);

      if (widget.party == null) {
        await db.insertPartyRecord(
          PartiesCompanion.insert(
            companyId: widget.companyId,
            partyName: _name.text.trim(),
            address1: Value(_address1.text.trim()),
            address2: Value(_address2.text.trim()),
            address3: Value(_address3.text.trim()),
            city: Value(_city.text.trim()),
            state: Value(_state.text.trim()),
            pincode: Value(_pincode.text.trim()),
            pan: Value(_pan.text.trim().toUpperCase()),
            gstin: Value(_gstin.text.trim().toUpperCase()),
            phone: Value(_phone.text.trim()),
            email: Value(_email.text.trim()),
          ),
        );
      } else {
        await db.updatePartyRecord(
          PartiesCompanion(
            id: Value(widget.party!.id),
            partyName: Value(_name.text.trim()),
            address1: Value(_address1.text.trim()),
            address2: Value(_address2.text.trim()),
            address3: Value(_address3.text.trim()),
            city: Value(_city.text.trim()),
            state: Value(_state.text.trim()),
            pincode: Value(_pincode.text.trim()),
            pan: Value(_pan.text.trim().toUpperCase()),
            gstin: Value(_gstin.text.trim().toUpperCase()),
            phone: Value(_phone.text.trim()),
            email: Value(_email.text.trim()),
            updatedAt: Value(DateTime.now()),
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
        18,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            widget.party == null ? 'Add Party' : 'Edit Party',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 18),

          _field(_name, 'Party Name'),

          _field(_address1, 'Address 1'),

          _field(_address2, 'Address 2'),

          _field(_address3, 'Address 3'),

          _field(_city, 'City'),

          _field(_state, 'State'),

          _field(_pincode, 'Pincode', keyboardType: TextInputType.number),

          _field(_pan, 'PAN'),

          _field(_gstin, 'GSTIN'),

          _field(_phone, 'Phone', keyboardType: TextInputType.phone),

          _field(_email, 'Email', keyboardType: TextInputType.emailAddress),

          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving...' : 'Save Party'),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
