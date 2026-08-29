import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/amount_in_words.dart';
import '../models/invoice_import_models.dart';

const _importUuid = Uuid();

class InvoiceImportService {
  final AppDatabase database;

  const InvoiceImportService(this.database);

  Future<InvoiceImportResult> importPreview({
    required InvoiceImportPreview preview,
    required Company company,
    bool overwriteDuplicates = false,
  }) async {
    var imported = 0;
    var overwritten = 0;
    var skipped = 0;
    var failed = 0;

    final errors = <String>[];

    for (final group in preview.invoices) {
      if (group.hasErrors) {
        failed++;
        errors.add('${group.invoiceNumber}: validation failed.');
        continue;
      }

      final first = group.first;

      try {
        final existing = await database.getInvoiceByCompanyAndNumber(
          companyId: company.id,
          invoiceNumber: group.invoiceNumber,
        );

        if (existing != null && !overwriteDuplicates) {
          skipped++;
          continue;
        }

        var party = await database.findPartyForImport(
          companyId: company.id,
          gstin: first.gst,
          pan: first.pan,
          partyName: first.partyName,
        );

        party ??= await database.createPartyFromImport(
          companyId: company.id,
          partyName: first.partyName,
          address1: first.address1,
          address2: first.address2,
          address3: first.address3,
          pan: first.pan,
          gstin: first.gst,
        );

        final invoiceId = existing?.id ?? _importUuid.v4();

        final items = <InvoiceItemsCompanion>[];

        var serial = 1;

        for (final row in group.rows) {
          final unit = await database.findUnitForImport(
            companyId: company.id,
            unitCode: row.unit,
          );

          items.add(
            InvoiceItemsCompanion.insert(
              id: Value(_importUuid.v4()),
              invoiceId: invoiceId,
              serialNo: serial++,
              description: row.description,
              hsnSac: Value(_nullable(row.hsnSac)),
              quantity: Value(row.quantity),
              unitId: Value(unit?.id),
              unitCodeSnapshot: Value(_nullable(row.unit)),
              ratePaise: Value(row.ratePaise),
              amountPaise: Value(row.amountPaise),
            ),
          );
        }

        final basicAmount = group.rows.fold<int>(
          0,
          (total, row) => total + row.amountPaise,
        );

        final taxableAmount = _firstNonZero(
          group.rows.map((row) => row.taxableAmountPaise),
        );

        final cgst = _firstNonZero(
          group.rows.map((row) => row.cgstAmountPaise),
        );

        final sgst = _firstNonZero(
          group.rows.map((row) => row.sgstAmountPaise),
        );

        final igst = _firstNonZero(
          group.rows.map((row) => row.igstAmountPaise),
        );

        final importedGrandTotal = _firstNonZero(
          group.rows.map((row) => row.grandTotalPaise),
        );

        final calculatedGrandTotal = basicAmount + cgst + sgst + igst;

        final grandTotal = importedGrandTotal > 0
            ? importedGrandTotal
            : calculatedGrandTotal;

        final hasTax = cgst > 0 || sgst > 0 || igst > 0;

        final gstMode = igst > 0
            ? 'igst'
            : hasTax
            ? 'cgstSgst'
            : 'none';

        final invoiceCompanion = InvoicesCompanion(
          companyId: Value(company.id),
          partyId: Value(party.id),
          invoiceNumber: Value(first.invoiceNumber),
          invoiceDate: Value(first.invoiceDate),
          poNumber: Value(_nullable(first.poNumber)),
          vendorCodeId: const Value(null),
          siteId: const Value(null),
          serviceEntry: const Value(null),
          serviceFrom: Value(first.serviceFrom),
          serviceTo: Value(first.serviceTo),

          companyNameSnapshot: Value(company.companyName),
          companyAddress1Snapshot: Value(company.address1),
          companyAddress2Snapshot: Value(company.address2),
          companyAddress3Snapshot: Value(
            _snapshotAddress3(
              company.address3,
              company.city,
              company.state,
              company.pincode,
            ),
          ),
          companyPanSnapshot: Value(company.pan),
          companyGstinSnapshot: Value(company.gstin),

          partyNameSnapshot: Value(first.partyName),
          partyAddress1Snapshot: Value(_nullable(first.address1)),
          partyAddress2Snapshot: Value(_nullable(first.address2)),
          partyAddress3Snapshot: Value(_nullable(first.address3)),
          partyPanSnapshot: Value(_nullable(first.pan)),
          partyGstinSnapshot: Value(_nullable(first.gst)),

          vendorCodeSnapshot: Value(_nullable(first.vendorCode)),
          siteNameSnapshot: Value(_nullable(first.sitePlant)),

          taxType: Value(hasTax ? 'taxable' : 'nonTaxable'),
          gstMode: Value(gstMode),

          basicAmountPaise: Value(basicAmount),
          taxableAmountPaise: Value(
            hasTax ? (taxableAmount > 0 ? taxableAmount : basicAmount) : 0,
          ),

          cgstRate: Value(cgst > 0 ? 9 : 0),
          cgstAmountPaise: Value(cgst),

          sgstRate: Value(sgst > 0 ? 9 : 0),
          sgstAmountPaise: Value(sgst),

          igstRate: Value(igst > 0 ? 18 : 0),
          igstAmountPaise: Value(igst),

          grandTotalPaise: Value(grandTotal),

          amountInWords: Value(AmountInWords.fromPaise(grandTotal)),

          status: const Value('issued'),
          syncStatus: const Value('local'),
          updatedAt: Value(DateTime.now()),
        );

        if (existing == null) {
          await database.saveInvoiceWithItems(
            invoice: InvoicesCompanion.insert(
              id: Value(invoiceId),
              companyId: company.id,
              partyId: Value(party.id),
              invoiceNumber: first.invoiceNumber,
              invoiceDate: first.invoiceDate,
              poNumber: invoiceCompanion.poNumber,
              vendorCodeId: const Value(null),
              siteId: const Value(null),
              serviceEntry: const Value(null),
              serviceFrom: Value(first.serviceFrom),
              serviceTo: Value(first.serviceTo),
              companyNameSnapshot: company.companyName,
              companyAddress1Snapshot: Value(company.address1),
              companyAddress2Snapshot: Value(company.address2),
              companyAddress3Snapshot: Value(
                _snapshotAddress3(
                  company.address3,
                  company.city,
                  company.state,
                  company.pincode,
                ),
              ),
              companyPanSnapshot: Value(company.pan),
              companyGstinSnapshot: Value(company.gstin),
              partyNameSnapshot: first.partyName,
              partyAddress1Snapshot: Value(_nullable(first.address1)),
              partyAddress2Snapshot: Value(_nullable(first.address2)),
              partyAddress3Snapshot: Value(_nullable(first.address3)),
              partyPanSnapshot: Value(_nullable(first.pan)),
              partyGstinSnapshot: Value(_nullable(first.gst)),
              vendorCodeSnapshot: Value(_nullable(first.vendorCode)),
              siteNameSnapshot: Value(_nullable(first.sitePlant)),
              taxType: invoiceCompanion.taxType,
              gstMode: invoiceCompanion.gstMode,
              basicAmountPaise: Value(basicAmount),
              taxableAmountPaise: invoiceCompanion.taxableAmountPaise,
              cgstRate: invoiceCompanion.cgstRate,
              cgstAmountPaise: Value(cgst),
              sgstRate: invoiceCompanion.sgstRate,
              sgstAmountPaise: Value(sgst),
              igstRate: invoiceCompanion.igstRate,
              igstAmountPaise: Value(igst),
              grandTotalPaise: Value(grandTotal),
              amountInWords: invoiceCompanion.amountInWords,
              status: const Value('issued'),
              syncStatus: const Value('local'),
            ),
            items: items,
          );

          imported++;
        } else {
          await database.overwriteImportedInvoice(
            existingInvoiceId: existing.id,
            invoice: invoiceCompanion,
            items: items,
          );

          overwritten++;
        }
      } catch (error) {
        failed++;

        errors.add('${group.invoiceNumber}: $error');
      }
    }

    final status = failed == 0
        ? 'completed'
        : (imported > 0 || overwritten > 0)
        ? 'partial'
        : 'failed';

    await database.insertImportBatch(
      ImportBatchesCompanion.insert(
        companyId: company.id,
        fileName: preview.fileName,
        totalRows: Value(preview.totalRows),
        importedCount: Value(imported + overwritten),
        skippedCount: Value(skipped),
        failedCount: Value(failed),
        status: Value(status),
        errorSummary: Value(errors.isEmpty ? null : errors.join('\n')),
      ),
    );

    return InvoiceImportResult(
      imported: imported,
      overwritten: overwritten,
      skipped: skipped,
      failed: failed,
      errors: errors,
    );
  }

  static String? _snapshotAddress3(
    String? address3,
    String? city,
    String? state,
    String? pincode,
  ) {
    final output = <String>[];
    final seen = <String>{};

    void addValue(String? value) {
      if (value == null) {
        return;
      }

      for (final piece in value.split(',')) {
        final text = piece.trim();

        if (text.isEmpty) {
          continue;
        }

        if (seen.add(text.toLowerCase())) {
          output.add(text);
        }
      }
    }

    addValue(address3);
    addValue(city);
    addValue(state);
    addValue(pincode);

    return output.isEmpty ? null : output.join(', ');
  }

  static String? _nullable(String? value) {
    final text = value?.trim();

    return text == null || text.isEmpty ? null : text;
  }

  static int _firstNonZero(Iterable<int> values) {
    for (final value in values) {
      if (value != 0) {
        return value;
      }
    }

    return 0;
  }
}
