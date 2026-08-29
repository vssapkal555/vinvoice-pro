import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../company/providers/company_providers.dart';

final vendorCodesProvider = StreamProvider<List<VendorCode>>((ref) async* {
  final db = ref.watch(appDatabaseProvider);

  final company = await ref.watch(primaryCompanyProvider.future);

  if (company == null) {
    yield const [];
    return;
  }

  yield* db.watchVendorCodesForCompany(company.id);
});
