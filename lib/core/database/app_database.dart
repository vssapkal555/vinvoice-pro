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

  TextColumn get vendorCode => text()();

  TextColumn get description => text().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {companyId, vendorCode},
  ];
}

class Sites extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();

  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();

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
    Parties,
    VendorCodes,
    Sites,
    Units,
    TaxRates,
    Invoices,
    InvoiceItems,
    Notes,
    ImportBatches,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Future migrations will be added here.
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');

      await _seedDefaultUnits();
      await _seedDefaultTaxRates();

      final demoCompanyId = await _seedDemoCompany();

      await _seedDemoParty(demoCompanyId);
      await _seedDemoVendorCode(demoCompanyId);
      await _seedDemoSite(demoCompanyId);
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

  Future<String> _seedDemoCompany() async {
    final existingCompanies = await (select(companies)..limit(1)).get();

    if (existingCompanies.isNotEmpty) {
      return existingCompanies.first.id;
    }

    final companyId = _uuid.v4();

    await into(companies).insert(
      CompaniesCompanion.insert(
        id: Value(companyId),
        companyName: 'VInvoice Demo Enterprises',
        address1: const Value('Office No. 101, Business Plaza'),
        address2: const Value('Main Road'),
        address3: const Value('Pune, Maharashtra'),
        city: const Value('Pune'),
        state: const Value('Maharashtra'),
        pincode: const Value('411001'),
        pan: const Value('ABCDE1234F'),
        gstin: const Value('27ABCDE1234F1Z5'),
        phone: const Value('9876543210'),
        email: const Value('accounts@vinvoicedemo.in'),
      ),
    );

    return companyId;
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

  Future<Company?> getPrimaryCompany() async {
    final rows = await (select(companies)..limit(1)).get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> updateCompanyRecord(CompaniesCompanion companion) {
    return update(companies).write(companion);
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
    return update(parties).write(companion);
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
    return update(vendorCodes).write(companion);
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
    return update(sites).write(companion);
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
    return update(units).write(companion);
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
    return update(taxRates).write(companion);
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

  static String? _nullableImportText(String? value) {
    final text = value?.trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
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
