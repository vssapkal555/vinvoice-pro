import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../company/providers/company_providers.dart';

class EditInvoiceData {
  final Company company;
  final Invoice invoice;
  final List<InvoiceItem> items;
  final List<Party> parties;
  final List<VendorCode> vendorCodes;
  final List<Site> sites;
  final List<Unit> units;
  final List<TaxRate> taxRates;

  const EditInvoiceData({
    required this.company,
    required this.invoice,
    required this.items,
    required this.parties,
    required this.vendorCodes,
    required this.sites,
    required this.units,
    required this.taxRates,
  });
}

final editInvoiceProvider = FutureProvider.family<EditInvoiceData, String>((
  ref,
  invoiceId,
) async {
  final db = ref.watch(appDatabaseProvider);

  final company = await ref.watch(primaryCompanyProvider.future);

  if (company == null) {
    throw StateError('Company profile is not configured.');
  }

  final invoice = await db.getInvoiceById(invoiceId);

  if (invoice == null) {
    throw StateError('Invoice not found.');
  }

  final status = invoice.status.toLowerCase();
  if (status != 'draft' && status != 'issued') {
    throw StateError('Only Draft or unpaid Issued invoices can be edited.');
  }

  if (status == 'issued') {
    final payments = await db.getPaymentsForInvoice(invoiceId);
    if (payments.isNotEmpty) {
      throw StateError(
        'This issued invoice already has payment activity and cannot be edited.',
      );
    }
  }

  final results = await Future.wait([
    db.getInvoiceItemsByInvoice(invoiceId),
    db.getActivePartiesForCompany(company.id),
    db.getActiveVendorCodesForCompany(company.id),
    db.getActiveSitesForCompany(company.id),
    db.getActiveUnitsForCompany(company.id),
    db.getActiveTaxRatesForCompany(company.id),
  ]);

  return EditInvoiceData(
    company: company,
    invoice: invoice,
    items: results[0] as List<InvoiceItem>,
    parties: results[1] as List<Party>,
    vendorCodes: results[2] as List<VendorCode>,
    sites: results[3] as List<Site>,
    units: results[4] as List<Unit>,
    taxRates: results[5] as List<TaxRate>,
  );
});
