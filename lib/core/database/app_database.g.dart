// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AuthProvider, String> provider =
      GeneratedColumn<String>(
        'provider',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AuthProvider>($UsersTable.$converterprovider);
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
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
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastLoginAtMeta = const VerificationMeta(
    'lastLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
    'last_login_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    provider,
    subjectId,
    name,
    email,
    photoUrl,
    createdAt,
    lastLoginAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
        _lastLoginAtMeta,
        lastLoginAt.isAcceptableOrUnknown(
          data['last_login_at']!,
          _lastLoginAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastLoginAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      provider: $UsersTable.$converterprovider.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}provider'],
        )!,
      ),
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AuthProvider, String, String> $converterprovider =
      const EnumNameConverter<AuthProvider>(AuthProvider.values);
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final String id;
  final AuthProvider provider;
  final String? subjectId;
  final String? name;
  final String? email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  const UserRow({
    required this.id,
    required this.provider,
    this.subjectId,
    this.name,
    this.email,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['provider'] = Variable<String>(
        $UsersTable.$converterprovider.toSql(provider),
      );
    }
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<String>(subjectId);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      provider: Value(provider),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      createdAt: Value(createdAt),
      lastLoginAt: Value(lastLoginAt),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<String>(json['id']),
      provider: $UsersTable.$converterprovider.fromJson(
        serializer.fromJson<String>(json['provider']),
      ),
      subjectId: serializer.fromJson<String?>(json['subjectId']),
      name: serializer.fromJson<String?>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastLoginAt: serializer.fromJson<DateTime>(json['lastLoginAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'provider': serializer.toJson<String>(
        $UsersTable.$converterprovider.toJson(provider),
      ),
      'subjectId': serializer.toJson<String?>(subjectId),
      'name': serializer.toJson<String?>(name),
      'email': serializer.toJson<String?>(email),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastLoginAt': serializer.toJson<DateTime>(lastLoginAt),
    };
  }

  UserRow copyWith({
    String? id,
    AuthProvider? provider,
    Value<String?> subjectId = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> photoUrl = const Value.absent(),
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) => UserRow(
    id: id ?? this.id,
    provider: provider ?? this.provider,
    subjectId: subjectId.present ? subjectId.value : this.subjectId,
    name: name.present ? name.value : this.name,
    email: email.present ? email.value : this.email,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    createdAt: createdAt ?? this.createdAt,
    lastLoginAt: lastLoginAt ?? this.lastLoginAt,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      provider: data.provider.present ? data.provider.value : this.provider,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('subjectId: $subjectId, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastLoginAt: $lastLoginAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    provider,
    subjectId,
    name,
    email,
    photoUrl,
    createdAt,
    lastLoginAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.provider == this.provider &&
          other.subjectId == this.subjectId &&
          other.name == this.name &&
          other.email == this.email &&
          other.photoUrl == this.photoUrl &&
          other.createdAt == this.createdAt &&
          other.lastLoginAt == this.lastLoginAt);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<String> id;
  final Value<AuthProvider> provider;
  final Value<String?> subjectId;
  final Value<String?> name;
  final Value<String?> email;
  final Value<String?> photoUrl;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastLoginAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.provider = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required AuthProvider provider,
    this.subjectId = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.photoUrl = const Value.absent(),
    required DateTime createdAt,
    required DateTime lastLoginAt,
    this.rowid = const Value.absent(),
  }) : provider = Value(provider),
       createdAt = Value(createdAt),
       lastLoginAt = Value(lastLoginAt);
  static Insertable<UserRow> custom({
    Expression<String>? id,
    Expression<String>? provider,
    Expression<String>? subjectId,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? photoUrl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastLoginAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (provider != null) 'provider': provider,
      if (subjectId != null) 'subject_id': subjectId,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<AuthProvider>? provider,
    Value<String?>? subjectId,
    Value<String?>? name,
    Value<String?>? email,
    Value<String?>? photoUrl,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastLoginAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(
        $UsersTable.$converterprovider.toSql(provider.value),
      );
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('provider: $provider, ')
          ..write('subjectId: $subjectId, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 7,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repositoryUrlMeta = const VerificationMeta(
    'repositoryUrl',
  );
  @override
  late final GeneratedColumn<String> repositoryUrl = GeneratedColumn<String>(
    'repository_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProjectOrigin, String> origin =
      GeneratedColumn<String>(
        'origin',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ProjectOrigin>($ProjectsTable.$converterorigin);
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorHex,
    repositoryUrl,
    origin,
    confidence,
    createdAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('repository_url')) {
      context.handle(
        _repositoryUrlMeta,
        repositoryUrl.isAcceptableOrUnknown(
          data['repository_url']!,
          _repositoryUrlMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      repositoryUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repository_url'],
      ),
      origin: $ProjectsTable.$converterorigin.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}origin'],
        )!,
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProjectOrigin, String, String> $converterorigin =
      const EnumNameConverter<ProjectOrigin>(ProjectOrigin.values);
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final String name;
  final String colorHex;
  final String? repositoryUrl;
  final ProjectOrigin origin;

  /// Set when [origin] is discovered, from 0 to 1.
  final double? confidence;
  final DateTime createdAt;
  final DateTime? archivedAt;
  const Project({
    required this.id,
    required this.name,
    required this.colorHex,
    this.repositoryUrl,
    required this.origin,
    this.confidence,
    required this.createdAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_hex'] = Variable<String>(colorHex);
    if (!nullToAbsent || repositoryUrl != null) {
      map['repository_url'] = Variable<String>(repositoryUrl);
    }
    {
      map['origin'] = Variable<String>(
        $ProjectsTable.$converterorigin.toSql(origin),
      );
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: Value(colorHex),
      repositoryUrl: repositoryUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(repositoryUrl),
      origin: Value(origin),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      repositoryUrl: serializer.fromJson<String?>(json['repositoryUrl']),
      origin: $ProjectsTable.$converterorigin.fromJson(
        serializer.fromJson<String>(json['origin']),
      ),
      confidence: serializer.fromJson<double?>(json['confidence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'repositoryUrl': serializer.toJson<String?>(repositoryUrl),
      'origin': serializer.toJson<String>(
        $ProjectsTable.$converterorigin.toJson(origin),
      ),
      'confidence': serializer.toJson<double?>(confidence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  Project copyWith({
    String? id,
    String? name,
    String? colorHex,
    Value<String?> repositoryUrl = const Value.absent(),
    ProjectOrigin? origin,
    Value<double?> confidence = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    colorHex: colorHex ?? this.colorHex,
    repositoryUrl: repositoryUrl.present
        ? repositoryUrl.value
        : this.repositoryUrl,
    origin: origin ?? this.origin,
    confidence: confidence.present ? confidence.value : this.confidence,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      repositoryUrl: data.repositoryUrl.present
          ? data.repositoryUrl.value
          : this.repositoryUrl,
      origin: data.origin.present ? data.origin.value : this.origin,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('repositoryUrl: $repositoryUrl, ')
          ..write('origin: $origin, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    colorHex,
    repositoryUrl,
    origin,
    confidence,
    createdAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.repositoryUrl == this.repositoryUrl &&
          other.origin == this.origin &&
          other.confidence == this.confidence &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> colorHex;
  final Value<String?> repositoryUrl;
  final Value<ProjectOrigin> origin;
  final Value<double?> confidence;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.repositoryUrl = const Value.absent(),
    this.origin = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String colorHex,
    this.repositoryUrl = const Value.absent(),
    required ProjectOrigin origin,
    this.confidence = const Value.absent(),
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       colorHex = Value(colorHex),
       origin = Value(origin),
       createdAt = Value(createdAt);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<String>? repositoryUrl,
    Expression<String>? origin,
    Expression<double>? confidence,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (repositoryUrl != null) 'repository_url': repositoryUrl,
      if (origin != null) 'origin': origin,
      if (confidence != null) 'confidence': confidence,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? colorHex,
    Value<String?>? repositoryUrl,
    Value<ProjectOrigin>? origin,
    Value<double?>? confidence,
    Value<DateTime>? createdAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
      origin: origin ?? this.origin,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (repositoryUrl.present) {
      map['repository_url'] = Variable<String>(repositoryUrl.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(
        $ProjectsTable.$converterorigin.toSql(origin.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('repositoryUrl: $repositoryUrl, ')
          ..write('origin: $origin, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectRulesTable extends ProjectRules
    with TableInfo<$ProjectRulesTable, ProjectRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<RuleKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RuleKind>($ProjectRulesTable.$converterkind);
  static const VerificationMeta _patternMeta = const VerificationMeta(
    'pattern',
  );
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
    'pattern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    kind,
    pattern,
    enabled,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('pattern')) {
      context.handle(
        _patternMeta,
        pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta),
      );
    } else if (isInserting) {
      context.missing(_patternMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      kind: $ProjectRulesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      pattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProjectRulesTable createAlias(String alias) {
    return $ProjectRulesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RuleKind, String, String> $converterkind =
      const EnumNameConverter<RuleKind>(RuleKind.values);
}

class ProjectRule extends DataClass implements Insertable<ProjectRule> {
  final String id;
  final String projectId;
  final RuleKind kind;
  final String pattern;
  final bool enabled;
  final DateTime createdAt;
  const ProjectRule({
    required this.id,
    required this.projectId,
    required this.kind,
    required this.pattern,
    required this.enabled,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    {
      map['kind'] = Variable<String>(
        $ProjectRulesTable.$converterkind.toSql(kind),
      );
    }
    map['pattern'] = Variable<String>(pattern);
    map['enabled'] = Variable<bool>(enabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProjectRulesCompanion toCompanion(bool nullToAbsent) {
    return ProjectRulesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      kind: Value(kind),
      pattern: Value(pattern),
      enabled: Value(enabled),
      createdAt: Value(createdAt),
    );
  }

  factory ProjectRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectRule(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      kind: $ProjectRulesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      pattern: serializer.fromJson<String>(json['pattern']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'kind': serializer.toJson<String>(
        $ProjectRulesTable.$converterkind.toJson(kind),
      ),
      'pattern': serializer.toJson<String>(pattern),
      'enabled': serializer.toJson<bool>(enabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ProjectRule copyWith({
    String? id,
    String? projectId,
    RuleKind? kind,
    String? pattern,
    bool? enabled,
    DateTime? createdAt,
  }) => ProjectRule(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    kind: kind ?? this.kind,
    pattern: pattern ?? this.pattern,
    enabled: enabled ?? this.enabled,
    createdAt: createdAt ?? this.createdAt,
  );
  ProjectRule copyWithCompanion(ProjectRulesCompanion data) {
    return ProjectRule(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      kind: data.kind.present ? data.kind.value : this.kind,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectRule(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('kind: $kind, ')
          ..write('pattern: $pattern, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, projectId, kind, pattern, enabled, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectRule &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.kind == this.kind &&
          other.pattern == this.pattern &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt);
}

class ProjectRulesCompanion extends UpdateCompanion<ProjectRule> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<RuleKind> kind;
  final Value<String> pattern;
  final Value<bool> enabled;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ProjectRulesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.kind = const Value.absent(),
    this.pattern = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectRulesCompanion.insert({
    this.id = const Value.absent(),
    required String projectId,
    required RuleKind kind,
    required String pattern,
    this.enabled = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : projectId = Value(projectId),
       kind = Value(kind),
       pattern = Value(pattern),
       createdAt = Value(createdAt);
  static Insertable<ProjectRule> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? kind,
    Expression<String>? pattern,
    Expression<bool>? enabled,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (kind != null) 'kind': kind,
      if (pattern != null) 'pattern': pattern,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<RuleKind>? kind,
    Value<String>? pattern,
    Value<bool>? enabled,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ProjectRulesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      kind: kind ?? this.kind,
      pattern: pattern ?? this.pattern,
      enabled: enabled ?? this.enabled,
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
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ProjectRulesTable.$converterkind.toSql(kind.value),
      );
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
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
    return (StringBuffer('ProjectRulesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('kind: $kind, ')
          ..write('pattern: $pattern, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DataSourcesTable extends DataSources
    with TableInfo<$DataSourcesTable, DataSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DataSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SourceKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SourceKind>($DataSourcesTable.$converterkind);
  @override
  late final GeneratedColumnWithTypeConverter<SourceStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SourceStatus>($DataSourcesTable.$converterstatus);
  static const VerificationMeta _accountLabelMeta = const VerificationMeta(
    'accountLabel',
  );
  @override
  late final GeneratedColumn<String> accountLabel = GeneratedColumn<String>(
    'account_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grantedScopesMeta = const VerificationMeta(
    'grantedScopes',
  );
  @override
  late final GeneratedColumn<String> grantedScopes = GeneratedColumn<String>(
    'granted_scopes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncCursorMeta = const VerificationMeta(
    'syncCursor',
  );
  @override
  late final GeneratedColumn<String> syncCursor = GeneratedColumn<String>(
    'sync_cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _connectedAtMeta = const VerificationMeta(
    'connectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> connectedAt = GeneratedColumn<DateTime>(
    'connected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    status,
    accountLabel,
    host,
    grantedScopes,
    syncCursor,
    lastSyncedAt,
    connectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'data_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<DataSource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_label')) {
      context.handle(
        _accountLabelMeta,
        accountLabel.isAcceptableOrUnknown(
          data['account_label']!,
          _accountLabelMeta,
        ),
      );
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    }
    if (data.containsKey('granted_scopes')) {
      context.handle(
        _grantedScopesMeta,
        grantedScopes.isAcceptableOrUnknown(
          data['granted_scopes']!,
          _grantedScopesMeta,
        ),
      );
    }
    if (data.containsKey('sync_cursor')) {
      context.handle(
        _syncCursorMeta,
        syncCursor.isAcceptableOrUnknown(data['sync_cursor']!, _syncCursorMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('connected_at')) {
      context.handle(
        _connectedAtMeta,
        connectedAt.isAcceptableOrUnknown(
          data['connected_at']!,
          _connectedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_connectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DataSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DataSource(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: $DataSourcesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      status: $DataSourcesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      accountLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_label'],
      ),
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      ),
      grantedScopes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}granted_scopes'],
      ),
      syncCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_cursor'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      connectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}connected_at'],
      )!,
    );
  }

  @override
  $DataSourcesTable createAlias(String alias) {
    return $DataSourcesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SourceKind, String, String> $converterkind =
      const EnumNameConverter<SourceKind>(SourceKind.values);
  static JsonTypeConverter2<SourceStatus, String, String> $converterstatus =
      const EnumNameConverter<SourceStatus>(SourceStatus.values);
}

class DataSource extends DataClass implements Insertable<DataSource> {
  final String id;
  final SourceKind kind;
  final SourceStatus status;
  final String? accountLabel;

  /// Instance address for GitHub Enterprise and self-managed GitLab.
  final String? host;
  final String? grantedScopes;

  /// Opaque incremental-sync position.
  final String? syncCursor;
  final DateTime? lastSyncedAt;
  final DateTime connectedAt;
  const DataSource({
    required this.id,
    required this.kind,
    required this.status,
    this.accountLabel,
    this.host,
    this.grantedScopes,
    this.syncCursor,
    this.lastSyncedAt,
    required this.connectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['kind'] = Variable<String>(
        $DataSourcesTable.$converterkind.toSql(kind),
      );
    }
    {
      map['status'] = Variable<String>(
        $DataSourcesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || accountLabel != null) {
      map['account_label'] = Variable<String>(accountLabel);
    }
    if (!nullToAbsent || host != null) {
      map['host'] = Variable<String>(host);
    }
    if (!nullToAbsent || grantedScopes != null) {
      map['granted_scopes'] = Variable<String>(grantedScopes);
    }
    if (!nullToAbsent || syncCursor != null) {
      map['sync_cursor'] = Variable<String>(syncCursor);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['connected_at'] = Variable<DateTime>(connectedAt);
    return map;
  }

  DataSourcesCompanion toCompanion(bool nullToAbsent) {
    return DataSourcesCompanion(
      id: Value(id),
      kind: Value(kind),
      status: Value(status),
      accountLabel: accountLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(accountLabel),
      host: host == null && nullToAbsent ? const Value.absent() : Value(host),
      grantedScopes: grantedScopes == null && nullToAbsent
          ? const Value.absent()
          : Value(grantedScopes),
      syncCursor: syncCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(syncCursor),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      connectedAt: Value(connectedAt),
    );
  }

  factory DataSource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DataSource(
      id: serializer.fromJson<String>(json['id']),
      kind: $DataSourcesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      status: $DataSourcesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      accountLabel: serializer.fromJson<String?>(json['accountLabel']),
      host: serializer.fromJson<String?>(json['host']),
      grantedScopes: serializer.fromJson<String?>(json['grantedScopes']),
      syncCursor: serializer.fromJson<String?>(json['syncCursor']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      connectedAt: serializer.fromJson<DateTime>(json['connectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(
        $DataSourcesTable.$converterkind.toJson(kind),
      ),
      'status': serializer.toJson<String>(
        $DataSourcesTable.$converterstatus.toJson(status),
      ),
      'accountLabel': serializer.toJson<String?>(accountLabel),
      'host': serializer.toJson<String?>(host),
      'grantedScopes': serializer.toJson<String?>(grantedScopes),
      'syncCursor': serializer.toJson<String?>(syncCursor),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'connectedAt': serializer.toJson<DateTime>(connectedAt),
    };
  }

  DataSource copyWith({
    String? id,
    SourceKind? kind,
    SourceStatus? status,
    Value<String?> accountLabel = const Value.absent(),
    Value<String?> host = const Value.absent(),
    Value<String?> grantedScopes = const Value.absent(),
    Value<String?> syncCursor = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    DateTime? connectedAt,
  }) => DataSource(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    status: status ?? this.status,
    accountLabel: accountLabel.present ? accountLabel.value : this.accountLabel,
    host: host.present ? host.value : this.host,
    grantedScopes: grantedScopes.present
        ? grantedScopes.value
        : this.grantedScopes,
    syncCursor: syncCursor.present ? syncCursor.value : this.syncCursor,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    connectedAt: connectedAt ?? this.connectedAt,
  );
  DataSource copyWithCompanion(DataSourcesCompanion data) {
    return DataSource(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      status: data.status.present ? data.status.value : this.status,
      accountLabel: data.accountLabel.present
          ? data.accountLabel.value
          : this.accountLabel,
      host: data.host.present ? data.host.value : this.host,
      grantedScopes: data.grantedScopes.present
          ? data.grantedScopes.value
          : this.grantedScopes,
      syncCursor: data.syncCursor.present
          ? data.syncCursor.value
          : this.syncCursor,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      connectedAt: data.connectedAt.present
          ? data.connectedAt.value
          : this.connectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DataSource(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('accountLabel: $accountLabel, ')
          ..write('host: $host, ')
          ..write('grantedScopes: $grantedScopes, ')
          ..write('syncCursor: $syncCursor, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('connectedAt: $connectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    status,
    accountLabel,
    host,
    grantedScopes,
    syncCursor,
    lastSyncedAt,
    connectedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DataSource &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.status == this.status &&
          other.accountLabel == this.accountLabel &&
          other.host == this.host &&
          other.grantedScopes == this.grantedScopes &&
          other.syncCursor == this.syncCursor &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.connectedAt == this.connectedAt);
}

class DataSourcesCompanion extends UpdateCompanion<DataSource> {
  final Value<String> id;
  final Value<SourceKind> kind;
  final Value<SourceStatus> status;
  final Value<String?> accountLabel;
  final Value<String?> host;
  final Value<String?> grantedScopes;
  final Value<String?> syncCursor;
  final Value<DateTime?> lastSyncedAt;
  final Value<DateTime> connectedAt;
  final Value<int> rowid;
  const DataSourcesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.status = const Value.absent(),
    this.accountLabel = const Value.absent(),
    this.host = const Value.absent(),
    this.grantedScopes = const Value.absent(),
    this.syncCursor = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.connectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DataSourcesCompanion.insert({
    this.id = const Value.absent(),
    required SourceKind kind,
    required SourceStatus status,
    this.accountLabel = const Value.absent(),
    this.host = const Value.absent(),
    this.grantedScopes = const Value.absent(),
    this.syncCursor = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required DateTime connectedAt,
    this.rowid = const Value.absent(),
  }) : kind = Value(kind),
       status = Value(status),
       connectedAt = Value(connectedAt);
  static Insertable<DataSource> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? status,
    Expression<String>? accountLabel,
    Expression<String>? host,
    Expression<String>? grantedScopes,
    Expression<String>? syncCursor,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? connectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (status != null) 'status': status,
      if (accountLabel != null) 'account_label': accountLabel,
      if (host != null) 'host': host,
      if (grantedScopes != null) 'granted_scopes': grantedScopes,
      if (syncCursor != null) 'sync_cursor': syncCursor,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (connectedAt != null) 'connected_at': connectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DataSourcesCompanion copyWith({
    Value<String>? id,
    Value<SourceKind>? kind,
    Value<SourceStatus>? status,
    Value<String?>? accountLabel,
    Value<String?>? host,
    Value<String?>? grantedScopes,
    Value<String?>? syncCursor,
    Value<DateTime?>? lastSyncedAt,
    Value<DateTime>? connectedAt,
    Value<int>? rowid,
  }) {
    return DataSourcesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      status: status ?? this.status,
      accountLabel: accountLabel ?? this.accountLabel,
      host: host ?? this.host,
      grantedScopes: grantedScopes ?? this.grantedScopes,
      syncCursor: syncCursor ?? this.syncCursor,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      connectedAt: connectedAt ?? this.connectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $DataSourcesTable.$converterkind.toSql(kind.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $DataSourcesTable.$converterstatus.toSql(status.value),
      );
    }
    if (accountLabel.present) {
      map['account_label'] = Variable<String>(accountLabel.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (grantedScopes.present) {
      map['granted_scopes'] = Variable<String>(grantedScopes.value);
    }
    if (syncCursor.present) {
      map['sync_cursor'] = Variable<String>(syncCursor.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (connectedAt.present) {
      map['connected_at'] = Variable<DateTime>(connectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DataSourcesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('status: $status, ')
          ..write('accountLabel: $accountLabel, ')
          ..write('host: $host, ')
          ..write('grantedScopes: $grantedScopes, ')
          ..write('syncCursor: $syncCursor, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('connectedAt: $connectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PairedDevicesTable extends PairedDevices
    with TableInfo<$PairedDevicesTable, PairedDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PairedDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES data_sources (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DeviceKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DeviceKind>($PairedDevicesTable.$converterkind);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<String> publicKey = GeneratedColumn<String>(
    'public_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pairedAtMeta = const VerificationMeta(
    'pairedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pairedAt = GeneratedColumn<DateTime>(
    'paired_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    kind,
    name,
    publicKey,
    pairedAt,
    lastSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'paired_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<PairedDevice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('paired_at')) {
      context.handle(
        _pairedAtMeta,
        pairedAt.isAcceptableOrUnknown(data['paired_at']!, _pairedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_pairedAtMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PairedDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PairedDevice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      kind: $PairedDevicesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}public_key'],
      )!,
      pairedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paired_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
    );
  }

  @override
  $PairedDevicesTable createAlias(String alias) {
    return $PairedDevicesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DeviceKind, String, String> $converterkind =
      const EnumNameConverter<DeviceKind>(DeviceKind.values);
}

class PairedDevice extends DataClass implements Insertable<PairedDevice> {
  final String id;
  final String sourceId;
  final DeviceKind kind;
  final String name;

  /// Public key that verifies events signed by this device.
  final String publicKey;
  final DateTime pairedAt;
  final DateTime? lastSeenAt;
  const PairedDevice({
    required this.id,
    required this.sourceId,
    required this.kind,
    required this.name,
    required this.publicKey,
    required this.pairedAt,
    this.lastSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    {
      map['kind'] = Variable<String>(
        $PairedDevicesTable.$converterkind.toSql(kind),
      );
    }
    map['name'] = Variable<String>(name);
    map['public_key'] = Variable<String>(publicKey);
    map['paired_at'] = Variable<DateTime>(pairedAt);
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    return map;
  }

  PairedDevicesCompanion toCompanion(bool nullToAbsent) {
    return PairedDevicesCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      kind: Value(kind),
      name: Value(name),
      publicKey: Value(publicKey),
      pairedAt: Value(pairedAt),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
    );
  }

  factory PairedDevice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PairedDevice(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      kind: $PairedDevicesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      name: serializer.fromJson<String>(json['name']),
      publicKey: serializer.fromJson<String>(json['publicKey']),
      pairedAt: serializer.fromJson<DateTime>(json['pairedAt']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'kind': serializer.toJson<String>(
        $PairedDevicesTable.$converterkind.toJson(kind),
      ),
      'name': serializer.toJson<String>(name),
      'publicKey': serializer.toJson<String>(publicKey),
      'pairedAt': serializer.toJson<DateTime>(pairedAt),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
    };
  }

  PairedDevice copyWith({
    String? id,
    String? sourceId,
    DeviceKind? kind,
    String? name,
    String? publicKey,
    DateTime? pairedAt,
    Value<DateTime?> lastSeenAt = const Value.absent(),
  }) => PairedDevice(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    publicKey: publicKey ?? this.publicKey,
    pairedAt: pairedAt ?? this.pairedAt,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
  );
  PairedDevice copyWithCompanion(PairedDevicesCompanion data) {
    return PairedDevice(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      pairedAt: data.pairedAt.present ? data.pairedAt.value : this.pairedAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PairedDevice(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('publicKey: $publicKey, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sourceId, kind, name, publicKey, pairedAt, lastSeenAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PairedDevice &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.publicKey == this.publicKey &&
          other.pairedAt == this.pairedAt &&
          other.lastSeenAt == this.lastSeenAt);
}

class PairedDevicesCompanion extends UpdateCompanion<PairedDevice> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<DeviceKind> kind;
  final Value<String> name;
  final Value<String> publicKey;
  final Value<DateTime> pairedAt;
  final Value<DateTime?> lastSeenAt;
  final Value<int> rowid;
  const PairedDevicesCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.pairedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PairedDevicesCompanion.insert({
    this.id = const Value.absent(),
    required String sourceId,
    required DeviceKind kind,
    required String name,
    required String publicKey,
    required DateTime pairedAt,
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       kind = Value(kind),
       name = Value(name),
       publicKey = Value(publicKey),
       pairedAt = Value(pairedAt);
  static Insertable<PairedDevice> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? publicKey,
    Expression<DateTime>? pairedAt,
    Expression<DateTime>? lastSeenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (publicKey != null) 'public_key': publicKey,
      if (pairedAt != null) 'paired_at': pairedAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PairedDevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceId,
    Value<DeviceKind>? kind,
    Value<String>? name,
    Value<String>? publicKey,
    Value<DateTime>? pairedAt,
    Value<DateTime?>? lastSeenAt,
    Value<int>? rowid,
  }) {
    return PairedDevicesCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      publicKey: publicKey ?? this.publicKey,
      pairedAt: pairedAt ?? this.pairedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $PairedDevicesTable.$converterkind.toSql(kind.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<String>(publicKey.value);
    }
    if (pairedAt.present) {
      map['paired_at'] = Variable<DateTime>(pairedAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PairedDevicesCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('publicKey: $publicKey, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackedRepositoriesTable extends TrackedRepositories
    with TableInfo<$TrackedRepositoriesTable, TrackedRepository> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackedRepositoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES data_sources (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _ignoredMeta = const VerificationMeta(
    'ignored',
  );
  @override
  late final GeneratedColumn<bool> ignored = GeneratedColumn<bool>(
    'ignored',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ignored" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    fullName,
    projectId,
    ignored,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracked_repositories';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackedRepository> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('ignored')) {
      context.handle(
        _ignoredMeta,
        ignored.isAcceptableOrUnknown(data['ignored']!, _ignoredMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackedRepository map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackedRepository(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      ignored: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ignored'],
      )!,
    );
  }

  @override
  $TrackedRepositoriesTable createAlias(String alias) {
    return $TrackedRepositoriesTable(attachedDatabase, alias);
  }
}

class TrackedRepository extends DataClass
    implements Insertable<TrackedRepository> {
  final String id;
  final String sourceId;
  final String fullName;
  final String? projectId;
  final bool ignored;
  const TrackedRepository({
    required this.id,
    required this.sourceId,
    required this.fullName,
    this.projectId,
    required this.ignored,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['ignored'] = Variable<bool>(ignored);
    return map;
  }

  TrackedRepositoriesCompanion toCompanion(bool nullToAbsent) {
    return TrackedRepositoriesCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      fullName: Value(fullName),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      ignored: Value(ignored),
    );
  }

  factory TrackedRepository.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackedRepository(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      fullName: serializer.fromJson<String>(json['fullName']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      ignored: serializer.fromJson<bool>(json['ignored']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'fullName': serializer.toJson<String>(fullName),
      'projectId': serializer.toJson<String?>(projectId),
      'ignored': serializer.toJson<bool>(ignored),
    };
  }

  TrackedRepository copyWith({
    String? id,
    String? sourceId,
    String? fullName,
    Value<String?> projectId = const Value.absent(),
    bool? ignored,
  }) => TrackedRepository(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    fullName: fullName ?? this.fullName,
    projectId: projectId.present ? projectId.value : this.projectId,
    ignored: ignored ?? this.ignored,
  );
  TrackedRepository copyWithCompanion(TrackedRepositoriesCompanion data) {
    return TrackedRepository(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      ignored: data.ignored.present ? data.ignored.value : this.ignored,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackedRepository(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('fullName: $fullName, ')
          ..write('projectId: $projectId, ')
          ..write('ignored: $ignored')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sourceId, fullName, projectId, ignored);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackedRepository &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.fullName == this.fullName &&
          other.projectId == this.projectId &&
          other.ignored == this.ignored);
}

class TrackedRepositoriesCompanion extends UpdateCompanion<TrackedRepository> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<String> fullName;
  final Value<String?> projectId;
  final Value<bool> ignored;
  final Value<int> rowid;
  const TrackedRepositoriesCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.fullName = const Value.absent(),
    this.projectId = const Value.absent(),
    this.ignored = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackedRepositoriesCompanion.insert({
    this.id = const Value.absent(),
    required String sourceId,
    required String fullName,
    this.projectId = const Value.absent(),
    this.ignored = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       fullName = Value(fullName);
  static Insertable<TrackedRepository> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? fullName,
    Expression<String>? projectId,
    Expression<bool>? ignored,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (fullName != null) 'full_name': fullName,
      if (projectId != null) 'project_id': projectId,
      if (ignored != null) 'ignored': ignored,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackedRepositoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceId,
    Value<String>? fullName,
    Value<String?>? projectId,
    Value<bool>? ignored,
    Value<int>? rowid,
  }) {
    return TrackedRepositoriesCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      fullName: fullName ?? this.fullName,
      projectId: projectId ?? this.projectId,
      ignored: ignored ?? this.ignored,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (ignored.present) {
      map['ignored'] = Variable<bool>(ignored.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackedRepositoriesCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('fullName: $fullName, ')
          ..write('projectId: $projectId, ')
          ..write('ignored: $ignored, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkSessionsTable extends WorkSessions
    with TableInfo<$WorkSessionsTable, WorkSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE SET NULL',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivityCategory, String>
  category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ActivityCategory>($WorkSessionsTable.$convertercategory);
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    category,
    startedAt,
    endedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      category: $WorkSessionsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      )!,
    );
  }

  @override
  $WorkSessionsTable createAlias(String alias) {
    return $WorkSessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActivityCategory, String, String>
  $convertercategory = const EnumNameConverter<ActivityCategory>(
    ActivityCategory.values,
  );
}

class WorkSession extends DataClass implements Insertable<WorkSession> {
  final String id;
  final String? projectId;
  final ActivityCategory category;
  final DateTime startedAt;
  final DateTime endedAt;
  const WorkSession({
    required this.id,
    this.projectId,
    required this.category,
    required this.startedAt,
    required this.endedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    {
      map['category'] = Variable<String>(
        $WorkSessionsTable.$convertercategory.toSql(category),
      );
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    map['ended_at'] = Variable<DateTime>(endedAt);
    return map;
  }

  WorkSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkSessionsCompanion(
      id: Value(id),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      category: Value(category),
      startedAt: Value(startedAt),
      endedAt: Value(endedAt),
    );
  }

  factory WorkSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkSession(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      category: $WorkSessionsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String?>(projectId),
      'category': serializer.toJson<String>(
        $WorkSessionsTable.$convertercategory.toJson(category),
      ),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime>(endedAt),
    };
  }

  WorkSession copyWith({
    String? id,
    Value<String?> projectId = const Value.absent(),
    ActivityCategory? category,
    DateTime? startedAt,
    DateTime? endedAt,
  }) => WorkSession(
    id: id ?? this.id,
    projectId: projectId.present ? projectId.value : this.projectId,
    category: category ?? this.category,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
  );
  WorkSession copyWithCompanion(WorkSessionsCompanion data) {
    return WorkSession(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      category: data.category.present ? data.category.value : this.category,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkSession(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('category: $category, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, category, startedAt, endedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkSession &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.category == this.category &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt);
}

class WorkSessionsCompanion extends UpdateCompanion<WorkSession> {
  final Value<String> id;
  final Value<String?> projectId;
  final Value<ActivityCategory> category;
  final Value<DateTime> startedAt;
  final Value<DateTime> endedAt;
  final Value<int> rowid;
  const WorkSessionsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.category = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    required ActivityCategory category,
    required DateTime startedAt,
    required DateTime endedAt,
    this.rowid = const Value.absent(),
  }) : category = Value(category),
       startedAt = Value(startedAt),
       endedAt = Value(endedAt);
  static Insertable<WorkSession> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? category,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (category != null) 'category': category,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkSessionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? projectId,
    Value<ActivityCategory>? category,
    Value<DateTime>? startedAt,
    Value<DateTime>? endedAt,
    Value<int>? rowid,
  }) {
    return WorkSessionsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      category: category ?? this.category,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $WorkSessionsTable.$convertercategory.toSql(category.value),
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkSessionsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('category: $category, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityEventsTable extends ActivityEvents
    with TableInfo<$ActivityEventsTable, ActivityEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES data_sources (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivityKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ActivityKind>($ActivityEventsTable.$converterkind);
  @override
  late final GeneratedColumnWithTypeConverter<ActivityCategory, String>
  category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ActivityCategory>($ActivityEventsTable.$convertercategory);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _applicationMeta = const VerificationMeta(
    'application',
  );
  @override
  late final GeneratedColumn<String> application = GeneratedColumn<String>(
    'application',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workspacePathMeta = const VerificationMeta(
    'workspacePath',
  );
  @override
  late final GeneratedColumn<String> workspacePath = GeneratedColumn<String>(
    'workspace_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES work_sessions (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id) ON DELETE SET NULL',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AttributionState, String>
  attribution = GeneratedColumn<String>(
    'attribution',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(AttributionState.none.name),
  ).withConverter<AttributionState>($ActivityEventsTable.$converterattribution);
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attributionReasonMeta = const VerificationMeta(
    'attributionReason',
  );
  @override
  late final GeneratedColumn<String> attributionReason =
      GeneratedColumn<String>(
        'attribution_reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _mergedEventCountMeta = const VerificationMeta(
    'mergedEventCount',
  );
  @override
  late final GeneratedColumn<int> mergedEventCount = GeneratedColumn<int>(
    'merged_event_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isPrivateMeta = const VerificationMeta(
    'isPrivate',
  );
  @override
  late final GeneratedColumn<bool> isPrivate = GeneratedColumn<bool>(
    'is_private',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_private" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCorrectedMeta = const VerificationMeta(
    'isCorrected',
  );
  @override
  late final GeneratedColumn<bool> isCorrected = GeneratedColumn<bool>(
    'is_corrected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_corrected" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    externalId,
    kind,
    category,
    title,
    application,
    workspacePath,
    domain,
    startedAt,
    endedAt,
    sessionId,
    projectId,
    attribution,
    confidence,
    attributionReason,
    mergedEventCount,
    isPrivate,
    isCorrected,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('application')) {
      context.handle(
        _applicationMeta,
        application.isAcceptableOrUnknown(
          data['application']!,
          _applicationMeta,
        ),
      );
    }
    if (data.containsKey('workspace_path')) {
      context.handle(
        _workspacePathMeta,
        workspacePath.isAcceptableOrUnknown(
          data['workspace_path']!,
          _workspacePathMeta,
        ),
      );
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('attribution_reason')) {
      context.handle(
        _attributionReasonMeta,
        attributionReason.isAcceptableOrUnknown(
          data['attribution_reason']!,
          _attributionReasonMeta,
        ),
      );
    }
    if (data.containsKey('merged_event_count')) {
      context.handle(
        _mergedEventCountMeta,
        mergedEventCount.isAcceptableOrUnknown(
          data['merged_event_count']!,
          _mergedEventCountMeta,
        ),
      );
    }
    if (data.containsKey('is_private')) {
      context.handle(
        _isPrivateMeta,
        isPrivate.isAcceptableOrUnknown(data['is_private']!, _isPrivateMeta),
      );
    }
    if (data.containsKey('is_corrected')) {
      context.handle(
        _isCorrectedMeta,
        isCorrected.isAcceptableOrUnknown(
          data['is_corrected']!,
          _isCorrectedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      ),
      kind: $ActivityEventsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      category: $ActivityEventsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      application: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}application'],
      ),
      workspacePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_path'],
      ),
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      attribution: $ActivityEventsTable.$converterattribution.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}attribution'],
        )!,
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      attributionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attribution_reason'],
      ),
      mergedEventCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}merged_event_count'],
      )!,
      isPrivate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_private'],
      )!,
      isCorrected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_corrected'],
      )!,
    );
  }

  @override
  $ActivityEventsTable createAlias(String alias) {
    return $ActivityEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActivityKind, String, String> $converterkind =
      const EnumNameConverter<ActivityKind>(ActivityKind.values);
  static JsonTypeConverter2<ActivityCategory, String, String>
  $convertercategory = const EnumNameConverter<ActivityCategory>(
    ActivityCategory.values,
  );
  static JsonTypeConverter2<AttributionState, String, String>
  $converterattribution = const EnumNameConverter<AttributionState>(
    AttributionState.values,
  );
}

class ActivityEvent extends DataClass implements Insertable<ActivityEvent> {
  final String id;
  final String sourceId;

  /// The source's own ID, used to de-duplicate re-imports.
  final String? externalId;
  final ActivityKind kind;
  final ActivityCategory category;
  final String title;
  final String? application;
  final String? workspacePath;
  final String? domain;
  final DateTime startedAt;

  /// Null for point-in-time events such as a commit.
  final DateTime? endedAt;
  final String? sessionId;
  final String? projectId;
  final AttributionState attribution;

  /// Set when [attribution] is inferred, from 0 to 1.
  final double? confidence;
  final String? attributionReason;
  final int mergedEventCount;
  final bool isPrivate;

  /// The user edited this event's times ("corrected by you").
  final bool isCorrected;
  const ActivityEvent({
    required this.id,
    required this.sourceId,
    this.externalId,
    required this.kind,
    required this.category,
    required this.title,
    this.application,
    this.workspacePath,
    this.domain,
    required this.startedAt,
    this.endedAt,
    this.sessionId,
    this.projectId,
    required this.attribution,
    this.confidence,
    this.attributionReason,
    required this.mergedEventCount,
    required this.isPrivate,
    required this.isCorrected,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<String>(externalId);
    }
    {
      map['kind'] = Variable<String>(
        $ActivityEventsTable.$converterkind.toSql(kind),
      );
    }
    {
      map['category'] = Variable<String>(
        $ActivityEventsTable.$convertercategory.toSql(category),
      );
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || application != null) {
      map['application'] = Variable<String>(application);
    }
    if (!nullToAbsent || workspacePath != null) {
      map['workspace_path'] = Variable<String>(workspacePath);
    }
    if (!nullToAbsent || domain != null) {
      map['domain'] = Variable<String>(domain);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    {
      map['attribution'] = Variable<String>(
        $ActivityEventsTable.$converterattribution.toSql(attribution),
      );
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || attributionReason != null) {
      map['attribution_reason'] = Variable<String>(attributionReason);
    }
    map['merged_event_count'] = Variable<int>(mergedEventCount);
    map['is_private'] = Variable<bool>(isPrivate);
    map['is_corrected'] = Variable<bool>(isCorrected);
    return map;
  }

  ActivityEventsCompanion toCompanion(bool nullToAbsent) {
    return ActivityEventsCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      externalId: externalId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalId),
      kind: Value(kind),
      category: Value(category),
      title: Value(title),
      application: application == null && nullToAbsent
          ? const Value.absent()
          : Value(application),
      workspacePath: workspacePath == null && nullToAbsent
          ? const Value.absent()
          : Value(workspacePath),
      domain: domain == null && nullToAbsent
          ? const Value.absent()
          : Value(domain),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      attribution: Value(attribution),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      attributionReason: attributionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(attributionReason),
      mergedEventCount: Value(mergedEventCount),
      isPrivate: Value(isPrivate),
      isCorrected: Value(isCorrected),
    );
  }

  factory ActivityEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityEvent(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      externalId: serializer.fromJson<String?>(json['externalId']),
      kind: $ActivityEventsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      category: $ActivityEventsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      title: serializer.fromJson<String>(json['title']),
      application: serializer.fromJson<String?>(json['application']),
      workspacePath: serializer.fromJson<String?>(json['workspacePath']),
      domain: serializer.fromJson<String?>(json['domain']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      projectId: serializer.fromJson<String?>(json['projectId']),
      attribution: $ActivityEventsTable.$converterattribution.fromJson(
        serializer.fromJson<String>(json['attribution']),
      ),
      confidence: serializer.fromJson<double?>(json['confidence']),
      attributionReason: serializer.fromJson<String?>(
        json['attributionReason'],
      ),
      mergedEventCount: serializer.fromJson<int>(json['mergedEventCount']),
      isPrivate: serializer.fromJson<bool>(json['isPrivate']),
      isCorrected: serializer.fromJson<bool>(json['isCorrected']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'externalId': serializer.toJson<String?>(externalId),
      'kind': serializer.toJson<String>(
        $ActivityEventsTable.$converterkind.toJson(kind),
      ),
      'category': serializer.toJson<String>(
        $ActivityEventsTable.$convertercategory.toJson(category),
      ),
      'title': serializer.toJson<String>(title),
      'application': serializer.toJson<String?>(application),
      'workspacePath': serializer.toJson<String?>(workspacePath),
      'domain': serializer.toJson<String?>(domain),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'sessionId': serializer.toJson<String?>(sessionId),
      'projectId': serializer.toJson<String?>(projectId),
      'attribution': serializer.toJson<String>(
        $ActivityEventsTable.$converterattribution.toJson(attribution),
      ),
      'confidence': serializer.toJson<double?>(confidence),
      'attributionReason': serializer.toJson<String?>(attributionReason),
      'mergedEventCount': serializer.toJson<int>(mergedEventCount),
      'isPrivate': serializer.toJson<bool>(isPrivate),
      'isCorrected': serializer.toJson<bool>(isCorrected),
    };
  }

  ActivityEvent copyWith({
    String? id,
    String? sourceId,
    Value<String?> externalId = const Value.absent(),
    ActivityKind? kind,
    ActivityCategory? category,
    String? title,
    Value<String?> application = const Value.absent(),
    Value<String?> workspacePath = const Value.absent(),
    Value<String?> domain = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<String?> sessionId = const Value.absent(),
    Value<String?> projectId = const Value.absent(),
    AttributionState? attribution,
    Value<double?> confidence = const Value.absent(),
    Value<String?> attributionReason = const Value.absent(),
    int? mergedEventCount,
    bool? isPrivate,
    bool? isCorrected,
  }) => ActivityEvent(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    externalId: externalId.present ? externalId.value : this.externalId,
    kind: kind ?? this.kind,
    category: category ?? this.category,
    title: title ?? this.title,
    application: application.present ? application.value : this.application,
    workspacePath: workspacePath.present
        ? workspacePath.value
        : this.workspacePath,
    domain: domain.present ? domain.value : this.domain,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    projectId: projectId.present ? projectId.value : this.projectId,
    attribution: attribution ?? this.attribution,
    confidence: confidence.present ? confidence.value : this.confidence,
    attributionReason: attributionReason.present
        ? attributionReason.value
        : this.attributionReason,
    mergedEventCount: mergedEventCount ?? this.mergedEventCount,
    isPrivate: isPrivate ?? this.isPrivate,
    isCorrected: isCorrected ?? this.isCorrected,
  );
  ActivityEvent copyWithCompanion(ActivityEventsCompanion data) {
    return ActivityEvent(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      kind: data.kind.present ? data.kind.value : this.kind,
      category: data.category.present ? data.category.value : this.category,
      title: data.title.present ? data.title.value : this.title,
      application: data.application.present
          ? data.application.value
          : this.application,
      workspacePath: data.workspacePath.present
          ? data.workspacePath.value
          : this.workspacePath,
      domain: data.domain.present ? data.domain.value : this.domain,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      attribution: data.attribution.present
          ? data.attribution.value
          : this.attribution,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      attributionReason: data.attributionReason.present
          ? data.attributionReason.value
          : this.attributionReason,
      mergedEventCount: data.mergedEventCount.present
          ? data.mergedEventCount.value
          : this.mergedEventCount,
      isPrivate: data.isPrivate.present ? data.isPrivate.value : this.isPrivate,
      isCorrected: data.isCorrected.present
          ? data.isCorrected.value
          : this.isCorrected,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEvent(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('externalId: $externalId, ')
          ..write('kind: $kind, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('application: $application, ')
          ..write('workspacePath: $workspacePath, ')
          ..write('domain: $domain, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('projectId: $projectId, ')
          ..write('attribution: $attribution, ')
          ..write('confidence: $confidence, ')
          ..write('attributionReason: $attributionReason, ')
          ..write('mergedEventCount: $mergedEventCount, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('isCorrected: $isCorrected')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    externalId,
    kind,
    category,
    title,
    application,
    workspacePath,
    domain,
    startedAt,
    endedAt,
    sessionId,
    projectId,
    attribution,
    confidence,
    attributionReason,
    mergedEventCount,
    isPrivate,
    isCorrected,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityEvent &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.externalId == this.externalId &&
          other.kind == this.kind &&
          other.category == this.category &&
          other.title == this.title &&
          other.application == this.application &&
          other.workspacePath == this.workspacePath &&
          other.domain == this.domain &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.sessionId == this.sessionId &&
          other.projectId == this.projectId &&
          other.attribution == this.attribution &&
          other.confidence == this.confidence &&
          other.attributionReason == this.attributionReason &&
          other.mergedEventCount == this.mergedEventCount &&
          other.isPrivate == this.isPrivate &&
          other.isCorrected == this.isCorrected);
}

class ActivityEventsCompanion extends UpdateCompanion<ActivityEvent> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<String?> externalId;
  final Value<ActivityKind> kind;
  final Value<ActivityCategory> category;
  final Value<String> title;
  final Value<String?> application;
  final Value<String?> workspacePath;
  final Value<String?> domain;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> sessionId;
  final Value<String?> projectId;
  final Value<AttributionState> attribution;
  final Value<double?> confidence;
  final Value<String?> attributionReason;
  final Value<int> mergedEventCount;
  final Value<bool> isPrivate;
  final Value<bool> isCorrected;
  final Value<int> rowid;
  const ActivityEventsCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.externalId = const Value.absent(),
    this.kind = const Value.absent(),
    this.category = const Value.absent(),
    this.title = const Value.absent(),
    this.application = const Value.absent(),
    this.workspacePath = const Value.absent(),
    this.domain = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.attribution = const Value.absent(),
    this.confidence = const Value.absent(),
    this.attributionReason = const Value.absent(),
    this.mergedEventCount = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.isCorrected = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityEventsCompanion.insert({
    this.id = const Value.absent(),
    required String sourceId,
    this.externalId = const Value.absent(),
    required ActivityKind kind,
    required ActivityCategory category,
    required String title,
    this.application = const Value.absent(),
    this.workspacePath = const Value.absent(),
    this.domain = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.attribution = const Value.absent(),
    this.confidence = const Value.absent(),
    this.attributionReason = const Value.absent(),
    this.mergedEventCount = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.isCorrected = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       kind = Value(kind),
       category = Value(category),
       title = Value(title),
       startedAt = Value(startedAt);
  static Insertable<ActivityEvent> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? externalId,
    Expression<String>? kind,
    Expression<String>? category,
    Expression<String>? title,
    Expression<String>? application,
    Expression<String>? workspacePath,
    Expression<String>? domain,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? sessionId,
    Expression<String>? projectId,
    Expression<String>? attribution,
    Expression<double>? confidence,
    Expression<String>? attributionReason,
    Expression<int>? mergedEventCount,
    Expression<bool>? isPrivate,
    Expression<bool>? isCorrected,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (externalId != null) 'external_id': externalId,
      if (kind != null) 'kind': kind,
      if (category != null) 'category': category,
      if (title != null) 'title': title,
      if (application != null) 'application': application,
      if (workspacePath != null) 'workspace_path': workspacePath,
      if (domain != null) 'domain': domain,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (sessionId != null) 'session_id': sessionId,
      if (projectId != null) 'project_id': projectId,
      if (attribution != null) 'attribution': attribution,
      if (confidence != null) 'confidence': confidence,
      if (attributionReason != null) 'attribution_reason': attributionReason,
      if (mergedEventCount != null) 'merged_event_count': mergedEventCount,
      if (isPrivate != null) 'is_private': isPrivate,
      if (isCorrected != null) 'is_corrected': isCorrected,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceId,
    Value<String?>? externalId,
    Value<ActivityKind>? kind,
    Value<ActivityCategory>? category,
    Value<String>? title,
    Value<String?>? application,
    Value<String?>? workspacePath,
    Value<String?>? domain,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String?>? sessionId,
    Value<String?>? projectId,
    Value<AttributionState>? attribution,
    Value<double?>? confidence,
    Value<String?>? attributionReason,
    Value<int>? mergedEventCount,
    Value<bool>? isPrivate,
    Value<bool>? isCorrected,
    Value<int>? rowid,
  }) {
    return ActivityEventsCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      externalId: externalId ?? this.externalId,
      kind: kind ?? this.kind,
      category: category ?? this.category,
      title: title ?? this.title,
      application: application ?? this.application,
      workspacePath: workspacePath ?? this.workspacePath,
      domain: domain ?? this.domain,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      sessionId: sessionId ?? this.sessionId,
      projectId: projectId ?? this.projectId,
      attribution: attribution ?? this.attribution,
      confidence: confidence ?? this.confidence,
      attributionReason: attributionReason ?? this.attributionReason,
      mergedEventCount: mergedEventCount ?? this.mergedEventCount,
      isPrivate: isPrivate ?? this.isPrivate,
      isCorrected: isCorrected ?? this.isCorrected,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ActivityEventsTable.$converterkind.toSql(kind.value),
      );
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $ActivityEventsTable.$convertercategory.toSql(category.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (application.present) {
      map['application'] = Variable<String>(application.value);
    }
    if (workspacePath.present) {
      map['workspace_path'] = Variable<String>(workspacePath.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (attribution.present) {
      map['attribution'] = Variable<String>(
        $ActivityEventsTable.$converterattribution.toSql(attribution.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (attributionReason.present) {
      map['attribution_reason'] = Variable<String>(attributionReason.value);
    }
    if (mergedEventCount.present) {
      map['merged_event_count'] = Variable<int>(mergedEventCount.value);
    }
    if (isPrivate.present) {
      map['is_private'] = Variable<bool>(isPrivate.value);
    }
    if (isCorrected.present) {
      map['is_corrected'] = Variable<bool>(isCorrected.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEventsCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('externalId: $externalId, ')
          ..write('kind: $kind, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('application: $application, ')
          ..write('workspacePath: $workspacePath, ')
          ..write('domain: $domain, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('projectId: $projectId, ')
          ..write('attribution: $attribution, ')
          ..write('confidence: $confidence, ')
          ..write('attributionReason: $attributionReason, ')
          ..write('mergedEventCount: $mergedEventCount, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('isCorrected: $isCorrected, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventTombstonesTable extends EventTombstones
    with TableInfo<$EventTombstonesTable, EventTombstone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventTombstonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES data_sources (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [sourceId, externalId, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_tombstones';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventTombstone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_deletedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceId, externalId};
  @override
  EventTombstone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventTombstone(
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      )!,
    );
  }

  @override
  $EventTombstonesTable createAlias(String alias) {
    return $EventTombstonesTable(attachedDatabase, alias);
  }
}

class EventTombstone extends DataClass implements Insertable<EventTombstone> {
  final String sourceId;
  final String externalId;
  final DateTime deletedAt;
  const EventTombstone({
    required this.sourceId,
    required this.externalId,
    required this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_id'] = Variable<String>(sourceId);
    map['external_id'] = Variable<String>(externalId);
    map['deleted_at'] = Variable<DateTime>(deletedAt);
    return map;
  }

  EventTombstonesCompanion toCompanion(bool nullToAbsent) {
    return EventTombstonesCompanion(
      sourceId: Value(sourceId),
      externalId: Value(externalId),
      deletedAt: Value(deletedAt),
    );
  }

  factory EventTombstone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventTombstone(
      sourceId: serializer.fromJson<String>(json['sourceId']),
      externalId: serializer.fromJson<String>(json['externalId']),
      deletedAt: serializer.fromJson<DateTime>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceId': serializer.toJson<String>(sourceId),
      'externalId': serializer.toJson<String>(externalId),
      'deletedAt': serializer.toJson<DateTime>(deletedAt),
    };
  }

  EventTombstone copyWith({
    String? sourceId,
    String? externalId,
    DateTime? deletedAt,
  }) => EventTombstone(
    sourceId: sourceId ?? this.sourceId,
    externalId: externalId ?? this.externalId,
    deletedAt: deletedAt ?? this.deletedAt,
  );
  EventTombstone copyWithCompanion(EventTombstonesCompanion data) {
    return EventTombstone(
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventTombstone(')
          ..write('sourceId: $sourceId, ')
          ..write('externalId: $externalId, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sourceId, externalId, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventTombstone &&
          other.sourceId == this.sourceId &&
          other.externalId == this.externalId &&
          other.deletedAt == this.deletedAt);
}

class EventTombstonesCompanion extends UpdateCompanion<EventTombstone> {
  final Value<String> sourceId;
  final Value<String> externalId;
  final Value<DateTime> deletedAt;
  final Value<int> rowid;
  const EventTombstonesCompanion({
    this.sourceId = const Value.absent(),
    this.externalId = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventTombstonesCompanion.insert({
    required String sourceId,
    required String externalId,
    required DateTime deletedAt,
    this.rowid = const Value.absent(),
  }) : sourceId = Value(sourceId),
       externalId = Value(externalId),
       deletedAt = Value(deletedAt);
  static Insertable<EventTombstone> custom({
    Expression<String>? sourceId,
    Expression<String>? externalId,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceId != null) 'source_id': sourceId,
      if (externalId != null) 'external_id': externalId,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventTombstonesCompanion copyWith({
    Value<String>? sourceId,
    Value<String>? externalId,
    Value<DateTime>? deletedAt,
    Value<int>? rowid,
  }) {
    return EventTombstonesCompanion(
      sourceId: sourceId ?? this.sourceId,
      externalId: externalId ?? this.externalId,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventTombstonesCompanion(')
          ..write('sourceId: $sourceId, ')
          ..write('externalId: $externalId, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExclusionsTable extends Exclusions
    with TableInfo<$ExclusionsTable, Exclusion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExclusionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExclusionKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ExclusionKind>($ExclusionsTable.$converterkind);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, kind, value, label, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exclusions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exclusion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exclusion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exclusion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: $ExclusionsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExclusionsTable createAlias(String alias) {
    return $ExclusionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ExclusionKind, String, String> $converterkind =
      const EnumNameConverter<ExclusionKind>(ExclusionKind.values);
}

class Exclusion extends DataClass implements Insertable<Exclusion> {
  final String id;
  final ExclusionKind kind;

  /// A package name or a domain.
  final String value;
  final String? label;
  final DateTime createdAt;
  const Exclusion({
    required this.id,
    required this.kind,
    required this.value,
    this.label,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['kind'] = Variable<String>(
        $ExclusionsTable.$converterkind.toSql(kind),
      );
    }
    map['value'] = Variable<String>(value);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExclusionsCompanion toCompanion(bool nullToAbsent) {
    return ExclusionsCompanion(
      id: Value(id),
      kind: Value(kind),
      value: Value(value),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory Exclusion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exclusion(
      id: serializer.fromJson<String>(json['id']),
      kind: $ExclusionsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      value: serializer.fromJson<String>(json['value']),
      label: serializer.fromJson<String?>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(
        $ExclusionsTable.$converterkind.toJson(kind),
      ),
      'value': serializer.toJson<String>(value),
      'label': serializer.toJson<String?>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Exclusion copyWith({
    String? id,
    ExclusionKind? kind,
    String? value,
    Value<String?> label = const Value.absent(),
    DateTime? createdAt,
  }) => Exclusion(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    value: value ?? this.value,
    label: label.present ? label.value : this.label,
    createdAt: createdAt ?? this.createdAt,
  );
  Exclusion copyWithCompanion(ExclusionsCompanion data) {
    return Exclusion(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      value: data.value.present ? data.value.value : this.value,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exclusion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, value, label, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exclusion &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.value == this.value &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class ExclusionsCompanion extends UpdateCompanion<Exclusion> {
  final Value<String> id;
  final Value<ExclusionKind> kind;
  final Value<String> value;
  final Value<String?> label;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExclusionsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.value = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExclusionsCompanion.insert({
    this.id = const Value.absent(),
    required ExclusionKind kind,
    required String value,
    this.label = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : kind = Value(kind),
       value = Value(value),
       createdAt = Value(createdAt);
  static Insertable<Exclusion> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? value,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (value != null) 'value': value,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExclusionsCompanion copyWith({
    Value<String>? id,
    Value<ExclusionKind>? kind,
    Value<String>? value,
    Value<String?>? label,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ExclusionsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      value: value ?? this.value,
      label: label ?? this.label,
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
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ExclusionsTable.$converterkind.toSql(kind.value),
      );
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
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
    return (StringBuffer('ExclusionsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('value: $value, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReportsTable extends Reports with TableInfo<$ReportsTable, Report> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReportPeriod, String> period =
      GeneratedColumn<String>(
        'period',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReportPeriod>($ReportsTable.$converterperiod);
  static const VerificationMeta _periodStartMeta = const VerificationMeta(
    'periodStart',
  );
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    period,
    periodStart,
    body,
    generatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<Report> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(
          data['period_start']!,
          _periodStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Report map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Report(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      period: $ReportsTable.$converterperiod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}period'],
        )!,
      ),
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}period_start'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
    );
  }

  @override
  $ReportsTable createAlias(String alias) {
    return $ReportsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReportPeriod, String, String> $converterperiod =
      const EnumNameConverter<ReportPeriod>(ReportPeriod.values);
}

class Report extends DataClass implements Insertable<Report> {
  final String id;
  final ReportPeriod period;
  final DateTime periodStart;

  /// Rule-based report body, as JSON.
  final String body;
  final DateTime generatedAt;
  const Report({
    required this.id,
    required this.period,
    required this.periodStart,
    required this.body,
    required this.generatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['period'] = Variable<String>(
        $ReportsTable.$converterperiod.toSql(period),
      );
    }
    map['period_start'] = Variable<DateTime>(periodStart);
    map['body'] = Variable<String>(body);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    return map;
  }

  ReportsCompanion toCompanion(bool nullToAbsent) {
    return ReportsCompanion(
      id: Value(id),
      period: Value(period),
      periodStart: Value(periodStart),
      body: Value(body),
      generatedAt: Value(generatedAt),
    );
  }

  factory Report.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Report(
      id: serializer.fromJson<String>(json['id']),
      period: $ReportsTable.$converterperiod.fromJson(
        serializer.fromJson<String>(json['period']),
      ),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      body: serializer.fromJson<String>(json['body']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'period': serializer.toJson<String>(
        $ReportsTable.$converterperiod.toJson(period),
      ),
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'body': serializer.toJson<String>(body),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  Report copyWith({
    String? id,
    ReportPeriod? period,
    DateTime? periodStart,
    String? body,
    DateTime? generatedAt,
  }) => Report(
    id: id ?? this.id,
    period: period ?? this.period,
    periodStart: periodStart ?? this.periodStart,
    body: body ?? this.body,
    generatedAt: generatedAt ?? this.generatedAt,
  );
  Report copyWithCompanion(ReportsCompanion data) {
    return Report(
      id: data.id.present ? data.id.value : this.id,
      period: data.period.present ? data.period.value : this.period,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      body: data.body.present ? data.body.value : this.body,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Report(')
          ..write('id: $id, ')
          ..write('period: $period, ')
          ..write('periodStart: $periodStart, ')
          ..write('body: $body, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, period, periodStart, body, generatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Report &&
          other.id == this.id &&
          other.period == this.period &&
          other.periodStart == this.periodStart &&
          other.body == this.body &&
          other.generatedAt == this.generatedAt);
}

class ReportsCompanion extends UpdateCompanion<Report> {
  final Value<String> id;
  final Value<ReportPeriod> period;
  final Value<DateTime> periodStart;
  final Value<String> body;
  final Value<DateTime> generatedAt;
  final Value<int> rowid;
  const ReportsCompanion({
    this.id = const Value.absent(),
    this.period = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.body = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReportsCompanion.insert({
    this.id = const Value.absent(),
    required ReportPeriod period,
    required DateTime periodStart,
    required String body,
    required DateTime generatedAt,
    this.rowid = const Value.absent(),
  }) : period = Value(period),
       periodStart = Value(periodStart),
       body = Value(body),
       generatedAt = Value(generatedAt);
  static Insertable<Report> custom({
    Expression<String>? id,
    Expression<String>? period,
    Expression<DateTime>? periodStart,
    Expression<String>? body,
    Expression<DateTime>? generatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (period != null) 'period': period,
      if (periodStart != null) 'period_start': periodStart,
      if (body != null) 'body': body,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReportsCompanion copyWith({
    Value<String>? id,
    Value<ReportPeriod>? period,
    Value<DateTime>? periodStart,
    Value<String>? body,
    Value<DateTime>? generatedAt,
    Value<int>? rowid,
  }) {
    return ReportsCompanion(
      id: id ?? this.id,
      period: period ?? this.period,
      periodStart: periodStart ?? this.periodStart,
      body: body ?? this.body,
      generatedAt: generatedAt ?? this.generatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(
        $ReportsTable.$converterperiod.toSql(period.value),
      );
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportsCompanion(')
          ..write('id: $id, ')
          ..write('period: $period, ')
          ..write('periodStart: $periodStart, ')
          ..write('body: $body, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $ProjectRulesTable projectRules = $ProjectRulesTable(this);
  late final $DataSourcesTable dataSources = $DataSourcesTable(this);
  late final $PairedDevicesTable pairedDevices = $PairedDevicesTable(this);
  late final $TrackedRepositoriesTable trackedRepositories =
      $TrackedRepositoriesTable(this);
  late final $WorkSessionsTable workSessions = $WorkSessionsTable(this);
  late final $ActivityEventsTable activityEvents = $ActivityEventsTable(this);
  late final $EventTombstonesTable eventTombstones = $EventTombstonesTable(
    this,
  );
  late final $ExclusionsTable exclusions = $ExclusionsTable(this);
  late final $ReportsTable reports = $ReportsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final Index usersProviderSubjectIdx = Index(
    'users_provider_subject_idx',
    'CREATE UNIQUE INDEX users_provider_subject_idx ON users (provider, subject_id)',
  );
  late final Index projectRulesProjectIdx = Index(
    'project_rules_project_idx',
    'CREATE INDEX project_rules_project_idx ON project_rules (project_id)',
  );
  late final Index dataSourcesKindIdx = Index(
    'data_sources_kind_idx',
    'CREATE INDEX data_sources_kind_idx ON data_sources (kind)',
  );
  late final Index pairedDevicesSourceIdx = Index(
    'paired_devices_source_idx',
    'CREATE INDEX paired_devices_source_idx ON paired_devices (source_id)',
  );
  late final Index trackedRepositoriesSourceNameIdx = Index(
    'tracked_repositories_source_name_idx',
    'CREATE UNIQUE INDEX tracked_repositories_source_name_idx ON tracked_repositories (source_id, full_name)',
  );
  late final Index trackedRepositoriesProjectIdx = Index(
    'tracked_repositories_project_idx',
    'CREATE INDEX tracked_repositories_project_idx ON tracked_repositories (project_id)',
  );
  late final Index workSessionsStartedIdx = Index(
    'work_sessions_started_idx',
    'CREATE INDEX work_sessions_started_idx ON work_sessions (started_at)',
  );
  late final Index workSessionsProjectIdx = Index(
    'work_sessions_project_idx',
    'CREATE INDEX work_sessions_project_idx ON work_sessions (project_id)',
  );
  late final Index activityEventsStartedIdx = Index(
    'activity_events_started_idx',
    'CREATE INDEX activity_events_started_idx ON activity_events (started_at)',
  );
  late final Index activityEventsProjectIdx = Index(
    'activity_events_project_idx',
    'CREATE INDEX activity_events_project_idx ON activity_events (project_id)',
  );
  late final Index activityEventsSessionIdx = Index(
    'activity_events_session_idx',
    'CREATE INDEX activity_events_session_idx ON activity_events (session_id)',
  );
  late final Index activityEventsSourceExternalIdx = Index(
    'activity_events_source_external_idx',
    'CREATE UNIQUE INDEX activity_events_source_external_idx ON activity_events (source_id, external_id)',
  );
  late final Index exclusionsKindValueIdx = Index(
    'exclusions_kind_value_idx',
    'CREATE UNIQUE INDEX exclusions_kind_value_idx ON exclusions (kind, value)',
  );
  late final Index reportsPeriodStartIdx = Index(
    'reports_period_start_idx',
    'CREATE UNIQUE INDEX reports_period_start_idx ON reports (period, period_start)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    projects,
    projectRules,
    dataSources,
    pairedDevices,
    trackedRepositories,
    workSessions,
    activityEvents,
    eventTombstones,
    exclusions,
    reports,
    appSettings,
    usersProviderSubjectIdx,
    projectRulesProjectIdx,
    dataSourcesKindIdx,
    pairedDevicesSourceIdx,
    trackedRepositoriesSourceNameIdx,
    trackedRepositoriesProjectIdx,
    workSessionsStartedIdx,
    workSessionsProjectIdx,
    activityEventsStartedIdx,
    activityEventsProjectIdx,
    activityEventsSessionIdx,
    activityEventsSourceExternalIdx,
    exclusionsKindValueIdx,
    reportsPeriodStartIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('project_rules', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'data_sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('paired_devices', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'data_sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tracked_repositories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tracked_repositories', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('work_sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'data_sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('activity_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'work_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('activity_events', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('activity_events', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'data_sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('event_tombstones', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  required AuthProvider provider,
  Value<String?> subjectId,
  Value<String?> name,
  Value<String?> email,
  Value<String?> photoUrl,
  required DateTime createdAt,
  required DateTime lastLoginAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<AuthProvider> provider,
  Value<String?> subjectId,
  Value<String?> name,
  Value<String?> email,
  Value<String?> photoUrl,
  Value<DateTime> createdAt,
  Value<DateTime> lastLoginAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
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

  ColumnWithTypeConverterFilters<AuthProvider, AuthProvider, String>
  get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
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

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AuthProvider, String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => column,
  );
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
          UserRow,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<AuthProvider> provider = const Value.absent(),
                Value<String?> subjectId = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastLoginAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                provider: provider,
                subjectId: subjectId,
                name: name,
                email: email,
                photoUrl: photoUrl,
                createdAt: createdAt,
                lastLoginAt: lastLoginAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required AuthProvider provider,
                Value<String?> subjectId = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                required DateTime createdAt,
                required DateTime lastLoginAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                provider: provider,
                subjectId: subjectId,
                name: name,
                email: email,
                photoUrl: photoUrl,
                createdAt: createdAt,
                lastLoginAt: lastLoginAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, UserRow>(table),
                  BaseReferences<_$AppDatabase, $UsersTable, UserRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
      UserRow,
      PrefetchHooks Function()
    >;
typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  Value<String> id,
  required String name,
  required String colorHex,
  Value<String?> repositoryUrl,
  required ProjectOrigin origin,
  Value<double?> confidence,
  required DateTime createdAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> colorHex,
  Value<String?> repositoryUrl,
  Value<ProjectOrigin> origin,
  Value<double?> confidence,
  Value<DateTime> createdAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProjectRulesTable, List<ProjectRule>>
  _projectRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.projectRules,
    aliasName: 'projects__id__project_rules__project_id',
  );

  $$ProjectRulesTableProcessedTableManager get projectRulesRefs {
    final manager = $$ProjectRulesTableTableManager(
      $_db,
      $_db.projectRules,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TrackedRepositoriesTable, List<TrackedRepository>>
  _trackedRepositoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.trackedRepositories,
        aliasName: 'projects__id__tracked_repositories__project_id',
      );

  $$TrackedRepositoriesTableProcessedTableManager get trackedRepositoriesRefs {
    final manager = $$TrackedRepositoriesTableTableManager(
      $_db,
      $_db.trackedRepositories,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trackedRepositoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkSessionsTable, List<WorkSession>>
  _workSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workSessions,
    aliasName: 'projects__id__work_sessions__project_id',
  );

  $$WorkSessionsTableProcessedTableManager get workSessionsRefs {
    final manager = $$WorkSessionsTableTableManager(
      $_db,
      $_db.workSessions,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActivityEventsTable, List<ActivityEvent>>
  _activityEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activityEvents,
    aliasName: 'projects__id__activity_events__project_id',
  );

  $$ActivityEventsTableProcessedTableManager get activityEventsRefs {
    final manager = $$ActivityEventsTableTableManager(
      $_db,
      $_db.activityEvents,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activityEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repositoryUrl => $composableBuilder(
    column: $table.repositoryUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ProjectOrigin, ProjectOrigin, String>
  get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> projectRulesRefs(
    Expression<bool> Function($$ProjectRulesTableFilterComposer f) f,
  ) {
    final $$ProjectRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projectRules,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRulesTableFilterComposer(
            $db: $db,
            $table: $db.projectRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> trackedRepositoriesRefs(
    Expression<bool> Function($$TrackedRepositoriesTableFilterComposer f) f,
  ) {
    final $$TrackedRepositoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackedRepositories,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackedRepositoriesTableFilterComposer(
            $db: $db,
            $table: $db.trackedRepositories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workSessionsRefs(
    Expression<bool> Function($$WorkSessionsTableFilterComposer f) f,
  ) {
    final $$WorkSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workSessions,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activityEventsRefs(
    Expression<bool> Function($$ActivityEventsTableFilterComposer f) f,
  ) {
    final $$ActivityEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityEvents,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityEventsTableFilterComposer(
            $db: $db,
            $table: $db.activityEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repositoryUrl => $composableBuilder(
    column: $table.repositoryUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<String> get repositoryUrl => $composableBuilder(
    column: $table.repositoryUrl,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ProjectOrigin, String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> projectRulesRefs<T extends Object>(
    Expression<T> Function($$ProjectRulesTableAnnotationComposer a) f,
  ) {
    final $$ProjectRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projectRules,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.projectRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> trackedRepositoriesRefs<T extends Object>(
    Expression<T> Function($$TrackedRepositoriesTableAnnotationComposer a) f,
  ) {
    final $$TrackedRepositoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackedRepositories,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackedRepositoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.trackedRepositories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workSessionsRefs<T extends Object>(
    Expression<T> Function($$WorkSessionsTableAnnotationComposer a) f,
  ) {
    final $$WorkSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workSessions,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activityEventsRefs<T extends Object>(
    Expression<T> Function($$ActivityEventsTableAnnotationComposer a) f,
  ) {
    final $$ActivityEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityEvents,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.activityEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, $$ProjectsTableReferences),
          Project,
          PrefetchHooks Function({
            bool projectRulesRefs,
            bool trackedRepositoriesRefs,
            bool workSessionsRefs,
            bool activityEventsRefs,
          })
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<String?> repositoryUrl = const Value.absent(),
                Value<ProjectOrigin> origin = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                colorHex: colorHex,
                repositoryUrl: repositoryUrl,
                origin: origin,
                confidence: confidence,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required String colorHex,
                Value<String?> repositoryUrl = const Value.absent(),
                required ProjectOrigin origin,
                Value<double?> confidence = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                name: name,
                colorHex: colorHex,
                repositoryUrl: repositoryUrl,
                origin: origin,
                confidence: confidence,
                createdAt: createdAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProjectsTable, Project>(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectRulesRefs = false,
                trackedRepositoriesRefs = false,
                workSessionsRefs = false,
                activityEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (projectRulesRefs) db.projectRules,
                    if (trackedRepositoriesRefs) db.trackedRepositories,
                    if (workSessionsRefs) db.workSessions,
                    if (activityEventsRefs) db.activityEvents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (projectRulesRefs)
                        await $_getPrefetchedDataByColumns<
                          Project,
                          $ProjectsTable,
                          ProjectRule,
                          $ProjectRulesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._projectRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).projectRulesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'project_id',
                          typedResults: items,
                        ),
                      if (trackedRepositoriesRefs)
                        await $_getPrefetchedDataByColumns<
                          Project,
                          $ProjectsTable,
                          TrackedRepository,
                          $TrackedRepositoriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._trackedRepositoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).trackedRepositoriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'project_id',
                          typedResults: items,
                        ),
                      if (workSessionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Project,
                          $ProjectsTable,
                          WorkSession,
                          $WorkSessionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._workSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).workSessionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'project_id',
                          typedResults: items,
                        ),
                      if (activityEventsRefs)
                        await $_getPrefetchedDataByColumns<
                          Project,
                          $ProjectsTable,
                          ActivityEvent,
                          $ActivityEventsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._activityEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).activityEventsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'project_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, $$ProjectsTableReferences),
      Project,
      PrefetchHooks Function({
        bool projectRulesRefs,
        bool trackedRepositoriesRefs,
        bool workSessionsRefs,
        bool activityEventsRefs,
      })
    >;
typedef $$ProjectRulesTableCreateCompanionBuilder =
    ProjectRulesCompanion Function({
      Value<String> id,
      required String projectId,
      required RuleKind kind,
      required String pattern,
      Value<bool> enabled,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ProjectRulesTableUpdateCompanionBuilder =
    ProjectRulesCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<RuleKind> kind,
      Value<String> pattern,
      Value<bool> enabled,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ProjectRulesTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectRulesTable, ProjectRule> {
  $$ProjectRulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('project_rules__project_id__projects__id');

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProjectRulesTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectRulesTable> {
  $$ProjectRulesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<RuleKind, RuleKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectRulesTable> {
  $$ProjectRulesTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectRulesTable> {
  $$ProjectRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RuleKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectRulesTable,
          ProjectRule,
          $$ProjectRulesTableFilterComposer,
          $$ProjectRulesTableOrderingComposer,
          $$ProjectRulesTableAnnotationComposer,
          $$ProjectRulesTableCreateCompanionBuilder,
          $$ProjectRulesTableUpdateCompanionBuilder,
          (ProjectRule, $$ProjectRulesTableReferences),
          ProjectRule,
          PrefetchHooks Function({bool projectId})
        > {
  $$ProjectRulesTableTableManager(_$AppDatabase db, $ProjectRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<RuleKind> kind = const Value.absent(),
                Value<String> pattern = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectRulesCompanion(
                id: id,
                projectId: projectId,
                kind: kind,
                pattern: pattern,
                enabled: enabled,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String projectId,
                required RuleKind kind,
                required String pattern,
                Value<bool> enabled = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ProjectRulesCompanion.insert(
                id: id,
                projectId: projectId,
                kind: kind,
                pattern: pattern,
                enabled: enabled,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProjectRulesTable, ProjectRule>(table),
                  $$ProjectRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
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
                    if (projectId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.projectId,
                        referencedTable: $$ProjectRulesTableReferences
                            ._projectIdTable(db),
                        referencedColumn: $$ProjectRulesTableReferences
                            ._projectIdTable(db)
                            .id,
                      ) as T;
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

typedef $$ProjectRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectRulesTable,
      ProjectRule,
      $$ProjectRulesTableFilterComposer,
      $$ProjectRulesTableOrderingComposer,
      $$ProjectRulesTableAnnotationComposer,
      $$ProjectRulesTableCreateCompanionBuilder,
      $$ProjectRulesTableUpdateCompanionBuilder,
      (ProjectRule, $$ProjectRulesTableReferences),
      ProjectRule,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$DataSourcesTableCreateCompanionBuilder =
    DataSourcesCompanion Function({
      Value<String> id,
      required SourceKind kind,
      required SourceStatus status,
      Value<String?> accountLabel,
      Value<String?> host,
      Value<String?> grantedScopes,
      Value<String?> syncCursor,
      Value<DateTime?> lastSyncedAt,
      required DateTime connectedAt,
      Value<int> rowid,
    });
typedef $$DataSourcesTableUpdateCompanionBuilder =
    DataSourcesCompanion Function({
      Value<String> id,
      Value<SourceKind> kind,
      Value<SourceStatus> status,
      Value<String?> accountLabel,
      Value<String?> host,
      Value<String?> grantedScopes,
      Value<String?> syncCursor,
      Value<DateTime?> lastSyncedAt,
      Value<DateTime> connectedAt,
      Value<int> rowid,
    });

final class $$DataSourcesTableReferences
    extends BaseReferences<_$AppDatabase, $DataSourcesTable, DataSource> {
  $$DataSourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PairedDevicesTable, List<PairedDevice>>
  _pairedDevicesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pairedDevices,
    aliasName: 'data_sources__id__paired_devices__source_id',
  );

  $$PairedDevicesTableProcessedTableManager get pairedDevicesRefs {
    final manager = $$PairedDevicesTableTableManager(
      $_db,
      $_db.pairedDevices,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pairedDevicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TrackedRepositoriesTable, List<TrackedRepository>>
  _trackedRepositoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.trackedRepositories,
        aliasName: 'data_sources__id__tracked_repositories__source_id',
      );

  $$TrackedRepositoriesTableProcessedTableManager get trackedRepositoriesRefs {
    final manager = $$TrackedRepositoriesTableTableManager(
      $_db,
      $_db.trackedRepositories,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trackedRepositoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActivityEventsTable, List<ActivityEvent>>
  _activityEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activityEvents,
    aliasName: 'data_sources__id__activity_events__source_id',
  );

  $$ActivityEventsTableProcessedTableManager get activityEventsRefs {
    final manager = $$ActivityEventsTableTableManager(
      $_db,
      $_db.activityEvents,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activityEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventTombstonesTable, List<EventTombstone>>
  _eventTombstonesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.eventTombstones,
    aliasName: 'data_sources__id__event_tombstones__source_id',
  );

  $$EventTombstonesTableProcessedTableManager get eventTombstonesRefs {
    final manager = $$EventTombstonesTableTableManager(
      $_db,
      $_db.eventTombstones,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _eventTombstonesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DataSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $DataSourcesTable> {
  $$DataSourcesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<SourceKind, SourceKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<SourceStatus, SourceStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get accountLabel => $composableBuilder(
    column: $table.accountLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grantedScopes => $composableBuilder(
    column: $table.grantedScopes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncCursor => $composableBuilder(
    column: $table.syncCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pairedDevicesRefs(
    Expression<bool> Function($$PairedDevicesTableFilterComposer f) f,
  ) {
    final $$PairedDevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pairedDevices,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairedDevicesTableFilterComposer(
            $db: $db,
            $table: $db.pairedDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> trackedRepositoriesRefs(
    Expression<bool> Function($$TrackedRepositoriesTableFilterComposer f) f,
  ) {
    final $$TrackedRepositoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trackedRepositories,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackedRepositoriesTableFilterComposer(
            $db: $db,
            $table: $db.trackedRepositories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activityEventsRefs(
    Expression<bool> Function($$ActivityEventsTableFilterComposer f) f,
  ) {
    final $$ActivityEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityEvents,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityEventsTableFilterComposer(
            $db: $db,
            $table: $db.activityEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventTombstonesRefs(
    Expression<bool> Function($$EventTombstonesTableFilterComposer f) f,
  ) {
    final $$EventTombstonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventTombstones,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventTombstonesTableFilterComposer(
            $db: $db,
            $table: $db.eventTombstones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DataSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $DataSourcesTable> {
  $$DataSourcesTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountLabel => $composableBuilder(
    column: $table.accountLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grantedScopes => $composableBuilder(
    column: $table.grantedScopes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncCursor => $composableBuilder(
    column: $table.syncCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DataSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DataSourcesTable> {
  $$DataSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SourceKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SourceStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get accountLabel => $composableBuilder(
    column: $table.accountLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<String> get grantedScopes => $composableBuilder(
    column: $table.grantedScopes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncCursor => $composableBuilder(
    column: $table.syncCursor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get connectedAt => $composableBuilder(
    column: $table.connectedAt,
    builder: (column) => column,
  );

  Expression<T> pairedDevicesRefs<T extends Object>(
    Expression<T> Function($$PairedDevicesTableAnnotationComposer a) f,
  ) {
    final $$PairedDevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pairedDevices,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairedDevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.pairedDevices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> trackedRepositoriesRefs<T extends Object>(
    Expression<T> Function($$TrackedRepositoriesTableAnnotationComposer a) f,
  ) {
    final $$TrackedRepositoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.trackedRepositories,
          getReferencedColumn: (t) => t.sourceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TrackedRepositoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.trackedRepositories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> activityEventsRefs<T extends Object>(
    Expression<T> Function($$ActivityEventsTableAnnotationComposer a) f,
  ) {
    final $$ActivityEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityEvents,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.activityEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventTombstonesRefs<T extends Object>(
    Expression<T> Function($$EventTombstonesTableAnnotationComposer a) f,
  ) {
    final $$EventTombstonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventTombstones,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventTombstonesTableAnnotationComposer(
            $db: $db,
            $table: $db.eventTombstones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DataSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DataSourcesTable,
          DataSource,
          $$DataSourcesTableFilterComposer,
          $$DataSourcesTableOrderingComposer,
          $$DataSourcesTableAnnotationComposer,
          $$DataSourcesTableCreateCompanionBuilder,
          $$DataSourcesTableUpdateCompanionBuilder,
          (DataSource, $$DataSourcesTableReferences),
          DataSource,
          PrefetchHooks Function({
            bool pairedDevicesRefs,
            bool trackedRepositoriesRefs,
            bool activityEventsRefs,
            bool eventTombstonesRefs,
          })
        > {
  $$DataSourcesTableTableManager(_$AppDatabase db, $DataSourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DataSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DataSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DataSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<SourceKind> kind = const Value.absent(),
                Value<SourceStatus> status = const Value.absent(),
                Value<String?> accountLabel = const Value.absent(),
                Value<String?> host = const Value.absent(),
                Value<String?> grantedScopes = const Value.absent(),
                Value<String?> syncCursor = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<DateTime> connectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DataSourcesCompanion(
                id: id,
                kind: kind,
                status: status,
                accountLabel: accountLabel,
                host: host,
                grantedScopes: grantedScopes,
                syncCursor: syncCursor,
                lastSyncedAt: lastSyncedAt,
                connectedAt: connectedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required SourceKind kind,
                required SourceStatus status,
                Value<String?> accountLabel = const Value.absent(),
                Value<String?> host = const Value.absent(),
                Value<String?> grantedScopes = const Value.absent(),
                Value<String?> syncCursor = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                required DateTime connectedAt,
                Value<int> rowid = const Value.absent(),
              }) => DataSourcesCompanion.insert(
                id: id,
                kind: kind,
                status: status,
                accountLabel: accountLabel,
                host: host,
                grantedScopes: grantedScopes,
                syncCursor: syncCursor,
                lastSyncedAt: lastSyncedAt,
                connectedAt: connectedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DataSourcesTable, DataSource>(table),
                  $$DataSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pairedDevicesRefs = false,
                trackedRepositoriesRefs = false,
                activityEventsRefs = false,
                eventTombstonesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pairedDevicesRefs) db.pairedDevices,
                    if (trackedRepositoriesRefs) db.trackedRepositories,
                    if (activityEventsRefs) db.activityEvents,
                    if (eventTombstonesRefs) db.eventTombstones,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pairedDevicesRefs)
                        await $_getPrefetchedDataByColumns<
                          DataSource,
                          $DataSourcesTable,
                          PairedDevice,
                          $PairedDevicesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DataSourcesTableReferences
                              ._pairedDevicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DataSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).pairedDevicesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'source_id',
                          typedResults: items,
                        ),
                      if (trackedRepositoriesRefs)
                        await $_getPrefetchedDataByColumns<
                          DataSource,
                          $DataSourcesTable,
                          TrackedRepository,
                          $TrackedRepositoriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DataSourcesTableReferences
                              ._trackedRepositoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DataSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).trackedRepositoriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'source_id',
                          typedResults: items,
                        ),
                      if (activityEventsRefs)
                        await $_getPrefetchedDataByColumns<
                          DataSource,
                          $DataSourcesTable,
                          ActivityEvent,
                          $ActivityEventsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DataSourcesTableReferences
                              ._activityEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DataSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).activityEventsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'source_id',
                          typedResults: items,
                        ),
                      if (eventTombstonesRefs)
                        await $_getPrefetchedDataByColumns<
                          DataSource,
                          $DataSourcesTable,
                          EventTombstone,
                          $EventTombstonesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DataSourcesTableReferences
                              ._eventTombstonesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DataSourcesTableReferences(
                                db,
                                table,
                                p0,
                              ).eventTombstonesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'source_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DataSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DataSourcesTable,
      DataSource,
      $$DataSourcesTableFilterComposer,
      $$DataSourcesTableOrderingComposer,
      $$DataSourcesTableAnnotationComposer,
      $$DataSourcesTableCreateCompanionBuilder,
      $$DataSourcesTableUpdateCompanionBuilder,
      (DataSource, $$DataSourcesTableReferences),
      DataSource,
      PrefetchHooks Function({
        bool pairedDevicesRefs,
        bool trackedRepositoriesRefs,
        bool activityEventsRefs,
        bool eventTombstonesRefs,
      })
    >;
typedef $$PairedDevicesTableCreateCompanionBuilder =
    PairedDevicesCompanion Function({
      Value<String> id,
      required String sourceId,
      required DeviceKind kind,
      required String name,
      required String publicKey,
      required DateTime pairedAt,
      Value<DateTime?> lastSeenAt,
      Value<int> rowid,
    });
typedef $$PairedDevicesTableUpdateCompanionBuilder =
    PairedDevicesCompanion Function({
      Value<String> id,
      Value<String> sourceId,
      Value<DeviceKind> kind,
      Value<String> name,
      Value<String> publicKey,
      Value<DateTime> pairedAt,
      Value<DateTime?> lastSeenAt,
      Value<int> rowid,
    });

final class $$PairedDevicesTableReferences
    extends BaseReferences<_$AppDatabase, $PairedDevicesTable, PairedDevice> {
  $$PairedDevicesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DataSourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.dataSources.createAlias('paired_devices__source_id__data_sources__id');

  $$DataSourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$DataSourcesTableTableManager(
      $_db,
      $_db.dataSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PairedDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $PairedDevicesTable> {
  $$PairedDevicesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<DeviceKind, DeviceKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pairedAt => $composableBuilder(
    column: $table.pairedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DataSourcesTableFilterComposer get sourceId {
    final $$DataSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableFilterComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PairedDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $PairedDevicesTable> {
  $$PairedDevicesTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pairedAt => $composableBuilder(
    column: $table.pairedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DataSourcesTableOrderingComposer get sourceId {
    final $$DataSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PairedDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PairedDevicesTable> {
  $$PairedDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DeviceKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<DateTime> get pairedAt =>
      $composableBuilder(column: $table.pairedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  $$DataSourcesTableAnnotationComposer get sourceId {
    final $$DataSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PairedDevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PairedDevicesTable,
          PairedDevice,
          $$PairedDevicesTableFilterComposer,
          $$PairedDevicesTableOrderingComposer,
          $$PairedDevicesTableAnnotationComposer,
          $$PairedDevicesTableCreateCompanionBuilder,
          $$PairedDevicesTableUpdateCompanionBuilder,
          (PairedDevice, $$PairedDevicesTableReferences),
          PairedDevice,
          PrefetchHooks Function({bool sourceId})
        > {
  $$PairedDevicesTableTableManager(_$AppDatabase db, $PairedDevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PairedDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PairedDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PairedDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<DeviceKind> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> publicKey = const Value.absent(),
                Value<DateTime> pairedAt = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PairedDevicesCompanion(
                id: id,
                sourceId: sourceId,
                kind: kind,
                name: name,
                publicKey: publicKey,
                pairedAt: pairedAt,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String sourceId,
                required DeviceKind kind,
                required String name,
                required String publicKey,
                required DateTime pairedAt,
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PairedDevicesCompanion.insert(
                id: id,
                sourceId: sourceId,
                kind: kind,
                name: name,
                publicKey: publicKey,
                pairedAt: pairedAt,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PairedDevicesTable, PairedDevice>(table),
                  $$PairedDevicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false}) {
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
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$PairedDevicesTableReferences
                            ._sourceIdTable(db),
                        referencedColumn: $$PairedDevicesTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
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

typedef $$PairedDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PairedDevicesTable,
      PairedDevice,
      $$PairedDevicesTableFilterComposer,
      $$PairedDevicesTableOrderingComposer,
      $$PairedDevicesTableAnnotationComposer,
      $$PairedDevicesTableCreateCompanionBuilder,
      $$PairedDevicesTableUpdateCompanionBuilder,
      (PairedDevice, $$PairedDevicesTableReferences),
      PairedDevice,
      PrefetchHooks Function({bool sourceId})
    >;
typedef $$TrackedRepositoriesTableCreateCompanionBuilder =
    TrackedRepositoriesCompanion Function({
      Value<String> id,
      required String sourceId,
      required String fullName,
      Value<String?> projectId,
      Value<bool> ignored,
      Value<int> rowid,
    });
typedef $$TrackedRepositoriesTableUpdateCompanionBuilder =
    TrackedRepositoriesCompanion Function({
      Value<String> id,
      Value<String> sourceId,
      Value<String> fullName,
      Value<String?> projectId,
      Value<bool> ignored,
      Value<int> rowid,
    });

final class $$TrackedRepositoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TrackedRepositoriesTable,
          TrackedRepository
        > {
  $$TrackedRepositoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DataSourcesTable _sourceIdTable(_$AppDatabase db) => db.dataSources
      .createAlias('tracked_repositories__source_id__data_sources__id');

  $$DataSourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$DataSourcesTableTableManager(
      $_db,
      $_db.dataSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('tracked_repositories__project_id__projects__id');

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrackedRepositoriesTableFilterComposer
    extends Composer<_$AppDatabase, $TrackedRepositoriesTable> {
  $$TrackedRepositoriesTableFilterComposer({
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

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ignored => $composableBuilder(
    column: $table.ignored,
    builder: (column) => ColumnFilters(column),
  );

  $$DataSourcesTableFilterComposer get sourceId {
    final $$DataSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableFilterComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackedRepositoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackedRepositoriesTable> {
  $$TrackedRepositoriesTableOrderingComposer({
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

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ignored => $composableBuilder(
    column: $table.ignored,
    builder: (column) => ColumnOrderings(column),
  );

  $$DataSourcesTableOrderingComposer get sourceId {
    final $$DataSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackedRepositoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackedRepositoriesTable> {
  $$TrackedRepositoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<bool> get ignored =>
      $composableBuilder(column: $table.ignored, builder: (column) => column);

  $$DataSourcesTableAnnotationComposer get sourceId {
    final $$DataSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrackedRepositoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackedRepositoriesTable,
          TrackedRepository,
          $$TrackedRepositoriesTableFilterComposer,
          $$TrackedRepositoriesTableOrderingComposer,
          $$TrackedRepositoriesTableAnnotationComposer,
          $$TrackedRepositoriesTableCreateCompanionBuilder,
          $$TrackedRepositoriesTableUpdateCompanionBuilder,
          (TrackedRepository, $$TrackedRepositoriesTableReferences),
          TrackedRepository,
          PrefetchHooks Function({bool sourceId, bool projectId})
        > {
  $$TrackedRepositoriesTableTableManager(
    _$AppDatabase db,
    $TrackedRepositoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackedRepositoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackedRepositoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TrackedRepositoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<bool> ignored = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackedRepositoriesCompanion(
                id: id,
                sourceId: sourceId,
                fullName: fullName,
                projectId: projectId,
                ignored: ignored,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String sourceId,
                required String fullName,
                Value<String?> projectId = const Value.absent(),
                Value<bool> ignored = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrackedRepositoriesCompanion.insert(
                id: id,
                sourceId: sourceId,
                fullName: fullName,
                projectId: projectId,
                ignored: ignored,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrackedRepositoriesTable, TrackedRepository>(
                    table,
                  ),
                  $$TrackedRepositoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false, projectId = false}) {
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
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$TrackedRepositoriesTableReferences
                            ._sourceIdTable(db),
                        referencedColumn: $$TrackedRepositoriesTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (projectId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.projectId,
                        referencedTable: $$TrackedRepositoriesTableReferences
                            ._projectIdTable(db),
                        referencedColumn: $$TrackedRepositoriesTableReferences
                            ._projectIdTable(db)
                            .id,
                      ) as T;
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

typedef $$TrackedRepositoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackedRepositoriesTable,
      TrackedRepository,
      $$TrackedRepositoriesTableFilterComposer,
      $$TrackedRepositoriesTableOrderingComposer,
      $$TrackedRepositoriesTableAnnotationComposer,
      $$TrackedRepositoriesTableCreateCompanionBuilder,
      $$TrackedRepositoriesTableUpdateCompanionBuilder,
      (TrackedRepository, $$TrackedRepositoriesTableReferences),
      TrackedRepository,
      PrefetchHooks Function({bool sourceId, bool projectId})
    >;
typedef $$WorkSessionsTableCreateCompanionBuilder =
    WorkSessionsCompanion Function({
      Value<String> id,
      Value<String?> projectId,
      required ActivityCategory category,
      required DateTime startedAt,
      required DateTime endedAt,
      Value<int> rowid,
    });
typedef $$WorkSessionsTableUpdateCompanionBuilder =
    WorkSessionsCompanion Function({
      Value<String> id,
      Value<String?> projectId,
      Value<ActivityCategory> category,
      Value<DateTime> startedAt,
      Value<DateTime> endedAt,
      Value<int> rowid,
    });

final class $$WorkSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkSessionsTable, WorkSession> {
  $$WorkSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('work_sessions__project_id__projects__id');

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ActivityEventsTable, List<ActivityEvent>>
  _activityEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activityEvents,
    aliasName: 'work_sessions__id__activity_events__session_id',
  );

  $$ActivityEventsTableProcessedTableManager get activityEventsRefs {
    final manager = $$ActivityEventsTableTableManager(
      $_db,
      $_db.activityEvents,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activityEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkSessionsTable> {
  $$WorkSessionsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<ActivityCategory, ActivityCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> activityEventsRefs(
    Expression<bool> Function($$ActivityEventsTableFilterComposer f) f,
  ) {
    final $$ActivityEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityEvents,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityEventsTableFilterComposer(
            $db: $db,
            $table: $db.activityEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkSessionsTable> {
  $$WorkSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkSessionsTable> {
  $$WorkSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> activityEventsRefs<T extends Object>(
    Expression<T> Function($$ActivityEventsTableAnnotationComposer a) f,
  ) {
    final $$ActivityEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activityEvents,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.activityEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkSessionsTable,
          WorkSession,
          $$WorkSessionsTableFilterComposer,
          $$WorkSessionsTableOrderingComposer,
          $$WorkSessionsTableAnnotationComposer,
          $$WorkSessionsTableCreateCompanionBuilder,
          $$WorkSessionsTableUpdateCompanionBuilder,
          (WorkSession, $$WorkSessionsTableReferences),
          WorkSession,
          PrefetchHooks Function({bool projectId, bool activityEventsRefs})
        > {
  $$WorkSessionsTableTableManager(_$AppDatabase db, $WorkSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<ActivityCategory> category = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkSessionsCompanion(
                id: id,
                projectId: projectId,
                category: category,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                required ActivityCategory category,
                required DateTime startedAt,
                required DateTime endedAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkSessionsCompanion.insert(
                id: id,
                projectId: projectId,
                category: category,
                startedAt: startedAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkSessionsTable, WorkSession>(table),
                  $$WorkSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({projectId = false, activityEventsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (activityEventsRefs) db.activityEvents,
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
                        if (projectId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.projectId,
                            referencedTable: $$WorkSessionsTableReferences
                                ._projectIdTable(db),
                            referencedColumn: $$WorkSessionsTableReferences
                                ._projectIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (activityEventsRefs)
                        await $_getPrefetchedDataByColumns<
                          WorkSession,
                          $WorkSessionsTable,
                          ActivityEvent,
                          $ActivityEventsTable
                        >(
                          currentTable: table,
                          referencedTable: $$WorkSessionsTableReferences
                              ._activityEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).activityEventsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkSessionsTable,
      WorkSession,
      $$WorkSessionsTableFilterComposer,
      $$WorkSessionsTableOrderingComposer,
      $$WorkSessionsTableAnnotationComposer,
      $$WorkSessionsTableCreateCompanionBuilder,
      $$WorkSessionsTableUpdateCompanionBuilder,
      (WorkSession, $$WorkSessionsTableReferences),
      WorkSession,
      PrefetchHooks Function({bool projectId, bool activityEventsRefs})
    >;
typedef $$ActivityEventsTableCreateCompanionBuilder =
    ActivityEventsCompanion Function({
      Value<String> id,
      required String sourceId,
      Value<String?> externalId,
      required ActivityKind kind,
      required ActivityCategory category,
      required String title,
      Value<String?> application,
      Value<String?> workspacePath,
      Value<String?> domain,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<String?> sessionId,
      Value<String?> projectId,
      Value<AttributionState> attribution,
      Value<double?> confidence,
      Value<String?> attributionReason,
      Value<int> mergedEventCount,
      Value<bool> isPrivate,
      Value<bool> isCorrected,
      Value<int> rowid,
    });
typedef $$ActivityEventsTableUpdateCompanionBuilder =
    ActivityEventsCompanion Function({
      Value<String> id,
      Value<String> sourceId,
      Value<String?> externalId,
      Value<ActivityKind> kind,
      Value<ActivityCategory> category,
      Value<String> title,
      Value<String?> application,
      Value<String?> workspacePath,
      Value<String?> domain,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<String?> sessionId,
      Value<String?> projectId,
      Value<AttributionState> attribution,
      Value<double?> confidence,
      Value<String?> attributionReason,
      Value<int> mergedEventCount,
      Value<bool> isPrivate,
      Value<bool> isCorrected,
      Value<int> rowid,
    });

final class $$ActivityEventsTableReferences
    extends BaseReferences<_$AppDatabase, $ActivityEventsTable, ActivityEvent> {
  $$ActivityEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DataSourcesTable _sourceIdTable(_$AppDatabase db) => db.dataSources
      .createAlias('activity_events__source_id__data_sources__id');

  $$DataSourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$DataSourcesTableTableManager(
      $_db,
      $_db.dataSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkSessionsTable _sessionIdTable(_$AppDatabase db) => db.workSessions
      .createAlias('activity_events__session_id__work_sessions__id');

  $$WorkSessionsTableProcessedTableManager? get sessionId {
    final $_column = $_itemColumn<String>('session_id');
    if ($_column == null) return null;
    final manager = $$WorkSessionsTableTableManager(
      $_db,
      $_db.workSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias('activity_events__project_id__projects__id');

  $$ProjectsTableProcessedTableManager? get projectId {
    final $_column = $_itemColumn<String>('project_id');
    if ($_column == null) return null;
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActivityEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableFilterComposer({
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

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivityKind, ActivityKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ActivityCategory, ActivityCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get application => $composableBuilder(
    column: $table.application,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspacePath => $composableBuilder(
    column: $table.workspacePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AttributionState, AttributionState, String>
  get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attributionReason => $composableBuilder(
    column: $table.attributionReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mergedEventCount => $composableBuilder(
    column: $table.mergedEventCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrivate => $composableBuilder(
    column: $table.isPrivate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrected => $composableBuilder(
    column: $table.isCorrected,
    builder: (column) => ColumnFilters(column),
  );

  $$DataSourcesTableFilterComposer get sourceId {
    final $$DataSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableFilterComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkSessionsTableFilterComposer get sessionId {
    final $$WorkSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableOrderingComposer({
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

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get application => $composableBuilder(
    column: $table.application,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspacePath => $composableBuilder(
    column: $table.workspacePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attribution => $composableBuilder(
    column: $table.attribution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attributionReason => $composableBuilder(
    column: $table.attributionReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mergedEventCount => $composableBuilder(
    column: $table.mergedEventCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrivate => $composableBuilder(
    column: $table.isPrivate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrected => $composableBuilder(
    column: $table.isCorrected,
    builder: (column) => ColumnOrderings(column),
  );

  $$DataSourcesTableOrderingComposer get sourceId {
    final $$DataSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkSessionsTableOrderingComposer get sessionId {
    final $$WorkSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.workSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ActivityKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get application => $composableBuilder(
    column: $table.application,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workspacePath => $composableBuilder(
    column: $table.workspacePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AttributionState, String> get attribution =>
      $composableBuilder(
        column: $table.attribution,
        builder: (column) => column,
      );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attributionReason => $composableBuilder(
    column: $table.attributionReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mergedEventCount => $composableBuilder(
    column: $table.mergedEventCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrivate =>
      $composableBuilder(column: $table.isPrivate, builder: (column) => column);

  GeneratedColumn<bool> get isCorrected => $composableBuilder(
    column: $table.isCorrected,
    builder: (column) => column,
  );

  $$DataSourcesTableAnnotationComposer get sourceId {
    final $$DataSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WorkSessionsTableAnnotationComposer get sessionId {
    final $$WorkSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivityEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityEventsTable,
          ActivityEvent,
          $$ActivityEventsTableFilterComposer,
          $$ActivityEventsTableOrderingComposer,
          $$ActivityEventsTableAnnotationComposer,
          $$ActivityEventsTableCreateCompanionBuilder,
          $$ActivityEventsTableUpdateCompanionBuilder,
          (ActivityEvent, $$ActivityEventsTableReferences),
          ActivityEvent,
          PrefetchHooks Function({
            bool sourceId,
            bool sessionId,
            bool projectId,
          })
        > {
  $$ActivityEventsTableTableManager(
    _$AppDatabase db,
    $ActivityEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String?> externalId = const Value.absent(),
                Value<ActivityKind> kind = const Value.absent(),
                Value<ActivityCategory> category = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> application = const Value.absent(),
                Value<String?> workspacePath = const Value.absent(),
                Value<String?> domain = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<AttributionState> attribution = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> attributionReason = const Value.absent(),
                Value<int> mergedEventCount = const Value.absent(),
                Value<bool> isPrivate = const Value.absent(),
                Value<bool> isCorrected = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityEventsCompanion(
                id: id,
                sourceId: sourceId,
                externalId: externalId,
                kind: kind,
                category: category,
                title: title,
                application: application,
                workspacePath: workspacePath,
                domain: domain,
                startedAt: startedAt,
                endedAt: endedAt,
                sessionId: sessionId,
                projectId: projectId,
                attribution: attribution,
                confidence: confidence,
                attributionReason: attributionReason,
                mergedEventCount: mergedEventCount,
                isPrivate: isPrivate,
                isCorrected: isCorrected,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String sourceId,
                Value<String?> externalId = const Value.absent(),
                required ActivityKind kind,
                required ActivityCategory category,
                required String title,
                Value<String?> application = const Value.absent(),
                Value<String?> workspacePath = const Value.absent(),
                Value<String?> domain = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<AttributionState> attribution = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> attributionReason = const Value.absent(),
                Value<int> mergedEventCount = const Value.absent(),
                Value<bool> isPrivate = const Value.absent(),
                Value<bool> isCorrected = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityEventsCompanion.insert(
                id: id,
                sourceId: sourceId,
                externalId: externalId,
                kind: kind,
                category: category,
                title: title,
                application: application,
                workspacePath: workspacePath,
                domain: domain,
                startedAt: startedAt,
                endedAt: endedAt,
                sessionId: sessionId,
                projectId: projectId,
                attribution: attribution,
                confidence: confidence,
                attributionReason: attributionReason,
                mergedEventCount: mergedEventCount,
                isPrivate: isPrivate,
                isCorrected: isCorrected,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivityEventsTable, ActivityEvent>(table),
                  $$ActivityEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sourceId = false, sessionId = false, projectId = false}) {
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
                        if (sourceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sourceId,
                            referencedTable: $$ActivityEventsTableReferences
                                ._sourceIdTable(db),
                            referencedColumn: $$ActivityEventsTableReferences
                                ._sourceIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (sessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sessionId,
                            referencedTable: $$ActivityEventsTableReferences
                                ._sessionIdTable(db),
                            referencedColumn: $$ActivityEventsTableReferences
                                ._sessionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (projectId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.projectId,
                            referencedTable: $$ActivityEventsTableReferences
                                ._projectIdTable(db),
                            referencedColumn: $$ActivityEventsTableReferences
                                ._projectIdTable(db)
                                .id,
                          ) as T;
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

typedef $$ActivityEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityEventsTable,
      ActivityEvent,
      $$ActivityEventsTableFilterComposer,
      $$ActivityEventsTableOrderingComposer,
      $$ActivityEventsTableAnnotationComposer,
      $$ActivityEventsTableCreateCompanionBuilder,
      $$ActivityEventsTableUpdateCompanionBuilder,
      (ActivityEvent, $$ActivityEventsTableReferences),
      ActivityEvent,
      PrefetchHooks Function({bool sourceId, bool sessionId, bool projectId})
    >;
typedef $$EventTombstonesTableCreateCompanionBuilder =
    EventTombstonesCompanion Function({
      required String sourceId,
      required String externalId,
      required DateTime deletedAt,
      Value<int> rowid,
    });
typedef $$EventTombstonesTableUpdateCompanionBuilder =
    EventTombstonesCompanion Function({
      Value<String> sourceId,
      Value<String> externalId,
      Value<DateTime> deletedAt,
      Value<int> rowid,
    });

final class $$EventTombstonesTableReferences
    extends
        BaseReferences<_$AppDatabase, $EventTombstonesTable, EventTombstone> {
  $$EventTombstonesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DataSourcesTable _sourceIdTable(_$AppDatabase db) => db.dataSources
      .createAlias('event_tombstones__source_id__data_sources__id');

  $$DataSourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$DataSourcesTableTableManager(
      $_db,
      $_db.dataSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventTombstonesTableFilterComposer
    extends Composer<_$AppDatabase, $EventTombstonesTable> {
  $$EventTombstonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DataSourcesTableFilterComposer get sourceId {
    final $$DataSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableFilterComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventTombstonesTableOrderingComposer
    extends Composer<_$AppDatabase, $EventTombstonesTable> {
  $$EventTombstonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DataSourcesTableOrderingComposer get sourceId {
    final $$DataSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventTombstonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventTombstonesTable> {
  $$EventTombstonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$DataSourcesTableAnnotationComposer get sourceId {
    final $$DataSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.dataSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DataSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.dataSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventTombstonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventTombstonesTable,
          EventTombstone,
          $$EventTombstonesTableFilterComposer,
          $$EventTombstonesTableOrderingComposer,
          $$EventTombstonesTableAnnotationComposer,
          $$EventTombstonesTableCreateCompanionBuilder,
          $$EventTombstonesTableUpdateCompanionBuilder,
          (EventTombstone, $$EventTombstonesTableReferences),
          EventTombstone,
          PrefetchHooks Function({bool sourceId})
        > {
  $$EventTombstonesTableTableManager(
    _$AppDatabase db,
    $EventTombstonesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventTombstonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventTombstonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventTombstonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceId = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<DateTime> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventTombstonesCompanion(
                sourceId: sourceId,
                externalId: externalId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceId,
                required String externalId,
                required DateTime deletedAt,
                Value<int> rowid = const Value.absent(),
              }) => EventTombstonesCompanion.insert(
                sourceId: sourceId,
                externalId: externalId,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventTombstonesTable, EventTombstone>(table),
                  $$EventTombstonesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceId = false}) {
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
                    if (sourceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceId,
                        referencedTable: $$EventTombstonesTableReferences
                            ._sourceIdTable(db),
                        referencedColumn: $$EventTombstonesTableReferences
                            ._sourceIdTable(db)
                            .id,
                      ) as T;
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

typedef $$EventTombstonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventTombstonesTable,
      EventTombstone,
      $$EventTombstonesTableFilterComposer,
      $$EventTombstonesTableOrderingComposer,
      $$EventTombstonesTableAnnotationComposer,
      $$EventTombstonesTableCreateCompanionBuilder,
      $$EventTombstonesTableUpdateCompanionBuilder,
      (EventTombstone, $$EventTombstonesTableReferences),
      EventTombstone,
      PrefetchHooks Function({bool sourceId})
    >;
typedef $$ExclusionsTableCreateCompanionBuilder = ExclusionsCompanion Function({
  Value<String> id,
  required ExclusionKind kind,
  required String value,
  Value<String?> label,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ExclusionsTableUpdateCompanionBuilder = ExclusionsCompanion Function({
  Value<String> id,
  Value<ExclusionKind> kind,
  Value<String> value,
  Value<String?> label,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ExclusionsTableFilterComposer
    extends Composer<_$AppDatabase, $ExclusionsTable> {
  $$ExclusionsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<ExclusionKind, ExclusionKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExclusionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExclusionsTable> {
  $$ExclusionsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExclusionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExclusionsTable> {
  $$ExclusionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExclusionKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ExclusionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExclusionsTable,
          Exclusion,
          $$ExclusionsTableFilterComposer,
          $$ExclusionsTableOrderingComposer,
          $$ExclusionsTableAnnotationComposer,
          $$ExclusionsTableCreateCompanionBuilder,
          $$ExclusionsTableUpdateCompanionBuilder,
          (
            Exclusion,
            BaseReferences<_$AppDatabase, $ExclusionsTable, Exclusion>,
          ),
          Exclusion,
          PrefetchHooks Function()
        > {
  $$ExclusionsTableTableManager(_$AppDatabase db, $ExclusionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExclusionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExclusionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExclusionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<ExclusionKind> kind = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExclusionsCompanion(
                id: id,
                kind: kind,
                value: value,
                label: label,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required ExclusionKind kind,
                required String value,
                Value<String?> label = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ExclusionsCompanion.insert(
                id: id,
                kind: kind,
                value: value,
                label: label,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExclusionsTable, Exclusion>(table),
                  BaseReferences<_$AppDatabase, $ExclusionsTable, Exclusion>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExclusionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExclusionsTable,
      Exclusion,
      $$ExclusionsTableFilterComposer,
      $$ExclusionsTableOrderingComposer,
      $$ExclusionsTableAnnotationComposer,
      $$ExclusionsTableCreateCompanionBuilder,
      $$ExclusionsTableUpdateCompanionBuilder,
      (Exclusion, BaseReferences<_$AppDatabase, $ExclusionsTable, Exclusion>),
      Exclusion,
      PrefetchHooks Function()
    >;
typedef $$ReportsTableCreateCompanionBuilder = ReportsCompanion Function({
  Value<String> id,
  required ReportPeriod period,
  required DateTime periodStart,
  required String body,
  required DateTime generatedAt,
  Value<int> rowid,
});
typedef $$ReportsTableUpdateCompanionBuilder = ReportsCompanion Function({
  Value<String> id,
  Value<ReportPeriod> period,
  Value<DateTime> periodStart,
  Value<String> body,
  Value<DateTime> generatedAt,
  Value<int> rowid,
});

class $$ReportsTableFilterComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<ReportPeriod, ReportPeriod, String>
  get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableOrderingComposer({
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

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReportPeriod, String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );
}

class $$ReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReportsTable,
          Report,
          $$ReportsTableFilterComposer,
          $$ReportsTableOrderingComposer,
          $$ReportsTableAnnotationComposer,
          $$ReportsTableCreateCompanionBuilder,
          $$ReportsTableUpdateCompanionBuilder,
          (Report, BaseReferences<_$AppDatabase, $ReportsTable, Report>),
          Report,
          PrefetchHooks Function()
        > {
  $$ReportsTableTableManager(_$AppDatabase db, $ReportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<ReportPeriod> period = const Value.absent(),
                Value<DateTime> periodStart = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReportsCompanion(
                id: id,
                period: period,
                periodStart: periodStart,
                body: body,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required ReportPeriod period,
                required DateTime periodStart,
                required String body,
                required DateTime generatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ReportsCompanion.insert(
                id: id,
                period: period,
                periodStart: periodStart,
                body: body,
                generatedAt: generatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReportsTable, Report>(table),
                  BaseReferences<_$AppDatabase, $ReportsTable, Report>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReportsTable,
      Report,
      $$ReportsTableFilterComposer,
      $$ReportsTableOrderingComposer,
      $$ReportsTableAnnotationComposer,
      $$ReportsTableCreateCompanionBuilder,
      $$ReportsTableUpdateCompanionBuilder,
      (Report, BaseReferences<_$AppDatabase, $ReportsTable, Report>),
      Report,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$ProjectRulesTableTableManager get projectRules =>
      $$ProjectRulesTableTableManager(_db, _db.projectRules);
  $$DataSourcesTableTableManager get dataSources =>
      $$DataSourcesTableTableManager(_db, _db.dataSources);
  $$PairedDevicesTableTableManager get pairedDevices =>
      $$PairedDevicesTableTableManager(_db, _db.pairedDevices);
  $$TrackedRepositoriesTableTableManager get trackedRepositories =>
      $$TrackedRepositoriesTableTableManager(_db, _db.trackedRepositories);
  $$WorkSessionsTableTableManager get workSessions =>
      $$WorkSessionsTableTableManager(_db, _db.workSessions);
  $$ActivityEventsTableTableManager get activityEvents =>
      $$ActivityEventsTableTableManager(_db, _db.activityEvents);
  $$EventTombstonesTableTableManager get eventTombstones =>
      $$EventTombstonesTableTableManager(_db, _db.eventTombstones);
  $$ExclusionsTableTableManager get exclusions =>
      $$ExclusionsTableTableManager(_db, _db.exclusions);
  $$ReportsTableTableManager get reports =>
      $$ReportsTableTableManager(_db, _db.reports);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
