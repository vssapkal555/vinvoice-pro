import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../company/providers/company_providers.dart';

final allInvoicesProvider = StreamProvider<List<Invoice>>((ref) async* {
  final db = ref.watch(appDatabaseProvider);

  final company = await ref.watch(primaryCompanyProvider.future);

  if (company == null) {
    yield const [];
    return;
  }

  yield* db.watchInvoicesForCompany(company.id);
});

class InvoiceDetailData {
  final Invoice invoice;
  final List<InvoiceItem> items;

  const InvoiceDetailData({required this.invoice, required this.items});
}

final invoiceDetailProvider = FutureProvider.family<InvoiceDetailData, String>((
  ref,
  invoiceId,
) async {
  final db = ref.watch(appDatabaseProvider);

  final company = await ref.watch(primaryCompanyProvider.future);
  if (company == null) {
    throw StateError('Company profile is not configured.');
  }

  final invoice = await db.getInvoiceByIdForCompany(
    invoiceId: invoiceId,
    companyId: company.id,
  );

  if (invoice == null) {
    throw StateError('Invoice not found for the selected company.');
  }

  final items = await db.getInvoiceItemsByInvoice(invoiceId);

  return InvoiceDetailData(invoice: invoice, items: items);
});
