import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../company/providers/company_providers.dart';

final expensesProvider = StreamProvider<List<Expense>>((ref) async* {
  final company = await ref.watch(primaryCompanyProvider.future);

  if (company == null) {
    yield const <Expense>[];
    return;
  }

  final db = ref.watch(appDatabaseProvider);

  yield* db.watchExpensesForCompany(company.id);
});

final totalExpensePaiseProvider = Provider<int>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? const <Expense>[];

  return expenses.fold<int>(
    0,
    (total, expense) => total + expense.totalAmountPaise,
  );
});
