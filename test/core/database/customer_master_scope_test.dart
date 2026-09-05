import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinvoice_pro/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('same user can reuse one customer across multiple companies', () async {
    await db.insertCompanyRecord(
      CompaniesCompanion.insert(
        id: const Value('company-a'),
        ownerUserId: const Value('user-1'),
        companyName: 'Company A',
      ),
    );
    await db.insertCompanyRecord(
      CompaniesCompanion.insert(
        id: const Value('company-b'),
        ownerUserId: const Value('user-1'),
        companyName: 'Company B',
      ),
    );

    final partyA = await db.createCustomerMasterAndLink(
      companyId: 'company-a',
      ownerUserId: 'user-1',
      partyName: 'Shared Customer',
      gstin: '27ABCDE1234F1Z5',
    );

    final available = await db.getAvailableCustomerMastersForCompany(
      ownerUserId: 'user-1',
      companyId: 'company-b',
    );
    expect(available, hasLength(1));

    final partyB = await db.linkCustomerMasterToCompany(
      companyId: 'company-b',
      customerMasterId: available.single.id,
    );

    expect(partyA.companyId, 'company-a');
    expect(partyB.companyId, 'company-b');
    expect(partyA.customerMasterId, partyB.customerMasterId);
    expect(partyA.id, isNot(partyB.id));
  });

  test('customer cannot be linked into another user company', () async {
    await db.insertCompanyRecord(
      CompaniesCompanion.insert(
        id: const Value('company-a'),
        ownerUserId: const Value('user-1'),
        companyName: 'Company A',
      ),
    );
    await db.insertCompanyRecord(
      CompaniesCompanion.insert(
        id: const Value('company-x'),
        ownerUserId: const Value('user-2'),
        companyName: 'Company X',
      ),
    );

    final party = await db.createCustomerMasterAndLink(
      companyId: 'company-a',
      ownerUserId: 'user-1',
      partyName: 'Private Customer',
    );

    expect(
      () => db.linkCustomerMasterToCompany(
        companyId: 'company-x',
        customerMasterId: party.customerMasterId!,
      ),
      throwsStateError,
    );
  });
}
