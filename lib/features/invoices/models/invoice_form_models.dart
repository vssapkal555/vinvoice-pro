enum InvoiceTaxType { taxable, nonTaxable }

enum InvoiceGstMode { cgstSgst, igst, none }

class InvoiceLineInput {
  final String description;
  final String hsnSac;
  final double quantity;

  final String? unitId;
  final String unitCode;

  final int ratePaise;

  const InvoiceLineInput({
    this.description = '',
    this.hsnSac = '',
    this.quantity = 1,
    this.unitId,
    this.unitCode = 'EA',
    this.ratePaise = 0,
  });

  int get amountPaise {
    if (quantity <= 0 || ratePaise <= 0) {
      return 0;
    }

    return (quantity * ratePaise).round();
  }

  InvoiceLineInput copyWith({
    String? description,
    String? hsnSac,
    double? quantity,
    String? unitId,
    String? unitCode,
    int? ratePaise,
  }) {
    return InvoiceLineInput(
      description: description ?? this.description,
      hsnSac: hsnSac ?? this.hsnSac,
      quantity: quantity ?? this.quantity,
      unitId: unitId ?? this.unitId,
      unitCode: unitCode ?? this.unitCode,
      ratePaise: ratePaise ?? this.ratePaise,
    );
  }
}

class InvoiceDraftModel {
  final String invoiceNumber;
  final DateTime invoiceDate;

  final String? partyId;
  final String? vendorCodeId;
  final String? siteId;

  final String poNumber;
  final String serviceEntry;

  final DateTime? serviceFrom;
  final DateTime? serviceTo;

  final InvoiceTaxType taxType;
  final InvoiceGstMode gstMode;

  final double cgstRate;
  final double sgstRate;
  final double igstRate;

  final List<InvoiceLineInput> items;

  InvoiceDraftModel({
    this.invoiceNumber = '',
    DateTime? invoiceDate,
    this.partyId,
    this.vendorCodeId,
    this.siteId,
    this.poNumber = '',
    this.serviceEntry = '',
    this.serviceFrom,
    this.serviceTo,
    this.taxType = InvoiceTaxType.taxable,
    this.gstMode = InvoiceGstMode.cgstSgst,
    this.cgstRate = 9,
    this.sgstRate = 9,
    this.igstRate = 18,
    List<InvoiceLineInput>? items,
  }) : invoiceDate = invoiceDate ?? DateTime.now(),
       items = items ?? List.generate(5, (_) => const InvoiceLineInput());
}
