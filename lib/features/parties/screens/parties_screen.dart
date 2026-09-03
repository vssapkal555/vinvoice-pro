import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../company/providers/company_providers.dart';
import '../providers/party_providers.dart';

class PartiesScreen extends ConsumerStatefulWidget {
  const PartiesScreen({super.key});

  @override
  ConsumerState<PartiesScreen> createState() => _PartiesScreenState();
}

class _PartiesScreenState extends ConsumerState<PartiesScreen> {
  final _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partiesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: partiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _PartiesError(
          error: error.toString(),
          onRetry: () {
            ref.invalidate(partiesProvider);
          },
        ),
        data: (parties) {
          final normalizedQuery = _query.trim().toLowerCase();

          final filtered = parties.where((party) {
            if (normalizedQuery.isEmpty) {
              return true;
            }

            return party.partyName.toLowerCase().contains(normalizedQuery) ||
                (party.gstin ?? '').toLowerCase().contains(normalizedQuery) ||
                (party.pan ?? '').toLowerCase().contains(normalizedQuery) ||
                (party.phone ?? '').toLowerCase().contains(normalizedQuery) ||
                (party.city ?? '').toLowerCase().contains(normalizedQuery);
          }).toList();

          final activeCount = parties.where((party) => party.isActive).length;

          final inactiveCount = parties.length - activeCount;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.paddingOf(context).top + 12,
                  16,
                  10,
                ),
                child: _PartiesHeader(
                  total: parties.length,
                  active: activeCount,
                  inactive: inactiveCount,
                  onAdd: () {
                    _openPartyForm(context);
                  },
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(partiesProvider);
                    await ref.read(partiesProvider.future);
                  },
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search party, GSTIN, PAN, phone or city',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    _searchController.clear();

