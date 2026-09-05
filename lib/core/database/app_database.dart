import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

const _uuid = Uuid();

class Companies extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  TextColumn get ownerUserId => text().nullable()();

  TextColumn get companyName => text()();

  TextColumn get address1 => text().nullable()();
  TextColumn get address2 => text().nullable()();
  TextColumn get address3 => text().nullable()();

  TextColumn get city => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get pincode => text().nullable()();

  TextColumn get pan => text().nullable()();
  TextColumn get gstin => text().nullable()();

  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();

  TextColumn get logoPath => text().nullable()();

  /// Durable company logo bytes. Do not rely on Android source file paths.
  BlobColumn get logoImage => blob().nullable()();

  // Invoice numbering: standard / custom.
  TextColumn get invoiceNumberMode =>
      text().withDefault(const Constant('standard'))();
  TextColumn get customInvoicePrefix => text().nullable()();
  TextColumn get customInvoiceSeries => text().nullable()();

  // Optional digital signature used on invoice PDFs.
  BoolColumn get applySignature =>
      boolean().withDefault(const Constant(false))();

  BoolColumn get applySignatureToHistorical =>
      boolean().withDefault(const Constant(false))();

  BlobColumn get signatureImage => blob().nullable()();
  TextColumn get signatoryName => text().nullable()();
  TextColumn get signatoryDesignation => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class CustomerMasters extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  TextColumn get ownerUserId => text()();

  TextColumn get partyName => text()();

  TextColumn get address1 => text().nullable()();
  TextColumn get address2 => text().nullable()();
  TextColumn get address3 => text().nullable()();

  TextColumn get city => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get pincode => text().nullable()();

  TextColumn get pan => text().nullable()();
  TextColumn get gstin => text().nullable()();

  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Parties extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();

  TextColumn get customerMasterId => text().nullable().references(
    CustomerMasters,
    #id,
    onDelete: KeyAction.setNull,
  )();

  TextColumn get partyName => text()();

  TextColumn get address1 => text().nullable()();
  TextColumn get address2 => text().nullable()();
  TextColumn get address3 => text().nullable()();

  TextColumn get city => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get pincode => text().nullable()();

  TextColumn get pan => text().nullable()();
  TextColumn get gstin => text().nullable()();

  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class VendorCodes extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();

  TextColumn get partyId =>
      text().nullable().references(Parties, #id, onDelete: KeyAction.cascade)();

  TextColumn get vendorCode => text()();

  TextColumn get description => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, partyId},
  ];
}

class Sites extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();

  TextColumn get partyId =>
      text().nullable().references(Parties, #id, onDelete: KeyAction.cascade)();

  TextColumn get siteName => text()();

  TextColumn get siteCode => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Units extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  // Null companyId means this is a built-in/default unit.
  TextColumn get companyId => text().nullable()();

  TextColumn get unitCode => text()();

  TextColumn get unitName => text()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class TaxRates extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  // Null companyId means this is a built-in/default tax rate.
  TextColumn get companyId => text().nullable()();

  TextColumn get taxName => text()();

  RealColumn get percentage => real()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Invoices extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.restrict)();

  TextColumn get partyId =>
      text().nullable().references(Parties, #id, onDelete: KeyAction.setNull)();

  TextColumn get invoiceNumber => text()();

  DateTimeColumn get invoiceDate => dateTime()();

  TextColumn get poNumber => text().nullable()();

  TextColumn get vendorCodeId => text().nullable().references(
    VendorCodes,
    #id,
    onDelete: KeyAction.setNull,
  )();

  TextColumn get siteId =>
      text().nullable().references(Sites, #id, onDelete: KeyAction.setNull)();

  TextColumn get serviceEntry => text().nullable()();

  DateTimeColumn get serviceFrom => dateTime().nullable()();

  DateTimeColumn get serviceTo => dateTime().nullable()();

  // Historical company snapshot.
  TextColumn get companyNameSnapshot => text()();
  TextColumn get companyAddress1Snapshot => text().nullable()();
  TextColumn get companyAddress2Snapshot => text().nullable()();
  TextColumn get companyAddress3Snapshot => text().nullable()();
  TextColumn get companyPanSnapshot => text().nullable()();
  TextColumn get companyGstinSnapshot => text().nullable()();
  BlobColumn get companyLogoSnapshot => blob().nullable()();

  // Historical signature snapshot.
  BoolColumn get signatureAppliedSnapshot =>
      boolean().withDefault(const Constant(false))();
  BlobColumn get signatureImageSnapshot => blob().nullable()();
  TextColumn get signatoryNameSnapshot => text().nullable()();
  TextColumn get signatoryDesignationSnapshot => text().nullable()();

  BoolColumn get signatureEligible =>
      boolean().withDefault(const Constant(false))();

  // Historical party snapshot.
  TextColumn get partyNameSnapshot => text()();
  TextColumn get partyAddress1Snapshot => text().nullable()();
  TextColumn get partyAddress2Snapshot => text().nullable()();
  TextColumn get partyAddress3Snapshot => text().nullable()();
  TextColumn get partyPanSnapshot => text().nullable()();
  TextColumn get partyGstinSnapshot => text().nullable()();

  // Historical selected master values.
  TextColumn get vendorCodeSnapshot => text().nullable()();
  TextColumn get siteNameSnapshot => text().nullable()();

  // taxable / nonTaxable
  TextColumn get taxType => text().withDefault(const Constant('taxable'))();

  // cgstSgst / igst / none
  TextColumn get gstMode => text().withDefault(const Constant('cgstSgst'))();

  // Currency values are stored in paise.
  IntColumn get basicAmountPaise => integer().withDefault(const Constant(0))();

  IntColumn get taxableAmountPaise =>
      integer().withDefault(const Constant(0))();

  RealColumn get cgstRate => real().withDefault(const Constant(0))();

  IntColumn get cgstAmountPaise => integer().withDefault(const Constant(0))();

  RealColumn get sgstRate => real().withDefault(const Constant(0))();

  IntColumn get sgstAmountPaise => integer().withDefault(const Constant(0))();

  RealColumn get igstRate => real().withDefault(const Constant(0))();

  IntColumn get igstAmountPaise => integer().withDefault(const Constant(0))();

  IntColumn get grandTotalPaise => integer().withDefault(const Constant(0))();

  TextColumn get amountInWords => text().nullable()();

  // draft / issued / cancelled
  TextColumn get status => text().withDefault(const Constant('draft'))();

  // local / pending / synced / failed
  TextColumn get syncStatus => text().withDefault(const Constant('local'))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, invoiceNumber},
  ];
}

