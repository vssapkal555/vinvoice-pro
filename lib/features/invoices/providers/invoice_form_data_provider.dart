import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../company/providers/company_providers.dart';
import '../data/invoice_number_service.dart';

class InvoiceFormData {
  final Company company;
  final List<Party> parties;
  final List<VendorCode> vendorCodes;
  final List<Site> sites;
  final List<Unit> units;
  final List<TaxRate> taxRates;
  final String invoiceNumber;

  const InvoiceFormData({
    required this.company,
    required this.parties,
    required this.vendorCodes,
    required this.sites,
    required this.units,
    required this.taxRates,
    required this.invoiceNumber,
  });

  double taxRate(String name, double fallback) {
    final matches = taxRates.where(
      (tax) => tax.taxName.toUpperCase() == name.toUpperCase(),
    );

    if (matches.isEmpty) {
      return fallback;
    }

    // Prefer a company-specific override.
    final companySpecific = matches.where((tax) => tax.companyId == company.id);

    if (companySpecific.isNotEmpty) {
      return companySpecific.first.percentage;
    }

    return matches.first.percentage;
  }
}

final invoiceFormDataProvider = FutureProvider.autoDispose<InvoiceFormData>((
  ref,
) async {
  final db = ref.watch(appDatabaseProvider);

  final company = await ref.watch(primaryCompanyProvider.future);

  if (company == null) {
    throw StateError('Please configure My Company before creating an invoice.');
  }

  final results = await Future.wait([
    db.getActivePartiesForCompany(company.id),
    db.getActiveVendorCodesForCompany(company.id),
    db.getActiveSitesForCompany(company.id),
    db.getActiveUnitsForCompany(company.id),
    db.getActiveTaxRatesForCompany(company.id),
  ]);

  final invoiceNumber = await InvoiceNumberService(
    db,
  ).generateNext(companyId: company.id, date: DateTime.now());

  return InvoiceFormData(
    company: company,
    parties: results[0] as List<Party>,
    vendorCodes: results[1] as List<VendorCode>,
    sites: results[2] as List<Site>,
    units: results[3] as List<Unit>,
    taxRates: results[4] as List<TaxRate>,
    invoiceNumber: invoiceNumber,
  );
});
