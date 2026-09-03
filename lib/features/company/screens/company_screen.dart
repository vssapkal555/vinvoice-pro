import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_providers.dart';
import '../../invoices/providers/invoice_list_providers.dart';
import '../data/company_logo_processor.dart';
import '../data/signature_image_processor.dart';
import '../providers/company_providers.dart';

class CompanyScreen extends ConsumerWidget {
  const CompanyScreen({this.createNew = false, super.key});

  final bool createNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final companyAsync = ref.watch(primaryCompanyProvider);
    final companiesAsync = ref.watch(companiesProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(createNew ? 'New Company' : 'My Company'),
        actions: [
          if (!createNew)
            companiesAsync.maybeWhen(
              data: (companies) => PopupMenuButton<String>(
                tooltip: 'Switch company',
                icon: const Icon(Icons.swap_horiz_rounded),
                onSelected: (value) async {
                  if (value == '__new__') {
                    await context.push('/company/new');
                    ref.invalidate(companiesProvider);
                    ref.invalidate(primaryCompanyProvider);
                    ref.invalidate(setupStepProvider);
                    return;
                  }

                  ref.read(selectedCompanyIdProvider.notifier).select(value);
                  ref.invalidate(primaryCompanyProvider);
                  ref.invalidate(setupStepProvider);
                },
                itemBuilder: (context) => [
                  for (final company in companies)
                    PopupMenuItem<String>(
                      value: company.id,
                      child: Row(
                        children: [
                          const Icon(Icons.apartment_outlined, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              company.companyName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: '__new__',
                    child: Row(
                      children: [
                        Icon(Icons.add_business_rounded, size: 18),
                        SizedBox(width: 10),
                        Text('Add Company'),
                      ],
                    ),
                  ),
                ],
              ),
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      body: createNew
          ? _CompanyForm(company: null, ownerUserId: user.id)
          : companyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _CompanyError(
                error: error.toString(),
                onRetry: () {
                  ref.invalidate(companiesProvider);
                  ref.invalidate(primaryCompanyProvider);
                },
              ),
              data: (company) =>
                  _CompanyForm(company: company, ownerUserId: user.id),
            ),
    );
  }
}

class _CompanyForm extends ConsumerStatefulWidget {
  final Company? company;
  final String ownerUserId;

  const _CompanyForm({required this.company, required this.ownerUserId});

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
  late final TextEditingController _customPrefix;
  late final TextEditingController _customSeries;
  late final TextEditingController _signatoryName;
  late final TextEditingController _signatoryDesignation;

  String _invoiceNumberMode = 'standard';
  bool _applySignature = false;
  bool _applySignatureToHistorical = false;
  Uint8List? _signatureImage;
  Uint8List? _logoImage;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _companyName = TextEditingController(
      text: widget.company?.companyName ?? '',
    );

    _address1 = TextEditingController(text: widget.company?.address1 ?? '');

    _address2 = TextEditingController(text: widget.company?.address2 ?? '');

    _address3 = TextEditingController(text: widget.company?.address3 ?? '');

    _city = TextEditingController(text: widget.company?.city ?? '');

    _state = TextEditingController(text: widget.company?.state ?? '');

    _pincode = TextEditingController(text: widget.company?.pincode ?? '');

    _pan = TextEditingController(text: widget.company?.pan ?? '');

    _gstin = TextEditingController(text: widget.company?.gstin ?? '');

    _phone = TextEditingController(text: widget.company?.phone ?? '');

    _email = TextEditingController(text: widget.company?.email ?? '');

    _invoiceNumberMode = widget.company?.invoiceNumberMode ?? 'standard';
    _customPrefix = TextEditingController(
      text: widget.company?.customInvoicePrefix ?? '',
    );
    _customSeries = TextEditingController(
      text: widget.company?.customInvoiceSeries ?? '0001',
    );
    _applySignature = widget.company?.applySignature ?? false;
    _applySignatureToHistorical =
        widget.company?.applySignatureToHistorical ?? false;
    _signatureImage = widget.company?.signatureImage;
    _logoImage = widget.company?.logoImage;
    _signatoryName = TextEditingController(
      text: widget.company?.signatoryName ?? '',
    );
    _signatoryDesignation = TextEditingController(
      text: widget.company?.signatoryDesignation ?? '',
    );
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
    _customPrefix.dispose();
    _customSeries.dispose();
    _signatoryName.dispose();
    _signatoryDesignation.dispose();

    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final selected = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['png', 'jpg', 'jpeg'],
      );

      if (selected == null) return;

      final bytes = await selected.readAsBytes();

      if (bytes.isEmpty) {
        _message('Unable to read the selected company logo.');
        return;
      }

      if (bytes.length > 3 * 1024 * 1024) {
        _message('Company logo must be smaller than 3 MB.');
        return;
      }

      final processed = CompanyLogoProcessor.process(bytes);

      if (!mounted) return;

      setState(() => _logoImage = processed);
      _message('Company logo ready. Save Company to apply it.');
    } catch (error) {
      _message('Unable to select company logo.\n$error');
    }
  }

