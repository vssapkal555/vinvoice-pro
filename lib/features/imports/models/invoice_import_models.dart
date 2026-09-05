enum ImportIssueSeverity { warning, error }

class ImportIssue {
  final ImportIssueSeverity severity;
  final String message;
  final int? excelRow;

  const ImportIssue({
    required this.severity,
    required this.message,
    this.excelRow,
  });
}

class ParsedInvoiceImportRow {
  final int excelRow;

  final String partyName;
  final String address1;
  final String address2;
  final String address3;
  final String pan;
  final String gst;

  final String invoiceNumber;
  final DateTime invoiceDate;

  final String poNumber;
  final String vendorCode;
  final String sitePlant;
  final String serviceEntry;

  final DateTime? serviceFrom;
  final DateTime? serviceTo;

  final String description;
  final String hsnSac;

  final double quantity;
  final String unit;

  final int ratePaise;
  final int amountPaise;

  final int taxableAmountPaise;
  final int cgstAmountPaise;
  final int sgstAmountPaise;
  final int igstAmountPaise;
  final int grandTotalPaise;

  const ParsedInvoiceImportRow({
    required this.excelRow,
    required this.partyName,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.pan,
    required this.gst,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.poNumber,
    required this.vendorCode,
    required this.sitePlant,
    required this.serviceEntry,
    required this.serviceFrom,
    required this.serviceTo,
    required this.description,
    required this.hsnSac,
    required this.quantity,
    required this.unit,
    required this.ratePaise,
    required this.amountPaise,
    required this.taxableAmountPaise,
    required this.cgstAmountPaise,
    required this.sgstAmountPaise,
    required this.igstAmountPaise,
    required this.grandTotalPaise,
  });
}

class ImportInvoiceGroup {
  final String invoiceNumber;
  final List<ParsedInvoiceImportRow> rows;

  final bool duplicate;
  final bool missingParty;

  final List<ImportIssue> issues;

  const ImportInvoiceGroup({
    required this.invoiceNumber,
    required this.rows,
    required this.duplicate,
    required this.missingParty,
    required this.issues,
  });

  bool get hasErrors =>
      issues.any((issue) => issue.severity == ImportIssueSeverity.error);

  bool get readyToImport => !hasErrors;

  ParsedInvoiceImportRow get first => rows.first;
}

class InvoiceImportPreview {
  final String fileName;
  final List<ImportInvoiceGroup> invoices;
  final List<ImportIssue> fileIssues;
  final bool companyIdentityVerified;

  const InvoiceImportPreview({
    required this.fileName,
    required this.invoices,
    required this.fileIssues,
    this.companyIdentityVerified = true,
  });

  int get totalInvoices => invoices.length;

  int get readyCount => invoices
      .where((invoice) => invoice.readyToImport && !invoice.duplicate)
      .length;

  int get duplicateCount =>
      invoices.where((invoice) => invoice.duplicate).length;

  int get missingPartyCount =>
      invoices.where((invoice) => invoice.missingParty).length;

  int get invalidCount => invoices.where((invoice) => invoice.hasErrors).length;

  int get totalRows =>
      invoices.fold<int>(0, (total, invoice) => total + invoice.rows.length);

  bool get hasFileErrors =>
      fileIssues.any((issue) => issue.severity == ImportIssueSeverity.error);
}

class InvoiceImportResult {
  final int imported;
  final int overwritten;
  final int skipped;
  final int failed;

  final List<String> errors;

  const InvoiceImportResult({
    required this.imported,
    required this.overwritten,
    required this.skipped,
    required this.failed,
    required this.errors,
  });
}
