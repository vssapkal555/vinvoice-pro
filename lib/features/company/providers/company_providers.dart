import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';

final primaryCompanyProvider = FutureProvider<Company?>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.getPrimaryCompany();
});
