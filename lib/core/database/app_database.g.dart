// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CompaniesTable extends Companies
    with TableInfo<$CompaniesTable, Company> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompaniesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _ownerUserIdMeta = const VerificationMeta(
    'ownerUserId',
  );
  @override
  late final GeneratedColumn<String> ownerUserId = GeneratedColumn<String>(
    'owner_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyNameMeta = const VerificationMeta(
    'companyName',
  );
  @override
  late final GeneratedColumn<String> companyName = GeneratedColumn<String>(
    'company_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _address1Meta = const VerificationMeta(
    'address1',
  );
  @override
  late final GeneratedColumn<String> address1 = GeneratedColumn<String>(
    'address1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _address2Meta = const VerificationMeta(
    'address2',
  );
  @override
  late final GeneratedColumn<String> address2 = GeneratedColumn<String>(
    'address2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _address3Meta = const VerificationMeta(
    'address3',
  );
  @override
  late final GeneratedColumn<String> address3 = GeneratedColumn<String>(
    'address3',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pincodeMeta = const VerificationMeta(
    'pincode',
  );
  @override
  late final GeneratedColumn<String> pincode = GeneratedColumn<String>(
    'pincode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _panMeta = const VerificationMeta('pan');
  @override
  late final GeneratedColumn<String> pan = GeneratedColumn<String>(
    'pan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
    'gstin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoPathMeta = const VerificationMeta(
    'logoPath',
  );
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
    'logo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUserId,
    companyName,
    address1,
    address2,
    address3,
    city,
    state,
    pincode,
    pan,
    gstin,
    phone,
    email,
    logoPath,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'companies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Company> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
        _ownerUserIdMeta,
        ownerUserId.isAcceptableOrUnknown(
          data['owner_user_id']!,
          _ownerUserIdMeta,
        ),
      );
    }
    if (data.containsKey('company_name')) {
      context.handle(
        _companyNameMeta,
        companyName.isAcceptableOrUnknown(
          data['company_name']!,
          _companyNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companyNameMeta);
    }
    if (data.containsKey('address1')) {
      context.handle(
        _address1Meta,
        address1.isAcceptableOrUnknown(data['address1']!, _address1Meta),
      );
    }
    if (data.containsKey('address2')) {
      context.handle(
        _address2Meta,
        address2.isAcceptableOrUnknown(data['address2']!, _address2Meta),
      );
    }
    if (data.containsKey('address3')) {
      context.handle(
        _address3Meta,
        address3.isAcceptableOrUnknown(data['address3']!, _address3Meta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('pincode')) {
      context.handle(
        _pincodeMeta,
        pincode.isAcceptableOrUnknown(data['pincode']!, _pincodeMeta),
      );
    }
    if (data.containsKey('pan')) {
      context.handle(
        _panMeta,
        pan.isAcceptableOrUnknown(data['pan']!, _panMeta),
      );
    }
    if (data.containsKey('gstin')) {
      context.handle(
        _gstinMeta,
        gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('logo_path')) {
      context.handle(
        _logoPathMeta,
        logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Company map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Company(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_user_id'],
      ),
      companyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_name'],
      )!,
      address1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address1'],
      ),
      address2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address2'],
      ),
      address3: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address3'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
      pincode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pincode'],
      ),
      pan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pan'],
      ),
      gstin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      logoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_path'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CompaniesTable createAlias(String alias) {
    return $CompaniesTable(attachedDatabase, alias);
  }
}