  Future<void> _pickSignature() async {
    try {
      final selected = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['png', 'jpg', 'jpeg'],
      );
      if (selected == null) return;

      final bytes = await selected.readAsBytes();
      if (bytes.isEmpty) {
        _message('Unable to read the selected signature image.');
        return;
      }
      if (bytes.length > 2 * 1024 * 1024) {
        _message('Signature image must be smaller than 2 MB.');
        return;
      }
      if (!mounted) return;
      final cleaned = SignatureImageProcessor.clean(bytes);

      setState(() => _signatureImage = cleaned);

      _message('Signature auto-cleaned. Check the preview before saving.');
    } catch (error) {
      _message('Unable to select signature image.\n$error');
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_invoiceNumberMode == 'custom') {
      final prefix = _customPrefix.text.trim().toUpperCase();
      final series = _customSeries.text.trim();
      if (prefix.isEmpty ||
          prefix.length > 8 ||
          !RegExp(r'^[A-Z0-9]+$').hasMatch(prefix)) {
        _message('Custom prefix must contain 1 to 8 letters or numbers.');
        return;
      }
      if (series.isEmpty ||
          series.length > 4 ||
          !RegExp(r'^\d+$').hasMatch(series)) {
        _message('Custom series must contain 1 to 4 digits.');
        return;
      }
    }

