import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/money_utils.dart';
import '../../../core/utils/contact_validators.dart';
import '../data/invoice_calculator.dart';
import '../models/invoice_form_models.dart';
import '../providers/invoice_form_data_provider.dart';
import '../providers/invoice_list_providers.dart';
import '../../payments/providers/payment_providers.dart';
import '../../auth/providers/entitlement_write_guard.dart';

const _uuid = Uuid();

class CreateInvoiceScreen extends ConsumerWidget {
  const CreateInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(invoiceFormDataProvider);

    return formData.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('New Invoice')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 54),
                const SizedBox(height: 16),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(invoiceFormDataProvider);
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (data) => _CreateInvoiceForm(data: data),
    );
  }
}

class _CreateInvoiceForm extends ConsumerStatefulWidget {
  final InvoiceFormData data;

  const _CreateInvoiceForm({required this.data});

  @override
  ConsumerState<_CreateInvoiceForm> createState() => _CreateInvoiceFormState();
}

class _CreateInvoiceFormState extends ConsumerState<_CreateInvoiceForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _poNumberController;

  late final TextEditingController _serviceEntryController;

  late String _invoiceNumber;

  late DateTime _invoiceDate;

  Party? _party;
  VendorCode? _vendorCode;
  Site? _site;
  final List<Party> _sessionParties = [];
  final List<VendorCode> _sessionVendorCodes = [];
  final List<Site> _sessionSites = [];

  DateTime? _serviceFrom;
  DateTime? _serviceTo;

  InvoiceTaxType _taxType = InvoiceTaxType.taxable;

  InvoiceGstMode _gstMode = InvoiceGstMode.cgstSgst;

  late double _cgstRate;
  late double _sgstRate;
  late double _igstRate;

  late List<_EditableInvoiceItem> _items;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _invoiceNumber = widget.data.invoiceNumber;

    _invoiceDate = DateTime.now();

    _cgstRate = widget.data.taxRate('CGST', 9);

    _sgstRate = widget.data.taxRate('SGST', 9);

    _igstRate = widget.data.taxRate('IGST', 18);

    _poNumberController = TextEditingController();
    _poNumberController.addListener(_onPoChanged);

    _serviceEntryController = TextEditingController();

    _items = List.generate(
      5,
      (_) => _EditableInvoiceItem(unit: _defaultUnit()),
    );
  }

  Unit? _defaultUnit() {
    for (final unit in widget.data.units) {
      if (unit.unitCode.toUpperCase() == 'EA') {
        return unit;
      }
    }

    if (widget.data.units.isEmpty) {
      return null;
    }

    return widget.data.units.first;
  }

  void _onPoChanged() {
    if (mounted) setState(() {});
  }

  List<Site> get _availableSites {
    final party = _party;
    if (party == null) return const [];
    return [...widget.data.sites, ..._sessionSites]
        .where(
          (site) =>
              site.companyId == widget.data.company.id &&
              site.partyId == party.id &&
              site.isActive,
        )
        .toList();
  }

  @override
  void dispose() {
    _poNumberController.removeListener(_onPoChanged);
    _poNumberController.dispose();
    _serviceEntryController.dispose();

    for (final item in _items) {
      item.dispose();
    }

    super.dispose();
  }

  InvoiceCalculationResult get _calculation {
    return InvoiceCalculator.calculate(
      items: _items
          .map(
            (item) => InvoiceLineInput(
              description: item.description.text.trim(),
              hsnSac: item.hsnSac.text.trim(),
              quantity: item.quantity,
              unitId: item.unit?.id,
              unitCode: item.unit?.unitCode ?? '',
              ratePaise: item.ratePaise,
            ),
          )
          .toList(),
      taxType: _taxType,
      gstMode: _effectiveGstMode,
      cgstRate: _cgstRate,
      sgstRate: _sgstRate,
      igstRate: _igstRate,
    );
  }

  InvoiceGstMode get _effectiveGstMode {
    if (_taxType == InvoiceTaxType.nonTaxable) {
      return InvoiceGstMode.none;
    }

    return _gstMode;
  }

  Future<void> _pickInvoiceDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _invoiceDate = selected;
    });
  }

  Future<void> _pickServiceFrom() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _serviceFrom ?? _invoiceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _serviceFrom = selected;

      if (_serviceTo != null && _serviceTo!.isBefore(selected)) {
        _serviceTo = selected;
      }
    });
  }

  Future<void> _pickServiceTo() async {
    final initial = _serviceTo ?? _serviceFrom ?? _invoiceDate;

    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _serviceFrom ?? DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _serviceTo = selected;
    });
  }

  void _addItem() {
    setState(() {
      _items.add(_EditableInvoiceItem(unit: _defaultUnit()));
    });
  }

  void _removeItem(int index) {
    if (_items.length <= 1) {
      return;
    }

    final item = _items.removeAt(index);
    item.dispose();

    setState(() {});
  }

  Future<void> _selectParty() async {
    final selected = await showModalBottomSheet<Party>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _PartyPickerSheet(
        parties: [...widget.data.parties, ..._sessionParties],
        selectedParty: _party,
      ),
    );

    if (selected == null) {
      return;
    }

    final mappedVendors = [...widget.data.vendorCodes, ..._sessionVendorCodes]
        .where(
          (vendor) =>
              vendor.partyId == selected.id &&
              vendor.companyId == widget.data.company.id &&
              vendor.isActive,
        );

    final mappedVendor = mappedVendors.isEmpty ? null : mappedVendors.first;

    final sites = [...widget.data.sites, ..._sessionSites]
        .where(
          (site) =>
              site.companyId == widget.data.company.id &&
              site.partyId == selected.id &&
              site.isActive,
        )
        .toList();

    setState(() {
      _party = selected;
      _vendorCode = mappedVendor;
      _site = sites.length == 1 ? sites.first : null;
    });

    if (mappedVendor == null && mounted) {
      _showMessage(
        'No vendor code is mapped to ${selected.partyName}. Configure it in Vendor Codes.',
      );
    }
  }

  Future<void> _addCustomerFromInvoice() async {
    if (!await requireEntitlementWriteAccess(
      context,
      ref,
      action: 'add a customer',
    )) {
      return;
    }
    if (!mounted) {
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final company = widget.data.company;
    final ownerUserId = company.ownerUserId?.trim();

    if (ownerUserId != null && ownerUserId.isNotEmpty) {
      final available = await db.getAvailableCustomerMastersForCompany(
        ownerUserId: ownerUserId,
        companyId: company.id,
      );

      if (!mounted) {
        return;
      }

      if (available.isNotEmpty) {
        final action = await showModalBottomSheet<String>(
          context: context,
          useSafeArea: true,
          builder: (sheetContext) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add Customer / Party',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(sheetContext, 'existing'),
                  icon: const Icon(Icons.person_search_rounded),
                  label: const Text('Use Existing Customer'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(sheetContext, 'new'),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Create New Customer'),
                ),
              ],
            ),
          ),
        );

        if (!mounted || action == null) {
          return;
        }

        if (action == 'existing') {
          final reusable = await showModalBottomSheet<CustomerMaster>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (sheetContext) => FractionallySizedBox(
              heightFactor: 0.82,
              child: Scaffold(
                appBar: AppBar(title: const Text('Use Existing Customer')),
                body: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: available.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final customer = available[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.business_outlined),
                        ),
                        title: Text(customer.partyName),
                        subtitle: Text(
                          [
                            if ((customer.gstin ?? '').trim().isNotEmpty)
                              'GSTIN ${customer.gstin}',
                            if ((customer.pan ?? '').trim().isNotEmpty)
                              'PAN ${customer.pan}',
                          ].join('  •  '),
                        ),
                        trailing: const Icon(Icons.add_circle_outline_rounded),
                        onTap: () => Navigator.pop(sheetContext, customer),
                      ),
                    );
                  },
                ),
              ),
            ),
          );

          if (!mounted || reusable == null) {
            return;
          }

          final linked = await db.linkCustomerMasterToCompany(
            companyId: company.id,
            customerMasterId: reusable.id,
          );

          if (!mounted) {
            return;
          }

          setState(() {
            _sessionParties.add(linked);
            _party = linked;
            _vendorCode = null;
            _site = null;
          });
          _showMessage('${linked.partyName} added and selected.');
          return;
        }
      }
    }

    final formKey = GlobalKey<FormState>();
    var partyName = '';
    var gstin = '';
    var pan = '';
    var phone = '';
    var email = '';

    final values = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create New Customer'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Customer / Party Name',
                  ),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Customer name is required'
                      : null,
                  onChanged: (value) => partyName = value,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'GSTIN (optional)',
                  ),
                  onChanged: (value) => gstin = value,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'PAN (optional)',
                  ),
                  onChanged: (value) => pan = value,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile (optional)',
                  ),
                  validator: ContactValidators.indianMobile,
                  onChanged: (value) => phone = value,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                  ),
                  validator: ContactValidators.email,
                  onChanged: (value) => email = value,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }
              Navigator.pop(dialogContext, {
                'partyName': partyName.trim(),
                'gstin': gstin.trim(),
                'pan': pan.trim(),
                'phone': phone.trim(),
                'email': email.trim(),
              });
            },
            child: const Text('Add Customer'),
          ),
        ],
      ),
    );

    if (!mounted || values == null) {
      return;
    }

    Party created;
    if (ownerUserId != null && ownerUserId.isNotEmpty) {
      created = await db.createCustomerMasterAndLink(
        companyId: company.id,
        ownerUserId: ownerUserId,
        partyName: values['partyName']!,
        gstin: values['gstin'],
        pan: values['pan'],
        phone: ContactValidators.normalizeIndianMobile(values['phone'] ?? ''),
        email: ContactValidators.normalizeEmail(values['email'] ?? ''),
      );
    } else {
      final id = _uuid.v4();
      await db.insertPartyRecord(
        PartiesCompanion.insert(
          id: Value(id),
          companyId: company.id,
          partyName: values['partyName']!,
          gstin: Value(values['gstin']),
          pan: Value(values['pan']),
          phone: Value(
            ContactValidators.normalizeIndianMobile(values['phone'] ?? ''),
          ),
          email: Value(ContactValidators.normalizeEmail(values['email'] ?? '')),
        ),
      );
      final parties = await db.getPartiesForCompany(company.id);
      created = parties.firstWhere((party) => party.id == id);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _sessionParties.add(created);
      _party = created;
      _vendorCode = null;
      _site = null;
    });
    _showMessage('${created.partyName} added and selected.');
  }

  Future<void> _addVendorCodeForSelectedParty() async {
    final party = _party;
    if (party == null) {
      _showMessage('Select a customer before adding a Vendor Code.');
      return;
    }

    if (!await requireEntitlementWriteAccess(
      context,
      ref,
      action: 'create a vendor code',
    )) {
      return;
    }
    if (!mounted) {
      return;
    }

    final formKey = GlobalKey<FormState>();
    var code = '';
    var description = '';

    final values = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Vendor Code • ${party.partyName}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Vendor Code'),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Vendor code is required'
                    : null,
                onChanged: (value) => code = value,
              ),
              const SizedBox(height: 10),
              TextFormField(
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
                onChanged: (value) => description = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }
              Navigator.pop(dialogContext, {
                'code': code.trim(),
                'description': description.trim(),
              });
            },
            child: const Text('Add Vendor Code'),
          ),
        ],
      ),
    );

    if (!mounted || values == null) {
      return;
    }

    final db = ref.read(appDatabaseProvider);
    try {
      await db.insertVendorCodeRecord(
        VendorCodesCompanion.insert(
          id: Value(_uuid.v4()),
          companyId: widget.data.company.id,
          partyId: Value(party.id),
          vendorCode: values['code']!,
          description: Value(values['description']),
        ),
      );
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Unable to add Vendor Code. It may already exist for this customer.',
        );
      }
      return;
    }

    final created = await db.getVendorCodeForParty(
      companyId: widget.data.company.id,
      partyId: party.id,
    );

    if (!mounted || created == null) {
      return;
    }

    setState(() {
      _sessionVendorCodes.add(created);
      _vendorCode = created;
    });
    _showMessage('${created.vendorCode} added and selected.');
  }

  Future<void> _addSiteForSelectedParty() async {
    final party = _party;
    if (party == null) {
      _showMessage('Select a customer before adding a Site / Plant.');
      return;
    }
    if (!await requireEntitlementWriteAccess(
      context,
      ref,
      action: 'create a site / plant',
    )) {
      return;
    }
    if (!mounted) {
      return;
    }

    var siteNameInput = '';
    var siteCodeInput = '';
    final values = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Site / Plant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              textCapitalization: TextCapitalization.words,
              onChanged: (value) => siteNameInput = value,
              decoration: const InputDecoration(labelText: 'Site / Plant Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => siteCodeInput = value,
              decoration: const InputDecoration(
                labelText: 'Site Code (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = siteNameInput.trim();
              if (name.isEmpty) {
                return;
              }
              FocusScope.of(dialogContext).unfocus();
              Navigator.pop(dialogContext, [name, siteCodeInput.trim()]);
            },
            child: const Text('Save Site'),
          ),
        ],
      ),
    );
    if (values == null || !mounted) return;

    final id = _uuid.v4();
    final db = ref.read(appDatabaseProvider);
    await db.insertSiteRecord(
      SitesCompanion.insert(
        id: Value(id),
        companyId: widget.data.company.id,
        partyId: Value(party.id),
        siteName: values[0],
        siteCode: Value(values[1].isEmpty ? null : values[1]),
      ),
    );
    final refreshed = await db.getActiveSitesForParty(
      companyId: widget.data.company.id,
      partyId: party.id,
    );
    Site? created;
    for (final site in refreshed) {
      if (site.id == id) {
        created = site;
        break;
      }
    }
    if (!mounted || created == null) return;
    setState(() {
      _sessionSites.add(created!);
      _site = created;
    });
    _showMessage('${created.siteName} added and selected.');
  }

  Future<void> _saveInvoice({required bool issue}) async {
    if (!await requireEntitlementWriteAccess(
      context,
      ref,
      action: issue ? 'issue an invoice' : 'save an invoice draft',
    )) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    if (_saving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_party == null) {
      _showMessage('Please select a party.');
      return;
    }

    if (_vendorCode == null) {
      _showMessage(
        'This customer has no vendor code for the selected company. Configure the vendor code first.',
      );
      return;
    }

    if (issue && _poNumberController.text.trim().isEmpty) {
      _showMessage('PO Number is required to issue an invoice.');
      return;
    }

    if (_availableSites.isNotEmpty && _site == null) {
      _showMessage('Please select a Site / Plant.');
      return;
    }

    final validItems = _items.where(
      (item) =>
          item.description.text.trim().isNotEmpty &&
          item.quantity > 0 &&
          item.ratePaise >= 0,
    );

    if (validItems.isEmpty) {
      _showMessage('Add at least one invoice item.');
      return;
    }

    if (_serviceFrom != null &&
        _serviceTo != null &&
        _serviceTo!.isBefore(_serviceFrom!)) {
      _showMessage('Service To cannot be before Service From.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final db = ref.read(appDatabaseProvider);

      final company = widget.data.company;

      final party = _party!;

      final calculation = _calculation;

      final invoiceId = _uuid.v4();

      final invoice = InvoicesCompanion.insert(
        id: Value(invoiceId),
        companyId: company.id,
        partyId: Value(party.id),
        invoiceNumber: _invoiceNumber,
        invoiceDate: _invoiceDate,
        poNumber: Value(_emptyToNull(_poNumberController.text)),
        vendorCodeId: Value(_vendorCode?.id),
        siteId: Value(_site?.id),
        serviceEntry: Value(_emptyToNull(_serviceEntryController.text)),
        serviceFrom: Value(_serviceFrom),
        serviceTo: Value(_serviceTo),

        companyNameSnapshot: company.companyName,

        companyAddress1Snapshot: Value(company.address1),

        companyAddress2Snapshot: Value(company.address2),

        companyAddress3Snapshot: Value(
          _buildAddress3(
            company.address3,
            company.city,
            company.state,
            company.pincode,
          ),
        ),

        companyPanSnapshot: Value(company.pan),

        companyGstinSnapshot: Value(company.gstin),
        companyLogoSnapshot: Value(company.logoImage),

        signatureAppliedSnapshot: Value(
          company.applySignature &&
              company.signatureImage != null &&
              company.signatureImage!.isNotEmpty,
        ),
        signatureImageSnapshot: Value(
          company.applySignature ? company.signatureImage : null,
        ),
        signatoryNameSnapshot: Value(
          company.applySignature ? company.signatoryName : null,
        ),
        signatoryDesignationSnapshot: Value(
          company.applySignature ? company.signatoryDesignation : null,
        ),
        signatureEligible: const Value(true),

        partyNameSnapshot: party.partyName,

        partyAddress1Snapshot: Value(party.address1),

        partyAddress2Snapshot: Value(party.address2),

        partyAddress3Snapshot: Value(
          _buildAddress3(
            party.address3,
            party.city,
            party.state,
            party.pincode,
          ),
        ),

        partyPanSnapshot: Value(party.pan),

        partyGstinSnapshot: Value(party.gstin),

        vendorCodeSnapshot: Value(_vendorCode?.vendorCode),

        siteNameSnapshot: Value(_site?.siteName),

        taxType: Value(
          _taxType == InvoiceTaxType.taxable ? 'taxable' : 'nonTaxable',
        ),

        gstMode: Value(switch (_effectiveGstMode) {
          InvoiceGstMode.cgstSgst => 'cgstSgst',
          InvoiceGstMode.igst => 'igst',
          InvoiceGstMode.none => 'none',
        }),

        basicAmountPaise: Value(calculation.basicAmountPaise),

        taxableAmountPaise: Value(calculation.taxableAmountPaise),

        cgstRate: Value(calculation.cgstRate),

        cgstAmountPaise: Value(calculation.cgstAmountPaise),

        sgstRate: Value(calculation.sgstRate),

        sgstAmountPaise: Value(calculation.sgstAmountPaise),

        igstRate: Value(calculation.igstRate),

        igstAmountPaise: Value(calculation.igstAmountPaise),

        grandTotalPaise: Value(calculation.grandTotalPaise),

        amountInWords: Value(calculation.amountInWords),

        status: Value(issue ? 'issued' : 'draft'),

        syncStatus: const Value('local'),
      );

      final itemCompanions = <InvoiceItemsCompanion>[];

      var serial = 1;

      for (final item in _items) {
        final description = item.description.text.trim();

        if (description.isEmpty) {
          continue;
        }

        itemCompanions.add(
          InvoiceItemsCompanion.insert(
            id: Value(_uuid.v4()),
            invoiceId: invoiceId,
            serialNo: serial,
            description: description,
            hsnSac: Value(_emptyToNull(item.hsnSac.text)),
            quantity: Value(item.quantity),
            unitId: Value(item.unit?.id),
            unitCodeSnapshot: Value(item.unit?.unitCode),
            ratePaise: Value(item.ratePaise),
            amountPaise: Value(item.amountPaise),
          ),
        );

        serial++;
      }

      await db.saveInvoiceWithItems(invoice: invoice, items: itemCompanions);

      ref.invalidate(invoiceFormDataProvider);
      ref.invalidate(allInvoicesProvider);
      ref.invalidate(invoiceDetailProvider(invoiceId));
      ref.invalidate(invoicePaymentSummaryProvider(invoiceId));

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline, size: 48),
          title: Text(issue ? 'Invoice Issued' : 'Draft Saved'),
          content: Text(
            issue
                ? 'Invoice $_invoiceNumber was issued successfully.'
                : 'Invoice $_invoiceNumber was saved successfully.',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage('Unable to save invoice.\n$error');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _emptyToNull(String? value) {
    final text = value?.trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  String? _buildAddress3(
    String? address3,
    String? city,
    String? state,
    String? pincode,
  ) {
    final result = <String>[];

    final existing = (address3 ?? '').trim();

    if (existing.isNotEmpty) {
      result.add(existing);
    }

    final existingLower = existing.toLowerCase();

    final cityText = (city ?? '').trim();

    final stateText = (state ?? '').trim();

    final pinText = (pincode ?? '').trim();

    if (cityText.isNotEmpty &&
        !existingLower.contains(cityText.toLowerCase())) {
      result.add(cityText);
    }

    if (stateText.isNotEmpty &&
        !existingLower.contains(stateText.toLowerCase())) {
      result.add(stateText);
    }

    if (pinText.isNotEmpty && !existingLower.contains(pinText.toLowerCase())) {
      result.add(pinText);
    }

    return result.isEmpty ? null : result.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final calculation = _calculation;

    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 2,
    );

    final grandTotal = currency.format(
      MoneyUtils.paiseToRupees(calculation.grandTotalPaise),
    );

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(title: const Text('New Invoice')),

      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;

            final formContent = ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                wide ? 28 : 16,
                8,
                wide ? 28 : 16,
                130,
              ),
              children: [
                // =====================================================
                // INVOICE HERO
                // =====================================================
                _InvoiceHero(
                  invoiceNumber: _invoiceNumber,
                  invoiceDate: _invoiceDate,
                  grandTotal: grandTotal,
                  onDateTap: _pickInvoiceDate,
                ),

                const SizedBox(height: 18),

                // =====================================================
                // CUSTOMER
                // =====================================================
                _ModernSection(
                  title: 'Customer',
                  subtitle: 'Who are you billing?',
                  icon: Icons.business_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PartySelector(party: _party, onTap: _selectParty),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _addCustomerFromInvoice,
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          label: Text(
                            _party == null
                                ? 'Add Customer'
                                : 'Add / Link Customer',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // =====================================================
                // BILLING DETAILS
                // =====================================================
                _ModernSection(
                  title: 'Billing details',
                  subtitle: 'Reference and vendor information',
                  icon: Icons.description_outlined,
                  child: LayoutBuilder(
                    builder: (context, sectionConstraints) {
                      final twoColumns = sectionConstraints.maxWidth >= 560;

                      final fields = [
                        TextFormField(
                          controller: _poNumberController,
                          decoration: const InputDecoration(
                            labelText: 'PO Number',
                            prefixIcon: Icon(
                              Icons.confirmation_number_outlined,
                            ),
                          ),
                        ),
                        TextFormField(
                          controller: _serviceEntryController,
                          decoration: const InputDecoration(
                            labelText: 'Service Entry',
                            prefixIcon: Icon(Icons.assignment_outlined),
                          ),
                        ),
                        TextFormField(
                          key: ValueKey(_vendorCode?.id ?? 'no-vendor-code'),
                          initialValue: _vendorCode?.vendorCode ?? '',
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Vendor Code',
                            prefixIcon: const Icon(Icons.numbers_rounded),
                            suffixIcon: IconButton(
                              tooltip: 'Add Vendor Code',
                              onPressed: _party == null
                                  ? null
                                  : _addVendorCodeForSelectedParty,
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                              ),
                            ),
                            helperText: _party == null
                                ? 'Select customer first'
                                : _vendorCode == null
                                ? 'No vendor code mapped to this customer'
                                : 'Automatically selected from customer mapping',
                          ),
                        ),
                        DropdownButtonFormField<Site>(
                          key: ValueKey(
                            '${_party?.id ?? 'no-party'}-${_site?.id ?? 'no-site'}',
                          ),
                          initialValue: _availableSites.contains(_site)
                              ? _site
                              : null,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Site / Plant',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            suffixIcon: IconButton(
                              tooltip: 'Add Site / Plant',
                              onPressed: _party == null
                                  ? null
                                  : _addSiteForSelectedParty,
                              icon: const Icon(Icons.add_location_alt_outlined),
                            ),
                            helperText: _party == null
                                ? 'Select customer first'
                                : _availableSites.isEmpty
                                ? 'No site / plant configured for this customer'
                                : _availableSites.length == 1
                                ? 'Automatically selected'
                                : 'Select one of ${_availableSites.length} available sites',
                          ),
                          items: _availableSites.map((site) {
                            return DropdownMenuItem(
                              value: site,
                              child: Text(site.siteName),
                            );
                          }).toList(),
                          onChanged: _party == null || _availableSites.isEmpty
                              ? null
                              : (value) => setState(() => _site = value),
                        ),
                      ];

                      if (!twoColumns) {
                        return Column(
                          children: [
                            for (
                              var index = 0;
                              index < fields.length;
                              index++
                            ) ...[
                              fields[index],
                              if (index < fields.length - 1)
                                const SizedBox(height: 12),
                            ],
                          ],
                        );
                      }

                      return Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: fields[0]),
                              const SizedBox(width: 12),
                              Expanded(child: fields[1]),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: fields[2]),
                              const SizedBox(width: 12),
                              Expanded(child: fields[3]),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // =====================================================
                // SERVICE PERIOD
                // =====================================================
                _ModernSection(
                  title: 'Service period',
                  subtitle: 'Optional service date range',
                  icon: Icons.date_range_outlined,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ModernDateField(
                          label: 'Service From',
                          date: _serviceFrom,
                          onTap: _pickServiceFrom,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ModernDateField(
                          label: 'Service To',
                          date: _serviceTo,
                          onTap: _pickServiceTo,
                        ),
                      ),
                    ],
                  ),
                ),

                // =====================================================
                // SERVICES
                // =====================================================
                _ModernSection(
                  title: 'Services',
                  subtitle:
                      '${_items.length} service item${_items.length == 1 ? '' : 's'}',
                  icon: Icons.list_alt_rounded,
                  trailing: TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add'),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < _items.length; i++) ...[
                        _InvoiceItemCard(
                          key: ObjectKey(_items[i]),
                          serialNo: i + 1,
                          item: _items[i],
                          units: widget.data.units,
                          canRemove: _items.length > 1,
                          currency: currency,
                          onChanged: () {
                            setState(() {});
                          },
                          onRemove: () {
                            _removeItem(i);
                          },
                        ),
                        if (i < _items.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),

                // =====================================================
                // TAX
                // =====================================================
                _ModernSection(
                  title: 'Tax',
                  subtitle: 'Choose invoice tax treatment',
                  icon: Icons.percent_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<InvoiceTaxType>(
                        segments: const [
                          ButtonSegment(
                            value: InvoiceTaxType.taxable,
                            icon: Icon(Icons.receipt_long_outlined),
                            label: Text('Taxable'),
                          ),
                          ButtonSegment(
                            value: InvoiceTaxType.nonTaxable,
                            icon: Icon(Icons.money_off_csred_outlined),
                            label: Text('Non-Taxable'),
                          ),
                        ],
                        selected: {_taxType},
                        onSelectionChanged: (value) {
                          setState(() {
                            _taxType = value.first;
                          });
                        },
                      ),

                      if (_taxType == InvoiceTaxType.taxable) ...[
                        const SizedBox(height: 18),

                        const Text(
                          'GST Type',
                          style: TextStyle(
                            color: AppTheme.secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 9),

                        Row(
                          children: [
                            Expanded(
                              child: _GstModeOption(
                                title: 'CGST + SGST',
                                subtitle:
                                    '${_formatRate(_cgstRate)}% + ${_formatRate(_sgstRate)}%',
                                selected: _gstMode == InvoiceGstMode.cgstSgst,
                                onTap: () {
                                  setState(() {
                                    _gstMode = InvoiceGstMode.cgstSgst;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _GstModeOption(
                                title: 'IGST',
                                subtitle: '${_formatRate(_igstRate)}%',
                                selected: _gstMode == InvoiceGstMode.igst,
                                onTap: () {
                                  setState(() {
                                    _gstMode = InvoiceGstMode.igst;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // =====================================================
                // SUMMARY
                // =====================================================
                _InvoiceSummaryCard(
                  calculation: calculation,
                  currency: currency,
                  taxType: _taxType,
                  gstMode: _effectiveGstMode,
                  formatRate: _formatRate,
                ),
              ],
            );

            if (!wide) {
              return formContent;
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: formContent,
              ),
            );
          },
        ),
      ),

      bottomNavigationBar: SafeArea(
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grand Total',
                      style: TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        grandTotal,
                        style: const TextStyle(
                          color: AppTheme.darkText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saving
                            ? null
                            : () => _saveInvoice(issue: false),
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save Draft'),
                      ),
                    ),
                    if (_poNumberController.text.trim().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _saving
                              ? null
                              : () => _saveInvoice(issue: true),
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(_saving ? 'Saving...' : 'Issue Invoice'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRate(double rate) {
    if (rate == rate.roundToDouble()) {
      return rate.toInt().toString();
    }

    return rate.toString();
  }
}

class _EditableInvoiceItem {
  final TextEditingController description;
  final TextEditingController hsnSac;
  final TextEditingController quantityText;
  final TextEditingController rateText;

  Unit? unit;

  _EditableInvoiceItem({this.unit})
    : description = TextEditingController(),
      hsnSac = TextEditingController(),
      quantityText = TextEditingController(text: '1'),
      rateText = TextEditingController();

  double get quantity {
    final value = double.tryParse(quantityText.text.trim().replaceAll(',', ''));

    return value ?? 0;
  }

  int get ratePaise {
    return MoneyUtils.parseRupeesToPaise(rateText.text);
  }

  int get amountPaise {
    return (quantity * ratePaise).round();
  }

  void dispose() {
    description.dispose();
    hsnSac.dispose();
    quantityText.dispose();
    rateText.dispose();
  }
}

class _InvoiceItemCard extends StatefulWidget {
  final int serialNo;
  final _EditableInvoiceItem item;
  final List<Unit> units;
  final bool canRemove;
  final NumberFormat currency;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _InvoiceItemCard({
    super.key,
    required this.serialNo,
    required this.item,
    required this.units,
    required this.canRemove,
    required this.currency,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_InvoiceItemCard> createState() => _InvoiceItemCardState();
}

class _InvoiceItemCardState extends State<_InvoiceItemCard> {
  late bool _expanded;

  bool get _hasContent =>
      widget.item.description.text.trim().isNotEmpty ||
      widget.item.hsnSac.text.trim().isNotEmpty ||
      widget.item.rateText.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    // Keep the first row ready for immediate entry.
    // Other empty rows stay compact until tapped.
    _expanded = widget.serialNo == 1 || _hasContent;
  }

  void _notifyChanged() {
    if (!_expanded) {
      setState(() {
        _expanded = true;
      });
    }

    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final amount = widget.currency.format(
      MoneyUtils.paiseToRupees(widget.item.amountPaise),
    );

    final filled = _hasContent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: filled ? AppTheme.surface : AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: filled ? AppTheme.borderStrong : AppTheme.border,
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.serialNo.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            filled
                                ? widget.item.description.text.trim().isNotEmpty
                                      ? widget.item.description.text.trim()
                                      : 'Service item'
                                : 'Empty service item',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          if (filled) ...[
                            const SizedBox(height: 3),
                            Text(
                              amount,
                              style: const TextStyle(
                                color: AppTheme.secondaryText,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (widget.canRemove)
                      IconButton(
                        tooltip: 'Remove',
                        onPressed: widget.onRemove,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppTheme.tertiaryText,
                          size: 19,
                        ),
                      ),

                    AnimatedRotation(
                      duration: const Duration(milliseconds: 180),
                      turns: _expanded ? 0.5 : 0,
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.tertiaryText,
                        size: 23,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            secondChild: const SizedBox.shrink(),
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: widget.item.description,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description of Service',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty &&
                          widget.item.ratePaise > 0) {
                        return 'Description is required';
                      }

                      return null;
                    },
                    onChanged: (_) {
                      _notifyChanged();
                    },
                  ),

                  const SizedBox(height: 11),

                  TextFormField(
                    controller: widget.item.hsnSac,
                    decoration: const InputDecoration(
                      labelText: 'HSN / SAC',
                      prefixIcon: Icon(Icons.tag_outlined),
                    ),
                    onChanged: (_) {
                      _notifyChanged();
                    },
                  ),

                  const SizedBox(height: 11),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.item.quantityText,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,3}'),
                            ),
                          ],
                          decoration: const InputDecoration(labelText: 'Qty'),
                          validator: (value) {
                            if (widget.item.description.text.trim().isEmpty) {
                              return null;
                            }

                            if (widget.item.quantity <= 0) {
                              return 'Invalid';
                            }

                            return null;
                          },
                          onChanged: (_) {
                            _notifyChanged();
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: DropdownButtonFormField<Unit>(
                          initialValue: widget.item.unit,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: widget.units.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit.unitCode),
                            );
                          }).toList(),
                          onChanged: (value) {
                            widget.item.unit = value;
                            _notifyChanged();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 11),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.item.rateText,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Rate',
                            prefixText: '\u20B9 ',
                          ),
                          onChanged: (_) {
                            _notifyChanged();
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 58),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Amount',
                                style: TextStyle(
                                  color: AppTheme.secondaryText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  amount,
                                  style: const TextStyle(
                                    color: AppTheme.primaryDark,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// ============================================================================
// PARTY PICKER
// ============================================================================

class _PartyPickerSheet extends StatefulWidget {
  final List<Party> parties;
  final Party? selectedParty;

  const _PartyPickerSheet({required this.parties, this.selectedParty});

  @override
  State<_PartyPickerSheet> createState() => _PartyPickerSheetState();
}

class _PartyPickerSheetState extends State<_PartyPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.parties.where((party) {
      final query = _query.toLowerCase();

      return party.partyName.toLowerCase().contains(query) ||
          (party.gstin ?? '').toLowerCase().contains(query) ||
          (party.pan ?? '').toLowerCase().contains(query);
    }).toList();

    return FractionallySizedBox(
      heightFactor: 0.90,
      child: Column(
        children: [
          Container(
            width: 42,
            height: 5,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: AppTheme.borderStrong,
              borderRadius: BorderRadius.circular(99),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Customer',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Search your saved parties',
                        style: TextStyle(
                          color: AppTheme.secondaryText,
                          fontSize: 12,
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Party, GSTIN or PAN',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No matching party found',
                      style: TextStyle(color: AppTheme.secondaryText),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final party = filtered[index];

                      final selected = widget.selectedParty?.id == party.id;

                      return Material(
                        color: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pop(context, party);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    party.partyName.isEmpty
                                        ? '?'
                                        : party.partyName[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 13),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        party.partyName,
                                        style: const TextStyle(
                                          color: AppTheme.darkText,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if ((party.gstin ?? '').isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          'GSTIN ${party.gstin}',
                                          style: const TextStyle(
                                            color: AppTheme.secondaryText,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                if (selected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  )
                                else
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppTheme.tertiaryText,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CREATE INVOICE UI
// ============================================================================

class _InvoiceHero extends StatelessWidget {
  const _InvoiceHero({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.grandTotal,
    required this.onDateTap,
  });

  final String invoiceNumber;
  final DateTime invoiceDate;
  final String grandTotal;
  final VoidCallback onDateTap;

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
            ).colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DRAFT INVOICE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            invoiceNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onDateTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            DateFormat('dd MMM yyyy').format(invoiceDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Grand Total',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        grandTotal,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModernSection extends StatelessWidget {
  const _ModernSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

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

              ?trailing,
            ],
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }
}

class _PartySelector extends StatelessWidget {
  const _PartySelector({required this.party, required this.onTap});

  final Party? party;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = party != null;

    return Material(
      color: selected ? AppTheme.primarySoft : AppTheme.surfaceSoft,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.16)
                  : AppTheme.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : AppTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Text(
                        party!.partyName.isEmpty
                            ? '?'
                            : party!.partyName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : const Icon(
                        Icons.business_outlined,
                        color: AppTheme.secondaryText,
                      ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected ? party!.partyName : 'Select customer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      selected
                          ? ((party!.gstin ?? '').isNotEmpty
                                ? 'GSTIN ${party!.gstin}'
                                : 'Saved party')
                          : 'Search your saved parties',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.tertiaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernDateField extends StatelessWidget {
  const _ModernDateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_month_outlined, size: 19),
        ),
        child: Text(
          date == null ? 'Select' : DateFormat('dd MMM yyyy').format(date!),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: date == null ? AppTheme.tertiaryText : AppTheme.darkText,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _GstModeOption extends StatelessWidget {
  const _GstModeOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primarySoft : AppTheme.surfaceSoft,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selected ? AppTheme.primary : AppTheme.tertiaryText,
              size: 20,
            ),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? AppTheme.primaryDark : AppTheme.darkText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.secondaryText,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceSummaryCard extends StatelessWidget {
  const _InvoiceSummaryCard({
    required this.calculation,
    required this.currency,
    required this.taxType,
    required this.gstMode,
    required this.formatRate,
  });

  final InvoiceCalculationResult calculation;
  final NumberFormat currency;
  final InvoiceTaxType taxType;
  final InvoiceGstMode gstMode;
  final String Function(double) formatRate;

  String _money(int paise) {
    return currency.format(MoneyUtils.paiseToRupees(paise));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.brandNavy,
        borderRadius: BorderRadius.circular(22),
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
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  color: Colors.white,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'Invoice Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          _DarkSummaryRow(
            label: 'Basic Amount',
            value: _money(calculation.basicAmountPaise),
          ),

          if (taxType == InvoiceTaxType.taxable)
            _DarkSummaryRow(
              label: 'Taxable Amount',
              value: _money(calculation.taxableAmountPaise),
            ),

          if (gstMode == InvoiceGstMode.cgstSgst) ...[
            _DarkSummaryRow(
              label: 'CGST @ ${formatRate(calculation.cgstRate)}%',
              value: _money(calculation.cgstAmountPaise),
            ),
            _DarkSummaryRow(
              label: 'SGST @ ${formatRate(calculation.sgstRate)}%',
              value: _money(calculation.sgstAmountPaise),
            ),
          ],

          if (gstMode == InvoiceGstMode.igst)
            _DarkSummaryRow(
              label: 'IGST @ ${formatRate(calculation.igstRate)}%',
              value: _money(calculation.igstAmountPaise),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white.withValues(alpha: 0.14)),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'Grand Total',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _money(calculation.grandTotalPaise),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AMOUNT IN WORDS',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  calculation.amountInWords,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
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

class _DarkSummaryRow extends StatelessWidget {
  const _DarkSummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