class Company extends DataClass implements Insertable<Company> {
  final String id;
  final String? ownerUserId;
  final String companyName;
  final String? address1;
  final String? address2;
  final String? address3;
  final String? city;
  final String? state;
  final String? pincode;
  final String? pan;
  final String? gstin;
  final String? phone;
  final String? email;
  final String? logoPath;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Company({
    required this.id,
    this.ownerUserId,
    required this.companyName,
    this.address1,
    this.address2,
    this.address3,
    this.city,
    this.state,
    this.pincode,
    this.pan,
    this.gstin,
    this.phone,
    this.email,
    this.logoPath,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || ownerUserId != null) {
      map['owner_user_id'] = Variable<String>(ownerUserId);
    }
    map['company_name'] = Variable<String>(companyName);
    if (!nullToAbsent || address1 != null) {
      map['address1'] = Variable<String>(address1);
    }
    if (!nullToAbsent || address2 != null) {
      map['address2'] = Variable<String>(address2);
    }
    if (!nullToAbsent || address3 != null) {
      map['address3'] = Variable<String>(address3);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    if (!nullToAbsent || pincode != null) {
      map['pincode'] = Variable<String>(pincode);
    }
    if (!nullToAbsent || pan != null) {
      map['pan'] = Variable<String>(pan);
    }
    if (!nullToAbsent || gstin != null) {
      map['gstin'] = Variable<String>(gstin);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CompaniesCompanion toCompanion(bool nullToAbsent) {
    return CompaniesCompanion(
      id: Value(id),
      ownerUserId: ownerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUserId),
      companyName: Value(companyName),
      address1: address1 == null && nullToAbsent
          ? const Value.absent()
          : Value(address1),
      address2: address2 == null && nullToAbsent
          ? const Value.absent()
          : Value(address2),
      address3: address3 == null && nullToAbsent
          ? const Value.absent()
          : Value(address3),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      pincode: pincode == null && nullToAbsent
          ? const Value.absent()
          : Value(pincode),
      pan: pan == null && nullToAbsent ? const Value.absent() : Value(pan),
      gstin: gstin == null && nullToAbsent
          ? const Value.absent()
          : Value(gstin),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Company.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Company(
      id: serializer.fromJson<String>(json['id']),
      ownerUserId: serializer.fromJson<String?>(json['ownerUserId']),
      companyName: serializer.fromJson<String>(json['companyName']),
      address1: serializer.fromJson<String?>(json['address1']),
      address2: serializer.fromJson<String?>(json['address2']),
      address3: serializer.fromJson<String?>(json['address3']),
      city: serializer.fromJson<String?>(json['city']),
      state: serializer.fromJson<String?>(json['state']),
      pincode: serializer.fromJson<String?>(json['pincode']),
      pan: serializer.fromJson<String?>(json['pan']),
      gstin: serializer.fromJson<String?>(json['gstin']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerUserId': serializer.toJson<String?>(ownerUserId),
      'companyName': serializer.toJson<String>(companyName),
      'address1': serializer.toJson<String?>(address1),
      'address2': serializer.toJson<String?>(address2),
      'address3': serializer.toJson<String?>(address3),
      'city': serializer.toJson<String?>(city),
      'state': serializer.toJson<String?>(state),
      'pincode': serializer.toJson<String?>(pincode),
      'pan': serializer.toJson<String?>(pan),
      'gstin': serializer.toJson<String?>(gstin),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'logoPath': serializer.toJson<String?>(logoPath),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Company copyWith({
    String? id,
    Value<String?> ownerUserId = const Value.absent(),
    String? companyName,
    Value<String?> address1 = const Value.absent(),
    Value<String?> address2 = const Value.absent(),
    Value<String?> address3 = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<String?> state = const Value.absent(),
    Value<String?> pincode = const Value.absent(),
    Value<String?> pan = const Value.absent(),
    Value<String?> gstin = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> logoPath = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Company(
    id: id ?? this.id,
    ownerUserId: ownerUserId.present ? ownerUserId.value : this.ownerUserId,
    companyName: companyName ?? this.companyName,
    address1: address1.present ? address1.value : this.address1,
    address2: address2.present ? address2.value : this.address2,
    address3: address3.present ? address3.value : this.address3,
    city: city.present ? city.value : this.city,
    state: state.present ? state.value : this.state,
    pincode: pincode.present ? pincode.value : this.pincode,
    pan: pan.present ? pan.value : this.pan,
    gstin: gstin.present ? gstin.value : this.gstin,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    logoPath: logoPath.present ? logoPath.value : this.logoPath,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Company copyWithCompanion(CompaniesCompanion data) {
    return Company(
      id: data.id.present ? data.id.value : this.id,
      ownerUserId: data.ownerUserId.present
          ? data.ownerUserId.value
          : this.ownerUserId,
      companyName: data.companyName.present
          ? data.companyName.value
          : this.companyName,
      address1: data.address1.present ? data.address1.value : this.address1,
      address2: data.address2.present ? data.address2.value : this.address2,
      address3: data.address3.present ? data.address3.value : this.address3,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      pincode: data.pincode.present ? data.pincode.value : this.pincode,
      pan: data.pan.present ? data.pan.value : this.pan,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Company(')
          ..write('id: $id, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('companyName: $companyName, ')
          ..write('address1: $address1, ')
          ..write('address2: $address2, ')
          ..write('address3: $address3, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('pincode: $pincode, ')
          ..write('pan: $pan, ')
          ..write('gstin: $gstin, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('logoPath: $logoPath, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerUserId,
    companyName,
    address1,
    address2,
    address3,
    city,
    state,
    pincode,
    pan,
    gstin,
    phone,
    email,
    logoPath,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Company &&
          other.id == this.id &&
          other.ownerUserId == this.ownerUserId &&
          other.companyName == this.companyName &&
          other.address1 == this.address1 &&
          other.address2 == this.address2 &&
          other.address3 == this.address3 &&
          other.city == this.city &&
          other.state == this.state &&
          other.pincode == this.pincode &&
          other.pan == this.pan &&
          other.gstin == this.gstin &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.logoPath == this.logoPath &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CompaniesCompanion extends UpdateCompanion<Company> {
  final Value<String> id;
  final Value<String?> ownerUserId;
  final Value<String> companyName;
  final Value<String?> address1;
  final Value<String?> address2;
  final Value<String?> address3;
  final Value<String?> city;
  final Value<String?> state;
  final Value<String?> pincode;
  final Value<String?> pan;
  final Value<String?> gstin;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> logoPath;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CompaniesCompanion({
    this.id = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.companyName = const Value.absent(),
    this.address1 = const Value.absent(),
    this.address2 = const Value.absent(),
    this.address3 = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.pincode = const Value.absent(),
    this.pan = const Value.absent(),
    this.gstin = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompaniesCompanion.insert({
    this.id = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    required String companyName,
    this.address1 = const Value.absent(),
    this.address2 = const Value.absent(),
    this.address3 = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.pincode = const Value.absent(),
    this.pan = const Value.absent(),
    this.gstin = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : companyName = Value(companyName);
  static Insertable<Company> custom({
    Expression<String>? id,
    Expression<String>? ownerUserId,
    Expression<String>? companyName,
    Expression<String>? address1,
    Expression<String>? address2,
    Expression<String>? address3,
    Expression<String>? city,
    Expression<String>? state,
    Expression<String>? pincode,
    Expression<String>? pan,
    Expression<String>? gstin,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? logoPath,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (companyName != null) 'company_name': companyName,
      if (address1 != null) 'address1': address1,
      if (address2 != null) 'address2': address2,
      if (address3 != null) 'address3': address3,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (pan != null) 'pan': pan,
      if (gstin != null) 'gstin': gstin,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (logoPath != null) 'logo_path': logoPath,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompaniesCompanion copyWith({
    Value<String>? id,
    Value<String?>? ownerUserId,
    Value<String>? companyName,
    Value<String?>? address1,
    Value<String?>? address2,
    Value<String?>? address3,
    Value<String?>? city,
    Value<String?>? state,
    Value<String?>? pincode,
    Value<String?>? pan,
    Value<String?>? gstin,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? logoPath,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CompaniesCompanion(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      companyName: companyName ?? this.companyName,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      address3: address3 ?? this.address3,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      pan: pan ?? this.pan,
      gstin: gstin ?? this.gstin,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logoPath: logoPath ?? this.logoPath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<String>(ownerUserId.value);
    }
    if (companyName.present) {
      map['company_name'] = Variable<String>(companyName.value);
    }
    if (address1.present) {
      map['address1'] = Variable<String>(address1.value);
    }
    if (address2.present) {
      map['address2'] = Variable<String>(address2.value);
    }
    if (address3.present) {
      map['address3'] = Variable<String>(address3.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (pincode.present) {
      map['pincode'] = Variable<String>(pincode.value);
    }
    if (pan.present) {
      map['pan'] = Variable<String>(pan.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompaniesCompanion(')
          ..write('id: $id, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('companyName: $companyName, ')
          ..write('address1: $address1, ')
          ..write('address2: $address2, ')
          ..write('address3: $address3, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('pincode: $pincode, ')
          ..write('pan: $pan, ')
          ..write('gstin: $gstin, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('logoPath: $logoPath, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartiesTable extends Parties with TableInfo<$PartiesTable, Party> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _partyNameMeta = const VerificationMeta(
    'partyName',
  );
  @override
  late final GeneratedColumn<String> partyName = GeneratedColumn<String>(
    'party_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _address1Meta = const VerificationMeta(
    'address1',
  );
  @override
  late final GeneratedColumn<String> address1 = GeneratedColumn<String>(
    'address1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _address2Meta = const VerificationMeta(
    'address2',
  );
  @override
  late final GeneratedColumn<String> address2 = GeneratedColumn<String>(
    'address2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _address3Meta = const VerificationMeta(
    'address3',
  );
  @override
  late final GeneratedColumn<String> address3 = GeneratedColumn<String>(
    'address3',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pincodeMeta = const VerificationMeta(
    'pincode',
  );
  @override
  late final GeneratedColumn<String> pincode = GeneratedColumn<String>(
    'pincode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _panMeta = const VerificationMeta('pan');
  @override
  late final GeneratedColumn<String> pan = GeneratedColumn<String>(
    'pan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
    'gstin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    partyName,
    address1,
    address2,
    address3,
    city,
    state,
    pincode,
    pan,
    gstin,
    phone,
    email,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'parties';
  @override
  VerificationContext validateIntegrity(
    Insertable<Party> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('party_name')) {
      context.handle(
        _partyNameMeta,
        partyName.isAcceptableOrUnknown(data['party_name']!, _partyNameMeta),
      );
    } else if (isInserting) {
      context.missing(_partyNameMeta);
    }
    if (data.containsKey('address1')) {
      context.handle(
        _address1Meta,
        address1.isAcceptableOrUnknown(data['address1']!, _address1Meta),
      );
    }
    if (data.containsKey('address2')) {
      context.handle(
        _address2Meta,
        address2.isAcceptableOrUnknown(data['address2']!, _address2Meta),
      );
    }
    if (data.containsKey('address3')) {
      context.handle(
        _address3Meta,
        address3.isAcceptableOrUnknown(data['address3']!, _address3Meta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('pincode')) {
      context.handle(
        _pincodeMeta,
        pincode.isAcceptableOrUnknown(data['pincode']!, _pincodeMeta),
      );
    }
    if (data.containsKey('pan')) {
      context.handle(
        _panMeta,
        pan.isAcceptableOrUnknown(data['pan']!, _panMeta),
      );
    }
    if (data.containsKey('gstin')) {
      context.handle(
        _gstinMeta,
        gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Party map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Party(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      partyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_name'],
      )!,
      address1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address1'],
      ),
      address2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address2'],
      ),
      address3: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address3'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
      pincode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pincode'],
      ),
      pan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pan'],
      ),
      gstin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PartiesTable createAlias(String alias) {
    return $PartiesTable(attachedDatabase, alias);
  }
}

class Party extends DataClass implements Insertable<Party> {
  final String id;
  final String companyId;
  final String partyName;
  final String? address1;
  final String? address2;
  final String? address3;
  final String? city;
  final String? state;
  final String? pincode;
  final String? pan;
  final String? gstin;
  final String? phone;
  final String? email;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Party({
    required this.id,
    required this.companyId,
    required this.partyName,
    this.address1,
    this.address2,
    this.address3,
    this.city,
    this.state,
    this.pincode,
    this.pan,
    this.gstin,
    this.phone,
    this.email,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['party_name'] = Variable<String>(partyName);
    if (!nullToAbsent || address1 != null) {
      map['address1'] = Variable<String>(address1);
    }
    if (!nullToAbsent || address2 != null) {
      map['address2'] = Variable<String>(address2);
    }
    if (!nullToAbsent || address3 != null) {
      map['address3'] = Variable<String>(address3);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    if (!nullToAbsent || pincode != null) {
      map['pincode'] = Variable<String>(pincode);
    }
    if (!nullToAbsent || pan != null) {
      map['pan'] = Variable<String>(pan);
    }
    if (!nullToAbsent || gstin != null) {
      map['gstin'] = Variable<String>(gstin);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PartiesCompanion toCompanion(bool nullToAbsent) {
    return PartiesCompanion(
      id: Value(id),
      companyId: Value(companyId),
      partyName: Value(partyName),
      address1: address1 == null && nullToAbsent
          ? const Value.absent()
          : Value(address1),
      address2: address2 == null && nullToAbsent
          ? const Value.absent()
          : Value(address2),
      address3: address3 == null && nullToAbsent
          ? const Value.absent()
          : Value(address3),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      pincode: pincode == null && nullToAbsent
          ? const Value.absent()
          : Value(pincode),
      pan: pan == null && nullToAbsent ? const Value.absent() : Value(pan),
      gstin: gstin == null && nullToAbsent
          ? const Value.absent()
          : Value(gstin),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Party.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Party(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      partyName: serializer.fromJson<String>(json['partyName']),
      address1: serializer.fromJson<String?>(json['address1']),
      address2: serializer.fromJson<String?>(json['address2']),
      address3: serializer.fromJson<String?>(json['address3']),
      city: serializer.fromJson<String?>(json['city']),
      state: serializer.fromJson<String?>(json['state']),
      pincode: serializer.fromJson<String?>(json['pincode']),
      pan: serializer.fromJson<String?>(json['pan']),
      gstin: serializer.fromJson<String?>(json['gstin']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'partyName': serializer.toJson<String>(partyName),
      'address1': serializer.toJson<String?>(address1),
      'address2': serializer.toJson<String?>(address2),
      'address3': serializer.toJson<String?>(address3),
      'city': serializer.toJson<String?>(city),
      'state': serializer.toJson<String?>(state),
      'pincode': serializer.toJson<String?>(pincode),
      'pan': serializer.toJson<String?>(pan),
      'gstin': serializer.toJson<String?>(gstin),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Party copyWith({
    String? id,
    String? companyId,
    String? partyName,
    Value<String?> address1 = const Value.absent(),
    Value<String?> address2 = const Value.absent(),
    Value<String?> address3 = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<String?> state = const Value.absent(),
    Value<String?> pincode = const Value.absent(),
    Value<String?> pan = const Value.absent(),
    Value<String?> gstin = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Party(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    partyName: partyName ?? this.partyName,
    address1: address1.present ? address1.value : this.address1,
    address2: address2.present ? address2.value : this.address2,
    address3: address3.present ? address3.value : this.address3,
    city: city.present ? city.value : this.city,
    state: state.present ? state.value : this.state,
    pincode: pincode.present ? pincode.value : this.pincode,
    pan: pan.present ? pan.value : this.pan,
    gstin: gstin.present ? gstin.value : this.gstin,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Party copyWithCompanion(PartiesCompanion data) {
    return Party(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      partyName: data.partyName.present ? data.partyName.value : this.partyName,
      address1: data.address1.present ? data.address1.value : this.address1,
      address2: data.address2.present ? data.address2.value : this.address2,
      address3: data.address3.present ? data.address3.value : this.address3,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      pincode: data.pincode.present ? data.pincode.value : this.pincode,
      pan: data.pan.present ? data.pan.value : this.pan,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Party(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('partyName: $partyName, ')
          ..write('address1: $address1, ')
          ..write('address2: $address2, ')
          ..write('address3: $address3, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('pincode: $pincode, ')
          ..write('pan: $pan, ')
          ..write('gstin: $gstin, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    partyName,
    address1,
    address2,
    address3,
    city,
    state,
    pincode,
    pan,
    gstin,
    phone,
    email,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Party &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.partyName == this.partyName &&
          other.address1 == this.address1 &&
          other.address2 == this.address2 &&
          other.address3 == this.address3 &&
          other.city == this.city &&
          other.state == this.state &&
          other.pincode == this.pincode &&
          other.pan == this.pan &&
          other.gstin == this.gstin &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PartiesCompanion extends UpdateCompanion<Party> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> partyName;
  final Value<String?> address1;
  final Value<String?> address2;
  final Value<String?> address3;
  final Value<String?> city;
  final Value<String?> state;
  final Value<String?> pincode;
  final Value<String?> pan;
  final Value<String?> gstin;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PartiesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.partyName = const Value.absent(),
    this.address1 = const Value.absent(),
    this.address2 = const Value.absent(),
    this.address3 = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.pincode = const Value.absent(),
    this.pan = const Value.absent(),
    this.gstin = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartiesCompanion.insert({
    this.id = const Value.absent(),
    required String companyId,
    required String partyName,
    this.address1 = const Value.absent(),
    this.address2 = const Value.absent(),
    this.address3 = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.pincode = const Value.absent(),
    this.pan = const Value.absent(),
    this.gstin = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : companyId = Value(companyId),
       partyName = Value(partyName);
  static Insertable<Party> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? partyName,
    Expression<String>? address1,
    Expression<String>? address2,
    Expression<String>? address3,
    Expression<String>? city,
    Expression<String>? state,
    Expression<String>? pincode,
    Expression<String>? pan,
    Expression<String>? gstin,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (partyName != null) 'party_name': partyName,
      if (address1 != null) 'address1': address1,
      if (address2 != null) 'address2': address2,
      if (address3 != null) 'address3': address3,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (pan != null) 'pan': pan,
      if (gstin != null) 'gstin': gstin,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartiesCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? partyName,
    Value<String?>? address1,
    Value<String?>? address2,
    Value<String?>? address3,
    Value<String?>? city,
    Value<String?>? state,
    Value<String?>? pincode,
    Value<String?>? pan,
    Value<String?>? gstin,
    Value<String?>? phone,
    Value<String?>? email,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PartiesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      partyName: partyName ?? this.partyName,
      address1: address1 ?? this.address1,
      address2: address2 ?? this.address2,
      address3: address3 ?? this.address3,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      pan: pan ?? this.pan,
      gstin: gstin ?? this.gstin,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (partyName.present) {
      map['party_name'] = Variable<String>(partyName.value);
    }
    if (address1.present) {
      map['address1'] = Variable<String>(address1.value);
    }
    if (address2.present) {
      map['address2'] = Variable<String>(address2.value);
    }
    if (address3.present) {
      map['address3'] = Variable<String>(address3.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (pincode.present) {
      map['pincode'] = Variable<String>(pincode.value);
    }
    if (pan.present) {
      map['pan'] = Variable<String>(pan.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartiesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('partyName: $partyName, ')
          ..write('address1: $address1, ')
          ..write('address2: $address2, ')
          ..write('address3: $address3, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('pincode: $pincode, ')
          ..write('pan: $pan, ')
          ..write('gstin: $gstin, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VendorCodesTable extends VendorCodes
    with TableInfo<$VendorCodesTable, VendorCode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VendorCodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _vendorCodeMeta = const VerificationMeta(
    'vendorCode',
  );
  @override
  late final GeneratedColumn<String> vendorCode = GeneratedColumn<String>(
    'vendor_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    vendorCode,
    description,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vendor_codes';
  @override
  VerificationContext validateIntegrity(
    Insertable<VendorCode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('vendor_code')) {
      context.handle(
        _vendorCodeMeta,
        vendorCode.isAcceptableOrUnknown(data['vendor_code']!, _vendorCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_vendorCodeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {companyId, vendorCode},
  ];
  @override
  VendorCode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VendorCode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      vendorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vendor_code'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VendorCodesTable createAlias(String alias) {
    return $VendorCodesTable(attachedDatabase, alias);
  }
}

class VendorCode extends DataClass implements Insertable<VendorCode> {
  final String id;
  final String companyId;
  final String vendorCode;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  const VendorCode({
    required this.id,
    required this.companyId,
    required this.vendorCode,
    this.description,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['vendor_code'] = Variable<String>(vendorCode);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VendorCodesCompanion toCompanion(bool nullToAbsent) {
    return VendorCodesCompanion(
      id: Value(id),
      companyId: Value(companyId),
      vendorCode: Value(vendorCode),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory VendorCode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VendorCode(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      vendorCode: serializer.fromJson<String>(json['vendorCode']),
      description: serializer.fromJson<String?>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'vendorCode': serializer.toJson<String>(vendorCode),
      'description': serializer.toJson<String?>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VendorCode copyWith({
    String? id,
    String? companyId,
    String? vendorCode,
    Value<String?> description = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => VendorCode(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    vendorCode: vendorCode ?? this.vendorCode,
    description: description.present ? description.value : this.description,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  VendorCode copyWithCompanion(VendorCodesCompanion data) {
    return VendorCode(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      vendorCode: data.vendorCode.present
          ? data.vendorCode.value
          : this.vendorCode,
      description: data.description.present
          ? data.description.value
          : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VendorCode(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('vendorCode: $vendorCode, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, companyId, vendorCode, description, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VendorCode &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.vendorCode == this.vendorCode &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class VendorCodesCompanion extends UpdateCompanion<VendorCode> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> vendorCode;
  final Value<String?> description;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VendorCodesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.vendorCode = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VendorCodesCompanion.insert({
    this.id = const Value.absent(),
    required String companyId,
    required String vendorCode,
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : companyId = Value(companyId),
       vendorCode = Value(vendorCode);
  static Insertable<VendorCode> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? vendorCode,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (vendorCode != null) 'vendor_code': vendorCode,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VendorCodesCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? vendorCode,
    Value<String?>? description,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VendorCodesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      vendorCode: vendorCode ?? this.vendorCode,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (vendorCode.present) {
      map['vendor_code'] = Variable<String>(vendorCode.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VendorCodesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('vendorCode: $vendorCode, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SitesTable extends Sites with TableInfo<$SitesTable, Site> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _siteNameMeta = const VerificationMeta(
    'siteName',
  );
  @override
  late final GeneratedColumn<String> siteName = GeneratedColumn<String>(
    'site_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _siteCodeMeta = const VerificationMeta(
    'siteCode',
  );
  @override
  late final GeneratedColumn<String> siteCode = GeneratedColumn<String>(
    'site_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    siteName,
    siteCode,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sites';
  @override
  VerificationContext validateIntegrity(
    Insertable<Site> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('site_name')) {
      context.handle(
        _siteNameMeta,
        siteName.isAcceptableOrUnknown(data['site_name']!, _siteNameMeta),
      );
    } else if (isInserting) {
      context.missing(_siteNameMeta);
    }
    if (data.containsKey('site_code')) {
      context.handle(
        _siteCodeMeta,
        siteCode.isAcceptableOrUnknown(data['site_code']!, _siteCodeMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Site map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Site(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      siteName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_name'],
      )!,
      siteCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_code'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SitesTable createAlias(String alias) {
    return $SitesTable(attachedDatabase, alias);
  }
}

class Site extends DataClass implements Insertable<Site> {
  final String id;
  final String companyId;
  final String siteName;
  final String? siteCode;
  final bool isActive;
  final DateTime createdAt;
  const Site({
    required this.id,
    required this.companyId,
    required this.siteName,
    this.siteCode,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['site_name'] = Variable<String>(siteName);
    if (!nullToAbsent || siteCode != null) {
      map['site_code'] = Variable<String>(siteCode);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SitesCompanion toCompanion(bool nullToAbsent) {
    return SitesCompanion(
      id: Value(id),
      companyId: Value(companyId),
      siteName: Value(siteName),
      siteCode: siteCode == null && nullToAbsent
          ? const Value.absent()
          : Value(siteCode),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Site.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Site(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      siteName: serializer.fromJson<String>(json['siteName']),
      siteCode: serializer.fromJson<String?>(json['siteCode']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'siteName': serializer.toJson<String>(siteName),
      'siteCode': serializer.toJson<String?>(siteCode),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Site copyWith({
    String? id,
    String? companyId,
    String? siteName,
    Value<String?> siteCode = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => Site(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    siteName: siteName ?? this.siteName,
    siteCode: siteCode.present ? siteCode.value : this.siteCode,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Site copyWithCompanion(SitesCompanion data) {
    return Site(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      siteName: data.siteName.present ? data.siteName.value : this.siteName,
      siteCode: data.siteCode.present ? data.siteCode.value : this.siteCode,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Site(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('siteName: $siteName, ')
          ..write('siteCode: $siteCode, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, companyId, siteName, siteCode, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Site &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.siteName == this.siteName &&
          other.siteCode == this.siteCode &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class SitesCompanion extends UpdateCompanion<Site> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> siteName;
  final Value<String?> siteCode;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SitesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.siteName = const Value.absent(),
    this.siteCode = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SitesCompanion.insert({
    this.id = const Value.absent(),
    required String companyId,
    required String siteName,
    this.siteCode = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : companyId = Value(companyId),
       siteName = Value(siteName);
  static Insertable<Site> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? siteName,
    Expression<String>? siteCode,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (siteName != null) 'site_name': siteName,
      if (siteCode != null) 'site_code': siteCode,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SitesCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? siteName,
    Value<String?>? siteCode,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SitesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      siteName: siteName ?? this.siteName,
      siteCode: siteCode ?? this.siteCode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (siteName.present) {
      map['site_name'] = Variable<String>(siteName.value);
    }
    if (siteCode.present) {
      map['site_code'] = Variable<String>(siteCode.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SitesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('siteName: $siteName, ')
          ..write('siteCode: $siteCode, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnitsTable extends Units with TableInfo<$UnitsTable, Unit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitCodeMeta = const VerificationMeta(
    'unitCode',
  );
  @override
  late final GeneratedColumn<String> unitCode = GeneratedColumn<String>(
    'unit_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitNameMeta = const VerificationMeta(
    'unitName',
  );
  @override
  late final GeneratedColumn<String> unitName = GeneratedColumn<String>(
    'unit_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    unitCode,
    unitName,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'units';
  @override
  VerificationContext validateIntegrity(
    Insertable<Unit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    }
    if (data.containsKey('unit_code')) {
      context.handle(
        _unitCodeMeta,
        unitCode.isAcceptableOrUnknown(data['unit_code']!, _unitCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_unitCodeMeta);
    }
    if (data.containsKey('unit_name')) {
      context.handle(
        _unitNameMeta,
        unitName.isAcceptableOrUnknown(data['unit_name']!, _unitNameMeta),
      );
    } else if (isInserting) {
      context.missing(_unitNameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Unit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Unit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      ),
      unitCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_code'],
      )!,
      unitName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_name'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UnitsTable createAlias(String alias) {
    return $UnitsTable(attachedDatabase, alias);
  }
}

class Unit extends DataClass implements Insertable<Unit> {
  final String id;
  final String? companyId;
  final String unitCode;
  final String unitName;
  final bool isActive;
  final DateTime createdAt;
  const Unit({
    required this.id,
    this.companyId,
    required this.unitCode,
    required this.unitName,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || companyId != null) {
      map['company_id'] = Variable<String>(companyId);
    }
    map['unit_code'] = Variable<String>(unitCode);
    map['unit_name'] = Variable<String>(unitName);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UnitsCompanion toCompanion(bool nullToAbsent) {
    return UnitsCompanion(
      id: Value(id),
      companyId: companyId == null && nullToAbsent
          ? const Value.absent()
          : Value(companyId),
      unitCode: Value(unitCode),
      unitName: Value(unitName),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Unit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Unit(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String?>(json['companyId']),
      unitCode: serializer.fromJson<String>(json['unitCode']),
      unitName: serializer.fromJson<String>(json['unitName']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String?>(companyId),
      'unitCode': serializer.toJson<String>(unitCode),
      'unitName': serializer.toJson<String>(unitName),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Unit copyWith({
    String? id,
    Value<String?> companyId = const Value.absent(),
    String? unitCode,
    String? unitName,
    bool? isActive,
    DateTime? createdAt,
  }) => Unit(
    id: id ?? this.id,
    companyId: companyId.present ? companyId.value : this.companyId,
    unitCode: unitCode ?? this.unitCode,
    unitName: unitName ?? this.unitName,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Unit copyWithCompanion(UnitsCompanion data) {
    return Unit(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      unitCode: data.unitCode.present ? data.unitCode.value : this.unitCode,
      unitName: data.unitName.present ? data.unitName.value : this.unitName,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Unit(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('unitCode: $unitCode, ')
          ..write('unitName: $unitName, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, companyId, unitCode, unitName, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Unit &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.unitCode == this.unitCode &&
          other.unitName == this.unitName &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class UnitsCompanion extends UpdateCompanion<Unit> {
  final Value<String> id;
  final Value<String?> companyId;
  final Value<String> unitCode;
  final Value<String> unitName;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UnitsCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.unitCode = const Value.absent(),
    this.unitName = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnitsCompanion.insert({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    required String unitCode,
    required String unitName,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : unitCode = Value(unitCode),
       unitName = Value(unitName);
  static Insertable<Unit> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? unitCode,
    Expression<String>? unitName,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (unitCode != null) 'unit_code': unitCode,
      if (unitName != null) 'unit_name': unitName,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnitsCompanion copyWith({
    Value<String>? id,
    Value<String?>? companyId,
    Value<String>? unitCode,
    Value<String>? unitName,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UnitsCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      unitCode: unitCode ?? this.unitCode,
      unitName: unitName ?? this.unitName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (unitCode.present) {
      map['unit_code'] = Variable<String>(unitCode.value);
    }
    if (unitName.present) {
      map['unit_name'] = Variable<String>(unitName.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitsCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('unitCode: $unitCode, ')
          ..write('unitName: $unitName, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaxRatesTable extends TaxRates with TableInfo<$TaxRatesTable, TaxRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaxRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxNameMeta = const VerificationMeta(
    'taxName',
  );
  @override
  late final GeneratedColumn<String> taxName = GeneratedColumn<String>(
    'tax_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _percentageMeta = const VerificationMeta(
    'percentage',
  );
  @override
  late final GeneratedColumn<double> percentage = GeneratedColumn<double>(
    'percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    taxName,
    percentage,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tax_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaxRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    }
    if (data.containsKey('tax_name')) {
      context.handle(
        _taxNameMeta,
        taxName.isAcceptableOrUnknown(data['tax_name']!, _taxNameMeta),
      );
    } else if (isInserting) {
      context.missing(_taxNameMeta);
    }
    if (data.containsKey('percentage')) {
      context.handle(
        _percentageMeta,
        percentage.isAcceptableOrUnknown(data['percentage']!, _percentageMeta),
      );
    } else if (isInserting) {
      context.missing(_percentageMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaxRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaxRate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      ),
      taxName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_name'],
      )!,
      percentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}percentage'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TaxRatesTable createAlias(String alias) {
    return $TaxRatesTable(attachedDatabase, alias);
  }
}

class TaxRate extends DataClass implements Insertable<TaxRate> {
  final String id;
  final String? companyId;
  final String taxName;
  final double percentage;
  final bool isActive;
  final DateTime createdAt;
  const TaxRate({
    required this.id,
    this.companyId,
    required this.taxName,
    required this.percentage,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || companyId != null) {
      map['company_id'] = Variable<String>(companyId);
    }
    map['tax_name'] = Variable<String>(taxName);
    map['percentage'] = Variable<double>(percentage);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TaxRatesCompanion toCompanion(bool nullToAbsent) {
    return TaxRatesCompanion(
      id: Value(id),
      companyId: companyId == null && nullToAbsent
          ? const Value.absent()
          : Value(companyId),
      taxName: Value(taxName),
      percentage: Value(percentage),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory TaxRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaxRate(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String?>(json['companyId']),
      taxName: serializer.fromJson<String>(json['taxName']),
      percentage: serializer.fromJson<double>(json['percentage']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String?>(companyId),
      'taxName': serializer.toJson<String>(taxName),
      'percentage': serializer.toJson<double>(percentage),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TaxRate copyWith({
    String? id,
    Value<String?> companyId = const Value.absent(),
    String? taxName,
    double? percentage,
    bool? isActive,
    DateTime? createdAt,
  }) => TaxRate(
    id: id ?? this.id,
    companyId: companyId.present ? companyId.value : this.companyId,
    taxName: taxName ?? this.taxName,
    percentage: percentage ?? this.percentage,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  TaxRate copyWithCompanion(TaxRatesCompanion data) {
    return TaxRate(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      taxName: data.taxName.present ? data.taxName.value : this.taxName,
      percentage: data.percentage.present
          ? data.percentage.value
          : this.percentage,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaxRate(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('taxName: $taxName, ')
          ..write('percentage: $percentage, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, companyId, taxName, percentage, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaxRate &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.taxName == this.taxName &&
          other.percentage == this.percentage &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class TaxRatesCompanion extends UpdateCompanion<TaxRate> {
  final Value<String> id;
  final Value<String?> companyId;
  final Value<String> taxName;
  final Value<double> percentage;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TaxRatesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.taxName = const Value.absent(),
    this.percentage = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaxRatesCompanion.insert({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    required String taxName,
    required double percentage,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : taxName = Value(taxName),
       percentage = Value(percentage);
  static Insertable<TaxRate> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? taxName,
    Expression<double>? percentage,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (taxName != null) 'tax_name': taxName,
      if (percentage != null) 'percentage': percentage,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaxRatesCompanion copyWith({
    Value<String>? id,
    Value<String?>? companyId,
    Value<String>? taxName,
    Value<double>? percentage,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TaxRatesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      taxName: taxName ?? this.taxName,
      percentage: percentage ?? this.percentage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (taxName.present) {
      map['tax_name'] = Variable<String>(taxName.value);
    }
    if (percentage.present) {
      map['percentage'] = Variable<double>(percentage.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaxRatesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('taxName: $taxName, ')
          ..write('percentage: $percentage, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _partyIdMeta = const VerificationMeta(
    'partyId',
  );
  @override
  late final GeneratedColumn<String> partyId = GeneratedColumn<String>(
    'party_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES parties (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta(
    'invoiceNumber',
  );
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceDateMeta = const VerificationMeta(
    'invoiceDate',
  );
  @override
  late final GeneratedColumn<DateTime> invoiceDate = GeneratedColumn<DateTime>(
    'invoice_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _poNumberMeta = const VerificationMeta(
    'poNumber',
  );
  @override
  late final GeneratedColumn<String> poNumber = GeneratedColumn<String>(
    'po_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vendorCodeIdMeta = const VerificationMeta(
    'vendorCodeId',
  );
  @override
  late final GeneratedColumn<String> vendorCodeId = GeneratedColumn<String>(
    'vendor_code_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vendor_codes (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sites (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _serviceEntryMeta = const VerificationMeta(
    'serviceEntry',
  );
  @override
  late final GeneratedColumn<String> serviceEntry = GeneratedColumn<String>(
    'service_entry',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serviceFromMeta = const VerificationMeta(
    'serviceFrom',
  );
  @override
  late final GeneratedColumn<DateTime> serviceFrom = GeneratedColumn<DateTime>(
    'service_from',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serviceToMeta = const VerificationMeta(
    'serviceTo',
  );
  @override
  late final GeneratedColumn<DateTime> serviceTo = GeneratedColumn<DateTime>(
    'service_to',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyNameSnapshotMeta =
      const VerificationMeta('companyNameSnapshot');
  @override
  late final GeneratedColumn<String> companyNameSnapshot =
      GeneratedColumn<String>(
        'company_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _companyAddress1SnapshotMeta =
      const VerificationMeta('companyAddress1Snapshot');
  @override
  late final GeneratedColumn<String> companyAddress1Snapshot =
      GeneratedColumn<String>(
        'company_address1_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _companyAddress2SnapshotMeta =
      const VerificationMeta('companyAddress2Snapshot');
  @override
  late final GeneratedColumn<String> companyAddress2Snapshot =
      GeneratedColumn<String>(
        'company_address2_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _companyAddress3SnapshotMeta =
      const VerificationMeta('companyAddress3Snapshot');
  @override
  late final GeneratedColumn<String> companyAddress3Snapshot =
      GeneratedColumn<String>(
        'company_address3_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _companyPanSnapshotMeta =
      const VerificationMeta('companyPanSnapshot');
  @override
  late final GeneratedColumn<String> companyPanSnapshot =
      GeneratedColumn<String>(
        'company_pan_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _companyGstinSnapshotMeta =
      const VerificationMeta('companyGstinSnapshot');
  @override
  late final GeneratedColumn<String> companyGstinSnapshot =
      GeneratedColumn<String>(
        'company_gstin_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _partyNameSnapshotMeta = const VerificationMeta(
    'partyNameSnapshot',
  );
  @override
  late final GeneratedColumn<String> partyNameSnapshot =
      GeneratedColumn<String>(
        'party_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _partyAddress1SnapshotMeta =
      const VerificationMeta('partyAddress1Snapshot');
  @override
  late final GeneratedColumn<String> partyAddress1Snapshot =
      GeneratedColumn<String>(
        'party_address1_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _partyAddress2SnapshotMeta =
      const VerificationMeta('partyAddress2Snapshot');
  @override
  late final GeneratedColumn<String> partyAddress2Snapshot =
      GeneratedColumn<String>(
        'party_address2_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _partyAddress3SnapshotMeta =
      const VerificationMeta('partyAddress3Snapshot');
  @override
  late final GeneratedColumn<String> partyAddress3Snapshot =
      GeneratedColumn<String>(
        'party_address3_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _partyPanSnapshotMeta = const VerificationMeta(
    'partyPanSnapshot',
  );
  @override
  late final GeneratedColumn<String> partyPanSnapshot = GeneratedColumn<String>(
    'party_pan_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partyGstinSnapshotMeta =
      const VerificationMeta('partyGstinSnapshot');
  @override
  late final GeneratedColumn<String> partyGstinSnapshot =
      GeneratedColumn<String>(
        'party_gstin_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _vendorCodeSnapshotMeta =
      const VerificationMeta('vendorCodeSnapshot');
  @override
  late final GeneratedColumn<String> vendorCodeSnapshot =
      GeneratedColumn<String>(
        'vendor_code_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _siteNameSnapshotMeta = const VerificationMeta(
    'siteNameSnapshot',
  );
  @override
  late final GeneratedColumn<String> siteNameSnapshot = GeneratedColumn<String>(
    'site_name_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxTypeMeta = const VerificationMeta(
    'taxType',
  );
  @override
  late final GeneratedColumn<String> taxType = GeneratedColumn<String>(
    'tax_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('taxable'),
  );
  static const VerificationMeta _gstModeMeta = const VerificationMeta(
    'gstMode',
  );
  @override
  late final GeneratedColumn<String> gstMode = GeneratedColumn<String>(
    'gst_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cgstSgst'),
  );
  static const VerificationMeta _basicAmountPaiseMeta = const VerificationMeta(
    'basicAmountPaise',
  );
  @override
  late final GeneratedColumn<int> basicAmountPaise = GeneratedColumn<int>(
    'basic_amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _taxableAmountPaiseMeta =
      const VerificationMeta('taxableAmountPaise');
  @override
  late final GeneratedColumn<int> taxableAmountPaise = GeneratedColumn<int>(
    'taxable_amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cgstRateMeta = const VerificationMeta(
    'cgstRate',
  );
  @override
  late final GeneratedColumn<double> cgstRate = GeneratedColumn<double>(
    'cgst_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cgstAmountPaiseMeta = const VerificationMeta(
    'cgstAmountPaise',
  );
  @override
  late final GeneratedColumn<int> cgstAmountPaise = GeneratedColumn<int>(
    'cgst_amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sgstRateMeta = const VerificationMeta(
    'sgstRate',
  );
  @override
  late final GeneratedColumn<double> sgstRate = GeneratedColumn<double>(
    'sgst_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sgstAmountPaiseMeta = const VerificationMeta(
    'sgstAmountPaise',
  );
  @override
  late final GeneratedColumn<int> sgstAmountPaise = GeneratedColumn<int>(
    'sgst_amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _igstRateMeta = const VerificationMeta(
    'igstRate',
  );
  @override
  late final GeneratedColumn<double> igstRate = GeneratedColumn<double>(
    'igst_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _igstAmountPaiseMeta = const VerificationMeta(
    'igstAmountPaise',
  );
  @override
  late final GeneratedColumn<int> igstAmountPaise = GeneratedColumn<int>(
    'igst_amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _grandTotalPaiseMeta = const VerificationMeta(
    'grandTotalPaise',
  );
  @override
  late final GeneratedColumn<int> grandTotalPaise = GeneratedColumn<int>(
    'grand_total_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _amountInWordsMeta = const VerificationMeta(
    'amountInWords',
  );
  @override
  late final GeneratedColumn<String> amountInWords = GeneratedColumn<String>(
    'amount_in_words',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    partyId,
    invoiceNumber,
    invoiceDate,
    poNumber,
    vendorCodeId,
    siteId,
    serviceEntry,
    serviceFrom,
    serviceTo,
    companyNameSnapshot,
    companyAddress1Snapshot,
    companyAddress2Snapshot,
    companyAddress3Snapshot,
    companyPanSnapshot,
    companyGstinSnapshot,
    partyNameSnapshot,
    partyAddress1Snapshot,
    partyAddress2Snapshot,
    partyAddress3Snapshot,
    partyPanSnapshot,
    partyGstinSnapshot,
    vendorCodeSnapshot,
    siteNameSnapshot,
    taxType,
    gstMode,
    basicAmountPaise,
    taxableAmountPaise,
    cgstRate,
    cgstAmountPaise,
    sgstRate,
    sgstAmountPaise,
    igstRate,
    igstAmountPaise,
    grandTotalPaise,
    amountInWords,
    status,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Invoice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('party_id')) {
      context.handle(
        _partyIdMeta,
        partyId.isAcceptableOrUnknown(data['party_id']!, _partyIdMeta),
      );
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(
          data['invoice_number']!,
          _invoiceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('invoice_date')) {
      context.handle(
        _invoiceDateMeta,
        invoiceDate.isAcceptableOrUnknown(
          data['invoice_date']!,
          _invoiceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceDateMeta);
    }
    if (data.containsKey('po_number')) {
      context.handle(
        _poNumberMeta,
        poNumber.isAcceptableOrUnknown(data['po_number']!, _poNumberMeta),
      );
    }
    if (data.containsKey('vendor_code_id')) {
      context.handle(
        _vendorCodeIdMeta,
        vendorCodeId.isAcceptableOrUnknown(
          data['vendor_code_id']!,
          _vendorCodeIdMeta,
        ),
      );
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    }
    if (data.containsKey('service_entry')) {
      context.handle(
        _serviceEntryMeta,
        serviceEntry.isAcceptableOrUnknown(
          data['service_entry']!,
          _serviceEntryMeta,
        ),
      );
    }
    if (data.containsKey('service_from')) {
      context.handle(
        _serviceFromMeta,
        serviceFrom.isAcceptableOrUnknown(
          data['service_from']!,
          _serviceFromMeta,
        ),
      );
    }
    if (data.containsKey('service_to')) {
      context.handle(
        _serviceToMeta,
        serviceTo.isAcceptableOrUnknown(data['service_to']!, _serviceToMeta),
      );
    }
    if (data.containsKey('company_name_snapshot')) {
      context.handle(
        _companyNameSnapshotMeta,
        companyNameSnapshot.isAcceptableOrUnknown(
          data['company_name_snapshot']!,
          _companyNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_companyNameSnapshotMeta);
    }
    if (data.containsKey('company_address1_snapshot')) {
      context.handle(
        _companyAddress1SnapshotMeta,
        companyAddress1Snapshot.isAcceptableOrUnknown(
          data['company_address1_snapshot']!,
          _companyAddress1SnapshotMeta,
        ),
      );
    }
    if (data.containsKey('company_address2_snapshot')) {
      context.handle(
        _companyAddress2SnapshotMeta,
        companyAddress2Snapshot.isAcceptableOrUnknown(
          data['company_address2_snapshot']!,
          _companyAddress2SnapshotMeta,
        ),
      );
    }
    if (data.containsKey('company_address3_snapshot')) {
      context.handle(
        _companyAddress3SnapshotMeta,
        companyAddress3Snapshot.isAcceptableOrUnknown(
          data['company_address3_snapshot']!,
          _companyAddress3SnapshotMeta,
        ),
      );
    }
    if (data.containsKey('company_pan_snapshot')) {
      context.handle(
        _companyPanSnapshotMeta,
        companyPanSnapshot.isAcceptableOrUnknown(
          data['company_pan_snapshot']!,
          _companyPanSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('company_gstin_snapshot')) {
      context.handle(
        _companyGstinSnapshotMeta,
        companyGstinSnapshot.isAcceptableOrUnknown(
          data['company_gstin_snapshot']!,
          _companyGstinSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('party_name_snapshot')) {
      context.handle(
        _partyNameSnapshotMeta,
        partyNameSnapshot.isAcceptableOrUnknown(
          data['party_name_snapshot']!,
          _partyNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partyNameSnapshotMeta);
    }
    if (data.containsKey('party_address1_snapshot')) {
      context.handle(
        _partyAddress1SnapshotMeta,
        partyAddress1Snapshot.isAcceptableOrUnknown(
          data['party_address1_snapshot']!,
          _partyAddress1SnapshotMeta,
        ),
      );
    }
    if (data.containsKey('party_address2_snapshot')) {
      context.handle(
        _partyAddress2SnapshotMeta,
        partyAddress2Snapshot.isAcceptableOrUnknown(
          data['party_address2_snapshot']!,
          _partyAddress2SnapshotMeta,
        ),
      );
    }
    if (data.containsKey('party_address3_snapshot')) {
      context.handle(
        _partyAddress3SnapshotMeta,
        partyAddress3Snapshot.isAcceptableOrUnknown(
          data['party_address3_snapshot']!,
          _partyAddress3SnapshotMeta,
        ),
      );
    }
    if (data.containsKey('party_pan_snapshot')) {
      context.handle(
        _partyPanSnapshotMeta,
        partyPanSnapshot.isAcceptableOrUnknown(
          data['party_pan_snapshot']!,
          _partyPanSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('party_gstin_snapshot')) {
      context.handle(
        _partyGstinSnapshotMeta,
        partyGstinSnapshot.isAcceptableOrUnknown(
          data['party_gstin_snapshot']!,
          _partyGstinSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('vendor_code_snapshot')) {
      context.handle(
        _vendorCodeSnapshotMeta,
        vendorCodeSnapshot.isAcceptableOrUnknown(
          data['vendor_code_snapshot']!,
          _vendorCodeSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('site_name_snapshot')) {
      context.handle(
        _siteNameSnapshotMeta,
        siteNameSnapshot.isAcceptableOrUnknown(
          data['site_name_snapshot']!,
          _siteNameSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('tax_type')) {
      context.handle(
        _taxTypeMeta,
        taxType.isAcceptableOrUnknown(data['tax_type']!, _taxTypeMeta),
      );
    }
    if (data.containsKey('gst_mode')) {
      context.handle(
        _gstModeMeta,
        gstMode.isAcceptableOrUnknown(data['gst_mode']!, _gstModeMeta),
      );
    }
    if (data.containsKey('basic_amount_paise')) {
      context.handle(
        _basicAmountPaiseMeta,
        basicAmountPaise.isAcceptableOrUnknown(
          data['basic_amount_paise']!,
          _basicAmountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('taxable_amount_paise')) {
      context.handle(
        _taxableAmountPaiseMeta,
        taxableAmountPaise.isAcceptableOrUnknown(
          data['taxable_amount_paise']!,
          _taxableAmountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('cgst_rate')) {
      context.handle(
        _cgstRateMeta,
        cgstRate.isAcceptableOrUnknown(data['cgst_rate']!, _cgstRateMeta),
      );
    }
    if (data.containsKey('cgst_amount_paise')) {
      context.handle(
        _cgstAmountPaiseMeta,
        cgstAmountPaise.isAcceptableOrUnknown(
          data['cgst_amount_paise']!,
          _cgstAmountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('sgst_rate')) {
      context.handle(
        _sgstRateMeta,
        sgstRate.isAcceptableOrUnknown(data['sgst_rate']!, _sgstRateMeta),
      );
    }
    if (data.containsKey('sgst_amount_paise')) {
      context.handle(
        _sgstAmountPaiseMeta,
        sgstAmountPaise.isAcceptableOrUnknown(
          data['sgst_amount_paise']!,
          _sgstAmountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('igst_rate')) {
      context.handle(
        _igstRateMeta,
        igstRate.isAcceptableOrUnknown(data['igst_rate']!, _igstRateMeta),
      );
    }
    if (data.containsKey('igst_amount_paise')) {
      context.handle(
        _igstAmountPaiseMeta,
        igstAmountPaise.isAcceptableOrUnknown(
          data['igst_amount_paise']!,
          _igstAmountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('grand_total_paise')) {
      context.handle(
        _grandTotalPaiseMeta,
        grandTotalPaise.isAcceptableOrUnknown(
          data['grand_total_paise']!,
          _grandTotalPaiseMeta,
        ),
      );
    }
    if (data.containsKey('amount_in_words')) {
      context.handle(
        _amountInWordsMeta,
        amountInWords.isAcceptableOrUnknown(
          data['amount_in_words']!,
          _amountInWordsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {companyId, invoiceNumber},
  ];
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      partyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_id'],
      ),
      invoiceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_number'],
      )!,
      invoiceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}invoice_date'],
      )!,
      poNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}po_number'],
      ),
      vendorCodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vendor_code_id'],
      ),
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      ),
      serviceEntry: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_entry'],
      ),
      serviceFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}service_from'],
      ),
      serviceTo: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}service_to'],
      ),
      companyNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_name_snapshot'],
      )!,
      companyAddress1Snapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_address1_snapshot'],
      ),
      companyAddress2Snapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_address2_snapshot'],
      ),
      companyAddress3Snapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_address3_snapshot'],
      ),
      companyPanSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_pan_snapshot'],
      ),
      companyGstinSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_gstin_snapshot'],
      ),
      partyNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_name_snapshot'],
      )!,
      partyAddress1Snapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_address1_snapshot'],
      ),
      partyAddress2Snapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_address2_snapshot'],
      ),
      partyAddress3Snapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_address3_snapshot'],
      ),
      partyPanSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_pan_snapshot'],
      ),
      partyGstinSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}party_gstin_snapshot'],
      ),
      vendorCodeSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vendor_code_snapshot'],
      ),
      siteNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_name_snapshot'],
      ),
      taxType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_type'],
      )!,
      gstMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gst_mode'],
      )!,
      basicAmountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}basic_amount_paise'],
      )!,
      taxableAmountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}taxable_amount_paise'],
      )!,
      cgstRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cgst_rate'],
      )!,
      cgstAmountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cgst_amount_paise'],
      )!,
      sgstRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sgst_rate'],
      )!,
      sgstAmountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sgst_amount_paise'],
      )!,
      igstRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}igst_rate'],
      )!,
      igstAmountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}igst_amount_paise'],
      )!,
      grandTotalPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grand_total_paise'],
      )!,
      amountInWords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_in_words'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class Invoice extends DataClass implements Insertable<Invoice> {
  final String id;
  final String companyId;
  final String? partyId;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String? poNumber;
  final String? vendorCodeId;
  final String? siteId;
  final String? serviceEntry;
  final DateTime? serviceFrom;
  final DateTime? serviceTo;
  final String companyNameSnapshot;
  final String? companyAddress1Snapshot;
  final String? companyAddress2Snapshot;
  final String? companyAddress3Snapshot;
  final String? companyPanSnapshot;
  final String? companyGstinSnapshot;
  final String partyNameSnapshot;
  final String? partyAddress1Snapshot;
  final String? partyAddress2Snapshot;
  final String? partyAddress3Snapshot;
  final String? partyPanSnapshot;
  final String? partyGstinSnapshot;
  final String? vendorCodeSnapshot;
  final String? siteNameSnapshot;
  final String taxType;
  final String gstMode;
  final int basicAmountPaise;
  final int taxableAmountPaise;
  final double cgstRate;
  final int cgstAmountPaise;
  final double sgstRate;
  final int sgstAmountPaise;
  final double igstRate;
  final int igstAmountPaise;
  final int grandTotalPaise;
  final String? amountInWords;
  final String status;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Invoice({
    required this.id,
    required this.companyId,
    this.partyId,
    required this.invoiceNumber,
    required this.invoiceDate,
    this.poNumber,
    this.vendorCodeId,
    this.siteId,
    this.serviceEntry,
    this.serviceFrom,
    this.serviceTo,
    required this.companyNameSnapshot,
    this.companyAddress1Snapshot,
    this.companyAddress2Snapshot,
    this.companyAddress3Snapshot,
    this.companyPanSnapshot,
    this.companyGstinSnapshot,
    required this.partyNameSnapshot,
    this.partyAddress1Snapshot,
    this.partyAddress2Snapshot,
    this.partyAddress3Snapshot,
    this.partyPanSnapshot,
    this.partyGstinSnapshot,
    this.vendorCodeSnapshot,
    this.siteNameSnapshot,
    required this.taxType,
    required this.gstMode,
    required this.basicAmountPaise,
    required this.taxableAmountPaise,
    required this.cgstRate,
    required this.cgstAmountPaise,
    required this.sgstRate,
    required this.sgstAmountPaise,
    required this.igstRate,
    required this.igstAmountPaise,
    required this.grandTotalPaise,
    this.amountInWords,
    required this.status,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    if (!nullToAbsent || partyId != null) {
      map['party_id'] = Variable<String>(partyId);
    }
    map['invoice_number'] = Variable<String>(invoiceNumber);
    map['invoice_date'] = Variable<DateTime>(invoiceDate);
    if (!nullToAbsent || poNumber != null) {
      map['po_number'] = Variable<String>(poNumber);
    }
    if (!nullToAbsent || vendorCodeId != null) {
      map['vendor_code_id'] = Variable<String>(vendorCodeId);
    }
    if (!nullToAbsent || siteId != null) {
      map['site_id'] = Variable<String>(siteId);
    }
    if (!nullToAbsent || serviceEntry != null) {
      map['service_entry'] = Variable<String>(serviceEntry);
    }
    if (!nullToAbsent || serviceFrom != null) {
      map['service_from'] = Variable<DateTime>(serviceFrom);
    }
    if (!nullToAbsent || serviceTo != null) {
      map['service_to'] = Variable<DateTime>(serviceTo);
    }
    map['company_name_snapshot'] = Variable<String>(companyNameSnapshot);
    if (!nullToAbsent || companyAddress1Snapshot != null) {
      map['company_address1_snapshot'] = Variable<String>(
        companyAddress1Snapshot,
      );
    }
    if (!nullToAbsent || companyAddress2Snapshot != null) {
      map['company_address2_snapshot'] = Variable<String>(
        companyAddress2Snapshot,
      );
    }
    if (!nullToAbsent || companyAddress3Snapshot != null) {
      map['company_address3_snapshot'] = Variable<String>(
        companyAddress3Snapshot,
      );
    }
    if (!nullToAbsent || companyPanSnapshot != null) {
      map['company_pan_snapshot'] = Variable<String>(companyPanSnapshot);
    }
    if (!nullToAbsent || companyGstinSnapshot != null) {
      map['company_gstin_snapshot'] = Variable<String>(companyGstinSnapshot);
    }
    map['party_name_snapshot'] = Variable<String>(partyNameSnapshot);
    if (!nullToAbsent || partyAddress1Snapshot != null) {
      map['party_address1_snapshot'] = Variable<String>(partyAddress1Snapshot);
    }
    if (!nullToAbsent || partyAddress2Snapshot != null) {
      map['party_address2_snapshot'] = Variable<String>(partyAddress2Snapshot);
    }
    if (!nullToAbsent || partyAddress3Snapshot != null) {
      map['party_address3_snapshot'] = Variable<String>(partyAddress3Snapshot);
    }
    if (!nullToAbsent || partyPanSnapshot != null) {
      map['party_pan_snapshot'] = Variable<String>(partyPanSnapshot);
    }
    if (!nullToAbsent || partyGstinSnapshot != null) {
      map['party_gstin_snapshot'] = Variable<String>(partyGstinSnapshot);
    }
    if (!nullToAbsent || vendorCodeSnapshot != null) {
      map['vendor_code_snapshot'] = Variable<String>(vendorCodeSnapshot);
    }
    if (!nullToAbsent || siteNameSnapshot != null) {
      map['site_name_snapshot'] = Variable<String>(siteNameSnapshot);
    }
    map['tax_type'] = Variable<String>(taxType);
    map['gst_mode'] = Variable<String>(gstMode);
    map['basic_amount_paise'] = Variable<int>(basicAmountPaise);
    map['taxable_amount_paise'] = Variable<int>(taxableAmountPaise);
    map['cgst_rate'] = Variable<double>(cgstRate);
    map['cgst_amount_paise'] = Variable<int>(cgstAmountPaise);
    map['sgst_rate'] = Variable<double>(sgstRate);
    map['sgst_amount_paise'] = Variable<int>(sgstAmountPaise);
    map['igst_rate'] = Variable<double>(igstRate);
    map['igst_amount_paise'] = Variable<int>(igstAmountPaise);
    map['grand_total_paise'] = Variable<int>(grandTotalPaise);
    if (!nullToAbsent || amountInWords != null) {
      map['amount_in_words'] = Variable<String>(amountInWords);
    }
    map['status'] = Variable<String>(status);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      companyId: Value(companyId),
      partyId: partyId == null && nullToAbsent
          ? const Value.absent()
          : Value(partyId),
      invoiceNumber: Value(invoiceNumber),
      invoiceDate: Value(invoiceDate),
      poNumber: poNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(poNumber),
      vendorCodeId: vendorCodeId == null && nullToAbsent
          ? const Value.absent()
          : Value(vendorCodeId),
      siteId: siteId == null && nullToAbsent
          ? const Value.absent()
          : Value(siteId),
      serviceEntry: serviceEntry == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceEntry),
      serviceFrom: serviceFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceFrom),
      serviceTo: serviceTo == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceTo),
      companyNameSnapshot: Value(companyNameSnapshot),
      companyAddress1Snapshot: companyAddress1Snapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(companyAddress1Snapshot),
      companyAddress2Snapshot: companyAddress2Snapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(companyAddress2Snapshot),
      companyAddress3Snapshot: companyAddress3Snapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(companyAddress3Snapshot),
      companyPanSnapshot: companyPanSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(companyPanSnapshot),
      companyGstinSnapshot: companyGstinSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(companyGstinSnapshot),
      partyNameSnapshot: Value(partyNameSnapshot),
      partyAddress1Snapshot: partyAddress1Snapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(partyAddress1Snapshot),
      partyAddress2Snapshot: partyAddress2Snapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(partyAddress2Snapshot),
      partyAddress3Snapshot: partyAddress3Snapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(partyAddress3Snapshot),
      partyPanSnapshot: partyPanSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(partyPanSnapshot),
      partyGstinSnapshot: partyGstinSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(partyGstinSnapshot),
      vendorCodeSnapshot: vendorCodeSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(vendorCodeSnapshot),
      siteNameSnapshot: siteNameSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(siteNameSnapshot),
      taxType: Value(taxType),
      gstMode: Value(gstMode),
      basicAmountPaise: Value(basicAmountPaise),
      taxableAmountPaise: Value(taxableAmountPaise),
      cgstRate: Value(cgstRate),
      cgstAmountPaise: Value(cgstAmountPaise),
      sgstRate: Value(sgstRate),
      sgstAmountPaise: Value(sgstAmountPaise),
      igstRate: Value(igstRate),
      igstAmountPaise: Value(igstAmountPaise),
      grandTotalPaise: Value(grandTotalPaise),
      amountInWords: amountInWords == null && nullToAbsent
          ? const Value.absent()
          : Value(amountInWords),
      status: Value(status),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Invoice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      partyId: serializer.fromJson<String?>(json['partyId']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      invoiceDate: serializer.fromJson<DateTime>(json['invoiceDate']),
      poNumber: serializer.fromJson<String?>(json['poNumber']),
      vendorCodeId: serializer.fromJson<String?>(json['vendorCodeId']),
      siteId: serializer.fromJson<String?>(json['siteId']),
      serviceEntry: serializer.fromJson<String?>(json['serviceEntry']),
      serviceFrom: serializer.fromJson<DateTime?>(json['serviceFrom']),
      serviceTo: serializer.fromJson<DateTime?>(json['serviceTo']),
      companyNameSnapshot: serializer.fromJson<String>(
        json['companyNameSnapshot'],
      ),
      companyAddress1Snapshot: serializer.fromJson<String?>(
        json['companyAddress1Snapshot'],
      ),
      companyAddress2Snapshot: serializer.fromJson<String?>(
        json['companyAddress2Snapshot'],
      ),
      companyAddress3Snapshot: serializer.fromJson<String?>(
        json['companyAddress3Snapshot'],
      ),
      companyPanSnapshot: serializer.fromJson<String?>(
        json['companyPanSnapshot'],
      ),
      companyGstinSnapshot: serializer.fromJson<String?>(
        json['companyGstinSnapshot'],
      ),
      partyNameSnapshot: serializer.fromJson<String>(json['partyNameSnapshot']),
      partyAddress1Snapshot: serializer.fromJson<String?>(
        json['partyAddress1Snapshot'],
      ),
      partyAddress2Snapshot: serializer.fromJson<String?>(
        json['partyAddress2Snapshot'],
      ),
      partyAddress3Snapshot: serializer.fromJson<String?>(
        json['partyAddress3Snapshot'],
      ),
      partyPanSnapshot: serializer.fromJson<String?>(json['partyPanSnapshot']),
      partyGstinSnapshot: serializer.fromJson<String?>(
        json['partyGstinSnapshot'],
      ),
      vendorCodeSnapshot: serializer.fromJson<String?>(
        json['vendorCodeSnapshot'],
      ),
      siteNameSnapshot: serializer.fromJson<String?>(json['siteNameSnapshot']),
      taxType: serializer.fromJson<String>(json['taxType']),
      gstMode: serializer.fromJson<String>(json['gstMode']),
      basicAmountPaise: serializer.fromJson<int>(json['basicAmountPaise']),
      taxableAmountPaise: serializer.fromJson<int>(json['taxableAmountPaise']),
      cgstRate: serializer.fromJson<double>(json['cgstRate']),
      cgstAmountPaise: serializer.fromJson<int>(json['cgstAmountPaise']),
      sgstRate: serializer.fromJson<double>(json['sgstRate']),
      sgstAmountPaise: serializer.fromJson<int>(json['sgstAmountPaise']),
      igstRate: serializer.fromJson<double>(json['igstRate']),
      igstAmountPaise: serializer.fromJson<int>(json['igstAmountPaise']),
      grandTotalPaise: serializer.fromJson<int>(json['grandTotalPaise']),
      amountInWords: serializer.fromJson<String?>(json['amountInWords']),
      status: serializer.fromJson<String>(json['status']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'partyId': serializer.toJson<String?>(partyId),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'invoiceDate': serializer.toJson<DateTime>(invoiceDate),
      'poNumber': serializer.toJson<String?>(poNumber),
      'vendorCodeId': serializer.toJson<String?>(vendorCodeId),
      'siteId': serializer.toJson<String?>(siteId),
      'serviceEntry': serializer.toJson<String?>(serviceEntry),
      'serviceFrom': serializer.toJson<DateTime?>(serviceFrom),
      'serviceTo': serializer.toJson<DateTime?>(serviceTo),
      'companyNameSnapshot': serializer.toJson<String>(companyNameSnapshot),
      'companyAddress1Snapshot': serializer.toJson<String?>(
        companyAddress1Snapshot,
      ),
      'companyAddress2Snapshot': serializer.toJson<String?>(
        companyAddress2Snapshot,
      ),
      'companyAddress3Snapshot': serializer.toJson<String?>(
        companyAddress3Snapshot,
      ),
      'companyPanSnapshot': serializer.toJson<String?>(companyPanSnapshot),
      'companyGstinSnapshot': serializer.toJson<String?>(companyGstinSnapshot),
      'partyNameSnapshot': serializer.toJson<String>(partyNameSnapshot),
      'partyAddress1Snapshot': serializer.toJson<String?>(
        partyAddress1Snapshot,
      ),
      'partyAddress2Snapshot': serializer.toJson<String?>(
        partyAddress2Snapshot,
      ),
      'partyAddress3Snapshot': serializer.toJson<String?>(
        partyAddress3Snapshot,
      ),
      'partyPanSnapshot': serializer.toJson<String?>(partyPanSnapshot),
      'partyGstinSnapshot': serializer.toJson<String?>(partyGstinSnapshot),
      'vendorCodeSnapshot': serializer.toJson<String?>(vendorCodeSnapshot),
      'siteNameSnapshot': serializer.toJson<String?>(siteNameSnapshot),
      'taxType': serializer.toJson<String>(taxType),
      'gstMode': serializer.toJson<String>(gstMode),
      'basicAmountPaise': serializer.toJson<int>(basicAmountPaise),
      'taxableAmountPaise': serializer.toJson<int>(taxableAmountPaise),
      'cgstRate': serializer.toJson<double>(cgstRate),
      'cgstAmountPaise': serializer.toJson<int>(cgstAmountPaise),
      'sgstRate': serializer.toJson<double>(sgstRate),
      'sgstAmountPaise': serializer.toJson<int>(sgstAmountPaise),
      'igstRate': serializer.toJson<double>(igstRate),
      'igstAmountPaise': serializer.toJson<int>(igstAmountPaise),
      'grandTotalPaise': serializer.toJson<int>(grandTotalPaise),
      'amountInWords': serializer.toJson<String?>(amountInWords),
      'status': serializer.toJson<String>(status),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Invoice copyWith({
    String? id,
    String? companyId,
    Value<String?> partyId = const Value.absent(),
    String? invoiceNumber,
    DateTime? invoiceDate,
    Value<String?> poNumber = const Value.absent(),
    Value<String?> vendorCodeId = const Value.absent(),
    Value<String?> siteId = const Value.absent(),
    Value<String?> serviceEntry = const Value.absent(),
    Value<DateTime?> serviceFrom = const Value.absent(),
    Value<DateTime?> serviceTo = const Value.absent(),
    String? companyNameSnapshot,
    Value<String?> companyAddress1Snapshot = const Value.absent(),
    Value<String?> companyAddress2Snapshot = const Value.absent(),
    Value<String?> companyAddress3Snapshot = const Value.absent(),
    Value<String?> companyPanSnapshot = const Value.absent(),
    Value<String?> companyGstinSnapshot = const Value.absent(),
    String? partyNameSnapshot,
    Value<String?> partyAddress1Snapshot = const Value.absent(),
    Value<String?> partyAddress2Snapshot = const Value.absent(),
    Value<String?> partyAddress3Snapshot = const Value.absent(),
    Value<String?> partyPanSnapshot = const Value.absent(),
    Value<String?> partyGstinSnapshot = const Value.absent(),
    Value<String?> vendorCodeSnapshot = const Value.absent(),
    Value<String?> siteNameSnapshot = const Value.absent(),
    String? taxType,
    String? gstMode,
    int? basicAmountPaise,
    int? taxableAmountPaise,
    double? cgstRate,
    int? cgstAmountPaise,
    double? sgstRate,
    int? sgstAmountPaise,
    double? igstRate,
    int? igstAmountPaise,
    int? grandTotalPaise,
    Value<String?> amountInWords = const Value.absent(),
    String? status,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Invoice(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    partyId: partyId.present ? partyId.value : this.partyId,
    invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    invoiceDate: invoiceDate ?? this.invoiceDate,
    poNumber: poNumber.present ? poNumber.value : this.poNumber,
    vendorCodeId: vendorCodeId.present ? vendorCodeId.value : this.vendorCodeId,
    siteId: siteId.present ? siteId.value : this.siteId,
    serviceEntry: serviceEntry.present ? serviceEntry.value : this.serviceEntry,
    serviceFrom: serviceFrom.present ? serviceFrom.value : this.serviceFrom,
    serviceTo: serviceTo.present ? serviceTo.value : this.serviceTo,
    companyNameSnapshot: companyNameSnapshot ?? this.companyNameSnapshot,
    companyAddress1Snapshot: companyAddress1Snapshot.present
        ? companyAddress1Snapshot.value
        : this.companyAddress1Snapshot,
    companyAddress2Snapshot: companyAddress2Snapshot.present
        ? companyAddress2Snapshot.value
        : this.companyAddress2Snapshot,
    companyAddress3Snapshot: companyAddress3Snapshot.present
        ? companyAddress3Snapshot.value
        : this.companyAddress3Snapshot,
    companyPanSnapshot: companyPanSnapshot.present
        ? companyPanSnapshot.value
        : this.companyPanSnapshot,
    companyGstinSnapshot: companyGstinSnapshot.present
        ? companyGstinSnapshot.value
        : this.companyGstinSnapshot,
    partyNameSnapshot: partyNameSnapshot ?? this.partyNameSnapshot,
    partyAddress1Snapshot: partyAddress1Snapshot.present
        ? partyAddress1Snapshot.value
        : this.partyAddress1Snapshot,
    partyAddress2Snapshot: partyAddress2Snapshot.present
        ? partyAddress2Snapshot.value
        : this.partyAddress2Snapshot,
    partyAddress3Snapshot: partyAddress3Snapshot.present
        ? partyAddress3Snapshot.value
        : this.partyAddress3Snapshot,
    partyPanSnapshot: partyPanSnapshot.present
        ? partyPanSnapshot.value
        : this.partyPanSnapshot,
    partyGstinSnapshot: partyGstinSnapshot.present
        ? partyGstinSnapshot.value
        : this.partyGstinSnapshot,
    vendorCodeSnapshot: vendorCodeSnapshot.present
        ? vendorCodeSnapshot.value
        : this.vendorCodeSnapshot,
    siteNameSnapshot: siteNameSnapshot.present
        ? siteNameSnapshot.value
        : this.siteNameSnapshot,
    taxType: taxType ?? this.taxType,
    gstMode: gstMode ?? this.gstMode,
    basicAmountPaise: basicAmountPaise ?? this.basicAmountPaise,
    taxableAmountPaise: taxableAmountPaise ?? this.taxableAmountPaise,
    cgstRate: cgstRate ?? this.cgstRate,
    cgstAmountPaise: cgstAmountPaise ?? this.cgstAmountPaise,
    sgstRate: sgstRate ?? this.sgstRate,
    sgstAmountPaise: sgstAmountPaise ?? this.sgstAmountPaise,
    igstRate: igstRate ?? this.igstRate,
    igstAmountPaise: igstAmountPaise ?? this.igstAmountPaise,
    grandTotalPaise: grandTotalPaise ?? this.grandTotalPaise,
    amountInWords: amountInWords.present
        ? amountInWords.value
        : this.amountInWords,
    status: status ?? this.status,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      partyId: data.partyId.present ? data.partyId.value : this.partyId,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      invoiceDate: data.invoiceDate.present
          ? data.invoiceDate.value
          : this.invoiceDate,
      poNumber: data.poNumber.present ? data.poNumber.value : this.poNumber,
      vendorCodeId: data.vendorCodeId.present
          ? data.vendorCodeId.value
          : this.vendorCodeId,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      serviceEntry: data.serviceEntry.present
          ? data.serviceEntry.value
          : this.serviceEntry,
      serviceFrom: data.serviceFrom.present
          ? data.serviceFrom.value
          : this.serviceFrom,
      serviceTo: data.serviceTo.present ? data.serviceTo.value : this.serviceTo,
      companyNameSnapshot: data.companyNameSnapshot.present
          ? data.companyNameSnapshot.value
          : this.companyNameSnapshot,
      companyAddress1Snapshot: data.companyAddress1Snapshot.present
          ? data.companyAddress1Snapshot.value
          : this.companyAddress1Snapshot,
      companyAddress2Snapshot: data.companyAddress2Snapshot.present
          ? data.companyAddress2Snapshot.value
          : this.companyAddress2Snapshot,
      companyAddress3Snapshot: data.companyAddress3Snapshot.present
          ? data.companyAddress3Snapshot.value
          : this.companyAddress3Snapshot,
      companyPanSnapshot: data.companyPanSnapshot.present
          ? data.companyPanSnapshot.value
          : this.companyPanSnapshot,
      companyGstinSnapshot: data.companyGstinSnapshot.present
          ? data.companyGstinSnapshot.value
          : this.companyGstinSnapshot,
      partyNameSnapshot: data.partyNameSnapshot.present
          ? data.partyNameSnapshot.value
          : this.partyNameSnapshot,
      partyAddress1Snapshot: data.partyAddress1Snapshot.present
          ? data.partyAddress1Snapshot.value
          : this.partyAddress1Snapshot,
      partyAddress2Snapshot: data.partyAddress2Snapshot.present
          ? data.partyAddress2Snapshot.value
          : this.partyAddress2Snapshot,
      partyAddress3Snapshot: data.partyAddress3Snapshot.present
          ? data.partyAddress3Snapshot.value
          : this.partyAddress3Snapshot,
      partyPanSnapshot: data.partyPanSnapshot.present
          ? data.partyPanSnapshot.value
          : this.partyPanSnapshot,
      partyGstinSnapshot: data.partyGstinSnapshot.present
          ? data.partyGstinSnapshot.value
          : this.partyGstinSnapshot,
      vendorCodeSnapshot: data.vendorCodeSnapshot.present
          ? data.vendorCodeSnapshot.value
          : this.vendorCodeSnapshot,
      siteNameSnapshot: data.siteNameSnapshot.present
          ? data.siteNameSnapshot.value
          : this.siteNameSnapshot,
      taxType: data.taxType.present ? data.taxType.value : this.taxType,
      gstMode: data.gstMode.present ? data.gstMode.value : this.gstMode,
      basicAmountPaise: data.basicAmountPaise.present
          ? data.basicAmountPaise.value
          : this.basicAmountPaise,
      taxableAmountPaise: data.taxableAmountPaise.present
          ? data.taxableAmountPaise.value
          : this.taxableAmountPaise,
      cgstRate: data.cgstRate.present ? data.cgstRate.value : this.cgstRate,
      cgstAmountPaise: data.cgstAmountPaise.present
          ? data.cgstAmountPaise.value
          : this.cgstAmountPaise,
      sgstRate: data.sgstRate.present ? data.sgstRate.value : this.sgstRate,
      sgstAmountPaise: data.sgstAmountPaise.present
          ? data.sgstAmountPaise.value
          : this.sgstAmountPaise,
      igstRate: data.igstRate.present ? data.igstRate.value : this.igstRate,
      igstAmountPaise: data.igstAmountPaise.present
          ? data.igstAmountPaise.value
          : this.igstAmountPaise,
      grandTotalPaise: data.grandTotalPaise.present
          ? data.grandTotalPaise.value
          : this.grandTotalPaise,
      amountInWords: data.amountInWords.present
          ? data.amountInWords.value
          : this.amountInWords,
      status: data.status.present ? data.status.value : this.status,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('partyId: $partyId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('poNumber: $poNumber, ')
          ..write('vendorCodeId: $vendorCodeId, ')
          ..write('siteId: $siteId, ')
          ..write('serviceEntry: $serviceEntry, ')
          ..write('serviceFrom: $serviceFrom, ')
          ..write('serviceTo: $serviceTo, ')
          ..write('companyNameSnapshot: $companyNameSnapshot, ')
          ..write('companyAddress1Snapshot: $companyAddress1Snapshot, ')
          ..write('companyAddress2Snapshot: $companyAddress2Snapshot, ')
          ..write('companyAddress3Snapshot: $companyAddress3Snapshot, ')
          ..write('companyPanSnapshot: $companyPanSnapshot, ')
          ..write('companyGstinSnapshot: $companyGstinSnapshot, ')
          ..write('partyNameSnapshot: $partyNameSnapshot, ')
          ..write('partyAddress1Snapshot: $partyAddress1Snapshot, ')
          ..write('partyAddress2Snapshot: $partyAddress2Snapshot, ')
          ..write('partyAddress3Snapshot: $partyAddress3Snapshot, ')
          ..write('partyPanSnapshot: $partyPanSnapshot, ')
          ..write('partyGstinSnapshot: $partyGstinSnapshot, ')
          ..write('vendorCodeSnapshot: $vendorCodeSnapshot, ')
          ..write('siteNameSnapshot: $siteNameSnapshot, ')
          ..write('taxType: $taxType, ')
          ..write('gstMode: $gstMode, ')
          ..write('basicAmountPaise: $basicAmountPaise, ')
          ..write('taxableAmountPaise: $taxableAmountPaise, ')
          ..write('cgstRate: $cgstRate, ')
          ..write('cgstAmountPaise: $cgstAmountPaise, ')
          ..write('sgstRate: $sgstRate, ')
          ..write('sgstAmountPaise: $sgstAmountPaise, ')
          ..write('igstRate: $igstRate, ')
          ..write('igstAmountPaise: $igstAmountPaise, ')
          ..write('grandTotalPaise: $grandTotalPaise, ')
          ..write('amountInWords: $amountInWords, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    companyId,
    partyId,
    invoiceNumber,
    invoiceDate,
    poNumber,
    vendorCodeId,
    siteId,
    serviceEntry,
    serviceFrom,
    serviceTo,
    companyNameSnapshot,
    companyAddress1Snapshot,
    companyAddress2Snapshot,
    companyAddress3Snapshot,
    companyPanSnapshot,
    companyGstinSnapshot,
    partyNameSnapshot,
    partyAddress1Snapshot,
    partyAddress2Snapshot,
    partyAddress3Snapshot,
    partyPanSnapshot,
    partyGstinSnapshot,
    vendorCodeSnapshot,
    siteNameSnapshot,
    taxType,
    gstMode,
    basicAmountPaise,
    taxableAmountPaise,
    cgstRate,
    cgstAmountPaise,
    sgstRate,
    sgstAmountPaise,
    igstRate,
    igstAmountPaise,
    grandTotalPaise,
    amountInWords,
    status,
    syncStatus,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.partyId == this.partyId &&
          other.invoiceNumber == this.invoiceNumber &&
          other.invoiceDate == this.invoiceDate &&
          other.poNumber == this.poNumber &&
          other.vendorCodeId == this.vendorCodeId &&
          other.siteId == this.siteId &&
          other.serviceEntry == this.serviceEntry &&
          other.serviceFrom == this.serviceFrom &&
          other.serviceTo == this.serviceTo &&
          other.companyNameSnapshot == this.companyNameSnapshot &&
          other.companyAddress1Snapshot == this.companyAddress1Snapshot &&
          other.companyAddress2Snapshot == this.companyAddress2Snapshot &&
          other.companyAddress3Snapshot == this.companyAddress3Snapshot &&
          other.companyPanSnapshot == this.companyPanSnapshot &&
          other.companyGstinSnapshot == this.companyGstinSnapshot &&
          other.partyNameSnapshot == this.partyNameSnapshot &&
          other.partyAddress1Snapshot == this.partyAddress1Snapshot &&
          other.partyAddress2Snapshot == this.partyAddress2Snapshot &&
          other.partyAddress3Snapshot == this.partyAddress3Snapshot &&
          other.partyPanSnapshot == this.partyPanSnapshot &&
          other.partyGstinSnapshot == this.partyGstinSnapshot &&
          other.vendorCodeSnapshot == this.vendorCodeSnapshot &&
          other.siteNameSnapshot == this.siteNameSnapshot &&
          other.taxType == this.taxType &&
          other.gstMode == this.gstMode &&
          other.basicAmountPaise == this.basicAmountPaise &&
          other.taxableAmountPaise == this.taxableAmountPaise &&
          other.cgstRate == this.cgstRate &&
          other.cgstAmountPaise == this.cgstAmountPaise &&
          other.sgstRate == this.sgstRate &&
          other.sgstAmountPaise == this.sgstAmountPaise &&
          other.igstRate == this.igstRate &&
          other.igstAmountPaise == this.igstAmountPaise &&
          other.grandTotalPaise == this.grandTotalPaise &&
          other.amountInWords == this.amountInWords &&
          other.status == this.status &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String?> partyId;
  final Value<String> invoiceNumber;
  final Value<DateTime> invoiceDate;
  final Value<String?> poNumber;
  final Value<String?> vendorCodeId;
  final Value<String?> siteId;
  final Value<String?> serviceEntry;
  final Value<DateTime?> serviceFrom;
  final Value<DateTime?> serviceTo;
  final Value<String> companyNameSnapshot;
  final Value<String?> companyAddress1Snapshot;
  final Value<String?> companyAddress2Snapshot;
  final Value<String?> companyAddress3Snapshot;
  final Value<String?> companyPanSnapshot;
  final Value<String?> companyGstinSnapshot;
  final Value<String> partyNameSnapshot;
  final Value<String?> partyAddress1Snapshot;
  final Value<String?> partyAddress2Snapshot;
  final Value<String?> partyAddress3Snapshot;
  final Value<String?> partyPanSnapshot;
  final Value<String?> partyGstinSnapshot;
  final Value<String?> vendorCodeSnapshot;
  final Value<String?> siteNameSnapshot;
  final Value<String> taxType;
  final Value<String> gstMode;
  final Value<int> basicAmountPaise;
  final Value<int> taxableAmountPaise;
  final Value<double> cgstRate;
  final Value<int> cgstAmountPaise;
  final Value<double> sgstRate;
  final Value<int> sgstAmountPaise;
  final Value<double> igstRate;
  final Value<int> igstAmountPaise;
  final Value<int> grandTotalPaise;
  final Value<String?> amountInWords;
  final Value<String> status;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.partyId = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.invoiceDate = const Value.absent(),
    this.poNumber = const Value.absent(),
    this.vendorCodeId = const Value.absent(),
    this.siteId = const Value.absent(),
    this.serviceEntry = const Value.absent(),
    this.serviceFrom = const Value.absent(),
    this.serviceTo = const Value.absent(),
    this.companyNameSnapshot = const Value.absent(),
    this.companyAddress1Snapshot = const Value.absent(),
    this.companyAddress2Snapshot = const Value.absent(),
    this.companyAddress3Snapshot = const Value.absent(),
    this.companyPanSnapshot = const Value.absent(),
    this.companyGstinSnapshot = const Value.absent(),
    this.partyNameSnapshot = const Value.absent(),
    this.partyAddress1Snapshot = const Value.absent(),
    this.partyAddress2Snapshot = const Value.absent(),
    this.partyAddress3Snapshot = const Value.absent(),
    this.partyPanSnapshot = const Value.absent(),
    this.partyGstinSnapshot = const Value.absent(),
    this.vendorCodeSnapshot = const Value.absent(),
    this.siteNameSnapshot = const Value.absent(),
    this.taxType = const Value.absent(),
    this.gstMode = const Value.absent(),
    this.basicAmountPaise = const Value.absent(),
    this.taxableAmountPaise = const Value.absent(),
    this.cgstRate = const Value.absent(),
    this.cgstAmountPaise = const Value.absent(),
    this.sgstRate = const Value.absent(),
    this.sgstAmountPaise = const Value.absent(),
    this.igstRate = const Value.absent(),
    this.igstAmountPaise = const Value.absent(),
    this.grandTotalPaise = const Value.absent(),
    this.amountInWords = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoicesCompanion.insert({
    this.id = const Value.absent(),
    required String companyId,
    this.partyId = const Value.absent(),
    required String invoiceNumber,
    required DateTime invoiceDate,
    this.poNumber = const Value.absent(),
    this.vendorCodeId = const Value.absent(),
    this.siteId = const Value.absent(),
    this.serviceEntry = const Value.absent(),
    this.serviceFrom = const Value.absent(),
    this.serviceTo = const Value.absent(),
    required String companyNameSnapshot,
    this.companyAddress1Snapshot = const Value.absent(),
    this.companyAddress2Snapshot = const Value.absent(),
    this.companyAddress3Snapshot = const Value.absent(),
    this.companyPanSnapshot = const Value.absent(),
    this.companyGstinSnapshot = const Value.absent(),
    required String partyNameSnapshot,
    this.partyAddress1Snapshot = const Value.absent(),
    this.partyAddress2Snapshot = const Value.absent(),
    this.partyAddress3Snapshot = const Value.absent(),
    this.partyPanSnapshot = const Value.absent(),
    this.partyGstinSnapshot = const Value.absent(),
    this.vendorCodeSnapshot = const Value.absent(),
    this.siteNameSnapshot = const Value.absent(),
    this.taxType = const Value.absent(),
    this.gstMode = const Value.absent(),
    this.basicAmountPaise = const Value.absent(),
    this.taxableAmountPaise = const Value.absent(),
    this.cgstRate = const Value.absent(),
    this.cgstAmountPaise = const Value.absent(),
    this.sgstRate = const Value.absent(),
    this.sgstAmountPaise = const Value.absent(),
    this.igstRate = const Value.absent(),
    this.igstAmountPaise = const Value.absent(),
    this.grandTotalPaise = const Value.absent(),
    this.amountInWords = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : companyId = Value(companyId),
       invoiceNumber = Value(invoiceNumber),
       invoiceDate = Value(invoiceDate),
       companyNameSnapshot = Value(companyNameSnapshot),
       partyNameSnapshot = Value(partyNameSnapshot);
  static Insertable<Invoice> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? partyId,
    Expression<String>? invoiceNumber,
    Expression<DateTime>? invoiceDate,
    Expression<String>? poNumber,
    Expression<String>? vendorCodeId,
    Expression<String>? siteId,
    Expression<String>? serviceEntry,
    Expression<DateTime>? serviceFrom,
    Expression<DateTime>? serviceTo,
    Expression<String>? companyNameSnapshot,
    Expression<String>? companyAddress1Snapshot,
    Expression<String>? companyAddress2Snapshot,
    Expression<String>? companyAddress3Snapshot,
    Expression<String>? companyPanSnapshot,
    Expression<String>? companyGstinSnapshot,
    Expression<String>? partyNameSnapshot,
    Expression<String>? partyAddress1Snapshot,
    Expression<String>? partyAddress2Snapshot,
    Expression<String>? partyAddress3Snapshot,
    Expression<String>? partyPanSnapshot,
    Expression<String>? partyGstinSnapshot,
    Expression<String>? vendorCodeSnapshot,
    Expression<String>? siteNameSnapshot,
    Expression<String>? taxType,
    Expression<String>? gstMode,
    Expression<int>? basicAmountPaise,
    Expression<int>? taxableAmountPaise,
    Expression<double>? cgstRate,
    Expression<int>? cgstAmountPaise,
    Expression<double>? sgstRate,
    Expression<int>? sgstAmountPaise,
    Expression<double>? igstRate,
    Expression<int>? igstAmountPaise,
    Expression<int>? grandTotalPaise,
    Expression<String>? amountInWords,
    Expression<String>? status,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (partyId != null) 'party_id': partyId,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (invoiceDate != null) 'invoice_date': invoiceDate,
      if (poNumber != null) 'po_number': poNumber,
      if (vendorCodeId != null) 'vendor_code_id': vendorCodeId,
      if (siteId != null) 'site_id': siteId,
      if (serviceEntry != null) 'service_entry': serviceEntry,
      if (serviceFrom != null) 'service_from': serviceFrom,
      if (serviceTo != null) 'service_to': serviceTo,
      if (companyNameSnapshot != null)
        'company_name_snapshot': companyNameSnapshot,
      if (companyAddress1Snapshot != null)
        'company_address1_snapshot': companyAddress1Snapshot,
      if (companyAddress2Snapshot != null)
        'company_address2_snapshot': companyAddress2Snapshot,
      if (companyAddress3Snapshot != null)
        'company_address3_snapshot': companyAddress3Snapshot,
      if (companyPanSnapshot != null)
        'company_pan_snapshot': companyPanSnapshot,
      if (companyGstinSnapshot != null)
        'company_gstin_snapshot': companyGstinSnapshot,
      if (partyNameSnapshot != null) 'party_name_snapshot': partyNameSnapshot,
      if (partyAddress1Snapshot != null)
        'party_address1_snapshot': partyAddress1Snapshot,
      if (partyAddress2Snapshot != null)
        'party_address2_snapshot': partyAddress2Snapshot,
      if (partyAddress3Snapshot != null)
        'party_address3_snapshot': partyAddress3Snapshot,
      if (partyPanSnapshot != null) 'party_pan_snapshot': partyPanSnapshot,
      if (partyGstinSnapshot != null)
        'party_gstin_snapshot': partyGstinSnapshot,
      if (vendorCodeSnapshot != null)
        'vendor_code_snapshot': vendorCodeSnapshot,
      if (siteNameSnapshot != null) 'site_name_snapshot': siteNameSnapshot,
      if (taxType != null) 'tax_type': taxType,
      if (gstMode != null) 'gst_mode': gstMode,
      if (basicAmountPaise != null) 'basic_amount_paise': basicAmountPaise,
      if (taxableAmountPaise != null)
        'taxable_amount_paise': taxableAmountPaise,
      if (cgstRate != null) 'cgst_rate': cgstRate,
      if (cgstAmountPaise != null) 'cgst_amount_paise': cgstAmountPaise,
      if (sgstRate != null) 'sgst_rate': sgstRate,
      if (sgstAmountPaise != null) 'sgst_amount_paise': sgstAmountPaise,
      if (igstRate != null) 'igst_rate': igstRate,
      if (igstAmountPaise != null) 'igst_amount_paise': igstAmountPaise,
      if (grandTotalPaise != null) 'grand_total_paise': grandTotalPaise,
      if (amountInWords != null) 'amount_in_words': amountInWords,
      if (status != null) 'status': status,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoicesCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String?>? partyId,
    Value<String>? invoiceNumber,
    Value<DateTime>? invoiceDate,
    Value<String?>? poNumber,
    Value<String?>? vendorCodeId,
    Value<String?>? siteId,
    Value<String?>? serviceEntry,
    Value<DateTime?>? serviceFrom,
    Value<DateTime?>? serviceTo,
    Value<String>? companyNameSnapshot,
    Value<String?>? companyAddress1Snapshot,
    Value<String?>? companyAddress2Snapshot,
    Value<String?>? companyAddress3Snapshot,
    Value<String?>? companyPanSnapshot,
    Value<String?>? companyGstinSnapshot,
    Value<String>? partyNameSnapshot,
    Value<String?>? partyAddress1Snapshot,
    Value<String?>? partyAddress2Snapshot,
    Value<String?>? partyAddress3Snapshot,
    Value<String?>? partyPanSnapshot,
    Value<String?>? partyGstinSnapshot,
    Value<String?>? vendorCodeSnapshot,
    Value<String?>? siteNameSnapshot,
    Value<String>? taxType,
    Value<String>? gstMode,
    Value<int>? basicAmountPaise,
    Value<int>? taxableAmountPaise,
    Value<double>? cgstRate,
    Value<int>? cgstAmountPaise,
    Value<double>? sgstRate,
    Value<int>? sgstAmountPaise,
    Value<double>? igstRate,
    Value<int>? igstAmountPaise,
    Value<int>? grandTotalPaise,
    Value<String?>? amountInWords,
    Value<String>? status,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return InvoicesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      partyId: partyId ?? this.partyId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      poNumber: poNumber ?? this.poNumber,
      vendorCodeId: vendorCodeId ?? this.vendorCodeId,
      siteId: siteId ?? this.siteId,
      serviceEntry: serviceEntry ?? this.serviceEntry,
      serviceFrom: serviceFrom ?? this.serviceFrom,
      serviceTo: serviceTo ?? this.serviceTo,
      companyNameSnapshot: companyNameSnapshot ?? this.companyNameSnapshot,
      companyAddress1Snapshot:
          companyAddress1Snapshot ?? this.companyAddress1Snapshot,
      companyAddress2Snapshot:
          companyAddress2Snapshot ?? this.companyAddress2Snapshot,
      companyAddress3Snapshot:
          companyAddress3Snapshot ?? this.companyAddress3Snapshot,
      companyPanSnapshot: companyPanSnapshot ?? this.companyPanSnapshot,
      companyGstinSnapshot: companyGstinSnapshot ?? this.companyGstinSnapshot,
      partyNameSnapshot: partyNameSnapshot ?? this.partyNameSnapshot,
      partyAddress1Snapshot:
          partyAddress1Snapshot ?? this.partyAddress1Snapshot,
      partyAddress2Snapshot:
          partyAddress2Snapshot ?? this.partyAddress2Snapshot,
      partyAddress3Snapshot:
          partyAddress3Snapshot ?? this.partyAddress3Snapshot,
      partyPanSnapshot: partyPanSnapshot ?? this.partyPanSnapshot,
      partyGstinSnapshot: partyGstinSnapshot ?? this.partyGstinSnapshot,
      vendorCodeSnapshot: vendorCodeSnapshot ?? this.vendorCodeSnapshot,
      siteNameSnapshot: siteNameSnapshot ?? this.siteNameSnapshot,
      taxType: taxType ?? this.taxType,
      gstMode: gstMode ?? this.gstMode,
      basicAmountPaise: basicAmountPaise ?? this.basicAmountPaise,
      taxableAmountPaise: taxableAmountPaise ?? this.taxableAmountPaise,
      cgstRate: cgstRate ?? this.cgstRate,
      cgstAmountPaise: cgstAmountPaise ?? this.cgstAmountPaise,
      sgstRate: sgstRate ?? this.sgstRate,
      sgstAmountPaise: sgstAmountPaise ?? this.sgstAmountPaise,
      igstRate: igstRate ?? this.igstRate,
      igstAmountPaise: igstAmountPaise ?? this.igstAmountPaise,
      grandTotalPaise: grandTotalPaise ?? this.grandTotalPaise,
      amountInWords: amountInWords ?? this.amountInWords,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (partyId.present) {
      map['party_id'] = Variable<String>(partyId.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (invoiceDate.present) {
      map['invoice_date'] = Variable<DateTime>(invoiceDate.value);
    }
    if (poNumber.present) {
      map['po_number'] = Variable<String>(poNumber.value);
    }
    if (vendorCodeId.present) {
      map['vendor_code_id'] = Variable<String>(vendorCodeId.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (serviceEntry.present) {
      map['service_entry'] = Variable<String>(serviceEntry.value);
    }
    if (serviceFrom.present) {
      map['service_from'] = Variable<DateTime>(serviceFrom.value);
    }
    if (serviceTo.present) {
      map['service_to'] = Variable<DateTime>(serviceTo.value);
    }
    if (companyNameSnapshot.present) {
      map['company_name_snapshot'] = Variable<String>(
        companyNameSnapshot.value,
      );
    }
    if (companyAddress1Snapshot.present) {
      map['company_address1_snapshot'] = Variable<String>(
        companyAddress1Snapshot.value,
      );
    }
    if (companyAddress2Snapshot.present) {
      map['company_address2_snapshot'] = Variable<String>(
        companyAddress2Snapshot.value,
      );
    }
    if (companyAddress3Snapshot.present) {
      map['company_address3_snapshot'] = Variable<String>(
        companyAddress3Snapshot.value,
      );
    }
    if (companyPanSnapshot.present) {
      map['company_pan_snapshot'] = Variable<String>(companyPanSnapshot.value);
    }
    if (companyGstinSnapshot.present) {
      map['company_gstin_snapshot'] = Variable<String>(
        companyGstinSnapshot.value,
      );
    }
    if (partyNameSnapshot.present) {
      map['party_name_snapshot'] = Variable<String>(partyNameSnapshot.value);
    }
    if (partyAddress1Snapshot.present) {
      map['party_address1_snapshot'] = Variable<String>(
        partyAddress1Snapshot.value,
      );
    }
    if (partyAddress2Snapshot.present) {
      map['party_address2_snapshot'] = Variable<String>(
        partyAddress2Snapshot.value,
      );
    }
    if (partyAddress3Snapshot.present) {
      map['party_address3_snapshot'] = Variable<String>(
        partyAddress3Snapshot.value,
      );
    }
    if (partyPanSnapshot.present) {
      map['party_pan_snapshot'] = Variable<String>(partyPanSnapshot.value);
    }
    if (partyGstinSnapshot.present) {
      map['party_gstin_snapshot'] = Variable<String>(partyGstinSnapshot.value);
    }
    if (vendorCodeSnapshot.present) {
      map['vendor_code_snapshot'] = Variable<String>(vendorCodeSnapshot.value);
    }
    if (siteNameSnapshot.present) {
      map['site_name_snapshot'] = Variable<String>(siteNameSnapshot.value);
    }
    if (taxType.present) {
      map['tax_type'] = Variable<String>(taxType.value);
    }
    if (gstMode.present) {
      map['gst_mode'] = Variable<String>(gstMode.value);
    }
    if (basicAmountPaise.present) {
      map['basic_amount_paise'] = Variable<int>(basicAmountPaise.value);
    }
    if (taxableAmountPaise.present) {
      map['taxable_amount_paise'] = Variable<int>(taxableAmountPaise.value);
    }
    if (cgstRate.present) {
      map['cgst_rate'] = Variable<double>(cgstRate.value);
    }
    if (cgstAmountPaise.present) {
      map['cgst_amount_paise'] = Variable<int>(cgstAmountPaise.value);
    }
    if (sgstRate.present) {
      map['sgst_rate'] = Variable<double>(sgstRate.value);
    }
    if (sgstAmountPaise.present) {
      map['sgst_amount_paise'] = Variable<int>(sgstAmountPaise.value);
    }
    if (igstRate.present) {
      map['igst_rate'] = Variable<double>(igstRate.value);
    }
    if (igstAmountPaise.present) {
      map['igst_amount_paise'] = Variable<int>(igstAmountPaise.value);
    }
    if (grandTotalPaise.present) {
      map['grand_total_paise'] = Variable<int>(grandTotalPaise.value);
    }
    if (amountInWords.present) {
      map['amount_in_words'] = Variable<String>(amountInWords.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('partyId: $partyId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('poNumber: $poNumber, ')
          ..write('vendorCodeId: $vendorCodeId, ')
          ..write('siteId: $siteId, ')
          ..write('serviceEntry: $serviceEntry, ')
          ..write('serviceFrom: $serviceFrom, ')
          ..write('serviceTo: $serviceTo, ')
          ..write('companyNameSnapshot: $companyNameSnapshot, ')
          ..write('companyAddress1Snapshot: $companyAddress1Snapshot, ')
          ..write('companyAddress2Snapshot: $companyAddress2Snapshot, ')
          ..write('companyAddress3Snapshot: $companyAddress3Snapshot, ')
          ..write('companyPanSnapshot: $companyPanSnapshot, ')
          ..write('companyGstinSnapshot: $companyGstinSnapshot, ')
          ..write('partyNameSnapshot: $partyNameSnapshot, ')
          ..write('partyAddress1Snapshot: $partyAddress1Snapshot, ')
          ..write('partyAddress2Snapshot: $partyAddress2Snapshot, ')
          ..write('partyAddress3Snapshot: $partyAddress3Snapshot, ')
          ..write('partyPanSnapshot: $partyPanSnapshot, ')
          ..write('partyGstinSnapshot: $partyGstinSnapshot, ')
          ..write('vendorCodeSnapshot: $vendorCodeSnapshot, ')
          ..write('siteNameSnapshot: $siteNameSnapshot, ')
          ..write('taxType: $taxType, ')
          ..write('gstMode: $gstMode, ')
          ..write('basicAmountPaise: $basicAmountPaise, ')
          ..write('taxableAmountPaise: $taxableAmountPaise, ')
          ..write('cgstRate: $cgstRate, ')
          ..write('cgstAmountPaise: $cgstAmountPaise, ')
          ..write('sgstRate: $sgstRate, ')
          ..write('sgstAmountPaise: $sgstAmountPaise, ')
          ..write('igstRate: $igstRate, ')
          ..write('igstAmountPaise: $igstAmountPaise, ')
          ..write('grandTotalPaise: $grandTotalPaise, ')
          ..write('amountInWords: $amountInWords, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvoiceItemsTable extends InvoiceItems
    with TableInfo<$InvoiceItemsTable, InvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<String> invoiceId = GeneratedColumn<String>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES invoices (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _serialNoMeta = const VerificationMeta(
    'serialNo',
  );
  @override
  late final GeneratedColumn<int> serialNo = GeneratedColumn<int>(
    'serial_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hsnSacMeta = const VerificationMeta('hsnSac');
  @override
  late final GeneratedColumn<String> hsnSac = GeneratedColumn<String>(
    'hsn_sac',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES units (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _unitCodeSnapshotMeta = const VerificationMeta(
    'unitCodeSnapshot',
  );
  @override
  late final GeneratedColumn<String> unitCodeSnapshot = GeneratedColumn<String>(
    'unit_code_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratePaiseMeta = const VerificationMeta(
    'ratePaise',
  );
  @override
  late final GeneratedColumn<int> ratePaise = GeneratedColumn<int>(
    'rate_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _amountPaiseMeta = const VerificationMeta(
    'amountPaise',
  );
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
    'amount_paise',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceId,
    serialNo,
    description,
    hsnSac,
    quantity,
    unitId,
    unitCodeSnapshot,
    ratePaise,
    amountPaise,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('serial_no')) {
      context.handle(
        _serialNoMeta,
        serialNo.isAcceptableOrUnknown(data['serial_no']!, _serialNoMeta),
      );
    } else if (isInserting) {
      context.missing(_serialNoMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('hsn_sac')) {
      context.handle(
        _hsnSacMeta,
        hsnSac.isAcceptableOrUnknown(data['hsn_sac']!, _hsnSacMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit_id')) {
      context.handle(
        _unitIdMeta,
        unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta),
      );
    }
    if (data.containsKey('unit_code_snapshot')) {
      context.handle(
        _unitCodeSnapshotMeta,
        unitCodeSnapshot.isAcceptableOrUnknown(
          data['unit_code_snapshot']!,
          _unitCodeSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('rate_paise')) {
      context.handle(
        _ratePaiseMeta,
        ratePaise.isAcceptableOrUnknown(data['rate_paise']!, _ratePaiseMeta),
      );
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
        _amountPaiseMeta,
        amountPaise.isAcceptableOrUnknown(
          data['amount_paise']!,
          _amountPaiseMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_id'],
      )!,
      serialNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}serial_no'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      hsnSac: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hsn_sac'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      ),
      unitCodeSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_code_snapshot'],
      ),
      ratePaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rate_paise'],
      )!,
      amountPaise: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_paise'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InvoiceItemsTable createAlias(String alias) {
    return $InvoiceItemsTable(attachedDatabase, alias);
  }
}

class InvoiceItem extends DataClass implements Insertable<InvoiceItem> {
  final String id;
  final String invoiceId;
  final int serialNo;
  final String description;
  final String? hsnSac;
  final double quantity;
  final String? unitId;
  final String? unitCodeSnapshot;
  final int ratePaise;
  final int amountPaise;
  final DateTime createdAt;
  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.serialNo,
    required this.description,
    this.hsnSac,
    required this.quantity,
    this.unitId,
    this.unitCodeSnapshot,
    required this.ratePaise,
    required this.amountPaise,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['invoice_id'] = Variable<String>(invoiceId);
    map['serial_no'] = Variable<int>(serialNo);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || hsnSac != null) {
      map['hsn_sac'] = Variable<String>(hsnSac);
    }
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || unitId != null) {
      map['unit_id'] = Variable<String>(unitId);
    }
    if (!nullToAbsent || unitCodeSnapshot != null) {
      map['unit_code_snapshot'] = Variable<String>(unitCodeSnapshot);
    }
    map['rate_paise'] = Variable<int>(ratePaise);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceItemsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      serialNo: Value(serialNo),
      description: Value(description),
      hsnSac: hsnSac == null && nullToAbsent
          ? const Value.absent()
          : Value(hsnSac),
      quantity: Value(quantity),
      unitId: unitId == null && nullToAbsent
          ? const Value.absent()
          : Value(unitId),
      unitCodeSnapshot: unitCodeSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(unitCodeSnapshot),
      ratePaise: Value(ratePaise),
      amountPaise: Value(amountPaise),
      createdAt: Value(createdAt),
    );
  }

  factory InvoiceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceItem(
      id: serializer.fromJson<String>(json['id']),
      invoiceId: serializer.fromJson<String>(json['invoiceId']),
      serialNo: serializer.fromJson<int>(json['serialNo']),
      description: serializer.fromJson<String>(json['description']),
      hsnSac: serializer.fromJson<String?>(json['hsnSac']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitId: serializer.fromJson<String?>(json['unitId']),
      unitCodeSnapshot: serializer.fromJson<String?>(json['unitCodeSnapshot']),
      ratePaise: serializer.fromJson<int>(json['ratePaise']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'invoiceId': serializer.toJson<String>(invoiceId),
      'serialNo': serializer.toJson<int>(serialNo),
      'description': serializer.toJson<String>(description),
      'hsnSac': serializer.toJson<String?>(hsnSac),
      'quantity': serializer.toJson<double>(quantity),
      'unitId': serializer.toJson<String?>(unitId),
      'unitCodeSnapshot': serializer.toJson<String?>(unitCodeSnapshot),
      'ratePaise': serializer.toJson<int>(ratePaise),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InvoiceItem copyWith({
    String? id,
    String? invoiceId,
    int? serialNo,
    String? description,
    Value<String?> hsnSac = const Value.absent(),
    double? quantity,
    Value<String?> unitId = const Value.absent(),
    Value<String?> unitCodeSnapshot = const Value.absent(),
    int? ratePaise,
    int? amountPaise,
    DateTime? createdAt,
  }) => InvoiceItem(
    id: id ?? this.id,
    invoiceId: invoiceId ?? this.invoiceId,
    serialNo: serialNo ?? this.serialNo,
    description: description ?? this.description,
    hsnSac: hsnSac.present ? hsnSac.value : this.hsnSac,
    quantity: quantity ?? this.quantity,
    unitId: unitId.present ? unitId.value : this.unitId,
    unitCodeSnapshot: unitCodeSnapshot.present
        ? unitCodeSnapshot.value
        : this.unitCodeSnapshot,
    ratePaise: ratePaise ?? this.ratePaise,
    amountPaise: amountPaise ?? this.amountPaise,
    createdAt: createdAt ?? this.createdAt,
  );
  InvoiceItem copyWithCompanion(InvoiceItemsCompanion data) {
    return InvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      serialNo: data.serialNo.present ? data.serialNo.value : this.serialNo,
      description: data.description.present
          ? data.description.value
          : this.description,
      hsnSac: data.hsnSac.present ? data.hsnSac.value : this.hsnSac,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      unitCodeSnapshot: data.unitCodeSnapshot.present
          ? data.unitCodeSnapshot.value
          : this.unitCodeSnapshot,
      ratePaise: data.ratePaise.present ? data.ratePaise.value : this.ratePaise,
      amountPaise: data.amountPaise.present
          ? data.amountPaise.value
          : this.amountPaise,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItem(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('serialNo: $serialNo, ')
          ..write('description: $description, ')
          ..write('hsnSac: $hsnSac, ')
          ..write('quantity: $quantity, ')
          ..write('unitId: $unitId, ')
          ..write('unitCodeSnapshot: $unitCodeSnapshot, ')
          ..write('ratePaise: $ratePaise, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    invoiceId,
    serialNo,
    description,
    hsnSac,
    quantity,
    unitId,
    unitCodeSnapshot,
    ratePaise,
    amountPaise,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceItem &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.serialNo == this.serialNo &&
          other.description == this.description &&
          other.hsnSac == this.hsnSac &&
          other.quantity == this.quantity &&
          other.unitId == this.unitId &&
          other.unitCodeSnapshot == this.unitCodeSnapshot &&
          other.ratePaise == this.ratePaise &&
          other.amountPaise == this.amountPaise &&
          other.createdAt == this.createdAt);
}

class InvoiceItemsCompanion extends UpdateCompanion<InvoiceItem> {
  final Value<String> id;
  final Value<String> invoiceId;
  final Value<int> serialNo;
  final Value<String> description;
  final Value<String?> hsnSac;
  final Value<double> quantity;
  final Value<String?> unitId;
  final Value<String?> unitCodeSnapshot;
  final Value<int> ratePaise;
  final Value<int> amountPaise;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.serialNo = const Value.absent(),
    this.description = const Value.absent(),
    this.hsnSac = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitId = const Value.absent(),
    this.unitCodeSnapshot = const Value.absent(),
    this.ratePaise = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvoiceItemsCompanion.insert({
    this.id = const Value.absent(),
    required String invoiceId,
    required int serialNo,
    required String description,
    this.hsnSac = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitId = const Value.absent(),
    this.unitCodeSnapshot = const Value.absent(),
    this.ratePaise = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : invoiceId = Value(invoiceId),
       serialNo = Value(serialNo),
       description = Value(description);
  static Insertable<InvoiceItem> custom({
    Expression<String>? id,
    Expression<String>? invoiceId,
    Expression<int>? serialNo,
    Expression<String>? description,
    Expression<String>? hsnSac,
    Expression<double>? quantity,
    Expression<String>? unitId,
    Expression<String>? unitCodeSnapshot,
    Expression<int>? ratePaise,
    Expression<int>? amountPaise,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (serialNo != null) 'serial_no': serialNo,
      if (description != null) 'description': description,
      if (hsnSac != null) 'hsn_sac': hsnSac,
      if (quantity != null) 'quantity': quantity,
      if (unitId != null) 'unit_id': unitId,
      if (unitCodeSnapshot != null) 'unit_code_snapshot': unitCodeSnapshot,
      if (ratePaise != null) 'rate_paise': ratePaise,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvoiceItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? invoiceId,
    Value<int>? serialNo,
    Value<String>? description,
    Value<String?>? hsnSac,
    Value<double>? quantity,
    Value<String?>? unitId,
    Value<String?>? unitCodeSnapshot,
    Value<int>? ratePaise,
    Value<int>? amountPaise,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InvoiceItemsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      serialNo: serialNo ?? this.serialNo,
      description: description ?? this.description,
      hsnSac: hsnSac ?? this.hsnSac,
      quantity: quantity ?? this.quantity,
      unitId: unitId ?? this.unitId,
      unitCodeSnapshot: unitCodeSnapshot ?? this.unitCodeSnapshot,
      ratePaise: ratePaise ?? this.ratePaise,
      amountPaise: amountPaise ?? this.amountPaise,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<String>(invoiceId.value);
    }
    if (serialNo.present) {
      map['serial_no'] = Variable<int>(serialNo.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (hsnSac.present) {
      map['hsn_sac'] = Variable<String>(hsnSac.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (unitCodeSnapshot.present) {
      map['unit_code_snapshot'] = Variable<String>(unitCodeSnapshot.value);
    }
    if (ratePaise.present) {
      map['rate_paise'] = Variable<int>(ratePaise.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('serialNo: $serialNo, ')
          ..write('description: $description, ')
          ..write('hsnSac: $hsnSac, ')
          ..write('quantity: $quantity, ')
          ..write('unitId: $unitId, ')
          ..write('unitCodeSnapshot: $unitCodeSnapshot, ')
          ..write('ratePaise: $ratePaise, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    title,
    content,
    isPinned,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final String id;
  final String companyId;
  final String title;
  final String? content;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Note({
    required this.id,
    required this.companyId,
    required this.title,
    this.content,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    map['is_pinned'] = Variable<bool>(isPinned);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      companyId: Value(companyId),
      title: Value(title),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      isPinned: Value(isPinned),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String?>(json['content']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String?>(content),
      'isPinned': serializer.toJson<bool>(isPinned),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Note copyWith({
    String? id,
    String? companyId,
    String? title,
    Value<String?> content = const Value.absent(),
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Note(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    title: title ?? this.title,
    content: content.present ? content.value : this.content,
    isPinned: isPinned ?? this.isPinned,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('isPinned: $isPinned, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    title,
    content,
    isPinned,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.title == this.title &&
          other.content == this.content &&
          other.isPinned == this.isPinned &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> title;
  final Value<String?> content;
  final Value<bool> isPinned;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    required String companyId,
    required String title,
    this.content = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : companyId = Value(companyId),
       title = Value(title);
  static Insertable<Note> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? title,
    Expression<String>? content,
    Expression<bool>? isPinned,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (isPinned != null) 'is_pinned': isPinned,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? title,
    Value<String?>? content,
    Value<bool>? isPinned,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('isPinned: $isPinned, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportBatchesTable extends ImportBatches
    with TableInfo<$ImportBatchesTable, ImportBatche> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _companyIdMeta = const VerificationMeta(
    'companyId',
  );
  @override
  late final GeneratedColumn<String> companyId = GeneratedColumn<String>(
    'company_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES companies (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceHashMeta = const VerificationMeta(
    'sourceHash',
  );
  @override
  late final GeneratedColumn<String> sourceHash = GeneratedColumn<String>(
    'source_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalRowsMeta = const VerificationMeta(
    'totalRows',
  );
  @override
  late final GeneratedColumn<int> totalRows = GeneratedColumn<int>(
    'total_rows',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _importedCountMeta = const VerificationMeta(
    'importedCount',
  );
  @override
  late final GeneratedColumn<int> importedCount = GeneratedColumn<int>(
    'imported_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _skippedCountMeta = const VerificationMeta(
    'skippedCount',
  );
  @override
  late final GeneratedColumn<int> skippedCount = GeneratedColumn<int>(
    'skipped_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _failedCountMeta = const VerificationMeta(
    'failedCount',
  );
  @override
  late final GeneratedColumn<int> failedCount = GeneratedColumn<int>(
    'failed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _errorSummaryMeta = const VerificationMeta(
    'errorSummary',
  );
  @override
  late final GeneratedColumn<String> errorSummary = GeneratedColumn<String>(
    'error_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    companyId,
    fileName,
    sourceHash,
    totalRows,
    importedCount,
    skippedCount,
    failedCount,
    status,
    errorSummary,
    importedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportBatche> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('company_id')) {
      context.handle(
        _companyIdMeta,
        companyId.isAcceptableOrUnknown(data['company_id']!, _companyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_companyIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('source_hash')) {
      context.handle(
        _sourceHashMeta,
        sourceHash.isAcceptableOrUnknown(data['source_hash']!, _sourceHashMeta),
      );
    }
    if (data.containsKey('total_rows')) {
      context.handle(
        _totalRowsMeta,
        totalRows.isAcceptableOrUnknown(data['total_rows']!, _totalRowsMeta),
      );
    }
    if (data.containsKey('imported_count')) {
      context.handle(
        _importedCountMeta,
        importedCount.isAcceptableOrUnknown(
          data['imported_count']!,
          _importedCountMeta,
        ),
      );
    }
    if (data.containsKey('skipped_count')) {
      context.handle(
        _skippedCountMeta,
        skippedCount.isAcceptableOrUnknown(
          data['skipped_count']!,
          _skippedCountMeta,
        ),
      );
    }
    if (data.containsKey('failed_count')) {
      context.handle(
        _failedCountMeta,
        failedCount.isAcceptableOrUnknown(
          data['failed_count']!,
          _failedCountMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error_summary')) {
      context.handle(
        _errorSummaryMeta,
        errorSummary.isAcceptableOrUnknown(
          data['error_summary']!,
          _errorSummaryMeta,
        ),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportBatche map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportBatche(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      companyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      sourceHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_hash'],
      ),
      totalRows: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_rows'],
      )!,
      importedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}imported_count'],
      )!,
      skippedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skipped_count'],
      )!,
      failedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_summary'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $ImportBatchesTable createAlias(String alias) {
    return $ImportBatchesTable(attachedDatabase, alias);
  }
}

class ImportBatche extends DataClass implements Insertable<ImportBatche> {
  final String id;
  final String companyId;
  final String fileName;
  final String? sourceHash;
  final int totalRows;
  final int importedCount;
  final int skippedCount;
  final int failedCount;
  final String status;
  final String? errorSummary;
  final DateTime importedAt;
  const ImportBatche({
    required this.id,
    required this.companyId,
    required this.fileName,
    this.sourceHash,
    required this.totalRows,
    required this.importedCount,
    required this.skippedCount,
    required this.failedCount,
    required this.status,
    this.errorSummary,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['company_id'] = Variable<String>(companyId);
    map['file_name'] = Variable<String>(fileName);
    if (!nullToAbsent || sourceHash != null) {
      map['source_hash'] = Variable<String>(sourceHash);
    }
    map['total_rows'] = Variable<int>(totalRows);
    map['imported_count'] = Variable<int>(importedCount);
    map['skipped_count'] = Variable<int>(skippedCount);
    map['failed_count'] = Variable<int>(failedCount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorSummary != null) {
      map['error_summary'] = Variable<String>(errorSummary);
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  ImportBatchesCompanion toCompanion(bool nullToAbsent) {
    return ImportBatchesCompanion(
      id: Value(id),
      companyId: Value(companyId),
      fileName: Value(fileName),
      sourceHash: sourceHash == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceHash),
      totalRows: Value(totalRows),
      importedCount: Value(importedCount),
      skippedCount: Value(skippedCount),
      failedCount: Value(failedCount),
      status: Value(status),
      errorSummary: errorSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(errorSummary),
      importedAt: Value(importedAt),
    );
  }

  factory ImportBatche.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportBatche(
      id: serializer.fromJson<String>(json['id']),
      companyId: serializer.fromJson<String>(json['companyId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      sourceHash: serializer.fromJson<String?>(json['sourceHash']),
      totalRows: serializer.fromJson<int>(json['totalRows']),
      importedCount: serializer.fromJson<int>(json['importedCount']),
      skippedCount: serializer.fromJson<int>(json['skippedCount']),
      failedCount: serializer.fromJson<int>(json['failedCount']),
      status: serializer.fromJson<String>(json['status']),
      errorSummary: serializer.fromJson<String?>(json['errorSummary']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'companyId': serializer.toJson<String>(companyId),
      'fileName': serializer.toJson<String>(fileName),
      'sourceHash': serializer.toJson<String?>(sourceHash),
      'totalRows': serializer.toJson<int>(totalRows),
      'importedCount': serializer.toJson<int>(importedCount),
      'skippedCount': serializer.toJson<int>(skippedCount),
      'failedCount': serializer.toJson<int>(failedCount),
      'status': serializer.toJson<String>(status),
      'errorSummary': serializer.toJson<String?>(errorSummary),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  ImportBatche copyWith({
    String? id,
    String? companyId,
    String? fileName,
    Value<String?> sourceHash = const Value.absent(),
    int? totalRows,
    int? importedCount,
    int? skippedCount,
    int? failedCount,
    String? status,
    Value<String?> errorSummary = const Value.absent(),
    DateTime? importedAt,
  }) => ImportBatche(
    id: id ?? this.id,
    companyId: companyId ?? this.companyId,
    fileName: fileName ?? this.fileName,
    sourceHash: sourceHash.present ? sourceHash.value : this.sourceHash,
    totalRows: totalRows ?? this.totalRows,
    importedCount: importedCount ?? this.importedCount,
    skippedCount: skippedCount ?? this.skippedCount,
    failedCount: failedCount ?? this.failedCount,
    status: status ?? this.status,
    errorSummary: errorSummary.present ? errorSummary.value : this.errorSummary,
    importedAt: importedAt ?? this.importedAt,
  );
  ImportBatche copyWithCompanion(ImportBatchesCompanion data) {
    return ImportBatche(
      id: data.id.present ? data.id.value : this.id,
      companyId: data.companyId.present ? data.companyId.value : this.companyId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      sourceHash: data.sourceHash.present
          ? data.sourceHash.value
          : this.sourceHash,
      totalRows: data.totalRows.present ? data.totalRows.value : this.totalRows,
      importedCount: data.importedCount.present
          ? data.importedCount.value
          : this.importedCount,
      skippedCount: data.skippedCount.present
          ? data.skippedCount.value
          : this.skippedCount,
      failedCount: data.failedCount.present
          ? data.failedCount.value
          : this.failedCount,
      status: data.status.present ? data.status.value : this.status,
      errorSummary: data.errorSummary.present
          ? data.errorSummary.value
          : this.errorSummary,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatche(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('fileName: $fileName, ')
          ..write('sourceHash: $sourceHash, ')
          ..write('totalRows: $totalRows, ')
          ..write('importedCount: $importedCount, ')
          ..write('skippedCount: $skippedCount, ')
          ..write('failedCount: $failedCount, ')
          ..write('status: $status, ')
          ..write('errorSummary: $errorSummary, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    companyId,
    fileName,
    sourceHash,
    totalRows,
    importedCount,
    skippedCount,
    failedCount,
    status,
    errorSummary,
    importedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportBatche &&
          other.id == this.id &&
          other.companyId == this.companyId &&
          other.fileName == this.fileName &&
          other.sourceHash == this.sourceHash &&
          other.totalRows == this.totalRows &&
          other.importedCount == this.importedCount &&
          other.skippedCount == this.skippedCount &&
          other.failedCount == this.failedCount &&
          other.status == this.status &&
          other.errorSummary == this.errorSummary &&
          other.importedAt == this.importedAt);
}

class ImportBatchesCompanion extends UpdateCompanion<ImportBatche> {
  final Value<String> id;
  final Value<String> companyId;
  final Value<String> fileName;
  final Value<String?> sourceHash;
  final Value<int> totalRows;
  final Value<int> importedCount;
  final Value<int> skippedCount;
  final Value<int> failedCount;
  final Value<String> status;
  final Value<String?> errorSummary;
  final Value<DateTime> importedAt;
  final Value<int> rowid;
  const ImportBatchesCompanion({
    this.id = const Value.absent(),
    this.companyId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.sourceHash = const Value.absent(),
    this.totalRows = const Value.absent(),
    this.importedCount = const Value.absent(),
    this.skippedCount = const Value.absent(),
    this.failedCount = const Value.absent(),
    this.status = const Value.absent(),
    this.errorSummary = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportBatchesCompanion.insert({
    this.id = const Value.absent(),
    required String companyId,
    required String fileName,
    this.sourceHash = const Value.absent(),
    this.totalRows = const Value.absent(),
    this.importedCount = const Value.absent(),
    this.skippedCount = const Value.absent(),
    this.failedCount = const Value.absent(),
    this.status = const Value.absent(),
    this.errorSummary = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : companyId = Value(companyId),
       fileName = Value(fileName);
  static Insertable<ImportBatche> custom({
    Expression<String>? id,
    Expression<String>? companyId,
    Expression<String>? fileName,
    Expression<String>? sourceHash,
    Expression<int>? totalRows,
    Expression<int>? importedCount,
    Expression<int>? skippedCount,
    Expression<int>? failedCount,
    Expression<String>? status,
    Expression<String>? errorSummary,
    Expression<DateTime>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (companyId != null) 'company_id': companyId,
      if (fileName != null) 'file_name': fileName,
      if (sourceHash != null) 'source_hash': sourceHash,
      if (totalRows != null) 'total_rows': totalRows,
      if (importedCount != null) 'imported_count': importedCount,
      if (skippedCount != null) 'skipped_count': skippedCount,
      if (failedCount != null) 'failed_count': failedCount,
      if (status != null) 'status': status,
      if (errorSummary != null) 'error_summary': errorSummary,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportBatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? companyId,
    Value<String>? fileName,
    Value<String?>? sourceHash,
    Value<int>? totalRows,
    Value<int>? importedCount,
    Value<int>? skippedCount,
    Value<int>? failedCount,
    Value<String>? status,
    Value<String?>? errorSummary,
    Value<DateTime>? importedAt,
    Value<int>? rowid,
  }) {
    return ImportBatchesCompanion(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      fileName: fileName ?? this.fileName,
      sourceHash: sourceHash ?? this.sourceHash,
      totalRows: totalRows ?? this.totalRows,
      importedCount: importedCount ?? this.importedCount,
      skippedCount: skippedCount ?? this.skippedCount,
      failedCount: failedCount ?? this.failedCount,
      status: status ?? this.status,
      errorSummary: errorSummary ?? this.errorSummary,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (companyId.present) {
      map['company_id'] = Variable<String>(companyId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (sourceHash.present) {
      map['source_hash'] = Variable<String>(sourceHash.value);
    }
    if (totalRows.present) {
      map['total_rows'] = Variable<int>(totalRows.value);
    }
    if (importedCount.present) {
      map['imported_count'] = Variable<int>(importedCount.value);
    }
    if (skippedCount.present) {
      map['skipped_count'] = Variable<int>(skippedCount.value);
    }
    if (failedCount.present) {
      map['failed_count'] = Variable<int>(failedCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorSummary.present) {
      map['error_summary'] = Variable<String>(errorSummary.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportBatchesCompanion(')
          ..write('id: $id, ')
          ..write('companyId: $companyId, ')
          ..write('fileName: $fileName, ')
          ..write('sourceHash: $sourceHash, ')
          ..write('totalRows: $totalRows, ')
          ..write('importedCount: $importedCount, ')
          ..write('skippedCount: $skippedCount, ')
          ..write('failedCount: $failedCount, ')
          ..write('status: $status, ')
          ..write('errorSummary: $errorSummary, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CompaniesTable companies = $CompaniesTable(this);
  late final $PartiesTable parties = $PartiesTable(this);
  late final $VendorCodesTable vendorCodes = $VendorCodesTable(this);
  late final $SitesTable sites = $SitesTable(this);
  late final $UnitsTable units = $UnitsTable(this);
  late final $TaxRatesTable taxRates = $TaxRatesTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceItemsTable invoiceItems = $InvoiceItemsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $ImportBatchesTable importBatches = $ImportBatchesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    companies,
    parties,
    vendorCodes,
    sites,
    units,
    taxRates,
    invoices,
    invoiceItems,
    notes,
    importBatches,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('parties', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('vendor_codes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sites', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'parties',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('invoices', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vendor_codes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('invoices', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sites',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('invoices', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'invoices',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('invoice_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'units',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('invoice_items', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('notes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'companies',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('import_batches', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CompaniesTableCreateCompanionBuilder =
    CompaniesCompanion Function({
      Value<String> id,
      Value<String?> ownerUserId,
      required String companyName,
      Value<String?> address1,
      Value<String?> address2,
      Value<String?> address3,
      Value<String?> city,
      Value<String?> state,
      Value<String?> pincode,
      Value<String?> pan,
      Value<String?> gstin,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> logoPath,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$CompaniesTableUpdateCompanionBuilder =
    CompaniesCompanion Function({
      Value<String> id,
      Value<String?> ownerUserId,
      Value<String> companyName,
      Value<String?> address1,
      Value<String?> address2,
      Value<String?> address3,
      Value<String?> city,
      Value<String?> state,
      Value<String?> pincode,
      Value<String?> pan,
      Value<String?> gstin,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> logoPath,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CompaniesTableReferences
    extends BaseReferences<_$AppDatabase, $CompaniesTable, Company> {
  $$CompaniesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PartiesTable, List<Party>> _partiesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.parties,
    aliasName: 'companies__id__parties__company_id',
  );

  $$PartiesTableProcessedTableManager get partiesRefs {
    final manager = $$PartiesTableTableManager(
      $_db,
      $_db.parties,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_partiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VendorCodesTable, List<VendorCode>>
  _vendorCodesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vendorCodes,
    aliasName: 'companies__id__vendor_codes__company_id',
  );

  $$VendorCodesTableProcessedTableManager get vendorCodesRefs {
    final manager = $$VendorCodesTableTableManager(
      $_db,
      $_db.vendorCodes,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vendorCodesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SitesTable, List<Site>> _sitesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sites,
    aliasName: 'companies__id__sites__company_id',
  );

  $$SitesTableProcessedTableManager get sitesRefs {
    final manager = $$SitesTableTableManager(
      $_db,
      $_db.sites,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sitesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.invoices,
    aliasName: 'companies__id__invoices__company_id',
  );

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: 'companies__id__notes__company_id',
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportBatchesTable, List<ImportBatche>>
  _importBatchesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.importBatches,
    aliasName: 'companies__id__import_batches__company_id',
  );

  $$ImportBatchesTableProcessedTableManager get importBatchesRefs {
    final manager = $$ImportBatchesTableTableManager(
      $_db,
      $_db.importBatches,
    ).filter((f) => f.companyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_importBatchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompaniesTableFilterComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address1 => $composableBuilder(
    column: $table.address1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address2 => $composableBuilder(
    column: $table.address2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address3 => $composableBuilder(
    column: $table.address3,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> partiesRefs(
    Expression<bool> Function($$PartiesTableFilterComposer f) f,
  ) {
    final $$PartiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableFilterComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vendorCodesRefs(
    Expression<bool> Function($$VendorCodesTableFilterComposer f) f,
  ) {
    final $$VendorCodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vendorCodes,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorCodesTableFilterComposer(
            $db: $db,
            $table: $db.vendorCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sitesRefs(
    Expression<bool> Function($$SitesTableFilterComposer f) f,
  ) {
    final $$SitesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sites,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SitesTableFilterComposer(
            $db: $db,
            $table: $db.sites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> invoicesRefs(
    Expression<bool> Function($$InvoicesTableFilterComposer f) f,
  ) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importBatchesRefs(
    Expression<bool> Function($$ImportBatchesTableFilterComposer f) f,
  ) {
    final $$ImportBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableFilterComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableOrderingComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address1 => $composableBuilder(
    column: $table.address1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address2 => $composableBuilder(
    column: $table.address2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address3 => $composableBuilder(
    column: $table.address3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompaniesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompaniesTable> {
  $$CompaniesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address1 =>
      $composableBuilder(column: $table.address1, builder: (column) => column);

  GeneratedColumn<String> get address2 =>
      $composableBuilder(column: $table.address2, builder: (column) => column);

  GeneratedColumn<String> get address3 =>
      $composableBuilder(column: $table.address3, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get pincode =>
      $composableBuilder(column: $table.pincode, builder: (column) => column);

  GeneratedColumn<String> get pan =>
      $composableBuilder(column: $table.pan, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> partiesRefs<T extends Object>(
    Expression<T> Function($$PartiesTableAnnotationComposer a) f,
  ) {
    final $$PartiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableAnnotationComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vendorCodesRefs<T extends Object>(
    Expression<T> Function($$VendorCodesTableAnnotationComposer a) f,
  ) {
    final $$VendorCodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vendorCodes,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorCodesTableAnnotationComposer(
            $db: $db,
            $table: $db.vendorCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sitesRefs<T extends Object>(
    Expression<T> Function($$SitesTableAnnotationComposer a) f,
  ) {
    final $$SitesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sites,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SitesTableAnnotationComposer(
            $db: $db,
            $table: $db.sites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> invoicesRefs<T extends Object>(
    Expression<T> Function($$InvoicesTableAnnotationComposer a) f,
  ) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> importBatchesRefs<T extends Object>(
    Expression<T> Function($$ImportBatchesTableAnnotationComposer a) f,
  ) {
    final $$ImportBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importBatches,
      getReferencedColumn: (t) => t.companyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.importBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompaniesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompaniesTable,
          Company,
          $$CompaniesTableFilterComposer,
          $$CompaniesTableOrderingComposer,
          $$CompaniesTableAnnotationComposer,
          $$CompaniesTableCreateCompanionBuilder,
          $$CompaniesTableUpdateCompanionBuilder,
          (Company, $$CompaniesTableReferences),
          Company,
          PrefetchHooks Function({
            bool partiesRefs,
            bool vendorCodesRefs,
            bool sitesRefs,
            bool invoicesRefs,
            bool notesRefs,
            bool importBatchesRefs,
          })
        > {
  $$CompaniesTableTableManager(_$AppDatabase db, $CompaniesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompaniesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompaniesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompaniesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> ownerUserId = const Value.absent(),
                Value<String> companyName = const Value.absent(),
                Value<String?> address1 = const Value.absent(),
                Value<String?> address2 = const Value.absent(),
                Value<String?> address3 = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> pincode = const Value.absent(),
                Value<String?> pan = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> logoPath = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompaniesCompanion(
                id: id,
                ownerUserId: ownerUserId,
                companyName: companyName,
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
                logoPath: logoPath,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> ownerUserId = const Value.absent(),
                required String companyName,
                Value<String?> address1 = const Value.absent(),
                Value<String?> address2 = const Value.absent(),
                Value<String?> address3 = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> pincode = const Value.absent(),
                Value<String?> pan = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> logoPath = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompaniesCompanion.insert(
                id: id,
                ownerUserId: ownerUserId,
                companyName: companyName,
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
                logoPath: logoPath,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompaniesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                partiesRefs = false,
                vendorCodesRefs = false,
                sitesRefs = false,
                invoicesRefs = false,
                notesRefs = false,
                importBatchesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (partiesRefs) db.parties,
                    if (vendorCodesRefs) db.vendorCodes,
                    if (sitesRefs) db.sites,
                    if (invoicesRefs) db.invoices,
                    if (notesRefs) db.notes,
                    if (importBatchesRefs) db.importBatches,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (partiesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Party
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._partiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).partiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (vendorCodesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          VendorCode
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._vendorCodesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).vendorCodesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sitesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Site
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._sitesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).sitesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (invoicesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Invoice
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._invoicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).invoicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (notesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          Note
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._notesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).notesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importBatchesRefs)
                        await $_getPrefetchedData<
                          Company,
                          $CompaniesTable,
                          ImportBatche
                        >(
                          currentTable: table,
                          referencedTable: $$CompaniesTableReferences
                              ._importBatchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompaniesTableReferences(
                                db,
                                table,
                                p0,
                              ).importBatchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.companyId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CompaniesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompaniesTable,
      Company,
      $$CompaniesTableFilterComposer,
      $$CompaniesTableOrderingComposer,
      $$CompaniesTableAnnotationComposer,
      $$CompaniesTableCreateCompanionBuilder,
      $$CompaniesTableUpdateCompanionBuilder,
      (Company, $$CompaniesTableReferences),
      Company,
      PrefetchHooks Function({
        bool partiesRefs,
        bool vendorCodesRefs,
        bool sitesRefs,
        bool invoicesRefs,
        bool notesRefs,
        bool importBatchesRefs,
      })
    >;
typedef $$PartiesTableCreateCompanionBuilder =
    PartiesCompanion Function({
      Value<String> id,
      required String companyId,
      required String partyName,
      Value<String?> address1,
      Value<String?> address2,
      Value<String?> address3,
      Value<String?> city,
      Value<String?> state,
      Value<String?> pincode,
      Value<String?> pan,
      Value<String?> gstin,
      Value<String?> phone,
      Value<String?> email,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PartiesTableUpdateCompanionBuilder =
    PartiesCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> partyName,
      Value<String?> address1,
      Value<String?> address2,
      Value<String?> address3,
      Value<String?> city,
      Value<String?> state,
      Value<String?> pincode,
      Value<String?> pan,
      Value<String?> gstin,
      Value<String?> phone,
      Value<String?> email,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PartiesTableReferences
    extends BaseReferences<_$AppDatabase, $PartiesTable, Party> {
  $$PartiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias('parties__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.invoices,
    aliasName: 'parties__id__invoices__party_id',
  );

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.partyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PartiesTableFilterComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyName => $composableBuilder(
    column: $table.partyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address1 => $composableBuilder(
    column: $table.address1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address2 => $composableBuilder(
    column: $table.address2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address3 => $composableBuilder(
    column: $table.address3,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> invoicesRefs(
    Expression<bool> Function($$InvoicesTableFilterComposer f) f,
  ) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartiesTableOrderingComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyName => $composableBuilder(
    column: $table.partyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address1 => $composableBuilder(
    column: $table.address1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address2 => $composableBuilder(
    column: $table.address2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address3 => $composableBuilder(
    column: $table.address3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PartiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartiesTable> {
  $$PartiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partyName =>
      $composableBuilder(column: $table.partyName, builder: (column) => column);

  GeneratedColumn<String> get address1 =>
      $composableBuilder(column: $table.address1, builder: (column) => column);

  GeneratedColumn<String> get address2 =>
      $composableBuilder(column: $table.address2, builder: (column) => column);

  GeneratedColumn<String> get address3 =>
      $composableBuilder(column: $table.address3, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get pincode =>
      $composableBuilder(column: $table.pincode, builder: (column) => column);

  GeneratedColumn<String> get pan =>
      $composableBuilder(column: $table.pan, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> invoicesRefs<T extends Object>(
    Expression<T> Function($$InvoicesTableAnnotationComposer a) f,
  ) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.partyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartiesTable,
          Party,
          $$PartiesTableFilterComposer,
          $$PartiesTableOrderingComposer,
          $$PartiesTableAnnotationComposer,
          $$PartiesTableCreateCompanionBuilder,
          $$PartiesTableUpdateCompanionBuilder,
          (Party, $$PartiesTableReferences),
          Party,
          PrefetchHooks Function({bool companyId, bool invoicesRefs})
        > {
  $$PartiesTableTableManager(_$AppDatabase db, $PartiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> partyName = const Value.absent(),
                Value<String?> address1 = const Value.absent(),
                Value<String?> address2 = const Value.absent(),
                Value<String?> address3 = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> pincode = const Value.absent(),
                Value<String?> pan = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion(
                id: id,
                companyId: companyId,
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
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String companyId,
                required String partyName,
                Value<String?> address1 = const Value.absent(),
                Value<String?> address2 = const Value.absent(),
                Value<String?> address3 = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> pincode = const Value.absent(),
                Value<String?> pan = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartiesCompanion.insert(
                id: id,
                companyId: companyId,
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
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PartiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false, invoicesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (invoicesRefs) db.invoices],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable: $$PartiesTableReferences
                                    ._companyIdTable(db),
                                referencedColumn: $$PartiesTableReferences
                                    ._companyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoicesRefs)
                    await $_getPrefetchedData<Party, $PartiesTable, Invoice>(
                      currentTable: table,
                      referencedTable: $$PartiesTableReferences
                          ._invoicesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PartiesTableReferences(db, table, p0).invoicesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.partyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PartiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartiesTable,
      Party,
      $$PartiesTableFilterComposer,
      $$PartiesTableOrderingComposer,
      $$PartiesTableAnnotationComposer,
      $$PartiesTableCreateCompanionBuilder,
      $$PartiesTableUpdateCompanionBuilder,
      (Party, $$PartiesTableReferences),
      Party,
      PrefetchHooks Function({bool companyId, bool invoicesRefs})
    >;
typedef $$VendorCodesTableCreateCompanionBuilder =
    VendorCodesCompanion Function({
      Value<String> id,
      required String companyId,
      required String vendorCode,
      Value<String?> description,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$VendorCodesTableUpdateCompanionBuilder =
    VendorCodesCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> vendorCode,
      Value<String?> description,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$VendorCodesTableReferences
    extends BaseReferences<_$AppDatabase, $VendorCodesTable, VendorCode> {
  $$VendorCodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias('vendor_codes__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.invoices,
    aliasName: 'vendor_codes__id__invoices__vendor_code_id',
  );

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.vendorCodeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VendorCodesTableFilterComposer
    extends Composer<_$AppDatabase, $VendorCodesTable> {
  $$VendorCodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vendorCode => $composableBuilder(
    column: $table.vendorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> invoicesRefs(
    Expression<bool> Function($$InvoicesTableFilterComposer f) f,
  ) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.vendorCodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VendorCodesTableOrderingComposer
    extends Composer<_$AppDatabase, $VendorCodesTable> {
  $$VendorCodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vendorCode => $composableBuilder(
    column: $table.vendorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VendorCodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VendorCodesTable> {
  $$VendorCodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vendorCode => $composableBuilder(
    column: $table.vendorCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> invoicesRefs<T extends Object>(
    Expression<T> Function($$InvoicesTableAnnotationComposer a) f,
  ) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.vendorCodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VendorCodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VendorCodesTable,
          VendorCode,
          $$VendorCodesTableFilterComposer,
          $$VendorCodesTableOrderingComposer,
          $$VendorCodesTableAnnotationComposer,
          $$VendorCodesTableCreateCompanionBuilder,
          $$VendorCodesTableUpdateCompanionBuilder,
          (VendorCode, $$VendorCodesTableReferences),
          VendorCode,
          PrefetchHooks Function({bool companyId, bool invoicesRefs})
        > {
  $$VendorCodesTableTableManager(_$AppDatabase db, $VendorCodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VendorCodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VendorCodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VendorCodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> vendorCode = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VendorCodesCompanion(
                id: id,
                companyId: companyId,
                vendorCode: vendorCode,
                description: description,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String companyId,
                required String vendorCode,
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VendorCodesCompanion.insert(
                id: id,
                companyId: companyId,
                vendorCode: vendorCode,
                description: description,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VendorCodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false, invoicesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (invoicesRefs) db.invoices],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable: $$VendorCodesTableReferences
                                    ._companyIdTable(db),
                                referencedColumn: $$VendorCodesTableReferences
                                    ._companyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoicesRefs)
                    await $_getPrefetchedData<
                      VendorCode,
                      $VendorCodesTable,
                      Invoice
                    >(
                      currentTable: table,
                      referencedTable: $$VendorCodesTableReferences
                          ._invoicesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$VendorCodesTableReferences(
                            db,
                            table,
                            p0,
                          ).invoicesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.vendorCodeId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VendorCodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VendorCodesTable,
      VendorCode,
      $$VendorCodesTableFilterComposer,
      $$VendorCodesTableOrderingComposer,
      $$VendorCodesTableAnnotationComposer,
      $$VendorCodesTableCreateCompanionBuilder,
      $$VendorCodesTableUpdateCompanionBuilder,
      (VendorCode, $$VendorCodesTableReferences),
      VendorCode,
      PrefetchHooks Function({bool companyId, bool invoicesRefs})
    >;
typedef $$SitesTableCreateCompanionBuilder =
    SitesCompanion Function({
      Value<String> id,
      required String companyId,
      required String siteName,
      Value<String?> siteCode,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$SitesTableUpdateCompanionBuilder =
    SitesCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> siteName,
      Value<String?> siteCode,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SitesTableReferences
    extends BaseReferences<_$AppDatabase, $SitesTable, Site> {
  $$SitesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias('sites__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.invoices,
    aliasName: 'sites__id__invoices__site_id',
  );

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.siteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SitesTableFilterComposer extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteName => $composableBuilder(
    column: $table.siteName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteCode => $composableBuilder(
    column: $table.siteCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> invoicesRefs(
    Expression<bool> Function($$InvoicesTableFilterComposer f) f,
  ) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.siteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SitesTableOrderingComposer
    extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteName => $composableBuilder(
    column: $table.siteName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteCode => $composableBuilder(
    column: $table.siteCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SitesTable> {
  $$SitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get siteName =>
      $composableBuilder(column: $table.siteName, builder: (column) => column);

  GeneratedColumn<String> get siteCode =>
      $composableBuilder(column: $table.siteCode, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> invoicesRefs<T extends Object>(
    Expression<T> Function($$InvoicesTableAnnotationComposer a) f,
  ) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.siteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SitesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SitesTable,
          Site,
          $$SitesTableFilterComposer,
          $$SitesTableOrderingComposer,
          $$SitesTableAnnotationComposer,
          $$SitesTableCreateCompanionBuilder,
          $$SitesTableUpdateCompanionBuilder,
          (Site, $$SitesTableReferences),
          Site,
          PrefetchHooks Function({bool companyId, bool invoicesRefs})
        > {
  $$SitesTableTableManager(_$AppDatabase db, $SitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> siteName = const Value.absent(),
                Value<String?> siteCode = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SitesCompanion(
                id: id,
                companyId: companyId,
                siteName: siteName,
                siteCode: siteCode,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String companyId,
                required String siteName,
                Value<String?> siteCode = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SitesCompanion.insert(
                id: id,
                companyId: companyId,
                siteName: siteName,
                siteCode: siteCode,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SitesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false, invoicesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (invoicesRefs) db.invoices],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable: $$SitesTableReferences
                                    ._companyIdTable(db),
                                referencedColumn: $$SitesTableReferences
                                    ._companyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoicesRefs)
                    await $_getPrefetchedData<Site, $SitesTable, Invoice>(
                      currentTable: table,
                      referencedTable: $$SitesTableReferences
                          ._invoicesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SitesTableReferences(db, table, p0).invoicesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.siteId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SitesTable,
      Site,
      $$SitesTableFilterComposer,
      $$SitesTableOrderingComposer,
      $$SitesTableAnnotationComposer,
      $$SitesTableCreateCompanionBuilder,
      $$SitesTableUpdateCompanionBuilder,
      (Site, $$SitesTableReferences),
      Site,
      PrefetchHooks Function({bool companyId, bool invoicesRefs})
    >;
typedef $$UnitsTableCreateCompanionBuilder =
    UnitsCompanion Function({
      Value<String> id,
      Value<String?> companyId,
      required String unitCode,
      required String unitName,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$UnitsTableUpdateCompanionBuilder =
    UnitsCompanion Function({
      Value<String> id,
      Value<String?> companyId,
      Value<String> unitCode,
      Value<String> unitName,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$UnitsTableReferences
    extends BaseReferences<_$AppDatabase, $UnitsTable, Unit> {
  $$UnitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InvoiceItemsTable, List<InvoiceItem>>
  _invoiceItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.invoiceItems,
    aliasName: 'units__id__invoice_items__unit_id',
  );

  $$InvoiceItemsTableProcessedTableManager get invoiceItemsRefs {
    final manager = $$InvoiceItemsTableTableManager(
      $_db,
      $_db.invoiceItems,
    ).filter((f) => f.unitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoiceItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UnitsTableFilterComposer extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitName => $composableBuilder(
    column: $table.unitName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> invoiceItemsRefs(
    Expression<bool> Function($$InvoiceItemsTableFilterComposer f) f,
  ) {
    final $$InvoiceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceItems,
      getReferencedColumn: (t) => t.unitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceItemsTableFilterComposer(
            $db: $db,
            $table: $db.invoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitCode => $composableBuilder(
    column: $table.unitCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitName => $composableBuilder(
    column: $table.unitName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get unitCode =>
      $composableBuilder(column: $table.unitCode, builder: (column) => column);

  GeneratedColumn<String> get unitName =>
      $composableBuilder(column: $table.unitName, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> invoiceItemsRefs<T extends Object>(
    Expression<T> Function($$InvoiceItemsTableAnnotationComposer a) f,
  ) {
    final $$InvoiceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceItems,
      getReferencedColumn: (t) => t.unitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.invoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitsTable,
          Unit,
          $$UnitsTableFilterComposer,
          $$UnitsTableOrderingComposer,
          $$UnitsTableAnnotationComposer,
          $$UnitsTableCreateCompanionBuilder,
          $$UnitsTableUpdateCompanionBuilder,
          (Unit, $$UnitsTableReferences),
          Unit,
          PrefetchHooks Function({bool invoiceItemsRefs})
        > {
  $$UnitsTableTableManager(_$AppDatabase db, $UnitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> companyId = const Value.absent(),
                Value<String> unitCode = const Value.absent(),
                Value<String> unitName = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitsCompanion(
                id: id,
                companyId: companyId,
                unitCode: unitCode,
                unitName: unitName,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> companyId = const Value.absent(),
                required String unitCode,
                required String unitName,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UnitsCompanion.insert(
                id: id,
                companyId: companyId,
                unitCode: unitCode,
                unitName: unitName,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UnitsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({invoiceItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (invoiceItemsRefs) db.invoiceItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (invoiceItemsRefs)
                    await $_getPrefetchedData<Unit, $UnitsTable, InvoiceItem>(
                      currentTable: table,
                      referencedTable: $$UnitsTableReferences
                          ._invoiceItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$UnitsTableReferences(
                        db,
                        table,
                        p0,
                      ).invoiceItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.unitId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UnitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitsTable,
      Unit,
      $$UnitsTableFilterComposer,
      $$UnitsTableOrderingComposer,
      $$UnitsTableAnnotationComposer,
      $$UnitsTableCreateCompanionBuilder,
      $$UnitsTableUpdateCompanionBuilder,
      (Unit, $$UnitsTableReferences),
      Unit,
      PrefetchHooks Function({bool invoiceItemsRefs})
    >;
typedef $$TaxRatesTableCreateCompanionBuilder =
    TaxRatesCompanion Function({
      Value<String> id,
      Value<String?> companyId,
      required String taxName,
      required double percentage,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$TaxRatesTableUpdateCompanionBuilder =
    TaxRatesCompanion Function({
      Value<String> id,
      Value<String?> companyId,
      Value<String> taxName,
      Value<double> percentage,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$TaxRatesTableFilterComposer
    extends Composer<_$AppDatabase, $TaxRatesTable> {
  $$TaxRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxName => $composableBuilder(
    column: $table.taxName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaxRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaxRatesTable> {
  $$TaxRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyId => $composableBuilder(
    column: $table.companyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxName => $composableBuilder(
    column: $table.taxName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaxRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaxRatesTable> {
  $$TaxRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get companyId =>
      $composableBuilder(column: $table.companyId, builder: (column) => column);

  GeneratedColumn<String> get taxName =>
      $composableBuilder(column: $table.taxName, builder: (column) => column);

  GeneratedColumn<double> get percentage => $composableBuilder(
    column: $table.percentage,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TaxRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaxRatesTable,
          TaxRate,
          $$TaxRatesTableFilterComposer,
          $$TaxRatesTableOrderingComposer,
          $$TaxRatesTableAnnotationComposer,
          $$TaxRatesTableCreateCompanionBuilder,
          $$TaxRatesTableUpdateCompanionBuilder,
          (TaxRate, BaseReferences<_$AppDatabase, $TaxRatesTable, TaxRate>),
          TaxRate,
          PrefetchHooks Function()
        > {
  $$TaxRatesTableTableManager(_$AppDatabase db, $TaxRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaxRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaxRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaxRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> companyId = const Value.absent(),
                Value<String> taxName = const Value.absent(),
                Value<double> percentage = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaxRatesCompanion(
                id: id,
                companyId: companyId,
                taxName: taxName,
                percentage: percentage,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> companyId = const Value.absent(),
                required String taxName,
                required double percentage,
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaxRatesCompanion.insert(
                id: id,
                companyId: companyId,
                taxName: taxName,
                percentage: percentage,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaxRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaxRatesTable,
      TaxRate,
      $$TaxRatesTableFilterComposer,
      $$TaxRatesTableOrderingComposer,
      $$TaxRatesTableAnnotationComposer,
      $$TaxRatesTableCreateCompanionBuilder,
      $$TaxRatesTableUpdateCompanionBuilder,
      (TaxRate, BaseReferences<_$AppDatabase, $TaxRatesTable, TaxRate>),
      TaxRate,
      PrefetchHooks Function()
    >;
typedef $$InvoicesTableCreateCompanionBuilder =
    InvoicesCompanion Function({
      Value<String> id,
      required String companyId,
      Value<String?> partyId,
      required String invoiceNumber,
      required DateTime invoiceDate,
      Value<String?> poNumber,
      Value<String?> vendorCodeId,
      Value<String?> siteId,
      Value<String?> serviceEntry,
      Value<DateTime?> serviceFrom,
      Value<DateTime?> serviceTo,
      required String companyNameSnapshot,
      Value<String?> companyAddress1Snapshot,
      Value<String?> companyAddress2Snapshot,
      Value<String?> companyAddress3Snapshot,
      Value<String?> companyPanSnapshot,
      Value<String?> companyGstinSnapshot,
      required String partyNameSnapshot,
      Value<String?> partyAddress1Snapshot,
      Value<String?> partyAddress2Snapshot,
      Value<String?> partyAddress3Snapshot,
      Value<String?> partyPanSnapshot,
      Value<String?> partyGstinSnapshot,
      Value<String?> vendorCodeSnapshot,
      Value<String?> siteNameSnapshot,
      Value<String> taxType,
      Value<String> gstMode,
      Value<int> basicAmountPaise,
      Value<int> taxableAmountPaise,
      Value<double> cgstRate,
      Value<int> cgstAmountPaise,
      Value<double> sgstRate,
      Value<int> sgstAmountPaise,
      Value<double> igstRate,
      Value<int> igstAmountPaise,
      Value<int> grandTotalPaise,
      Value<String?> amountInWords,
      Value<String> status,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$InvoicesTableUpdateCompanionBuilder =
    InvoicesCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String?> partyId,
      Value<String> invoiceNumber,
      Value<DateTime> invoiceDate,
      Value<String?> poNumber,
      Value<String?> vendorCodeId,
      Value<String?> siteId,
      Value<String?> serviceEntry,
      Value<DateTime?> serviceFrom,
      Value<DateTime?> serviceTo,
      Value<String> companyNameSnapshot,
      Value<String?> companyAddress1Snapshot,
      Value<String?> companyAddress2Snapshot,
      Value<String?> companyAddress3Snapshot,
      Value<String?> companyPanSnapshot,
      Value<String?> companyGstinSnapshot,
      Value<String> partyNameSnapshot,
      Value<String?> partyAddress1Snapshot,
      Value<String?> partyAddress2Snapshot,
      Value<String?> partyAddress3Snapshot,
      Value<String?> partyPanSnapshot,
      Value<String?> partyGstinSnapshot,
      Value<String?> vendorCodeSnapshot,
      Value<String?> siteNameSnapshot,
      Value<String> taxType,
      Value<String> gstMode,
      Value<int> basicAmountPaise,
      Value<int> taxableAmountPaise,
      Value<double> cgstRate,
      Value<int> cgstAmountPaise,
      Value<double> sgstRate,
      Value<int> sgstAmountPaise,
      Value<double> igstRate,
      Value<int> igstAmountPaise,
      Value<int> grandTotalPaise,
      Value<String?> amountInWords,
      Value<String> status,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$InvoicesTableReferences
    extends BaseReferences<_$AppDatabase, $InvoicesTable, Invoice> {
  $$InvoicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias('invoices__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PartiesTable _partyIdTable(_$AppDatabase db) =>
      db.parties.createAlias('invoices__party_id__parties__id');

  $$PartiesTableProcessedTableManager? get partyId {
    final $_column = $_itemColumn<String>('party_id');
    if ($_column == null) return null;
    final manager = $$PartiesTableTableManager(
      $_db,
      $_db.parties,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VendorCodesTable _vendorCodeIdTable(_$AppDatabase db) =>
      db.vendorCodes.createAlias('invoices__vendor_code_id__vendor_codes__id');

  $$VendorCodesTableProcessedTableManager? get vendorCodeId {
    final $_column = $_itemColumn<String>('vendor_code_id');
    if ($_column == null) return null;
    final manager = $$VendorCodesTableTableManager(
      $_db,
      $_db.vendorCodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vendorCodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SitesTable _siteIdTable(_$AppDatabase db) =>
      db.sites.createAlias('invoices__site_id__sites__id');

  $$SitesTableProcessedTableManager? get siteId {
    final $_column = $_itemColumn<String>('site_id');
    if ($_column == null) return null;
    final manager = $$SitesTableTableManager(
      $_db,
      $_db.sites,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_siteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InvoiceItemsTable, List<InvoiceItem>>
  _invoiceItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.invoiceItems,
    aliasName: 'invoices__id__invoice_items__invoice_id',
  );

  $$InvoiceItemsTableProcessedTableManager get invoiceItemsRefs {
    final manager = $$InvoiceItemsTableTableManager(
      $_db,
      $_db.invoiceItems,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoiceItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get poNumber => $composableBuilder(
    column: $table.poNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceEntry => $composableBuilder(
    column: $table.serviceEntry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serviceFrom => $composableBuilder(
    column: $table.serviceFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serviceTo => $composableBuilder(
    column: $table.serviceTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyNameSnapshot => $composableBuilder(
    column: $table.companyNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyAddress1Snapshot => $composableBuilder(
    column: $table.companyAddress1Snapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyAddress2Snapshot => $composableBuilder(
    column: $table.companyAddress2Snapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyAddress3Snapshot => $composableBuilder(
    column: $table.companyAddress3Snapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyPanSnapshot => $composableBuilder(
    column: $table.companyPanSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyGstinSnapshot => $composableBuilder(
    column: $table.companyGstinSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyNameSnapshot => $composableBuilder(
    column: $table.partyNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyAddress1Snapshot => $composableBuilder(
    column: $table.partyAddress1Snapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyAddress2Snapshot => $composableBuilder(
    column: $table.partyAddress2Snapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyAddress3Snapshot => $composableBuilder(
    column: $table.partyAddress3Snapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyPanSnapshot => $composableBuilder(
    column: $table.partyPanSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partyGstinSnapshot => $composableBuilder(
    column: $table.partyGstinSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vendorCodeSnapshot => $composableBuilder(
    column: $table.vendorCodeSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteNameSnapshot => $composableBuilder(
    column: $table.siteNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxType => $composableBuilder(
    column: $table.taxType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstMode => $composableBuilder(
    column: $table.gstMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get basicAmountPaise => $composableBuilder(
    column: $table.basicAmountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxableAmountPaise => $composableBuilder(
    column: $table.taxableAmountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cgstRate => $composableBuilder(
    column: $table.cgstRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cgstAmountPaise => $composableBuilder(
    column: $table.cgstAmountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sgstRate => $composableBuilder(
    column: $table.sgstRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sgstAmountPaise => $composableBuilder(
    column: $table.sgstAmountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get igstRate => $composableBuilder(
    column: $table.igstRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get igstAmountPaise => $composableBuilder(
    column: $table.igstAmountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grandTotalPaise => $composableBuilder(
    column: $table.grandTotalPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountInWords => $composableBuilder(
    column: $table.amountInWords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PartiesTableFilterComposer get partyId {
    final $$PartiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableFilterComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VendorCodesTableFilterComposer get vendorCodeId {
    final $$VendorCodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vendorCodeId,
      referencedTable: $db.vendorCodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorCodesTableFilterComposer(
            $db: $db,
            $table: $db.vendorCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SitesTableFilterComposer get siteId {
    final $$SitesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.siteId,
      referencedTable: $db.sites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SitesTableFilterComposer(
            $db: $db,
            $table: $db.sites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> invoiceItemsRefs(
    Expression<bool> Function($$InvoiceItemsTableFilterComposer f) f,
  ) {
    final $$InvoiceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceItems,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceItemsTableFilterComposer(
            $db: $db,
            $table: $db.invoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get poNumber => $composableBuilder(
    column: $table.poNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceEntry => $composableBuilder(
    column: $table.serviceEntry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serviceFrom => $composableBuilder(
    column: $table.serviceFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serviceTo => $composableBuilder(
    column: $table.serviceTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyNameSnapshot => $composableBuilder(
    column: $table.companyNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyAddress1Snapshot => $composableBuilder(
    column: $table.companyAddress1Snapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyAddress2Snapshot => $composableBuilder(
    column: $table.companyAddress2Snapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyAddress3Snapshot => $composableBuilder(
    column: $table.companyAddress3Snapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyPanSnapshot => $composableBuilder(
    column: $table.companyPanSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyGstinSnapshot => $composableBuilder(
    column: $table.companyGstinSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyNameSnapshot => $composableBuilder(
    column: $table.partyNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyAddress1Snapshot => $composableBuilder(
    column: $table.partyAddress1Snapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyAddress2Snapshot => $composableBuilder(
    column: $table.partyAddress2Snapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyAddress3Snapshot => $composableBuilder(
    column: $table.partyAddress3Snapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyPanSnapshot => $composableBuilder(
    column: $table.partyPanSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partyGstinSnapshot => $composableBuilder(
    column: $table.partyGstinSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vendorCodeSnapshot => $composableBuilder(
    column: $table.vendorCodeSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteNameSnapshot => $composableBuilder(
    column: $table.siteNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxType => $composableBuilder(
    column: $table.taxType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstMode => $composableBuilder(
    column: $table.gstMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get basicAmountPaise => $composableBuilder(
    column: $table.basicAmountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxableAmountPaise => $composableBuilder(
    column: $table.taxableAmountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cgstRate => $composableBuilder(
    column: $table.cgstRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cgstAmountPaise => $composableBuilder(
    column: $table.cgstAmountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sgstRate => $composableBuilder(
    column: $table.sgstRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sgstAmountPaise => $composableBuilder(
    column: $table.sgstAmountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get igstRate => $composableBuilder(
    column: $table.igstRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get igstAmountPaise => $composableBuilder(
    column: $table.igstAmountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grandTotalPaise => $composableBuilder(
    column: $table.grandTotalPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountInWords => $composableBuilder(
    column: $table.amountInWords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PartiesTableOrderingComposer get partyId {
    final $$PartiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableOrderingComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VendorCodesTableOrderingComposer get vendorCodeId {
    final $$VendorCodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vendorCodeId,
      referencedTable: $db.vendorCodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorCodesTableOrderingComposer(
            $db: $db,
            $table: $db.vendorCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SitesTableOrderingComposer get siteId {
    final $$SitesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.siteId,
      referencedTable: $db.sites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SitesTableOrderingComposer(
            $db: $db,
            $table: $db.sites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get poNumber =>
      $composableBuilder(column: $table.poNumber, builder: (column) => column);

  GeneratedColumn<String> get serviceEntry => $composableBuilder(
    column: $table.serviceEntry,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serviceFrom => $composableBuilder(
    column: $table.serviceFrom,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serviceTo =>
      $composableBuilder(column: $table.serviceTo, builder: (column) => column);

  GeneratedColumn<String> get companyNameSnapshot => $composableBuilder(
    column: $table.companyNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get companyAddress1Snapshot => $composableBuilder(
    column: $table.companyAddress1Snapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get companyAddress2Snapshot => $composableBuilder(
    column: $table.companyAddress2Snapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get companyAddress3Snapshot => $composableBuilder(
    column: $table.companyAddress3Snapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get companyPanSnapshot => $composableBuilder(
    column: $table.companyPanSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get companyGstinSnapshot => $composableBuilder(
    column: $table.companyGstinSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partyNameSnapshot => $composableBuilder(
    column: $table.partyNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partyAddress1Snapshot => $composableBuilder(
    column: $table.partyAddress1Snapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partyAddress2Snapshot => $composableBuilder(
    column: $table.partyAddress2Snapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partyAddress3Snapshot => $composableBuilder(
    column: $table.partyAddress3Snapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partyPanSnapshot => $composableBuilder(
    column: $table.partyPanSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partyGstinSnapshot => $composableBuilder(
    column: $table.partyGstinSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vendorCodeSnapshot => $composableBuilder(
    column: $table.vendorCodeSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get siteNameSnapshot => $composableBuilder(
    column: $table.siteNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taxType =>
      $composableBuilder(column: $table.taxType, builder: (column) => column);

  GeneratedColumn<String> get gstMode =>
      $composableBuilder(column: $table.gstMode, builder: (column) => column);

  GeneratedColumn<int> get basicAmountPaise => $composableBuilder(
    column: $table.basicAmountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taxableAmountPaise => $composableBuilder(
    column: $table.taxableAmountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cgstRate =>
      $composableBuilder(column: $table.cgstRate, builder: (column) => column);

  GeneratedColumn<int> get cgstAmountPaise => $composableBuilder(
    column: $table.cgstAmountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sgstRate =>
      $composableBuilder(column: $table.sgstRate, builder: (column) => column);

  GeneratedColumn<int> get sgstAmountPaise => $composableBuilder(
    column: $table.sgstAmountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<double> get igstRate =>
      $composableBuilder(column: $table.igstRate, builder: (column) => column);

  GeneratedColumn<int> get igstAmountPaise => $composableBuilder(
    column: $table.igstAmountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grandTotalPaise => $composableBuilder(
    column: $table.grandTotalPaise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get amountInWords => $composableBuilder(
    column: $table.amountInWords,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PartiesTableAnnotationComposer get partyId {
    final $$PartiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partyId,
      referencedTable: $db.parties,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartiesTableAnnotationComposer(
            $db: $db,
            $table: $db.parties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VendorCodesTableAnnotationComposer get vendorCodeId {
    final $$VendorCodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vendorCodeId,
      referencedTable: $db.vendorCodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorCodesTableAnnotationComposer(
            $db: $db,
            $table: $db.vendorCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SitesTableAnnotationComposer get siteId {
    final $$SitesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.siteId,
      referencedTable: $db.sites,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SitesTableAnnotationComposer(
            $db: $db,
            $table: $db.sites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> invoiceItemsRefs<T extends Object>(
    Expression<T> Function($$InvoiceItemsTableAnnotationComposer a) f,
  ) {
    final $$InvoiceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceItems,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.invoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoicesTable,
          Invoice,
          $$InvoicesTableFilterComposer,
          $$InvoicesTableOrderingComposer,
          $$InvoicesTableAnnotationComposer,
          $$InvoicesTableCreateCompanionBuilder,
          $$InvoicesTableUpdateCompanionBuilder,
          (Invoice, $$InvoicesTableReferences),
          Invoice,
          PrefetchHooks Function({
            bool companyId,
            bool partyId,
            bool vendorCodeId,
            bool siteId,
            bool invoiceItemsRefs,
          })
        > {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String?> partyId = const Value.absent(),
                Value<String> invoiceNumber = const Value.absent(),
                Value<DateTime> invoiceDate = const Value.absent(),
                Value<String?> poNumber = const Value.absent(),
                Value<String?> vendorCodeId = const Value.absent(),
                Value<String?> siteId = const Value.absent(),
                Value<String?> serviceEntry = const Value.absent(),
                Value<DateTime?> serviceFrom = const Value.absent(),
                Value<DateTime?> serviceTo = const Value.absent(),
                Value<String> companyNameSnapshot = const Value.absent(),
                Value<String?> companyAddress1Snapshot = const Value.absent(),
                Value<String?> companyAddress2Snapshot = const Value.absent(),
                Value<String?> companyAddress3Snapshot = const Value.absent(),
                Value<String?> companyPanSnapshot = const Value.absent(),
                Value<String?> companyGstinSnapshot = const Value.absent(),
                Value<String> partyNameSnapshot = const Value.absent(),
                Value<String?> partyAddress1Snapshot = const Value.absent(),
                Value<String?> partyAddress2Snapshot = const Value.absent(),
                Value<String?> partyAddress3Snapshot = const Value.absent(),
                Value<String?> partyPanSnapshot = const Value.absent(),
                Value<String?> partyGstinSnapshot = const Value.absent(),
                Value<String?> vendorCodeSnapshot = const Value.absent(),
                Value<String?> siteNameSnapshot = const Value.absent(),
                Value<String> taxType = const Value.absent(),
                Value<String> gstMode = const Value.absent(),
                Value<int> basicAmountPaise = const Value.absent(),
                Value<int> taxableAmountPaise = const Value.absent(),
                Value<double> cgstRate = const Value.absent(),
                Value<int> cgstAmountPaise = const Value.absent(),
                Value<double> sgstRate = const Value.absent(),
                Value<int> sgstAmountPaise = const Value.absent(),
                Value<double> igstRate = const Value.absent(),
                Value<int> igstAmountPaise = const Value.absent(),
                Value<int> grandTotalPaise = const Value.absent(),
                Value<String?> amountInWords = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicesCompanion(
                id: id,
                companyId: companyId,
                partyId: partyId,
                invoiceNumber: invoiceNumber,
                invoiceDate: invoiceDate,
                poNumber: poNumber,
                vendorCodeId: vendorCodeId,
                siteId: siteId,
                serviceEntry: serviceEntry,
                serviceFrom: serviceFrom,
                serviceTo: serviceTo,
                companyNameSnapshot: companyNameSnapshot,
                companyAddress1Snapshot: companyAddress1Snapshot,
                companyAddress2Snapshot: companyAddress2Snapshot,
                companyAddress3Snapshot: companyAddress3Snapshot,
                companyPanSnapshot: companyPanSnapshot,
                companyGstinSnapshot: companyGstinSnapshot,
                partyNameSnapshot: partyNameSnapshot,
                partyAddress1Snapshot: partyAddress1Snapshot,
                partyAddress2Snapshot: partyAddress2Snapshot,
                partyAddress3Snapshot: partyAddress3Snapshot,
                partyPanSnapshot: partyPanSnapshot,
                partyGstinSnapshot: partyGstinSnapshot,
                vendorCodeSnapshot: vendorCodeSnapshot,
                siteNameSnapshot: siteNameSnapshot,
                taxType: taxType,
                gstMode: gstMode,
                basicAmountPaise: basicAmountPaise,
                taxableAmountPaise: taxableAmountPaise,
                cgstRate: cgstRate,
                cgstAmountPaise: cgstAmountPaise,
                sgstRate: sgstRate,
                sgstAmountPaise: sgstAmountPaise,
                igstRate: igstRate,
                igstAmountPaise: igstAmountPaise,
                grandTotalPaise: grandTotalPaise,
                amountInWords: amountInWords,
                status: status,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String companyId,
                Value<String?> partyId = const Value.absent(),
                required String invoiceNumber,
                required DateTime invoiceDate,
                Value<String?> poNumber = const Value.absent(),
                Value<String?> vendorCodeId = const Value.absent(),
                Value<String?> siteId = const Value.absent(),
                Value<String?> serviceEntry = const Value.absent(),
                Value<DateTime?> serviceFrom = const Value.absent(),
                Value<DateTime?> serviceTo = const Value.absent(),
                required String companyNameSnapshot,
                Value<String?> companyAddress1Snapshot = const Value.absent(),
                Value<String?> companyAddress2Snapshot = const Value.absent(),
                Value<String?> companyAddress3Snapshot = const Value.absent(),
                Value<String?> companyPanSnapshot = const Value.absent(),
                Value<String?> companyGstinSnapshot = const Value.absent(),
                required String partyNameSnapshot,
                Value<String?> partyAddress1Snapshot = const Value.absent(),
                Value<String?> partyAddress2Snapshot = const Value.absent(),
                Value<String?> partyAddress3Snapshot = const Value.absent(),
                Value<String?> partyPanSnapshot = const Value.absent(),
                Value<String?> partyGstinSnapshot = const Value.absent(),
                Value<String?> vendorCodeSnapshot = const Value.absent(),
                Value<String?> siteNameSnapshot = const Value.absent(),
                Value<String> taxType = const Value.absent(),
                Value<String> gstMode = const Value.absent(),
                Value<int> basicAmountPaise = const Value.absent(),
                Value<int> taxableAmountPaise = const Value.absent(),
                Value<double> cgstRate = const Value.absent(),
                Value<int> cgstAmountPaise = const Value.absent(),
                Value<double> sgstRate = const Value.absent(),
                Value<int> sgstAmountPaise = const Value.absent(),
                Value<double> igstRate = const Value.absent(),
                Value<int> igstAmountPaise = const Value.absent(),
                Value<int> grandTotalPaise = const Value.absent(),
                Value<String?> amountInWords = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoicesCompanion.insert(
                id: id,
                companyId: companyId,
                partyId: partyId,
                invoiceNumber: invoiceNumber,
                invoiceDate: invoiceDate,
                poNumber: poNumber,
                vendorCodeId: vendorCodeId,
                siteId: siteId,
                serviceEntry: serviceEntry,
                serviceFrom: serviceFrom,
                serviceTo: serviceTo,
                companyNameSnapshot: companyNameSnapshot,
                companyAddress1Snapshot: companyAddress1Snapshot,
                companyAddress2Snapshot: companyAddress2Snapshot,
                companyAddress3Snapshot: companyAddress3Snapshot,
                companyPanSnapshot: companyPanSnapshot,
                companyGstinSnapshot: companyGstinSnapshot,
                partyNameSnapshot: partyNameSnapshot,
                partyAddress1Snapshot: partyAddress1Snapshot,
                partyAddress2Snapshot: partyAddress2Snapshot,
                partyAddress3Snapshot: partyAddress3Snapshot,
                partyPanSnapshot: partyPanSnapshot,
                partyGstinSnapshot: partyGstinSnapshot,
                vendorCodeSnapshot: vendorCodeSnapshot,
                siteNameSnapshot: siteNameSnapshot,
                taxType: taxType,
                gstMode: gstMode,
                basicAmountPaise: basicAmountPaise,
                taxableAmountPaise: taxableAmountPaise,
                cgstRate: cgstRate,
                cgstAmountPaise: cgstAmountPaise,
                sgstRate: sgstRate,
                sgstAmountPaise: sgstAmountPaise,
                igstRate: igstRate,
                igstAmountPaise: igstAmountPaise,
                grandTotalPaise: grandTotalPaise,
                amountInWords: amountInWords,
                status: status,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvoicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                companyId = false,
                partyId = false,
                vendorCodeId = false,
                siteId = false,
                invoiceItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (invoiceItemsRefs) db.invoiceItems,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (companyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.companyId,
                                    referencedTable: $$InvoicesTableReferences
                                        ._companyIdTable(db),
                                    referencedColumn: $$InvoicesTableReferences
                                        ._companyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (partyId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.partyId,
                                    referencedTable: $$InvoicesTableReferences
                                        ._partyIdTable(db),
                                    referencedColumn: $$InvoicesTableReferences
                                        ._partyIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (vendorCodeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.vendorCodeId,
                                    referencedTable: $$InvoicesTableReferences
                                        ._vendorCodeIdTable(db),
                                    referencedColumn: $$InvoicesTableReferences
                                        ._vendorCodeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (siteId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.siteId,
                                    referencedTable: $$InvoicesTableReferences
                                        ._siteIdTable(db),
                                    referencedColumn: $$InvoicesTableReferences
                                        ._siteIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (invoiceItemsRefs)
                        await $_getPrefetchedData<
                          Invoice,
                          $InvoicesTable,
                          InvoiceItem
                        >(
                          currentTable: table,
                          referencedTable: $$InvoicesTableReferences
                              ._invoiceItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).invoiceItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.invoiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoicesTable,
      Invoice,
      $$InvoicesTableFilterComposer,
      $$InvoicesTableOrderingComposer,
      $$InvoicesTableAnnotationComposer,
      $$InvoicesTableCreateCompanionBuilder,
      $$InvoicesTableUpdateCompanionBuilder,
      (Invoice, $$InvoicesTableReferences),
      Invoice,
      PrefetchHooks Function({
        bool companyId,
        bool partyId,
        bool vendorCodeId,
        bool siteId,
        bool invoiceItemsRefs,
      })
    >;
typedef $$InvoiceItemsTableCreateCompanionBuilder =
    InvoiceItemsCompanion Function({
      Value<String> id,
      required String invoiceId,
      required int serialNo,
      required String description,
      Value<String?> hsnSac,
      Value<double> quantity,
      Value<String?> unitId,
      Value<String?> unitCodeSnapshot,
      Value<int> ratePaise,
      Value<int> amountPaise,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$InvoiceItemsTableUpdateCompanionBuilder =
    InvoiceItemsCompanion Function({
      Value<String> id,
      Value<String> invoiceId,
      Value<int> serialNo,
      Value<String> description,
      Value<String?> hsnSac,
      Value<double> quantity,
      Value<String?> unitId,
      Value<String?> unitCodeSnapshot,
      Value<int> ratePaise,
      Value<int> amountPaise,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$InvoiceItemsTableReferences
    extends BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem> {
  $$InvoiceItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvoicesTable _invoiceIdTable(_$AppDatabase db) =>
      db.invoices.createAlias('invoice_items__invoice_id__invoices__id');

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<String>('invoice_id')!;

    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UnitsTable _unitIdTable(_$AppDatabase db) =>
      db.units.createAlias('invoice_items__unit_id__units__id');

  $$UnitsTableProcessedTableManager? get unitId {
    final $_column = $_itemColumn<String>('unit_id');
    if ($_column == null) return null;
    final manager = $$UnitsTableTableManager(
      $_db,
      $_db.units,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_unitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvoiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serialNo => $composableBuilder(
    column: $table.serialNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hsnSac => $composableBuilder(
    column: $table.hsnSac,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitCodeSnapshot => $composableBuilder(
    column: $table.unitCodeSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ratePaise => $composableBuilder(
    column: $table.ratePaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitsTableFilterComposer get unitId {
    final $$UnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitId,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableFilterComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serialNo => $composableBuilder(
    column: $table.serialNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hsnSac => $composableBuilder(
    column: $table.hsnSac,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitCodeSnapshot => $composableBuilder(
    column: $table.unitCodeSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ratePaise => $composableBuilder(
    column: $table.ratePaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitsTableOrderingComposer get unitId {
    final $$UnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitId,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableOrderingComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get serialNo =>
      $composableBuilder(column: $table.serialNo, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hsnSac =>
      $composableBuilder(column: $table.hsnSac, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unitCodeSnapshot => $composableBuilder(
    column: $table.unitCodeSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ratePaise =>
      $composableBuilder(column: $table.ratePaise, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
    column: $table.amountPaise,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UnitsTableAnnotationComposer get unitId {
    final $$UnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unitId,
      referencedTable: $db.units,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.units,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoiceItemsTable,
          InvoiceItem,
          $$InvoiceItemsTableFilterComposer,
          $$InvoiceItemsTableOrderingComposer,
          $$InvoiceItemsTableAnnotationComposer,
          $$InvoiceItemsTableCreateCompanionBuilder,
          $$InvoiceItemsTableUpdateCompanionBuilder,
          (InvoiceItem, $$InvoiceItemsTableReferences),
          InvoiceItem,
          PrefetchHooks Function({bool invoiceId, bool unitId})
        > {
  $$InvoiceItemsTableTableManager(_$AppDatabase db, $InvoiceItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> invoiceId = const Value.absent(),
                Value<int> serialNo = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> hsnSac = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String?> unitId = const Value.absent(),
                Value<String?> unitCodeSnapshot = const Value.absent(),
                Value<int> ratePaise = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoiceItemsCompanion(
                id: id,
                invoiceId: invoiceId,
                serialNo: serialNo,
                description: description,
                hsnSac: hsnSac,
                quantity: quantity,
                unitId: unitId,
                unitCodeSnapshot: unitCodeSnapshot,
                ratePaise: ratePaise,
                amountPaise: amountPaise,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String invoiceId,
                required int serialNo,
                required String description,
                Value<String?> hsnSac = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String?> unitId = const Value.absent(),
                Value<String?> unitCodeSnapshot = const Value.absent(),
                Value<int> ratePaise = const Value.absent(),
                Value<int> amountPaise = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvoiceItemsCompanion.insert(
                id: id,
                invoiceId: invoiceId,
                serialNo: serialNo,
                description: description,
                hsnSac: hsnSac,
                quantity: quantity,
                unitId: unitId,
                unitCodeSnapshot: unitCodeSnapshot,
                ratePaise: ratePaise,
                amountPaise: amountPaise,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvoiceItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({invoiceId = false, unitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (invoiceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.invoiceId,
                                referencedTable: $$InvoiceItemsTableReferences
                                    ._invoiceIdTable(db),
                                referencedColumn: $$InvoiceItemsTableReferences
                                    ._invoiceIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (unitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.unitId,
                                referencedTable: $$InvoiceItemsTableReferences
                                    ._unitIdTable(db),
                                referencedColumn: $$InvoiceItemsTableReferences
                                    ._unitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InvoiceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoiceItemsTable,
      InvoiceItem,
      $$InvoiceItemsTableFilterComposer,
      $$InvoiceItemsTableOrderingComposer,
      $$InvoiceItemsTableAnnotationComposer,
      $$InvoiceItemsTableCreateCompanionBuilder,
      $$InvoiceItemsTableUpdateCompanionBuilder,
      (InvoiceItem, $$InvoiceItemsTableReferences),
      InvoiceItem,
      PrefetchHooks Function({bool invoiceId, bool unitId})
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      required String companyId,
      required String title,
      Value<String?> content,
      Value<bool> isPinned,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> title,
      Value<String?> content,
      Value<bool> isPinned,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, Note> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias('notes__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, $$NotesTableReferences),
          Note,
          PrefetchHooks Function({bool companyId})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                companyId: companyId,
                title: title,
                content: content,
                isPinned: isPinned,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String companyId,
                required String title,
                Value<String?> content = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                companyId: companyId,
                title: title,
                content: content,
                isPinned: isPinned,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$NotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable: $$NotesTableReferences
                                    ._companyIdTable(db),
                                referencedColumn: $$NotesTableReferences
                                    ._companyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, $$NotesTableReferences),
      Note,
      PrefetchHooks Function({bool companyId})
    >;
typedef $$ImportBatchesTableCreateCompanionBuilder =
    ImportBatchesCompanion Function({
      Value<String> id,
      required String companyId,
      required String fileName,
      Value<String?> sourceHash,
      Value<int> totalRows,
      Value<int> importedCount,
      Value<int> skippedCount,
      Value<int> failedCount,
      Value<String> status,
      Value<String?> errorSummary,
      Value<DateTime> importedAt,
      Value<int> rowid,
    });
typedef $$ImportBatchesTableUpdateCompanionBuilder =
    ImportBatchesCompanion Function({
      Value<String> id,
      Value<String> companyId,
      Value<String> fileName,
      Value<String?> sourceHash,
      Value<int> totalRows,
      Value<int> importedCount,
      Value<int> skippedCount,
      Value<int> failedCount,
      Value<String> status,
      Value<String?> errorSummary,
      Value<DateTime> importedAt,
      Value<int> rowid,
    });

final class $$ImportBatchesTableReferences
    extends BaseReferences<_$AppDatabase, $ImportBatchesTable, ImportBatche> {
  $$ImportBatchesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CompaniesTable _companyIdTable(_$AppDatabase db) =>
      db.companies.createAlias('import_batches__company_id__companies__id');

  $$CompaniesTableProcessedTableManager get companyId {
    final $_column = $_itemColumn<String>('company_id')!;

    final manager = $$CompaniesTableTableManager(
      $_db,
      $_db.companies,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_companyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportBatchesTableFilterComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalRows => $composableBuilder(
    column: $table.totalRows,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importedCount => $composableBuilder(
    column: $table.importedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skippedCount => $composableBuilder(
    column: $table.skippedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorSummary => $composableBuilder(
    column: $table.errorSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CompaniesTableFilterComposer get companyId {
    final $$CompaniesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableFilterComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportBatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalRows => $composableBuilder(
    column: $table.totalRows,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importedCount => $composableBuilder(
    column: $table.importedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skippedCount => $composableBuilder(
    column: $table.skippedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorSummary => $composableBuilder(
    column: $table.errorSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CompaniesTableOrderingComposer get companyId {
    final $$CompaniesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableOrderingComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportBatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportBatchesTable> {
  $$ImportBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalRows =>
      $composableBuilder(column: $table.totalRows, builder: (column) => column);

  GeneratedColumn<int> get importedCount => $composableBuilder(
    column: $table.importedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get skippedCount => $composableBuilder(
    column: $table.skippedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failedCount => $composableBuilder(
    column: $table.failedCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorSummary => $composableBuilder(
    column: $table.errorSummary,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  $$CompaniesTableAnnotationComposer get companyId {
    final $$CompaniesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.companyId,
      referencedTable: $db.companies,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompaniesTableAnnotationComposer(
            $db: $db,
            $table: $db.companies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportBatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportBatchesTable,
          ImportBatche,
          $$ImportBatchesTableFilterComposer,
          $$ImportBatchesTableOrderingComposer,
          $$ImportBatchesTableAnnotationComposer,
          $$ImportBatchesTableCreateCompanionBuilder,
          $$ImportBatchesTableUpdateCompanionBuilder,
          (ImportBatche, $$ImportBatchesTableReferences),
          ImportBatche,
          PrefetchHooks Function({bool companyId})
        > {
  $$ImportBatchesTableTableManager(_$AppDatabase db, $ImportBatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> companyId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String?> sourceHash = const Value.absent(),
                Value<int> totalRows = const Value.absent(),
                Value<int> importedCount = const Value.absent(),
                Value<int> skippedCount = const Value.absent(),
                Value<int> failedCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorSummary = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportBatchesCompanion(
                id: id,
                companyId: companyId,
                fileName: fileName,
                sourceHash: sourceHash,
                totalRows: totalRows,
                importedCount: importedCount,
                skippedCount: skippedCount,
                failedCount: failedCount,
                status: status,
                errorSummary: errorSummary,
                importedAt: importedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String companyId,
                required String fileName,
                Value<String?> sourceHash = const Value.absent(),
                Value<int> totalRows = const Value.absent(),
                Value<int> importedCount = const Value.absent(),
                Value<int> skippedCount = const Value.absent(),
                Value<int> failedCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorSummary = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportBatchesCompanion.insert(
                id: id,
                companyId: companyId,
                fileName: fileName,
                sourceHash: sourceHash,
                totalRows: totalRows,
                importedCount: importedCount,
                skippedCount: skippedCount,
                failedCount: failedCount,
                status: status,
                errorSummary: errorSummary,
                importedAt: importedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportBatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({companyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (companyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.companyId,
                                referencedTable: $$ImportBatchesTableReferences
                                    ._companyIdTable(db),
                                referencedColumn: $$ImportBatchesTableReferences
                                    ._companyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImportBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportBatchesTable,
      ImportBatche,
      $$ImportBatchesTableFilterComposer,
      $$ImportBatchesTableOrderingComposer,
      $$ImportBatchesTableAnnotationComposer,
      $$ImportBatchesTableCreateCompanionBuilder,
      $$ImportBatchesTableUpdateCompanionBuilder,
      (ImportBatche, $$ImportBatchesTableReferences),
      ImportBatche,
      PrefetchHooks Function({bool companyId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CompaniesTableTableManager get companies =>
      $$CompaniesTableTableManager(_db, _db.companies);
  $$PartiesTableTableManager get parties =>
      $$PartiesTableTableManager(_db, _db.parties);
  $$VendorCodesTableTableManager get vendorCodes =>
      $$VendorCodesTableTableManager(_db, _db.vendorCodes);
  $$SitesTableTableManager get sites =>
      $$SitesTableTableManager(_db, _db.sites);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db, _db.units);
  $$TaxRatesTableTableManager get taxRates =>
      $$TaxRatesTableTableManager(_db, _db.taxRates);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceItemsTableTableManager get invoiceItems =>
      $$InvoiceItemsTableTableManager(_db, _db.invoiceItems);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$ImportBatchesTableTableManager get importBatches =>
      $$ImportBatchesTableTableManager(_db, _db.importBatches);
}