                                    setState(() {
                                      _query = '';
                                    });
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _query = value;
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _query.trim().isEmpty
                                  ? 'All Parties'
                                  : 'Search Results',
                              style: const TextStyle(
                                color: AppTheme.darkText,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '${filtered.length} ${filtered.length == 1 ? 'party' : 'parties'}',
                            style: const TextStyle(
                              color: AppTheme.secondaryText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      if (parties.isEmpty)
                        _EmptyParties(
                          onAdd: () {
                            _openPartyForm(context);
                          },
                        )
                      else if (filtered.isEmpty)
                        const _NoSearchResults()
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final grid = constraints.maxWidth >= 760;

                            if (!grid) {
                              return Column(
                                children: [
                                  for (
                                    var index = 0;
                                    index < filtered.length;
                                    index++
                                  ) ...[
                                    _PartyCard(
                                      party: filtered[index],
                                      onTap: () {
                                        _openPartyForm(
                                          context,
                                          party: filtered[index],
                                        );
                                      },
                                      onActiveChanged: (value) {
                                        _setPartyActive(filtered[index], value);
                                      },
                                    ),
                                    if (index < filtered.length - 1)
                                      const SizedBox(height: 10),
                                  ],
                                ],
                              );
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filtered.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 2.15,
                                  ),
                              itemBuilder: (context, index) {
                                final party = filtered[index];

                                return _PartyCard(
                                  party: party,
                                  onTap: () {
                                    _openPartyForm(context, party: party);
                                  },
                                  onActiveChanged: (value) {
                                    _setPartyActive(party, value);
                                  },
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _setPartyActive(Party party, bool value) async {
    final db = ref.read(appDatabaseProvider);

    await db.updatePartyRecord(
      PartiesCompanion(
        id: Value(party.id),
        isActive: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );

    ref.invalidate(partiesProvider);
  }

  Future<void> _openPartyForm(BuildContext context, {Party? party}) async {
    final company = await ref.read(primaryCompanyProvider.future);

    if (company == null || !context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.surface,
      builder: (context) {
        return _PartyFormSheet(companyId: company.id, party: party);
      },
    );

    ref.invalidate(partiesProvider);
  }
}

// ============================================================================
// HEADER
// ============================================================================

class _PartiesHeader extends StatelessWidget {
  const _PartiesHeader({
    required this.total,
    required this.active,
    required this.inactive,
    required this.onAdd,
  });
  final int total;
  final int active;
  final int inactive;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.secondary, 0.58)!,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.13),
            blurRadius: 17,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Directory',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Manage parties used in your invoices',
                      style: TextStyle(color: Colors.white70, fontSize: 9.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: scheme.primary,
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('New'),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _PartyMetric(label: 'Total', value: '$total'),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _PartyMetric(label: 'Active', value: '$active'),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _PartyMetric(label: 'Inactive', value: '$inactive'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PartyMetric extends StatelessWidget {
  const _PartyMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PARTY CARD
// ============================================================================

class _PartyCard extends StatelessWidget {
  const _PartyCard({
    required this.party,
    required this.onTap,
    required this.onActiveChanged,
  });

  final Party party;
  final VoidCallback onTap;
  final ValueChanged<bool> onActiveChanged;

  @override
  Widget build(BuildContext context) {
    final gstin = (party.gstin ?? '').trim();
    final pan = (party.pan ?? '').trim();
    final phone = (party.phone ?? '').trim();
    final city = (party.city ?? '').trim();

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: party.isActive
                      ? Theme.of(context).colorScheme.primaryContainer
                      : AppTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  party.partyName.isEmpty
                      ? '?'
                      : party.partyName[0].toUpperCase(),
                  style: TextStyle(
                    color: party.isActive
                        ? Theme.of(context).colorScheme.primary
                        : AppTheme.secondaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            party.partyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.darkText,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        _StatusBadge(active: party.isActive),
                      ],
                    ),

                    if (gstin.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _PartyMetaLine(
                        icon: Icons.receipt_long_outlined,
                        text: 'GSTIN $gstin',
                      ),
                    ],

                    if (city.isNotEmpty || phone.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      _PartyMetaLine(
                        icon: city.isNotEmpty
                            ? Icons.location_on_outlined
                            : Icons.phone_outlined,
                        text: [
                          if (city.isNotEmpty) city,
                          if (phone.isNotEmpty) phone,
                        ].join('  •  '),
                      ),
                    ],

                    if (pan.isNotEmpty && gstin.isEmpty) ...[
                      const SizedBox(height: 5),
                      _PartyMetaLine(
                        icon: Icons.badge_outlined,
                        text: 'PAN $pan',
                      ),
                    ],

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Text(
                          party.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: party.isActive
                                ? AppTheme.success
                                : AppTheme.secondaryText,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(width: 5),

                        SizedBox(
                          height: 30,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Switch(
                              value: party.isActive,
                              onChanged: onActiveChanged,
                            ),
                          ),
                        ),

                        const Spacer(),

                        const Text(
                          'Tap to edit',
                          style: TextStyle(
                            color: AppTheme.tertiaryText,
                            fontSize: 10,
                          ),
                        ),

                        const SizedBox(width: 3),

                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.tertiaryText,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartyMetaLine extends StatelessWidget {
  const _PartyMetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.tertiaryText),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppTheme.successSoft : AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        active ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          color: active ? AppTheme.success : AppTheme.secondaryText,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ============================================================================
// PARTY FORM
// ============================================================================

class _PartyFormSheet extends ConsumerStatefulWidget {
  const _PartyFormSheet({required this.companyId, this.party});

  final String companyId;
  final Party? party;

  @override
  ConsumerState<_PartyFormSheet> createState() => _PartyFormSheetState();
}

class _PartyFormSheetState extends ConsumerState<_PartyFormSheet> {
  final _formKey = GlobalKey<FormState>();

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

  bool get _editing => widget.party != null;

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
    if (_saving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final db = ref.read(appDatabaseProvider);

      if (!_editing) {
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

      ref.invalidate(partiesProvider);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save party.\n$error')));
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
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return FractionallySizedBox(
      heightFactor: 0.94,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 5,
                  margin: const EdgeInsets.only(top: 9),
                  decoration: BoxDecoration(
                    color: AppTheme.borderStrong,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(
                          Icons.business_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _editing ? 'Edit Party' : 'New Party',
                              style: const TextStyle(
                                color: AppTheme.darkText,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _editing
                                  ? 'Update customer information'
                                  : 'Add a customer to your directory',
                              style: const TextStyle(
                                color: AppTheme.secondaryText,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + keyboard),
                    children: [
                      _PartyFormSection(
                        title: 'Business Details',
                        children: [
                          TextFormField(
                            controller: _name,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Party Name',
                              prefixIcon: Icon(Icons.business_outlined),
                            ),
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Party name is required';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _gstin,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'GSTIN',
                              prefixIcon: Icon(Icons.receipt_long_outlined),
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextFormField(
                            controller: _pan,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'PAN',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      _PartyFormSection(
                        title: 'Address',
                        children: [
                          _PartyTextField(
                            controller: _address1,
                            label: 'Address 1',
                          ),
                          _PartyTextField(
                            controller: _address2,
                            label: 'Address 2',
                          ),
                          _PartyTextField(
                            controller: _address3,
                            label: 'Address 3',
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _city,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'City',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _state,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'State',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _pincode,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Pincode',
                              prefixIcon: Icon(Icons.pin_drop_outlined),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      _PartyFormSection(
                        title: 'Contact',
                        children: [
                          TextFormField(
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    border: Border(top: BorderSide(color: AppTheme.border)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _saving
                              ? 'Saving...'
                              : _editing
                              ? 'Update Party'
                              : 'Save Party',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PartyFormSection extends StatelessWidget {
  const _PartyFormSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.darkText,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _PartyTextField extends StatelessWidget {
  const _PartyTextField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

// ============================================================================
// EMPTY / ERROR
// ============================================================================

class _EmptyParties extends StatelessWidget {
  const _EmptyParties({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.business_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 27,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No parties yet',
            style: TextStyle(
              color: AppTheme.darkText,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Add your first customer to start creating invoices.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.secondaryText, fontSize: 12),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Party'),
          ),
        ],
      ),
    );
  }
}

class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 44),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: AppTheme.tertiaryText,
            size: 34,
          ),
          SizedBox(height: 10),
          Text(
            'No matching parties',
            style: TextStyle(
              color: AppTheme.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try another name, GSTIN, PAN or city.',
            style: TextStyle(color: AppTheme.secondaryText, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _PartiesError extends StatelessWidget {
  const _PartiesError({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 36,
              color: AppTheme.danger,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load parties',
              style: TextStyle(
                color: AppTheme.darkText,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