class InvoiceItems extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  TextColumn get invoiceId =>
      text().references(Invoices, #id, onDelete: KeyAction.cascade)();

  IntColumn get serialNo => integer()();

  TextColumn get description => text()();

  TextColumn get hsnSac => text().nullable()();

  RealColumn get quantity => real().withDefault(const Constant(1))();

  TextColumn get unitId =>
      text().nullable().references(Units, #id, onDelete: KeyAction.setNull)();

  // Historical unit snapshot.
  TextColumn get unitCodeSnapshot => text().nullable()();

  IntColumn get ratePaise => integer().withDefault(const Constant(0))();

  IntColumn get amountPaise => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Payments extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  TextColumn get invoiceId =>
      text().references(Invoices, #id, onDelete: KeyAction.cascade)();

  IntColumn get amountPaise => integer()();

  DateTimeColumn get paymentDate => dateTime()();

  // cash / bankTransfer / upi / cheque / card / other
  TextColumn get paymentMode => text()();

  TextColumn get referenceNumber => text().nullable()();

  TextColumn get receivedBy => text().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Notes extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text()();

  TextColumn get content => text().nullable()();

  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Expenses extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get expenseDate => dateTime()();

  TextColumn get category => text()();

  TextColumn get vendorPayee => text().nullable()();

  TextColumn get description => text()();

  IntColumn get baseAmountPaise => integer().withDefault(const Constant(0))();

  IntColumn get gstAmountPaise => integer().withDefault(const Constant(0))();

  IntColumn get totalAmountPaise => integer().withDefault(const Constant(0))();

  // cash / bankTransfer / upi / cheque / card / other
  TextColumn get paymentMode => text().nullable()();

  TextColumn get referenceNumber => text().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ImportBatches extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();

  TextColumn get fileName => text()();

  TextColumn get sourceHash => text().nullable()();

  IntColumn get totalRows => integer().withDefault(const Constant(0))();

  IntColumn get importedCount => integer().withDefault(const Constant(0))();

  IntColumn get skippedCount => integer().withDefault(const Constant(0))();

  IntColumn get failedCount => integer().withDefault(const Constant(0))();

  // pending / completed / partial / failed
  TextColumn get status => text().withDefault(const Constant('pending'))();

  TextColumn get errorSummary => text().nullable()();

  DateTimeColumn get importedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Companies,
    CustomerMasters,
    Parties,
    VendorCodes,
    Sites,
    Units,
    TaxRates,
    Invoices,
    InvoiceItems,
    Payments,
    Notes,
    Expenses,
    ImportBatches,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 9) {
        await m.createTable(customerMasters);
        await m.addColumn(parties, parties.customerMasterId);

        final existingParties = await select(parties).get();

        for (final party in existingParties) {
          final company =
              await (select(companies)
                    ..where((row) => row.id.equals(party.companyId))
                    ..limit(1))
                  .getSingleOrNull();

          final ownerUserId = company?.ownerUserId?.trim();

          if (ownerUserId == null || ownerUserId.isEmpty) {
            continue;
          }

          var master = await findCustomerMasterForOwner(
            ownerUserId: ownerUserId,
            gstin: party.gstin,
            pan: party.pan,
            partyName: party.partyName,
          );

          master ??= await _insertCustomerMaster(
            ownerUserId: ownerUserId,
            partyName: party.partyName,
            address1: party.address1,
            address2: party.address2,
            address3: party.address3,
            city: party.city,
            state: party.state,
            pincode: party.pincode,
            pan: party.pan,
            gstin: party.gstin,
            phone: party.phone,
            email: party.email,
          );

          await (update(parties)..where((row) => row.id.equals(party.id)))
              .write(PartiesCompanion(customerMasterId: Value(master.id)));
        }

        await customStatement('''
          CREATE UNIQUE INDEX IF NOT EXISTS
          parties_company_customer_master_unique
          ON parties(company_id, customer_master_id)
          WHERE customer_master_id IS NOT NULL
        ''');
      }

      if (from < 8) {
        await m.addColumn(companies, companies.logoImage);
        await m.addColumn(invoices, invoices.companyLogoSnapshot);
      }

      if (from < 7) {
        await m.addColumn(companies, companies.applySignatureToHistorical);
        await m.addColumn(invoices, invoices.signatureEligible);

        await customStatement('''
          UPDATE invoices
          SET signature_eligible = 1
          WHERE signature_applied_snapshot = 1
             OR signature_image_snapshot IS NOT NULL
             OR signatory_name_snapshot IS NOT NULL
             OR signatory_designation_snapshot IS NOT NULL
        ''');
      }

      if (from < 6) {
        await m.addColumn(companies, companies.invoiceNumberMode);
        await m.addColumn(companies, companies.customInvoicePrefix);
        await m.addColumn(companies, companies.customInvoiceSeries);
        await m.addColumn(companies, companies.applySignature);
        await m.addColumn(companies, companies.signatureImage);
        await m.addColumn(companies, companies.signatoryName);
        await m.addColumn(companies, companies.signatoryDesignation);

        await m.addColumn(invoices, invoices.signatureAppliedSnapshot);
        await m.addColumn(invoices, invoices.signatureImageSnapshot);
        await m.addColumn(invoices, invoices.signatoryNameSnapshot);
        await m.addColumn(invoices, invoices.signatoryDesignationSnapshot);
      }

      if (from < 5) {
        await m.addColumn(sites, sites.partyId);
      }

      if (from < 2) {
        await m.createTable(payments);
      }

      if (from < 3) {
        await m.createTable(expenses);
      }

      if (from < 4) {
        await m.addColumn(vendorCodes, vendorCodes.partyId);

        // Preserve legacy vendor codes. When a company has exactly one party,
        // the old vendor code can be mapped safely. Ambiguous legacy mappings
        // remain null and can be assigned from Vendor Codes settings.
        await customStatement('''
          UPDATE vendor_codes
          SET party_id = (
            SELECT p.id
            FROM parties p
            WHERE p.company_id = vendor_codes.company_id
            LIMIT 1
          )
          WHERE party_id IS NULL
            AND 1 = (
              SELECT COUNT(*)
              FROM parties p2
              WHERE p2.company_id = vendor_codes.company_id
            )
        ''');

        await customStatement('''
          CREATE UNIQUE INDEX IF NOT EXISTS
          vendor_codes_company_party_unique
          ON vendor_codes(company_id, party_id)
          WHERE party_id IS NOT NULL
        ''');
      }
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');

      await customStatement('''
        CREATE UNIQUE INDEX IF NOT EXISTS
        parties_company_customer_master_unique
        ON parties(company_id, customer_master_id)
        WHERE customer_master_id IS NOT NULL
      ''');

      await _seedDefaultUnits();
      await _seedDefaultTaxRates();
    },
  );

  Future<void> initialize() async {
    await customSelect('SELECT 1').get();
  }

  // ---------------------------------------------------------------------------
  // DEFAULT MASTER DATA
  // ---------------------------------------------------------------------------

  Future<void> _seedDefaultUnits() async {
    final existing = await (select(
      units,
    )..where((row) => row.companyId.isNull())).get();

    if (existing.isNotEmpty) {
      return;
    }

    await batch((batch) {
      batch.insertAll(units, [
        UnitsCompanion.insert(unitCode: 'EA', unitName: 'Each'),
        UnitsCompanion.insert(unitCode: 'Days', unitName: 'Days'),
        UnitsCompanion.insert(unitCode: 'Months', unitName: 'Months'),
        UnitsCompanion.insert(unitCode: 'KM', unitName: 'Kilometres'),
      ]);
    });
  }

  Future<void> _seedDefaultTaxRates() async {
    final existing = await (select(
      taxRates,
    )..where((row) => row.companyId.isNull())).get();

    if (existing.isNotEmpty) {
      return;
    }

    await batch((batch) {
      batch.insertAll(taxRates, [
        TaxRatesCompanion.insert(taxName: 'CGST', percentage: 9),
        TaxRatesCompanion.insert(taxName: 'SGST', percentage: 9),
        TaxRatesCompanion.insert(taxName: 'IGST', percentage: 18),
      ]);
    });
  }

  // ---------------------------------------------------------------------------
  // DEMO DATA
  // ---------------------------------------------------------------------------

  Future<Company> _createDemoCompanyForOwner(String ownerUserId) async {
    final companyId = _uuid.v4();

    await into(companies).insert(
      CompaniesCompanion.insert(
        id: Value(companyId),
        ownerUserId: Value(ownerUserId),
        companyName: 'VInvoice Demo Enterprises',
        address1: const Value('Office No. 101, Business Plaza'),
        address2: const Value('Main Road'),
        address3: const Value('Pune, Maharashtra'),
        city: const Value('Pune'),
        state: const Value('Maharashtra'),
        pincode: const Value('411001'),
      ),
    );

    await _seedDemoParty(companyId);
    await _seedDemoVendorCode(companyId);
    await _seedDemoSite(companyId);

    return (select(companies)
          ..where((row) => row.id.equals(companyId))
          ..limit(1))
        .getSingle();
  }

  Future<void> _seedDemoParty(String companyId) async {
    const demoPartyName = 'Demo Customer Pvt. Ltd.';

    final existing =
        await (select(parties)
              ..where(
                (row) =>
                    row.companyId.equals(companyId) &
                    row.partyName.equals(demoPartyName),
              )
              ..limit(1))
            .get();

    if (existing.isNotEmpty) {
      return;
    }

    await into(parties).insert(
      PartiesCompanion.insert(
        companyId: companyId,
        partyName: demoPartyName,
        address1: const Value('Plot No. 25, Industrial Area'),
        address2: const Value('MIDC Road'),
        address3: const Value('Pune, Maharashtra'),
        city: const Value('Pune'),
        state: const Value('Maharashtra'),
        pincode: const Value('411019'),
        pan: const Value('AAACD1234K'),
        gstin: const Value('27AAACD1234K1Z7'),
        phone: const Value('9123456780'),
        email: const Value('accounts@democustomer.in'),
      ),
    );
  }

  Future<void> _seedDemoVendorCode(String companyId) async {
    const demoVendorCode = 'VEN001';

    final existing =
        await (select(vendorCodes)
              ..where(
                (row) =>
                    row.companyId.equals(companyId) &
                    row.vendorCode.equals(demoVendorCode),
              )
              ..limit(1))
            .get();

    if (existing.isNotEmpty) {
      return;
    }

    await into(vendorCodes).insert(
      VendorCodesCompanion.insert(
        companyId: companyId,
        vendorCode: demoVendorCode,
        description: const Value('Default Demo Vendor Code'),
      ),
    );
  }

  Future<void> _seedDemoSite(String companyId) async {
    const demoSiteName = 'Pune Plant';

    final existing =
        await (select(sites)
              ..where(
                (row) =>
                    row.companyId.equals(companyId) &
                    row.siteName.equals(demoSiteName),
              )
              ..limit(1))
            .get();

    if (existing.isNotEmpty) {
      return;
    }

    await into(sites).insert(
      SitesCompanion.insert(
        companyId: companyId,
        siteName: demoSiteName,
        siteCode: const Value('PUNE-01'),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // COMPANY / PARTY / VENDOR CODE QUERIES
  // ---------------------------------------------------------------------------

  Future<List<Company>> getAllCompanies() {
    return select(companies).get();
  }

  Future<List<Company>> getCompaniesForOwner(String ownerUserId) {
    return (select(companies)
          ..where(
            (row) =>
                row.ownerUserId.equals(ownerUserId) & row.isActive.equals(true),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
        .get();
  }

  Future<Company> insertCompanyRecord(CompaniesCompanion companion) {
    return into(companies).insertReturning(companion);
  }

  Future<Company?> getPrimaryCompany() async {
    final rows = await (select(companies)..limit(1)).get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<Company?> getPrimaryCompanyForOwner(String ownerUserId) async {
    final rows =
        await (select(companies)
              ..where((row) => row.ownerUserId.equals(ownerUserId))
              ..limit(1))
            .get();

    return rows.isEmpty ? null : rows.first;
  }

  Future<Company> ensurePrimaryCompanyForOwner({
    required String ownerUserId,
  }) async {
    final existing = await getPrimaryCompanyForOwner(ownerUserId);

    if (existing != null) {
      await _seedDemoParty(existing.id);
      await _seedDemoVendorCode(existing.id);
      await _seedDemoSite(existing.id);

      return existing;
    }

    return _createDemoCompanyForOwner(ownerUserId);
  }

  Future<void> updateCompanyRecord(CompaniesCompanion companion) {
    if (!companion.id.present) {
      throw ArgumentError('Company id is required when updating a company.');
    }

    return (update(
      companies,
    )..where((row) => row.id.equals(companion.id.value))).write(companion);
  }

  Future<void> syncCompanySignatureToInvoices({
    required String companyId,
    required bool applySignature,
    required bool applyToHistorical,
    required Uint8List? signatureImage,
    required String? signatoryName,
    required String? signatoryDesignation,
  }) async {
    final hasImage =
        applySignature && signatureImage != null && signatureImage.isNotEmpty;

    await transaction(() async {
      await (update(invoices)..where(
            (row) =>
                row.companyId.equals(companyId) &
                row.signatureEligible.equals(true),
          ))
          .write(
            InvoicesCompanion(
              signatureAppliedSnapshot: Value(hasImage),
              signatureImageSnapshot: Value(hasImage ? signatureImage : null),
              signatoryNameSnapshot: Value(
                hasImage ? _nullableImportText(signatoryName) : null,
              ),
              signatoryDesignationSnapshot: Value(
                hasImage ? _nullableImportText(signatoryDesignation) : null,
              ),
              updatedAt: Value(DateTime.now()),
            ),
          );

      final historicalHasImage = hasImage && applyToHistorical;

      await (update(invoices)..where(
            (row) =>
                row.companyId.equals(companyId) &
                row.signatureEligible.equals(false),
          ))
          .write(
            InvoicesCompanion(
              signatureAppliedSnapshot: Value(historicalHasImage),
              signatureImageSnapshot: Value(
                historicalHasImage ? signatureImage : null,
              ),
              signatoryNameSnapshot: Value(
                historicalHasImage ? _nullableImportText(signatoryName) : null,
              ),
              signatoryDesignationSnapshot: Value(
                historicalHasImage
                    ? _nullableImportText(signatoryDesignation)
                    : null,
              ),
              updatedAt: Value(DateTime.now()),
            ),
          );
    });
  }

  Future<CustomerMaster?> findCustomerMasterForOwner({
    required String ownerUserId,
    String? gstin,
    String? pan,
    required String partyName,
  }) async {
    final all =
        await (select(customerMasters)..where(
              (row) =>
                  row.ownerUserId.equals(ownerUserId) &
                  row.isActive.equals(true),
            ))
            .get();

    final gst = (gstin ?? '').trim().toUpperCase();
    if (gst.isNotEmpty) {
      for (final master in all) {
        if ((master.gstin ?? '').trim().toUpperCase() == gst) {
          return master;
        }
      }
    }

    final panValue = (pan ?? '').trim().toUpperCase();
    if (panValue.isNotEmpty) {
      for (final master in all) {
        if ((master.pan ?? '').trim().toUpperCase() == panValue) {
          return master;
        }
      }
    }

    final name = partyName.trim().toLowerCase();
    for (final master in all) {
      if (master.partyName.trim().toLowerCase() == name) {
        return master;
      }
    }

    return null;
  }

  Future<Company> _requireCompanyOwnedBy({
    required String companyId,
    required String ownerUserId,
  }) async {
    final company =
        await (select(companies)
              ..where((row) => row.id.equals(companyId))
              ..limit(1))
            .getSingleOrNull();

    if (company == null) {
      throw StateError('Company not found.');
    }

    final actualOwner = company.ownerUserId?.trim();
    if (actualOwner == null ||
        actualOwner.isEmpty ||
        actualOwner != ownerUserId.trim()) {
      throw StateError('Company does not belong to the current user.');
    }

    return company;
  }

  Future<List<CustomerMaster>> getAvailableCustomerMastersForCompany({
    required String ownerUserId,
    required String companyId,
  }) async {
    await _requireCompanyOwnedBy(
      companyId: companyId,
      ownerUserId: ownerUserId,
    );

    final masters =
        await (select(customerMasters)
              ..where(
                (row) =>
                    row.ownerUserId.equals(ownerUserId) &
                    row.isActive.equals(true),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.partyName)]))
            .get();

    final linked =
        await (select(parties)..where(
              (row) =>
                  row.companyId.equals(companyId) &
                  row.customerMasterId.isNotNull(),
            ))
            .get();

    final linkedIds = linked
        .map((party) => party.customerMasterId)
        .whereType<String>()
        .toSet();

    return masters.where((master) => !linkedIds.contains(master.id)).toList();
  }

  Future<CustomerMaster> _insertCustomerMaster({
    required String ownerUserId,
    required String partyName,
    String? address1,
    String? address2,
    String? address3,
    String? city,
    String? state,
    String? pincode,
    String? pan,
    String? gstin,
    String? phone,
    String? email,
  }) async {
    final id = const Uuid().v4();

    await into(customerMasters).insert(
      CustomerMastersCompanion.insert(
        id: Value(id),
        ownerUserId: ownerUserId,
        partyName: partyName.trim(),
        address1: Value(_nullableImportText(address1)),
        address2: Value(_nullableImportText(address2)),
        address3: Value(_nullableImportText(address3)),
        city: Value(_nullableImportText(city)),
        state: Value(_nullableImportText(state)),
        pincode: Value(_nullableImportText(pincode)),
        pan: Value(_nullableImportText(pan?.toUpperCase())),
        gstin: Value(_nullableImportText(gstin?.toUpperCase())),
        phone: Value(_nullableImportText(phone)),
        email: Value(_nullableImportText(email?.toLowerCase())),
        isActive: const Value(true),
      ),
    );

    return (select(
      customerMasters,
    )..where((row) => row.id.equals(id))).getSingle();
  }

  Future<Party> linkCustomerMasterToCompany({
    required String companyId,
    required String customerMasterId,
  }) async {
    final company =
        await (select(companies)
              ..where((row) => row.id.equals(companyId))
              ..limit(1))
            .getSingleOrNull();
    if (company == null) {
      throw StateError('Company not found.');
    }

    final master =
        await (select(customerMasters)
              ..where((row) => row.id.equals(customerMasterId))
              ..limit(1))
            .getSingleOrNull();
    if (master == null) {
      throw StateError('Customer master not found.');
    }

    final companyOwner = company.ownerUserId?.trim();
    final customerOwner = master.ownerUserId.trim();
    if (companyOwner == null ||
        companyOwner.isEmpty ||
        companyOwner != customerOwner) {
      throw StateError(
        'Customer and company must belong to the same signed-in user.',
      );
    }

    final existing =
        await (select(parties)
              ..where(
                (row) =>
                    row.companyId.equals(companyId) &
                    row.customerMasterId.equals(customerMasterId),
              )
              ..limit(1))
            .get();

    if (existing.isNotEmpty) {
      return existing.first;
    }

    final id = const Uuid().v4();

    await into(parties).insert(
      PartiesCompanion.insert(
        id: Value(id),
        companyId: companyId,
        customerMasterId: Value(master.id),
        partyName: master.partyName,
        address1: Value(master.address1),
        address2: Value(master.address2),
        address3: Value(master.address3),
        city: Value(master.city),
        state: Value(master.state),
        pincode: Value(master.pincode),
        pan: Value(master.pan),
        gstin: Value(master.gstin),
        phone: Value(master.phone),
        email: Value(master.email),
        isActive: const Value(true),
      ),
    );

    return (select(parties)..where((row) => row.id.equals(id))).getSingle();
  }

  Future<Party> createCustomerMasterAndLink({
    required String companyId,
    required String ownerUserId,
    required String partyName,
    String? address1,
    String? address2,
    String? address3,
    String? city,
    String? state,
    String? pincode,
    String? pan,
    String? gstin,
    String? phone,
    String? email,
  }) async {
    await _requireCompanyOwnedBy(
      companyId: companyId,
      ownerUserId: ownerUserId,
    );

    var master = await findCustomerMasterForOwner(
      ownerUserId: ownerUserId,
      gstin: gstin,
      pan: pan,
      partyName: partyName,
    );

    master ??= await _insertCustomerMaster(
      ownerUserId: ownerUserId,
      partyName: partyName,
      address1: address1,
      address2: address2,
      address3: address3,
      city: city,
      state: state,
      pincode: pincode,
      pan: pan,
      gstin: gstin,
      phone: phone,
      email: email,
    );

    return linkCustomerMasterToCompany(
      companyId: companyId,
      customerMasterId: master.id,
    );
  }

  Future<void> updatePartyAndCustomerMaster({
    required String partyId,
    required String partyName,
    String? address1,
    String? address2,
    String? address3,
    String? city,
    String? state,
    String? pincode,
    String? pan,
    String? gstin,
    String? phone,
    String? email,
  }) async {
    final party = await (select(
      parties,
    )..where((row) => row.id.equals(partyId))).getSingle();

    final now = DateTime.now();

    await transaction(() async {
      final masterId = party.customerMasterId;

      if (masterId != null) {
        await (update(
          customerMasters,
        )..where((row) => row.id.equals(masterId))).write(
          CustomerMastersCompanion(
            partyName: Value(partyName.trim()),
            address1: Value(_nullableImportText(address1)),
            address2: Value(_nullableImportText(address2)),
            address3: Value(_nullableImportText(address3)),
            city: Value(_nullableImportText(city)),
            state: Value(_nullableImportText(state)),
            pincode: Value(_nullableImportText(pincode)),
            pan: Value(_nullableImportText(pan?.toUpperCase())),
            gstin: Value(_nullableImportText(gstin?.toUpperCase())),
            phone: Value(_nullableImportText(phone)),
            email: Value(_nullableImportText(email?.toLowerCase())),
            updatedAt: Value(now),
          ),
        );

        await (update(
          parties,
        )..where((row) => row.customerMasterId.equals(masterId))).write(
          PartiesCompanion(
            partyName: Value(partyName.trim()),
            address1: Value(_nullableImportText(address1)),
            address2: Value(_nullableImportText(address2)),
            address3: Value(_nullableImportText(address3)),
            city: Value(_nullableImportText(city)),
            state: Value(_nullableImportText(state)),
            pincode: Value(_nullableImportText(pincode)),
            pan: Value(_nullableImportText(pan?.toUpperCase())),
            gstin: Value(_nullableImportText(gstin?.toUpperCase())),
            phone: Value(_nullableImportText(phone)),
            email: Value(_nullableImportText(email?.toLowerCase())),
            updatedAt: Value(now),
          ),
        );
      } else {
        await (update(parties)..where((row) => row.id.equals(partyId))).write(
          PartiesCompanion(
            partyName: Value(partyName.trim()),
            address1: Value(_nullableImportText(address1)),
            address2: Value(_nullableImportText(address2)),
            address3: Value(_nullableImportText(address3)),
            city: Value(_nullableImportText(city)),
            state: Value(_nullableImportText(state)),
            pincode: Value(_nullableImportText(pincode)),
            pan: Value(_nullableImportText(pan?.toUpperCase())),
            gstin: Value(_nullableImportText(gstin?.toUpperCase())),
            phone: Value(_nullableImportText(phone)),
            email: Value(_nullableImportText(email?.toLowerCase())),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  Future<List<Party>> getPartiesForCompany(String companyId) {
    return (select(parties)
          ..where((row) => row.companyId.equals(companyId))
          ..orderBy([(row) => OrderingTerm.asc(row.partyName)]))
        .get();
  }

  Stream<List<Party>> watchPartiesForCompany(String companyId) {
    return (select(parties)
          ..where((row) => row.companyId.equals(companyId))
          ..orderBy([(row) => OrderingTerm.asc(row.partyName)]))
        .watch();
  }

  Future<void> insertPartyRecord(PartiesCompanion companion) {
    return into(parties).insert(companion);
  }

  Future<void> updatePartyRecord(PartiesCompanion companion) {
    if (!companion.id.present) {
      throw ArgumentError('Party id is required when updating a party.');
    }

    return (update(
      parties,
    )..where((row) => row.id.equals(companion.id.value))).write(companion);
  }

  Future<VendorCode?> getVendorCodeForParty({
    required String companyId,
    required String partyId,
  }) async {
    final rows =
        await (select(vendorCodes)
              ..where(
                (row) =>
                    row.companyId.equals(companyId) &
                    row.partyId.equals(partyId) &
                    row.isActive.equals(true),
              )
              ..limit(1))
            .get();

    return rows.isEmpty ? null : rows.first;
  }

  Future<List<VendorCode>> getVendorCodesForCompany(String companyId) {
    return (select(vendorCodes)
          ..where((row) => row.companyId.equals(companyId))
          ..orderBy([(row) => OrderingTerm.asc(row.vendorCode)]))
        .get();
  }

  Stream<List<VendorCode>> watchVendorCodesForCompany(String companyId) {
    return (select(vendorCodes)
          ..where((row) => row.companyId.equals(companyId))
          ..orderBy([(row) => OrderingTerm.asc(row.vendorCode)]))
        .watch();
  }

  Future<void> insertVendorCodeRecord(VendorCodesCompanion companion) {
    return into(vendorCodes).insert(companion);
  }

  Future<void> updateVendorCodeRecord(VendorCodesCompanion companion) {
    if (!companion.id.present) {
      throw ArgumentError(
        'Vendor code id is required when updating a vendor code.',
      );
    }

    return (update(
      vendorCodes,
    )..where((row) => row.id.equals(companion.id.value))).write(companion);
  }

  // ---------------------------------------------------------------------------
  // SITE / UNIT / TAX QUERIES
  // ---------------------------------------------------------------------------

  Stream<List<Site>> watchSitesForCompany(String companyId) {
    return (select(sites)
          ..where((row) => row.companyId.equals(companyId))
          ..orderBy([(row) => OrderingTerm.asc(row.siteName)]))
        .watch();
  }

  Future<void> insertSiteRecord(SitesCompanion companion) {
    return into(sites).insert(companion);
  }

  Future<void> updateSiteRecord(SitesCompanion companion) {
    if (!companion.id.present) {
      throw ArgumentError('Site id is required when updating a site.');
    }

    return (update(
      sites,
    )..where((row) => row.id.equals(companion.id.value))).write(companion);
  }

  Stream<List<Unit>> watchUnitsForCompany(String companyId) {
    return (select(units)
          ..where(
            (row) => row.companyId.isNull() | row.companyId.equals(companyId),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.unitCode)]))
        .watch();
  }

  Future<void> insertUnitRecord(UnitsCompanion companion) {
    return into(units).insert(companion);
  }

  Future<void> updateUnitRecord(UnitsCompanion companion) {
    if (!companion.id.present) {
      throw ArgumentError('Unit id is required when updating a unit.');
    }

    return (update(
      units,
    )..where((row) => row.id.equals(companion.id.value))).write(companion);
  }

  Stream<List<TaxRate>> watchTaxRatesForCompany(String companyId) {
    return (select(taxRates)
          ..where(
            (row) => row.companyId.isNull() | row.companyId.equals(companyId),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.taxName)]))
        .watch();
  }

  Future<void> insertTaxRateRecord(TaxRatesCompanion companion) {
    return into(taxRates).insert(companion);
  }

  Future<void> updateTaxRateRecord(TaxRatesCompanion companion) {
    if (!companion.id.present) {
      throw ArgumentError('Tax rate id is required when updating a tax rate.');
    }

    return (update(
      taxRates,
    )..where((row) => row.id.equals(companion.id.value))).write(companion);
  }

  // ---------------------------------------------------------------------------
  // INVOICE NUMBERING
  // ---------------------------------------------------------------------------

  Future<List<String>> getInvoiceNumbersForCompany(String companyId) async {
    final query = selectOnly(invoices)
      ..addColumns([invoices.invoiceNumber])
      ..where(invoices.companyId.equals(companyId));

    final rows = await query.get();

    return rows
        .map((row) => row.read(invoices.invoiceNumber))
        .whereType<String>()
        .toList();
  }

  // ---------------------------------------------------------------------------
  // INVOICE FORM MASTER DATA
  // ---------------------------------------------------------------------------

  Future<List<Party>> getActivePartiesForCompany(String companyId) {
    return (select(parties)
          ..where(
            (row) =>
                row.companyId.equals(companyId) & row.isActive.equals(true),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.partyName)]))
        .get();
  }

  Future<List<VendorCode>> getActiveVendorCodesForCompany(String companyId) {
    return (select(vendorCodes)
          ..where(
            (row) =>
                row.companyId.equals(companyId) & row.isActive.equals(true),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.vendorCode)]))
        .get();
  }

  Future<List<Site>> getActiveSitesForCompany(String companyId) {
    return (select(sites)
          ..where(
            (row) =>
                row.companyId.equals(companyId) & row.isActive.equals(true),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.siteName)]))
        .get();
  }

  Future<List<Site>> getActiveSitesForParty({
    required String companyId,
    required String partyId,
  }) {
    return (select(sites)
          ..where(
            (row) =>
                row.companyId.equals(companyId) &
                row.partyId.equals(partyId) &
                row.isActive.equals(true),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.siteName)]))
        .get();
  }

  Future<List<Unit>> getActiveUnitsForCompany(String companyId) {
    return (select(units)
          ..where(
            (row) =>
                row.isActive.equals(true) &
                (row.companyId.isNull() | row.companyId.equals(companyId)),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.unitCode)]))
        .get();
  }

  Future<List<TaxRate>> getActiveTaxRatesForCompany(String companyId) {
    return (select(taxRates)..where(
          (row) =>
              row.isActive.equals(true) &
              (row.companyId.isNull() | row.companyId.equals(companyId)),
        ))
        .get();
  }

  Future<void> saveInvoiceWithItems({
    required InvoicesCompanion invoice,
    required List<InvoiceItemsCompanion> items,
  }) async {
    await transaction(() async {
      await into(invoices).insert(invoice);

      if (items.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(invoiceItems, items);
        });
      }
    });
  }

  // ---------------------------------------------------------------------------
  // INVOICE LIST / DETAIL QUERIES
  // ---------------------------------------------------------------------------

  Stream<List<Invoice>> watchInvoicesForCompany(String companyId) {
    return (select(invoices)
          ..where((row) => row.companyId.equals(companyId))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.invoiceDate,
              mode: OrderingMode.desc,
            ),
            (row) => OrderingTerm(
              expression: row.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Future<Invoice?> getInvoiceById(String invoiceId) async {
    final rows =
        await (select(invoices)
              ..where((row) => row.id.equals(invoiceId))
              ..limit(1))
            .get();

    return rows.isEmpty ? null : rows.first;
  }

  Future<Invoice?> getInvoiceByIdForCompany({
    required String invoiceId,
    required String companyId,
  }) async {
    final rows =
        await (select(invoices)
              ..where(
                (row) =>
                    row.id.equals(invoiceId) & row.companyId.equals(companyId),
              )
              ..limit(1))
            .get();

    return rows.isEmpty ? null : rows.first;
  }

  Future<List<InvoiceItem>> getInvoiceItemsByInvoice(String invoiceId) {
    return (select(invoiceItems)
          ..where((row) => row.invoiceId.equals(invoiceId))
          ..orderBy([(row) => OrderingTerm.asc(row.serialNo)]))
        .get();
  }

  Stream<List<InvoiceItem>> watchInvoiceItemsByInvoice(String invoiceId) {
    return (select(invoiceItems)
          ..where((row) => row.invoiceId.equals(invoiceId))
          ..orderBy([(row) => OrderingTerm.asc(row.serialNo)]))
        .watch();
  }

  // ---------------------------------------------------------------------------
  // INVOICE UPDATE / STATUS
  // ---------------------------------------------------------------------------

  Future<void> updateInvoiceWithItems({
    required String invoiceId,
    required InvoicesCompanion invoice,
    required List<InvoiceItemsCompanion> items,
  }) async {
    await transaction(() async {
      await (update(
        invoices,
      )..where((row) => row.id.equals(invoiceId))).write(invoice);

      await (delete(
        invoiceItems,
      )..where((row) => row.invoiceId.equals(invoiceId))).go();

      if (items.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(invoiceItems, items);
        });
      }
    });
  }

  Future<void> updateInvoiceStatus({
    required String invoiceId,
    required String status,
  }) async {
    if (status.toLowerCase() == 'cancelled') {
      final paymentRows = await getPaymentsForInvoice(invoiceId);
      if (paymentRows.isNotEmpty) {
        throw StateError(
          'An invoice with payment activity cannot be cancelled.',
        );
      }
    }

    await (update(invoices)..where((row) => row.id.equals(invoiceId))).write(
      InvoicesCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<Party> createPartyFromImport({
    required String companyId,
    required String partyName,
    String? address1,
    String? address2,
    String? address3,
    String? pan,
    String? gstin,
  }) async {
    final company =
        await (select(companies)
              ..where((row) => row.id.equals(companyId))
              ..limit(1))
            .getSingle();

    final ownerUserId = company.ownerUserId?.trim();

    if (ownerUserId == null || ownerUserId.isEmpty) {
      final id = const Uuid().v4();

      await into(parties).insert(
        PartiesCompanion.insert(
          id: Value(id),
          companyId: companyId,
          partyName: partyName.trim(),
          address1: Value(_nullableImportText(address1)),
          address2: Value(_nullableImportText(address2)),
          address3: Value(_nullableImportText(address3)),
          pan: Value(_nullableImportText(pan?.toUpperCase())),
          gstin: Value(_nullableImportText(gstin?.toUpperCase())),
          isActive: const Value(true),
        ),
      );

      return (select(parties)..where((row) => row.id.equals(id))).getSingle();
    }

    return createCustomerMasterAndLink(
      companyId: companyId,
      ownerUserId: ownerUserId,
      partyName: partyName,
      address1: address1,
      address2: address2,
      address3: address3,
      pan: pan,
      gstin: gstin,
    );
  }

  static String? _nullableImportText(String? value) {
    final text = value?.trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  // ---------------------------------------------------------------------------
  // NOTES
  // ---------------------------------------------------------------------------

  Stream<List<Note>> watchNotesForCompany(String companyId) {
    return (select(notes)
          ..where((row) => row.companyId.equals(companyId))
          ..orderBy([
            (row) =>
                OrderingTerm(expression: row.isPinned, mode: OrderingMode.desc),
            (row) => OrderingTerm(
              expression: row.updatedAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Future<void> insertNoteRecord(NotesCompanion companion) {
    return into(notes).insert(companion);
  }

  Future<void> updateNoteRecord(NotesCompanion companion) {
    if (!companion.id.present) {
      throw ArgumentError('Note id is required when updating a note.');
    }

    return (update(
      notes,
    )..where((row) => row.id.equals(companion.id.value))).write(companion);
  }

  Future<void> deleteNoteRecord(String noteId) {
    return (delete(notes)..where((row) => row.id.equals(noteId))).go();
  }
  // ---------------------------------------------------------------------------
  // EXPENSES
  // ---------------------------------------------------------------------------

  Stream<List<Expense>> watchExpensesForCompany(String companyId) {
    return (select(expenses)
          ..where((row) => row.companyId.equals(companyId))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.expenseDate,
              mode: OrderingMode.desc,
            ),
            (row) => OrderingTerm(
              expression: row.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Future<Expense?> getExpenseById(String expenseId) async {
    final rows =
        await (select(expenses)
              ..where((row) => row.id.equals(expenseId))
              ..limit(1))
            .get();

    return rows.isEmpty ? null : rows.first;
  }

  Future<void> insertExpenseRecord(ExpensesCompanion companion) {
    return into(expenses).insert(companion);
  }

  Future<void> updateExpenseRecord(ExpensesCompanion companion) {
    if (!companion.id.present) {
      throw ArgumentError('Expense id is required when updating an expense.');
    }

    return (update(
      expenses,
    )..where((row) => row.id.equals(companion.id.value))).write(companion);
  }

  Future<void> deleteExpenseRecord(String expenseId) {
    return (delete(expenses)..where((row) => row.id.equals(expenseId))).go();
  }

  Future<int> getExpenseTotalForCompany(String companyId) async {
    final rows = await (select(
      expenses,
    )..where((row) => row.companyId.equals(companyId))).get();

    return rows.fold<int>(
      0,
      (total, expense) => total + expense.totalAmountPaise,
    );
  }
  // ---------------------------------------------------------------------------
  // PAYMENTS
  // ---------------------------------------------------------------------------

  Stream<List<Payment>> watchAllPayments() {
    return (select(payments)..orderBy([
          (row) => OrderingTerm(
            expression: row.paymentDate,
            mode: OrderingMode.desc,
          ),
          (row) =>
              OrderingTerm(expression: row.createdAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  Stream<List<Payment>> watchPaymentsForInvoice(String invoiceId) {
    return (select(payments)
          ..where((row) => row.invoiceId.equals(invoiceId))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.paymentDate,
              mode: OrderingMode.desc,
            ),
            (row) => OrderingTerm(
              expression: row.createdAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  Future<List<Payment>> getPaymentsForInvoice(String invoiceId) {
    return (select(payments)
          ..where((row) => row.invoiceId.equals(invoiceId))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.paymentDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<int> getPaidAmountForInvoice(String invoiceId) async {
    final rows = await getPaymentsForInvoice(invoiceId);

    return rows.fold<int>(0, (total, payment) => total + payment.amountPaise);
  }

  Future<int> getOutstandingAmountForInvoice(String invoiceId) async {
    final invoice = await getInvoiceById(invoiceId);

    if (invoice == null) {
      throw StateError('Invoice not found.');
    }

    final paid = await getPaidAmountForInvoice(invoiceId);

    final outstanding = invoice.grandTotalPaise - paid;

    return outstanding < 0 ? 0 : outstanding;
  }

  Future<void> recordInvoicePayment({
    required String invoiceId,
    required int amountPaise,
    required DateTime paymentDate,
    required String paymentMode,
    String? referenceNumber,
    String? receivedBy,
    String? notes,
  }) async {
    if (amountPaise <= 0) {
      throw ArgumentError('Payment amount must be greater than zero.');
    }

    await transaction(() async {
      final invoice = await getInvoiceById(invoiceId);

      if (invoice == null) {
        throw StateError('Invoice not found.');
      }

      if (invoice.status.toLowerCase() != 'issued') {
        throw StateError(
          'Payments can only be recorded against issued invoices.',
        );
      }

      final existingPayments = await (select(
        payments,
      )..where((row) => row.invoiceId.equals(invoiceId))).get();

      final paid = existingPayments.fold<int>(
        0,
        (total, payment) => total + payment.amountPaise,
      );

      final outstanding = invoice.grandTotalPaise - paid;

      if (outstanding <= 0) {
        throw StateError('This invoice is already fully paid.');
      }

      if (amountPaise > outstanding) {
        throw StateError('Payment amount cannot exceed invoice outstanding.');
      }

      await into(payments).insert(
        PaymentsCompanion.insert(
          invoiceId: invoiceId,
          amountPaise: amountPaise,
          paymentDate: paymentDate,
          paymentMode: paymentMode,
          referenceNumber: Value(_nullableImportText(referenceNumber)),
          receivedBy: Value(_nullableImportText(receivedBy)),
          notes: Value(_nullableImportText(notes)),
        ),
      );
    });
  }

  Future<void> deleteInvoicePayment(String paymentId) {
    return (delete(payments)..where((row) => row.id.equals(paymentId))).go();
  }
  // ---------------------------------------------------------------------------
  // EXCEL IMPORT
  // ---------------------------------------------------------------------------

  Future<Invoice?> getInvoiceByCompanyAndNumber({
    required String companyId,
    required String invoiceNumber,
  }) async {
    final rows =
        await (select(invoices)
              ..where(
                (row) =>
                    row.companyId.equals(companyId) &
                    row.invoiceNumber.equals(invoiceNumber),
              )
              ..limit(1))
            .get();

    return rows.isEmpty ? null : rows.first;
  }

  Future<Party?> findPartyForImport({
    required String companyId,
    String? gstin,
    String? pan,
    required String partyName,
  }) async {
    final all = await (select(
      parties,
    )..where((row) => row.companyId.equals(companyId))).get();

    final gst = (gstin ?? '').trim().toUpperCase();

    if (gst.isNotEmpty) {
      for (final party in all) {
        if ((party.gstin ?? '').trim().toUpperCase() == gst) {
          return party;
        }
      }
    }

    final panValue = (pan ?? '').trim().toUpperCase();

    if (panValue.isNotEmpty) {
      for (final party in all) {
        if ((party.pan ?? '').trim().toUpperCase() == panValue) {
          return party;
        }
      }
    }

    final name = partyName.trim().toLowerCase();

    for (final party in all) {
      if (party.partyName.trim().toLowerCase() == name) {
        return party;
      }
    }

    return null;
  }

  Future<VendorCode?> findVendorCodeForImport({
    required String companyId,
    required String partyId,
  }) async {
    final rows =
        await (select(vendorCodes)
              ..where(
                (row) =>
                    row.companyId.equals(companyId) &
                    row.partyId.equals(partyId),
              )
              ..limit(1))
            .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<Site?> findSiteForImport({
    required String companyId,
    required String partyId,
    required String siteName,
  }) async {
    final target = siteName.trim().toLowerCase();
    if (target.isEmpty) return null;
    final rows =
        await (select(sites)..where(
              (row) =>
                  row.companyId.equals(companyId) & row.partyId.equals(partyId),
            ))
            .get();
    for (final site in rows) {
      if (site.siteName.trim().toLowerCase() == target) return site;
    }
    return null;
  }

  Future<VendorCode> createVendorCodeFromImport({
    required String companyId,
    required String partyId,
    required String vendorCode,
  }) async {
    final id = const Uuid().v4();
    await into(vendorCodes).insert(
      VendorCodesCompanion.insert(
        id: Value(id),
        companyId: companyId,
        partyId: Value(partyId),
        vendorCode: vendorCode.trim(),
        isActive: const Value(true),
      ),
    );
    return (select(vendorCodes)..where((row) => row.id.equals(id))).getSingle();
  }

  Future<Site> createSiteFromImport({
    required String companyId,
    required String partyId,
    required String siteName,
  }) async {
    final id = const Uuid().v4();
    await into(sites).insert(
      SitesCompanion.insert(
        id: Value(id),
        companyId: companyId,
        partyId: Value(partyId),
        siteName: siteName.trim(),
        isActive: const Value(true),
      ),
    );
    return (select(sites)..where((row) => row.id.equals(id))).getSingle();
  }

  Future<Unit?> findUnitForImport({
    required String companyId,
    required String unitCode,
  }) async {
    final code = unitCode.trim().toLowerCase();

    if (code.isEmpty) {
      return null;
    }

    final rows =
        await (select(units)..where(
              (row) =>
                  row.isActive.equals(true) &
                  (row.companyId.isNull() | row.companyId.equals(companyId)),
            ))
            .get();

    for (final unit in rows) {
      if (unit.unitCode.trim().toLowerCase() == code) {
        return unit;
      }
    }

    return null;
  }

  Future<void> overwriteImportedInvoice({
    required String existingInvoiceId,
    required InvoicesCompanion invoice,
    required List<InvoiceItemsCompanion> items,
  }) async {
    await transaction(() async {
      await (update(
        invoices,
      )..where((row) => row.id.equals(existingInvoiceId))).write(invoice);

      await (delete(
        invoiceItems,
      )..where((row) => row.invoiceId.equals(existingInvoiceId))).go();

      if (items.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(invoiceItems, items);
        });
      }
    });
  }

  Future<void> insertImportBatch(ImportBatchesCompanion companion) {
    return into(importBatches).insert(companion);
  }

  Stream<List<ImportBatche>> watchImportHistory(String companyId) {
    return (select(importBatches)
          ..where((row) => row.companyId.equals(companyId))
          ..orderBy([
            (row) => OrderingTerm(
              expression: row.importedAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();

    final databaseFile = File(
      p.join(documentsDirectory.path, 'vinvoice_pro.sqlite'),
    );

    return NativeDatabase.createInBackground(databaseFile);
  });
}
