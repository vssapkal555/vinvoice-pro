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
import '../providers/edit_invoice_provider.dart';
import '../providers/invoice_list_providers.dart';

const _editUuid = Uuid();

class EditInvoiceScreen extends ConsumerWidget {
  final String invoiceId;

  const EditInvoiceScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(editInvoiceProvider(invoiceId));

    return dataAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Edit Invoice')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(error.toString(), textAlign: TextAlign.center),
          ),
        ),
      ),
      data: (data) => _EditInvoiceForm(data: data),
    );
  }
}

class _EditInvoiceForm extends ConsumerStatefulWidget {
  final EditInvoiceData data;

  const _EditInvoiceForm({required this.data});

  @override
  ConsumerState<_EditInvoiceForm> createState() => _EditInvoiceFormState();
}

class _EditInvoiceFormState extends ConsumerState<_EditInvoiceForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _poController;
  late final TextEditingController _serviceEntryController;

  late DateTime _invoiceDate;
  DateTime? _serviceFrom;
  DateTime? _serviceTo;

  Party? _party;
  VendorCode? _vendorCode;
  Site? _site;

  late InvoiceTaxType _taxType;
  late InvoiceGstMode _gstMode;

  late double _cgstRate;
  late double _sgstRate;
  late double _igstRate;

  late List<_EditItem> _items;

  bool _saving = false;
  bool _dirty = false;

  Invoice get _invoice => widget.data.invoice;

  @override
  void initState() {
    super.initState();

    _invoiceDate = _invoice.invoiceDate;
    _serviceFrom = _invoice.serviceFrom;
    _serviceTo = _invoice.serviceTo;

    _poController = TextEditingController(text: _invoice.poNumber ?? '');

    _serviceEntryController = TextEditingController(
      text: _invoice.serviceEntry ?? '',
    );

    for (final party in widget.data.parties) {
      if (party.id == _invoice.partyId) {
        _party = party;
        break;
      }
    }

    for (final vendor in widget.data.vendorCodes) {
      if (vendor.id == _invoice.vendorCodeId) {
        _vendorCode = vendor;
        break;
      }
    }

    for (final site in widget.data.sites) {
      if (site.id == _invoice.siteId) {
        _site = site;
        break;
      }
    }

    _taxType = _invoice.taxType == 'nonTaxable'
        ? InvoiceTaxType.nonTaxable
        : InvoiceTaxType.taxable;

    _gstMode = switch (_invoice.gstMode) {
      'igst' => InvoiceGstMode.igst,
      'none' => InvoiceGstMode.none,
      _ => InvoiceGstMode.cgstSgst,
    };

    _cgstRate = _invoice.cgstRate > 0 ? _invoice.cgstRate : _taxRate('CGST', 9);

    _sgstRate = _invoice.sgstRate > 0 ? _invoice.sgstRate : _taxRate('SGST', 9);

    _igstRate = _invoice.igstRate > 0
        ? _invoice.igstRate
        : _taxRate('IGST', 18);

    _items = widget.data.items.map((item) {
      Unit? unit;

      for (final candidate in widget.data.units) {
        if (candidate.id == item.unitId) {
          unit = candidate;
          break;
        }
      }

      return _EditItem(
        description: item.description,
        hsnSac: item.hsnSac ?? '',
        quantity: item.quantity,
        ratePaise: item.ratePaise,
        unit: unit,
      );
    }).toList();

    if (_items.isEmpty) {
      _items.add(_EditItem(unit: _defaultUnit()));
    }

    _poController.addListener(_markDirty);
    _serviceEntryController.addListener(_markDirty);
  }

  double _taxRate(String name, double fallback) {
    final matches = widget.data.taxRates.where(
      (tax) => tax.taxName.toUpperCase() == name.toUpperCase(),
    );

    if (matches.isEmpty) {
      return fallback;
    }

    final companySpecific = matches.where(
      (tax) => tax.companyId == widget.data.company.id,
    );

    if (companySpecific.isNotEmpty) {
      return companySpecific.first.percentage;
    }

    return matches.first.percentage;
  }

  Unit? _defaultUnit() {
    for (final unit in widget.data.units) {
      if (unit.unitCode.toUpperCase() == 'EA') {
        return unit;
      }
    }

    return widget.data.units.isEmpty ? null : widget.data.units.first;
  }

  void _markDirty() {
    if (!_dirty && mounted) {
      setState(() {
        _dirty = true;
      });
    }
  }

  @override
  void dispose() {
    _poController.removeListener(_markDirty);
    _serviceEntryController.removeListener(_markDirty);

    _poController.dispose();
    _serviceEntryController.dispose();

    for (final item in _items) {
      item.dispose();
    }

    super.dispose();
  }

  InvoiceGstMode get _effectiveGstMode {
    if (_taxType == InvoiceTaxType.nonTaxable) {
      return InvoiceGstMode.none;
    }

    return _gstMode;
  }

  InvoiceCalculationResult get _calculation {
    return InvoiceCalculator.calculate(
      items: _items.map((item) {
        return InvoiceLineInput(
          description: item.description.text.trim(),
          hsnSac: item.hsnSac.text.trim(),
          quantity: item.quantity,
          unitId: item.unit?.id,
          unitCode: item.unit?.unitCode ?? '',
          ratePaise: item.ratePaise,
        );
      }).toList(),
      taxType: _taxType,
      gstMode: _effectiveGstMode,
      cgstRate: _cgstRate,
      sgstRate: _sgstRate,
      igstRate: _igstRate,
    );
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty || _saving) {
      return true;
    }

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text('You have unsaved invoice changes.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('Keep Editing'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _pickInvoiceDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (result != null) {
      setState(() {
        _invoiceDate = result;
        _dirty = true;
      });
    }
  }

  Future<void> _pickServiceFrom() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _serviceFrom ?? _invoiceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (result != null) {
      setState(() {
        _serviceFrom = result;

        if (_serviceTo != null && _serviceTo!.isBefore(result)) {
          _serviceTo = result;
        }

        _dirty = true;
      });
    }
  }

  Future<void> _pickServiceTo() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _serviceTo ?? _serviceFrom ?? _invoiceDate,
      firstDate: _serviceFrom ?? DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (result != null) {
      setState(() {
        _serviceTo = result;
        _dirty = true;
      });
    }
  }

  void _addItem() {
    setState(() {
      _items.add(_EditItem(unit: _defaultUnit()));
      _dirty = true;
    });
  }

  void _removeItem(int index) {
    if (_items.length <= 1) {
      return;
    }

    final removed = _items.removeAt(index);

    removed.dispose();

    setState(() {
      _dirty = true;
    });
  }

  Future<void> _save() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_party == null) {
      _message('Please select a party.');
      return;
    }

    final validItems = _items.where(
      (item) => item.description.text.trim().isNotEmpty,
    );

    if (validItems.isEmpty) {
      _message('Add at least one invoice item.');
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

      final invoiceUpdate = InvoicesCompanion(
        partyId: Value(party.id),
        invoiceDate: Value(_invoiceDate),
        poNumber: Value(_nullable(_poController.text)),
        vendorCodeId: Value(_vendorCode?.id),
        siteId: Value(_site?.id),
        serviceEntry: Value(_nullable(_serviceEntryController.text)),
        serviceFrom: Value(_serviceFrom),
        serviceTo: Value(_serviceTo),

        companyNameSnapshot: Value(company.companyName),
        companyAddress1Snapshot: Value(company.address1),
        companyAddress2Snapshot: Value(company.address2),
        companyAddress3Snapshot: Value(
          _address3(
            company.address3,
            company.city,
            company.state,
            company.pincode,
          ),
        ),
        companyPanSnapshot: Value(company.pan),
        companyGstinSnapshot: Value(company.gstin),

        partyNameSnapshot: Value(party.partyName),
        partyAddress1Snapshot: Value(party.address1),
        partyAddress2Snapshot: Value(party.address2),
        partyAddress3Snapshot: Value(
          _address3(party.address3, party.city, party.state, party.pincode),
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
        updatedAt: Value(DateTime.now()),
      );

      final itemRows = <InvoiceItemsCompanion>[];

      var serial = 1;

      for (final item in _items) {
        final description = item.description.text.trim();

        if (description.isEmpty) {
          continue;
        }

        itemRows.add(
          InvoiceItemsCompanion.insert(
            id: Value(_editUuid.v4()),
            invoiceId: _invoice.id,
            serialNo: serial++,
            description: description,
            hsnSac: Value(_nullable(item.hsnSac.text)),
            quantity: Value(item.quantity),
            unitId: Value(item.unit?.id),
            unitCodeSnapshot: Value(item.unit?.unitCode),
            ratePaise: Value(item.ratePaise),
            amountPaise: Value(item.amountPaise),
          ),
        );
      }

      await db.updateInvoiceWithItems(
        invoiceId: _invoice.id,
        invoice: invoiceUpdate,
        items: itemRows,
      );

      ref.invalidate(allInvoicesProvider);
      ref.invalidate(invoiceDetailProvider(_invoice.id));
      ref.invalidate(editInvoiceProvider(_invoice.id));

      if (!mounted) return;

      _dirty = false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft updated successfully')),
      );

      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        _message('Unable to update invoice.\n$error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String? _nullable(String? text) {
    final value = text?.trim();

    return value == null || value.isEmpty ? null : value;
  }

  String? _address3(
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

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final result = _calculation;

    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 2,
    );

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final discard = await _confirmDiscard();

        if (discard && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Draft'),
          actions: [
            TextButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
            children: [
              _CardSection(
                title: 'Invoice Details',
                icon: Icons.receipt_long_outlined,
                child: Column(
                  children: [
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Invoice No.',
                        filled: true,
                      ),
                      child: Text(
                        _invoice.invoiceNumber,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _EditDateField(
                      label: 'Invoice Date',
                      date: _invoiceDate,
                      onTap: _pickInvoiceDate,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _poController,
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

              _CardSection(
                title: 'Party',
                icon: Icons.business_outlined,
                child: DropdownButtonFormField<Party>(
                  initialValue: _party,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Party'),
                  items: widget.data.parties.map((party) {
                    return DropdownMenuItem(
                      value: party,
                      child: Text(party.partyName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _party = value;
                      _dirty = true;
                    });
                  },
                ),
              ),

              _CardSection(
                title: 'Vendor & Service',
                icon: Icons.work_outline_rounded,
                child: Column(
                  children: [
                    DropdownButtonFormField<VendorCode>(
                      initialValue: _vendorCode,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Vendor Code',
                      ),
                      items: widget.data.vendorCodes.map((vendor) {
                        return DropdownMenuItem(
                          value: vendor,
                          child: Text(vendor.vendorCode),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _vendorCode = value;
                          _dirty = true;
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
                          _dirty = true;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _EditDateField(
                            label: 'Service From',
                            date: _serviceFrom,
                            onTap: _pickServiceFrom,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _EditDateField(
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

              _CardSection(
                title: 'Service Items',
                icon: Icons.list_alt_rounded,
                child: Column(
                  children: [
                    for (var i = 0; i < _items.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _EditItemCard(
                          item: _items[i],
                          serialNo: i + 1,
                          units: widget.data.units,
                          currency: currency,
                          canDelete: _items.length > 1,
                          onDelete: () {
                            _removeItem(i);
                          },
                          onChanged: () {
                            setState(() {
                              _dirty = true;
                            });
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

              _CardSection(
                title: 'Tax',
                icon: Icons.percent_rounded,
                child: Column(
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
                          _dirty = true;
                        });
                      },
                    ),

                    if (_taxType == InvoiceTaxType.taxable) ...[
                      const SizedBox(height: 16),

                      RadioGroup<InvoiceGstMode>(
                        groupValue: _gstMode,
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _gstMode = value;
                            _dirty = true;
                          });
                        },
                        child: Column(
                          children: [
                            RadioListTile<InvoiceGstMode>(
                              value: InvoiceGstMode.cgstSgst,
                              contentPadding: EdgeInsets.zero,
                              title: const Text('CGST + SGST'),
                              subtitle: Text(
                                'CGST ${_rate(_cgstRate)}% + SGST ${_rate(_sgstRate)}%',
                              ),
                            ),
                            RadioListTile<InvoiceGstMode>(
                              value: InvoiceGstMode.igst,
                              contentPadding: EdgeInsets.zero,
                              title: const Text('IGST'),
                              subtitle: Text('IGST ${_rate(_igstRate)}%'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              _CardSection(
                title: 'Invoice Summary',
                icon: Icons.calculate_outlined,
                child: Column(
                  children: [
                    _EditMoneyRow(
                      label: 'Basic Amount',
                      amount: result.basicAmountPaise,
                      currency: currency,
                    ),
                    if (_taxType == InvoiceTaxType.taxable)
                      _EditMoneyRow(
                        label: 'Taxable Amount',
                        amount: result.taxableAmountPaise,
                        currency: currency,
                      ),
                    if (result.cgstAmountPaise > 0)
                      _EditMoneyRow(
                        label: 'CGST @ ${_rate(result.cgstRate)}%',
                        amount: result.cgstAmountPaise,
                        currency: currency,
                      ),
                    if (result.sgstAmountPaise > 0)
                      _EditMoneyRow(
                        label: 'SGST @ ${_rate(result.sgstRate)}%',
                        amount: result.sgstAmountPaise,
                        currency: currency,
                      ),
                    if (result.igstAmountPaise > 0)
                      _EditMoneyRow(
                        label: 'IGST @ ${_rate(result.igstRate)}%',
                        amount: result.igstAmountPaise,
                        currency: currency,
                      ),
                    const Divider(height: 28),
                    _EditMoneyRow(
                      label: 'Grand Total',
                      amount: result.grandTotalPaise,
                      currency: currency,
                      bold: true,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        result.amountInWords,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? 'Saving...' : 'Update Draft'),
            ),
          ),
        ),
      ),
    );
  }

  String _rate(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}

class _EditItem {
  final TextEditingController description;
  final TextEditingController hsnSac;
  final TextEditingController qty;
  final TextEditingController rate;

  Unit? unit;

  _EditItem({
    String description = '',
    String hsnSac = '',
    double quantity = 1,
    int ratePaise = 0,
    this.unit,
  }) : description = TextEditingController(text: description),
       hsnSac = TextEditingController(text: hsnSac),
       qty = TextEditingController(
         text: quantity == quantity.roundToDouble()
             ? quantity.toInt().toString()
             : quantity.toString(),
       ),
       rate = TextEditingController(
         text: ratePaise == 0 ? '' : MoneyUtils.paiseToRupeesText(ratePaise),
       );

  double get quantity => double.tryParse(qty.text.trim()) ?? 0;

  int get ratePaise => MoneyUtils.parseRupeesToPaise(rate.text);

  int get amountPaise => (quantity * ratePaise).round();

  void dispose() {
    description.dispose();
    hsnSac.dispose();
    qty.dispose();
    rate.dispose();
  }
}

class _EditItemCard extends StatelessWidget {
  final _EditItem item;
  final int serialNo;
  final List<Unit> units;
  final NumberFormat currency;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _EditItemCard({
    required this.item,
    required this.serialNo,
    required this.units,
    required this.currency,
    required this.canDelete,
    required this.onDelete,
    required this.onChanged,
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
        children: [
          Row(
            children: [
              CircleAvatar(radius: 14, child: Text('$serialNo')),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Service Item',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (canDelete)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: item.description,
            decoration: const InputDecoration(
              labelText: 'Description of Service',
            ),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: item.hsnSac,
            decoration: const InputDecoration(labelText: 'HSN / SAC'),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: item.qty,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,3}'),
                    ),
                  ],
                  decoration: const InputDecoration(labelText: 'QTY'),
                  onChanged: (_) => onChanged(),
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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: item.rate,
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
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Amount'),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      currency.format(
                        MoneyUtils.paiseToRupees(item.amountPaise),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
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

class _CardSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _CardSection({
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
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _EditDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _EditDateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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

class _EditMoneyRow extends StatelessWidget {
  final String label;
  final int amount;
  final NumberFormat currency;
  final bool bold;

  const _EditMoneyRow({
    required this.label,
    required this.amount,
    required this.currency,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 18 : 15,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text(label, style: style)),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                currency.format(MoneyUtils.paiseToRupees(amount)),
                style: style,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
