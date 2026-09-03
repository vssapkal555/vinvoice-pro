import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../auth/providers/auth_providers.dart';

class SelectedCompanyIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? companyId) {
    state = companyId;
  }
}

final selectedCompanyIdProvider =
    NotifierProvider<SelectedCompanyIdNotifier, String?>(
      SelectedCompanyIdNotifier.new,
    );

final companiesProvider = FutureProvider<List<Company>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return const <Company>[];
  }

  return db.getCompaniesForOwner(user.id);
});

final primaryCompanyProvider = FutureProvider<Company?>((ref) async {
  final companies = await ref.watch(companiesProvider.future);

  if (companies.isEmpty) {
    return null;
  }

  final selectedId = ref.watch(selectedCompanyIdProvider);

  if (selectedId != null) {
    for (final company in companies) {
      if (company.id == selectedId) {
        return company;
      }
    }
  }

  return companies.first;
});

enum SetupStep { company, party, vendorCode, complete }

final setupStepProvider = FutureProvider<SetupStep>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final company = await ref.watch(primaryCompanyProvider.future);

  if (company == null) {
    return SetupStep.company;
  }

  final parties = await db.getActivePartiesForCompany(company.id);

  if (parties.isEmpty) {
    return SetupStep.party;
  }

  for (final party in parties) {
    final vendor = await db.getVendorCodeForParty(
      companyId: company.id,
      partyId: party.id,
    );

    if (vendor != null) {
      return SetupStep.complete;
    }
  }

  return SetupStep.vendorCode;
});
