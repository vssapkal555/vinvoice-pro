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
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('My Company')),
      body: companyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _CompanyError(
          error: error.toString(),
          onRetry: () {
            ref.invalidate(primaryCompanyProvider);
          },
        ),
        data: (company) {
          if (company == null) {
            return const _NoCompanyProfile();
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
  final _formKey = GlobalKey<FormState>();

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
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save company profile.\n$error')),
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
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;

            final content = ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                wide ? 28 : 16,
                8,
                wide ? 28 : 16,
                130,
              ),
              children: [
                _CompanyHero(
                  companyName: _companyName.text.trim().isEmpty
                      ? 'Your Business'
                      : _companyName.text.trim(),
                  gstin: _gstin.text.trim(),
                ),

                const SizedBox(height: 18),

                _CompanySection(
                  title: 'Business Identity',
                  subtitle: 'Primary information shown on invoices',
                  icon: Icons.apartment_rounded,
                  child: TextFormField(
                    controller: _companyName,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Company Name',
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Company name is required';
                      }

                      return null;
                    },
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ),

                _CompanySection(
                  title: 'Tax & Registration',
                  subtitle: 'Business tax identification details',
                  icon: Icons.receipt_long_outlined,
                  child: LayoutBuilder(
                    builder: (context, sectionConstraints) {
                      final twoColumns = sectionConstraints.maxWidth >= 520;

                      final gstField = TextFormField(
                        controller: _gstin,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'GSTIN',
                          prefixIcon: Icon(Icons.receipt_long_outlined),
                        ),
                        onChanged: (_) {
                          setState(() {});
                        },
                      );

                      final panField = TextFormField(
                        controller: _pan,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'PAN',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      );

                      if (!twoColumns) {
                        return Column(
                          children: [
                            gstField,
                            const SizedBox(height: 12),
                            panField,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: gstField),
                          const SizedBox(width: 12),
                          Expanded(child: panField),
                        ],
                      );
                    },
                  ),
                ),

                _CompanySection(
                  title: 'Registered Address',
                  subtitle: 'Address printed on invoice letterhead',
                  icon: Icons.location_on_outlined,
                  child: Column(
                    children: [
                      _CompanyTextField(
                        controller: _address1,
                        label: 'Address 1',
                      ),

                      _CompanyTextField(
                        controller: _address2,
                        label: 'Address 2',
                      ),

                      _CompanyTextField(
                        controller: _address3,
                        label: 'Address 3',
                      ),

                      LayoutBuilder(
                        builder: (context, sectionConstraints) {
                          final twoColumns = sectionConstraints.maxWidth >= 520;

                          final city = TextFormField(
                            controller: _city,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'City',
                            ),
                          );

                          final state = TextFormField(
                            controller: _state,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'State',
                            ),
                          );

                          if (!twoColumns) {
                            return Row(
                              children: [
                                Expanded(child: city),
                                const SizedBox(width: 10),
                                Expanded(child: state),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: city),
                              const SizedBox(width: 12),
                              Expanded(child: state),
                            ],
                          );
                        },
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
                ),

                _CompanySection(
                  title: 'Contact Information',
                  subtitle: 'Business contact details for customers',
                  icon: Icons.contact_phone_outlined,
                  child: LayoutBuilder(
                    builder: (context, sectionConstraints) {
                      final twoColumns = sectionConstraints.maxWidth >= 520;

                      final phone = TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      );

                      final email = TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      );

                      if (!twoColumns) {
                        return Column(
                          children: [phone, const SizedBox(height: 12), email],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: phone),
                          const SizedBox(width: 12),
                          Expanded(child: email),
                        ],
                      );
                    },
                  ),
                ),

                const _InvoiceProfileNote(),
              ],
            );

            if (!wide) {
              return content;
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: content,
              ),
            );
          },
        ),

        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: const Border(top: BorderSide(color: AppTheme.border)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brandNavy.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
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
              label: Text(_saving ? 'Saving...' : 'Save Company'),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HERO
// ============================================================================

class _CompanyHero extends StatelessWidget {
  const _CompanyHero({required this.companyName, required this.gstin});

  final String companyName;
  final String gstin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryDark, AppTheme.primary],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              companyName.isEmpty ? 'B' : companyName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BUSINESS PROFILE',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  companyName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  gstin.isEmpty ? 'GSTIN not configured' : 'GSTIN $gstin',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FORM SECTION
// ============================================================================

class _CompanySection extends StatelessWidget {
  const _CompanySection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 19),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }
}

class _CompanyTextField extends StatelessWidget {
  const _CompanyTextField({required this.controller, required this.label});

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
// INFORMATION
// ============================================================================

class _InvoiceProfileNote extends StatelessWidget {
  const _InvoiceProfileNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 20),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'These business details are used when creating new invoices. Existing invoices retain their saved company snapshot.',
              style: TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STATES
// ============================================================================

class _CompanyError extends StatelessWidget {
  const _CompanyError({required this.error, required this.onRetry});

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
              color: AppTheme.danger,
              size: 38,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load company profile',
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

class _NoCompanyProfile extends StatelessWidget {
  const _NoCompanyProfile();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.apartment_rounded,
              color: AppTheme.tertiaryText,
              size: 42,
            ),
            SizedBox(height: 12),
            Text(
              'No company profile found',
              style: TextStyle(
                color: AppTheme.darkText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
