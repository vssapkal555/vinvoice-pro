import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/company_providers.dart';

class CompanyScreen extends ConsumerWidget {
  const CompanyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyAsync = ref.watch(primaryCompanyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Company')),
      body: companyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (company) {
          if (company == null) {
            return const Center(child: Text('No company profile found'));
          }

          return _CompanyForm(company: company);
        },
      ),
    );
  }
}

class _CompanyForm extends ConsumerStatefulWidget {
  final Company company;

  const _CompanyForm({required this.company});

  @override
  ConsumerState<_CompanyForm> createState() => _CompanyFormState();
}

class _CompanyFormState extends ConsumerState<_CompanyForm> {
  late final TextEditingController _companyName;
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

    _companyName = TextEditingController(text: widget.company.companyName);

    _address1 = TextEditingController(text: widget.company.address1 ?? '');

    _address2 = TextEditingController(text: widget.company.address2 ?? '');

    _address3 = TextEditingController(text: widget.company.address3 ?? '');

    _city = TextEditingController(text: widget.company.city ?? '');

    _state = TextEditingController(text: widget.company.state ?? '');

    _pincode = TextEditingController(text: widget.company.pincode ?? '');

    _pan = TextEditingController(text: widget.company.pan ?? '');

    _gstin = TextEditingController(text: widget.company.gstin ?? '');

    _phone = TextEditingController(text: widget.company.phone ?? '');

    _email = TextEditingController(text: widget.company.email ?? '');
  }

  @override
  void dispose() {
    _companyName.dispose();
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
    if (_companyName.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Company name is required')));
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final db = ref.read(appDatabaseProvider);

      await db.updateCompanyRecord(
        CompaniesCompanion(
          id: Value(widget.company.id),
          companyName: Value(_companyName.text.trim()),
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

      ref.invalidate(primaryCompanyProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company profile updated successfully')),
      );
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Business Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.darkText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'These details will appear on your invoice letterhead.',
          style: TextStyle(color: AppTheme.secondaryText),
        ),
        const SizedBox(height: 24),

        _field(_companyName, 'Company Name'),

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

        const SizedBox(height: 10),

        ElevatedButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_saving ? 'Saving...' : 'Save Company'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
