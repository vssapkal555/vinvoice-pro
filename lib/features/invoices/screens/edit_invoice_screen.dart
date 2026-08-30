import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/theme/app_design_tokens.dart';
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

    final grandTotal = currency.format(
      MoneyUtils.paiseToRupees(result.grandTotalPaise),
    );

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final discard = await _confirmDiscard();

        if (discard && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Edit Draft')),
        body: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;

              final content = ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  wide ? 28 : AppSpacing.md,
                  8,
                  wide ? 28 : AppSpacing.md,
                  130,
                ),
                children: [
                  _EditInvoiceHero(
                    invoiceNumber: _invoice.invoiceNumber,
                    invoiceDate: _invoiceDate,
                    grandTotal: grandTotal,
                    dirty: _dirty,
                    onDateTap: _pickInvoiceDate,
                  ),

                  const SizedBox(height: 18),

                  _EditSection(
                    title: 'Customer',
                    subtitle: 'Who is this invoice for?',
                    icon: Icons.business_outlined,
                    child: DropdownButtonFormField<Party>(
                      initialValue: _party,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Customer',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                      items: widget.data.parties.map((party) {
                        return DropdownMenuItem(
                          value: party,
                          child: Text(
                            party.partyName,
                            overflow: TextOverflow.ellipsis,
                          ),
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

                  _EditSection(
                    title: 'Billing details',
                    subtitle: 'Reference and vendor information',
                    icon: Icons.description_outlined,
                    child: LayoutBuilder(
                      builder: (context, sectionConstraints) {
                        final twoColumns = sectionConstraints.maxWidth >= 560;

                        final fields = <Widget>[
                          TextFormField(
                            controller: _poController,
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
                          DropdownButtonFormField<VendorCode>(
                            initialValue: _vendorCode,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Vendor Code',
                              prefixIcon: Icon(Icons.numbers_rounded),
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
                          DropdownButtonFormField<Site>(
                            initialValue: _site,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Site / Plant',
                              prefixIcon: Icon(Icons.location_on_outlined),
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
                        ];

                        if (!twoColumns) {
                          return Column(
                            children: [
                              for (var i = 0; i < fields.length; i++) ...[
                                fields[i],
                                if (i < fields.length - 1)
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

                  _EditSection(
                    title: 'Service period',
                    subtitle: 'Optional service date range',
                    icon: Icons.date_range_outlined,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _EditModernDateField(
                            label: 'Service From',
                            date: _serviceFrom,
                            onTap: _pickServiceFrom,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _EditModernDateField(
                            label: 'Service To',
                            date: _serviceTo,
                            onTap: _pickServiceTo,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _EditSection(
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
                          _EditItemCard(
                            key: ObjectKey(_items[i]),
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
                          if (i < _items.length - 1) const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),

                  _EditSection(
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
                              _dirty = true;
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
                                child: _EditGstOption(
                                  title: 'CGST + SGST',
                                  subtitle:
                                      '${_rate(_cgstRate)}% + ${_rate(_sgstRate)}%',
                                  selected: _gstMode == InvoiceGstMode.cgstSgst,
                                  onTap: () {
                                    setState(() {
                                      _gstMode = InvoiceGstMode.cgstSgst;
                                      _dirty = true;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _EditGstOption(
                                  title: 'IGST',
                                  subtitle: '${_rate(_igstRate)}%',
                                  selected: _gstMode == InvoiceGstMode.igst,
                                  onTap: () {
                                    setState(() {
                                      _gstMode = InvoiceGstMode.igst;
                                      _dirty = true;
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

                  _EditSummaryCard(
                    result: result,
                    currency: currency,
                    taxType: _taxType,
                    gstMode: _effectiveGstMode,
                    rate: _rate,
                  ),
                ],
              );

              if (!wide) {
                return content;
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: content,
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
                      Text(
                        _dirty ? 'Unsaved changes' : 'Grand Total',
                        style: TextStyle(
                          color: _dirty
                              ? AppTheme.warning
                              : AppTheme.secondaryText,
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
                  child: FilledButton.icon(
                    onPressed: _saving || !_dirty ? null : _save,
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
                          : _dirty
                          ? 'Update Draft'
                          : 'Saved',
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

class _EditItemCard extends StatefulWidget {
  final _EditItem item;
  final int serialNo;
  final List<Unit> units;
  final NumberFormat currency;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _EditItemCard({
    super.key,
    required this.item,
    required this.serialNo,
    required this.units,
    required this.currency,
    required this.canDelete,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<_EditItemCard> createState() => _EditItemCardState();
}

class _EditItemCardState extends State<_EditItemCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();

    // Keep the first service ready to edit.
    // Additional existing services remain compact until tapped.
    _expanded = widget.serialNo == 1;
  }

  bool get _hasContent =>
      widget.item.description.text.trim().isNotEmpty ||
      widget.item.hsnSac.text.trim().isNotEmpty ||
      widget.item.rate.text.trim().isNotEmpty;

  void _changed() {
    widget.onChanged();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final amount = widget.currency.format(
      MoneyUtils.paiseToRupees(widget.item.amountPaise),
    );

    final title = widget.item.description.text.trim().isNotEmpty
        ? widget.item.description.text.trim()
        : 'Empty service item';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _hasContent ? AppTheme.surface : AppTheme.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _hasContent ? AppTheme.borderStrong : AppTheme.border,
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.primarySoft,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        widget.serialNo.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          color: AppTheme.primary,
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
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_hasContent) ...[
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

                    if (widget.canDelete)
                      IconButton(
                        tooltip: 'Remove service',
                        onPressed: widget.onDelete,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: AppTheme.tertiaryText,
                        ),
                      ),

                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.tertiaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            secondChild: const SizedBox.shrink(),
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  TextFormField(
                    controller: widget.item.description,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description of Service',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    onChanged: (_) => _changed(),
                  ),

                  const SizedBox(height: 11),

                  TextFormField(
                    controller: widget.item.hsnSac,
                    decoration: const InputDecoration(
                      labelText: 'HSN / SAC',
                      prefixIcon: Icon(Icons.tag_outlined),
                    ),
                    onChanged: (_) => _changed(),
                  ),

                  const SizedBox(height: 11),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.item.qty,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,3}'),
                            ),
                          ],
                          decoration: const InputDecoration(labelText: 'Qty'),
                          onChanged: (_) => _changed(),
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
                            _changed();
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
                          controller: widget.item.rate,
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
                          onChanged: (_) => _changed(),
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
                            color: AppTheme.primarySoft,
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
// EDIT SCREEN PRESENTATION
// ============================================================================

class _EditInvoiceHero extends StatelessWidget {
  const _EditInvoiceHero({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.grandTotal,
    required this.dirty,
    required this.onDateTap,
  });

  final String invoiceNumber;
  final DateTime invoiceDate;
  final String grandTotal;
  final bool dirty;
  final VoidCallback onDateTap;

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
            color: AppTheme.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'EDITING DRAFT',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              if (dirty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'UNSAVED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
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

class _EditSection extends StatelessWidget {
  const _EditSection({
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

class _EditModernDateField extends StatelessWidget {
  const _EditModernDateField({
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EditGstOption extends StatelessWidget {
  const _EditGstOption({
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

class _EditSummaryCard extends StatelessWidget {
  const _EditSummaryCard({
    required this.result,
    required this.currency,
    required this.taxType,
    required this.gstMode,
    required this.rate,
  });

  final InvoiceCalculationResult result;
  final NumberFormat currency;
  final InvoiceTaxType taxType;
  final InvoiceGstMode gstMode;
  final String Function(double) rate;

  String _money(int value) {
    return currency.format(MoneyUtils.paiseToRupees(value));
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
        children: [
          const Row(
            children: [
              Icon(Icons.calculate_outlined, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
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

          const SizedBox(height: 16),

          _EditDarkMoneyRow(
            label: 'Basic Amount',
            value: _money(result.basicAmountPaise),
          ),

          if (taxType == InvoiceTaxType.taxable)
            _EditDarkMoneyRow(
              label: 'Taxable Amount',
              value: _money(result.taxableAmountPaise),
            ),

          if (gstMode == InvoiceGstMode.cgstSgst) ...[
            _EditDarkMoneyRow(
              label: 'CGST @ ${rate(result.cgstRate)}%',
              value: _money(result.cgstAmountPaise),
            ),
            _EditDarkMoneyRow(
              label: 'SGST @ ${rate(result.sgstRate)}%',
              value: _money(result.sgstAmountPaise),
            ),
          ],

          if (gstMode == InvoiceGstMode.igst)
            _EditDarkMoneyRow(
              label: 'IGST @ ${rate(result.igstRate)}%',
              value: _money(result.igstAmountPaise),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white.withValues(alpha: 0.14)),
          ),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Grand Total',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _money(result.grandTotalPaise),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              result.amountInWords,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditDarkMoneyRow extends StatelessWidget {
  const _EditDarkMoneyRow({required this.label, required this.value});

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