    if (_applySignature &&
        (_signatureImage == null || _signatureImage!.isEmpty)) {
      _message('Upload a signature image or turn Apply Signature off.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final db = ref.read(appDatabaseProvider);

      final existing = widget.company;

      if (existing == null) {
        final created = await db.insertCompanyRecord(
          CompaniesCompanion.insert(
            ownerUserId: Value(widget.ownerUserId),
            companyName: _companyName.text.trim(),
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
            logoImage: Value(_logoImage),
            invoiceNumberMode: Value(_invoiceNumberMode),
            customInvoicePrefix: Value(
              _invoiceNumberMode == 'custom'
                  ? _customPrefix.text.trim().toUpperCase()
                  : null,
            ),
            customInvoiceSeries: Value(
              _invoiceNumberMode == 'custom' ? _customSeries.text.trim() : null,
            ),
            applySignature: Value(_applySignature),
            applySignatureToHistorical: Value(_applySignatureToHistorical),
            signatureImage: Value(_signatureImage),
            signatoryName: Value(_signatoryName.text.trim()),
            signatoryDesignation: Value(_signatoryDesignation.text.trim()),
          ),
        );

        ref.read(selectedCompanyIdProvider.notifier).select(created.id);
        ref.invalidate(companiesProvider);
        ref.invalidate(primaryCompanyProvider);
        ref.invalidate(setupStepProvider);

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company created successfully')),
        );

        if (Navigator.of(context).canPop()) {
          context.pop();
        }
      } else {
        await db.updateCompanyRecord(
          CompaniesCompanion(
            id: Value(existing.id),
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
            logoImage: Value(_logoImage),
            invoiceNumberMode: Value(_invoiceNumberMode),
            customInvoicePrefix: Value(
              _invoiceNumberMode == 'custom'
                  ? _customPrefix.text.trim().toUpperCase()
                  : null,
            ),
            customInvoiceSeries: Value(
              _invoiceNumberMode == 'custom' ? _customSeries.text.trim() : null,
            ),
            applySignature: Value(_applySignature),
            applySignatureToHistorical: Value(_applySignatureToHistorical),
            signatureImage: Value(_signatureImage),
            signatoryName: Value(_signatoryName.text.trim()),
            signatoryDesignation: Value(_signatoryDesignation.text.trim()),
            updatedAt: Value(DateTime.now()),
          ),
        );

        final signatureChanged =
            existing.applySignature != _applySignature ||
            existing.applySignatureToHistorical !=
                _applySignatureToHistorical ||
            existing.signatoryName != _signatoryName.text.trim() ||
            existing.signatoryDesignation !=
                _signatoryDesignation.text.trim() ||
            !listEquals(existing.signatureImage, _signatureImage);

        if (signatureChanged) {
          await db.syncCompanySignatureToInvoices(
            companyId: existing.id,
            applySignature: _applySignature,
            applyToHistorical: _applySignatureToHistorical,
            signatureImage: _signatureImage,
            signatoryName: _signatoryName.text.trim(),
            signatoryDesignation: _signatoryDesignation.text.trim(),
          );

          ref.invalidate(allInvoicesProvider);
          ref.invalidate(invoiceDetailProvider);
        }

        ref.invalidate(companiesProvider);
        ref.invalidate(primaryCompanyProvider);
        ref.invalidate(setupStepProvider);

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company profile updated successfully'),
            duration: Duration(milliseconds: 900),
          ),
        );
      }
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

                _CompanySection(
                  title: 'Company Branding',
                  subtitle: 'Logo used on invoices and PDF reports',
                  icon: Icons.image_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_logoImage != null)
                        Container(
                          height: 110,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Image.memory(_logoImage!, fit: BoxFit.contain),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceSoft,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                color: AppTheme.secondaryText,
                                size: 30,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No company logo uploaded',
                                style: TextStyle(
                                  color: AppTheme.secondaryText,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickLogo,
                              icon: const Icon(Icons.upload_file_rounded),
                              label: Text(
                                _logoImage == null
                                    ? 'Upload Company Logo'
                                    : 'Replace Company Logo',
                              ),
                            ),
                          ),
                          if (_logoImage != null) ...[
                            const SizedBox(width: 8),
                            IconButton.outlined(
                              tooltip: 'Remove company logo',
                              onPressed: () {
                                setState(() => _logoImage = null);
                              },
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'PNG is recommended. Light white/grey checker backgrounds are cleaned automatically.',
                        style: TextStyle(
                          color: AppTheme.secondaryText,
                          fontSize: 10.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                _CompanySection(
                  title: 'Invoice Numbering',
                  subtitle:
                      'Standard is default; customized numbering is optional',
                  icon: Icons.numbers_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment<String>(
                            value: 'standard',
                            label: Text('Standard'),
                          ),
                          ButtonSegment<String>(
                            value: 'custom',
                            label: Text('Customized'),
                          ),
                        ],
                        selected: {_invoiceNumberMode},
                        onSelectionChanged: (value) {
                          setState(() => _invoiceNumberMode = value.first);
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_invoiceNumberMode == 'standard')
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'VInvoice Pro standard numbering remains unchanged and is generated automatically.',
                            style: TextStyle(
                              color: AppTheme.secondaryText,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        )
                      else ...[
                        TextFormField(
                          controller: _customPrefix,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(8),
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Za-z0-9]'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Custom Prefix',
                            helperText:
                                'Maximum 8 characters; saved in CAPITAL letters',
                            prefixIcon: Icon(Icons.short_text_rounded),
                          ),
                          onChanged: (value) {
                            final upper = value.toUpperCase();
                            if (upper != value) {
                              _customPrefix.value = TextEditingValue(
                                text: upper,
                                selection: TextSelection.collapsed(
                                  offset: upper.length,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _customSeries,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(4),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Starting Number Series',
                            helperText: 'Maximum 4 digits. Example: 0001.',
                            prefixIcon: Icon(
                              Icons.format_list_numbered_rounded,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                _CompanySection(
                  title: 'Digital Signature',
                  subtitle: 'Optional authorised signature for invoice PDFs',
                  icon: Icons.draw_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _applySignature,
                        title: const Text('Apply Signature on Invoice'),
                        subtitle: const Text(
                          'Applies to invoices created in VInvoice Pro. Turn off to keep the signature saved without printing it.',
                        ),
                        onChanged: (value) =>
                            setState(() => _applySignature = value),
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _applySignatureToHistorical,
                        title: const Text(
                          'Apply Signature on Historical Invoices',
                        ),
                        subtitle: const Text(
                          'Default OFF. Turn on only when you intentionally want the current signature on imported or legacy invoices.',
                        ),
                        onChanged: (value) =>
                            setState(() => _applySignatureToHistorical = value),
                      ),
                      const SizedBox(height: 8),
                      if (_signatureImage != null)
                        Container(
                          height: 96,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppTheme.border),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Image.memory(
                            _signatureImage!,
                            fit: BoxFit.contain,
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceSoft,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: const Text(
                            'No signature image uploaded. A selected photo will be auto-cleaned.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.secondaryText,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickSignature,
                              icon: const Icon(Icons.upload_file_rounded),
                              label: Text(
                                _signatureImage == null
                                    ? 'Upload Signature'
                                    : 'Replace Signature',
                              ),
                            ),
                          ),
                          if (_signatureImage != null) ...[
                            const SizedBox(width: 8),
                            IconButton.outlined(
                              tooltip: 'Remove signature',
                              onPressed: () {
                                setState(() {
                                  _signatureImage = null;
                                  _applySignature = false;
                                  _applySignatureToHistorical = false;
                                });
                              },
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _signatoryName,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Signatory Name',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _signatoryDesignation,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Designation',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                    ],
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
              label: Text(
                _saving
                    ? 'Saving...'
                    : (widget.company == null
                          ? 'Create Company'
                          : 'Save Company'),
              ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.16),
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
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 19,
                ),
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
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),

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
