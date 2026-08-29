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
import '../data/invoice_calculator.dart';
import '../models/invoice_form_models.dart';
import '../providers/invoice_form_data_provider.dart';

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

  @override
  void dispose() {
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
        parties: widget.data.parties,
        selectedParty: _party,
      ),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _party = selected;
    });
  }

  Future<void> _saveDraft() async {
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

        status: const Value('draft'),

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

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline, size: 48),
          title: const Text('Draft Saved'),
          content: Text(
            'Invoice $_invoiceNumber was saved successfully.',
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Invoice'),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _saveDraft,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Draft'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
          children: [
            _SectionCard(
              title: 'Invoice Details',
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  _ReadOnlyField(label: 'Invoice No.', value: _invoiceNumber),
                  const SizedBox(height: 12),
                  _DateField(
                    label: 'Invoice Date',
                    date: _invoiceDate,
                    onTap: _pickInvoiceDate,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _poNumberController,
                    decoration: const InputDecoration(labelText: 'PO No.'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _serviceEntryController,
                    decoration: const InputDecoration(
                      labelText: 'Service Entry',
                    ),
                  ),
                ],
              ),
            ),

            _SectionCard(
              title: 'Party',
              icon: Icons.business_outlined,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _selectParty,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Select Party',
                    suffixIcon: Icon(Icons.search_rounded),
                  ),
                  child: Text(
                    _party?.partyName ?? 'Search party',
                    style: TextStyle(
                      color: _party == null
                          ? Theme.of(context).hintColor
                          : null,
                    ),
                  ),
                ),
              ),
            ),

            _SectionCard(
              title: 'Vendor & Service',
              icon: Icons.work_outline_rounded,
              child: Column(
                children: [
                  DropdownButtonFormField<VendorCode>(
                    initialValue: _vendorCode,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Vendor Code'),
                    items: widget.data.vendorCodes.map((vendor) {
                      return DropdownMenuItem(
                        value: vendor,
                        child: Text(vendor.vendorCode),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _vendorCode = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Site>(
                    initialValue: _site,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Site / Plant',
                    ),
                    items: widget.data.sites.map((site) {
                      return DropdownMenuItem(
                        value: site,
                        child: Text(site.siteName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _site = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: 'Service From',
                          date: _serviceFrom,
                          onTap: _pickServiceFrom,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateField(
                          label: 'Service To',
                          date: _serviceTo,
                          onTap: _pickServiceTo,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _SectionCard(
              title: 'Description of Service',
              icon: Icons.list_alt_rounded,
              child: Column(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _InvoiceItemCard(
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
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add Item'),
                    ),
                  ),
                ],
              ),
            ),

            _SectionCard(
              title: 'Tax',
              icon: Icons.percent_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<InvoiceTaxType>(
                    segments: const [
                      ButtonSegment(
                        value: InvoiceTaxType.taxable,
                        label: Text('Taxable'),
                      ),
                      ButtonSegment(
                        value: InvoiceTaxType.nonTaxable,
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
                    RadioGroup<InvoiceGstMode>(
                      groupValue: _gstMode,
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _gstMode = value;
                        });
                      },
                      child: Column(
                        children: [
                          RadioListTile<InvoiceGstMode>(
                            contentPadding: EdgeInsets.zero,
                            value: InvoiceGstMode.cgstSgst,
                            title: const Text('CGST + SGST'),
                            subtitle: Text(
                              'CGST ${_formatRate(_cgstRate)}% + SGST ${_formatRate(_sgstRate)}%',
                            ),
                          ),
                          RadioListTile<InvoiceGstMode>(
                            contentPadding: EdgeInsets.zero,
                            value: InvoiceGstMode.igst,
                            title: const Text('IGST'),
                            subtitle: Text('IGST ${_formatRate(_igstRate)}%'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            _SectionCard(
              title: 'Invoice Summary',
              icon: Icons.calculate_outlined,
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Basic Amount',
                    value: currency.format(
                      MoneyUtils.paiseToRupees(calculation.basicAmountPaise),
                    ),
                  ),

                  if (_taxType == InvoiceTaxType.taxable)
                    _SummaryRow(
                      label: 'Taxable Amount',
                      value: currency.format(
                        MoneyUtils.paiseToRupees(
                          calculation.taxableAmountPaise,
                        ),
                      ),
                    ),

                  if (_effectiveGstMode == InvoiceGstMode.cgstSgst) ...[
                    _SummaryRow(
                      label: 'CGST @ ${_formatRate(calculation.cgstRate)}%',
                      value: currency.format(
                        MoneyUtils.paiseToRupees(calculation.cgstAmountPaise),
                      ),
                    ),
                    _SummaryRow(
                      label: 'SGST @ ${_formatRate(calculation.sgstRate)}%',
                      value: currency.format(
                        MoneyUtils.paiseToRupees(calculation.sgstAmountPaise),
                      ),
                    ),
                  ],

                  if (_effectiveGstMode == InvoiceGstMode.igst)
                    _SummaryRow(
                      label: 'IGST @ ${_formatRate(calculation.igstRate)}%',
                      value: currency.format(
                        MoneyUtils.paiseToRupees(calculation.igstAmountPaise),
                      ),
                    ),

                  const Divider(height: 28),

                  _SummaryRow(
                    label: 'Grand Total',
                    value: currency.format(
                      MoneyUtils.paiseToRupees(calculation.grandTotalPaise),
                    ),
                    emphasize: true,
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount in Words',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          calculation.amountInWords,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
              ),
            ],
          ),
          child: FilledButton.icon(
            onPressed: _saving ? null : _saveDraft,
            icon: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Saving...' : 'Save Draft'),
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

class _InvoiceItemCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                child: Text(
                  '$serialNo',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Service Item',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (canRemove)
                IconButton(
                  tooltip: 'Remove',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: item.description,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Description of Service',
            ),
            validator: (value) {
              if ((value ?? '').trim().isEmpty && item.ratePaise > 0) {
                return 'Description is required';
              }

              return null;
            },
            onChanged: (_) {
              onChanged();
            },
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: item.hsnSac,
            decoration: const InputDecoration(labelText: 'HSN / SAC'),
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: item.quantityText,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,3}'),
                    ),
                  ],
                  decoration: const InputDecoration(labelText: 'QTY'),
                  validator: (value) {
                    if (item.description.text.trim().isEmpty) {
                      return null;
                    }

                    if (item.quantity <= 0) {
                      return 'Invalid';
                    }

                    return null;
                  },
                  onChanged: (_) {
                    onChanged();
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: DropdownButtonFormField<Unit>(
                  initialValue: item.unit,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items: units.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit.unitCode),
                    );
                  }).toList(),
                  onChanged: (value) {
                    item.unit = value;
                    onChanged();
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: item.rateText,
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
                    onChanged();
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Amount'),
                  child: Text(
                    currency.format(MoneyUtils.paiseToRupees(item.amountPaise)),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
      heightFactor: 0.88,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Select Party',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
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
                hintText: 'Search by party, GSTIN or PAN',
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
                ? const Center(child: Text('No matching party found'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final party = filtered[index];

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            party.partyName.isEmpty
                                ? '?'
                                : party.partyName[0].toUpperCase(),
                          ),
                        ),
                        title: Text(party.partyName),
                        subtitle: Text(
                          [
                            if ((party.gstin ?? '').isNotEmpty)
                              'GSTIN: ${party.gstin}',
                            if ((party.pan ?? '').isNotEmpty)
                              'PAN: ${party.pan}',
                          ].join('\n'),
                        ),
                        trailing: widget.selectedParty?.id == party.id
                            ? const Icon(Icons.check_circle)
                            : null,
                        onTap: () {
                          Navigator.pop(context, party);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label, filled: true),
      child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_month_outlined),
        ),
        child: Text(
          date == null ? 'Select date' : DateFormat('dd-MM-yyyy').format(date!),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: emphasize ? 18 : 15,
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
    );

    final valueStyle = TextStyle(
      fontSize: emphasize ? 18 : 15,
      fontWeight: emphasize ? FontWeight.w900 : FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: Text(
                  value,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: valueStyle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
