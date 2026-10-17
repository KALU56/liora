// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_database.dart';

// ignore_for_file: type=lint
class $StoredNotesTable extends StoredNotes
    with TableInfo<$StoredNotesTable, StoredNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, value, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $StoredNotesTable createAlias(String alias) {
    return $StoredNotesTable(attachedDatabase, alias);
  }
}

class StoredNote extends DataClass implements Insertable<StoredNote> {
  final String id;
  final String value;
  final int sortOrder;
  const StoredNote({
    required this.id,
    required this.value,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['value'] = Variable<String>(value);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  StoredNotesCompanion toCompanion(bool nullToAbsent) {
    return StoredNotesCompanion(
      id: Value(id),
      value: Value(value),
      sortOrder: Value(sortOrder),
    );
  }

  factory StoredNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredNote(
      id: serializer.fromJson<String>(json['id']),
      value: serializer.fromJson<String>(json['value']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'value': serializer.toJson<String>(value),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  StoredNote copyWith({String? id, String? value, int? sortOrder}) =>
      StoredNote(
        id: id ?? this.id,
        value: value ?? this.value,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  StoredNote copyWithCompanion(StoredNotesCompanion data) {
    return StoredNote(
      id: data.id.present ? data.id.value : this.id,
      value: data.value.present ? data.value.value : this.value,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredNote(')
          ..write('id: $id, ')
          ..write('value: $value, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, value, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredNote &&
          other.id == this.id &&
          other.value == this.value &&
          other.sortOrder == this.sortOrder);
}

class StoredNotesCompanion extends UpdateCompanion<StoredNote> {
  final Value<String> id;
  final Value<String> value;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const StoredNotesCompanion({
    this.id = const Value.absent(),
    this.value = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredNotesCompanion.insert({
    required String id,
    required String value,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       value = Value(value),
       sortOrder = Value(sortOrder);
  static Insertable<StoredNote> custom({
    Expression<String>? id,
    Expression<String>? value,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (value != null) 'value': value,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? value,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return StoredNotesCompanion(
      id: id ?? this.id,
      value: value ?? this.value,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredNotesCompanion(')
          ..write('id: $id, ')
          ..write('value: $value, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StoredAttachmentsTable extends StoredAttachments
    with TableInfo<$StoredAttachmentsTable, StoredAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoredAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, mimeType, bytes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stored_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bytes'],
      )!,
    );
  }

  @override
  $StoredAttachmentsTable createAlias(String alias) {
    return $StoredAttachmentsTable(attachedDatabase, alias);
  }
}

class StoredAttachment extends DataClass
    implements Insertable<StoredAttachment> {
  final String id;
  final String name;
  final String mimeType;
  final Uint8List bytes;
  const StoredAttachment({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.bytes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['mime_type'] = Variable<String>(mimeType);
    map['bytes'] = Variable<Uint8List>(bytes);
    return map;
  }

  StoredAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return StoredAttachmentsCompanion(
      id: Value(id),
      name: Value(name),
      mimeType: Value(mimeType),
      bytes: Value(bytes),
    );
  }

  factory StoredAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredAttachment(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'mimeType': serializer.toJson<String>(mimeType),
      'bytes': serializer.toJson<Uint8List>(bytes),
    };
  }

  StoredAttachment copyWith({
    String? id,
    String? name,
    String? mimeType,
    Uint8List? bytes,
  }) => StoredAttachment(
    id: id ?? this.id,
    name: name ?? this.name,
    mimeType: mimeType ?? this.mimeType,
    bytes: bytes ?? this.bytes,
  );
  StoredAttachment copyWithCompanion(StoredAttachmentsCompanion data) {
    return StoredAttachment(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredAttachment(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mimeType: $mimeType, ')
          ..write('bytes: $bytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, mimeType, $driftBlobEquality.hash(bytes));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredAttachment &&
          other.id == this.id &&
          other.name == this.name &&
          other.mimeType == this.mimeType &&
          $driftBlobEquality.equals(other.bytes, this.bytes));
}

class StoredAttachmentsCompanion extends UpdateCompanion<StoredAttachment> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> mimeType;
  final Value<Uint8List> bytes;
  final Value<int> rowid;
  const StoredAttachmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.bytes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoredAttachmentsCompanion.insert({
    required String id,
    required String name,
    required String mimeType,
    required Uint8List bytes,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       mimeType = Value(mimeType),
       bytes = Value(bytes);
  static Insertable<StoredAttachment> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? mimeType,
    Expression<Uint8List>? bytes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mimeType != null) 'mime_type': mimeType,
      if (bytes != null) 'bytes': bytes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoredAttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? mimeType,
    Value<Uint8List>? bytes,
    Value<int>? rowid,
  }) {
    return StoredAttachmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      mimeType: mimeType ?? this.mimeType,
      bytes: bytes ?? this.bytes,
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
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoredAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mimeType: $mimeType, ')
          ..write('bytes: $bytes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$NoteDatabase extends GeneratedDatabase {
  _$NoteDatabase(QueryExecutor e) : super(e);
  $NoteDatabaseManager get managers => $NoteDatabaseManager(this);
  late final $StoredNotesTable storedNotes = $StoredNotesTable(this);
  late final $StoredAttachmentsTable storedAttachments =
      $StoredAttachmentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    storedNotes,
    storedAttachments,
  ];
}

typedef $$StoredNotesTableCreateCompanionBuilder =
    StoredNotesCompanion Function({
      required String id,
      required String value,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$StoredNotesTableUpdateCompanionBuilder =
    StoredNotesCompanion Function({
      Value<String> id,
      Value<String> value,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$StoredNotesTableFilterComposer
    extends Composer<_$NoteDatabase, $StoredNotesTable> {
  $$StoredNotesTableFilterComposer({
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

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoredNotesTableOrderingComposer
    extends Composer<_$NoteDatabase, $StoredNotesTable> {
  $$StoredNotesTableOrderingComposer({
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

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoredNotesTableAnnotationComposer
    extends Composer<_$NoteDatabase, $StoredNotesTable> {
  $$StoredNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$StoredNotesTableTableManager
    extends
        RootTableManager<
          _$NoteDatabase,
          $StoredNotesTable,
          StoredNote,
          $$StoredNotesTableFilterComposer,
          $$StoredNotesTableOrderingComposer,
          $$StoredNotesTableAnnotationComposer,
          $$StoredNotesTableCreateCompanionBuilder,
          $$StoredNotesTableUpdateCompanionBuilder,
          (
            StoredNote,
            BaseReferences<_$NoteDatabase, $StoredNotesTable, StoredNote>,
          ),
          StoredNote,
          PrefetchHooks Function()
        > {
  $$StoredNotesTableTableManager(_$NoteDatabase db, $StoredNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoredNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoredNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredNotesCompanion(
                id: id,
                value: value,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String value,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => StoredNotesCompanion.insert(
                id: id,
                value: value,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StoredNotesTable, StoredNote>(table),
                  BaseReferences<_$NoteDatabase, $StoredNotesTable, StoredNote>(
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

typedef $$StoredNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$NoteDatabase,
      $StoredNotesTable,
      StoredNote,
      $$StoredNotesTableFilterComposer,
      $$StoredNotesTableOrderingComposer,
      $$StoredNotesTableAnnotationComposer,
      $$StoredNotesTableCreateCompanionBuilder,
      $$StoredNotesTableUpdateCompanionBuilder,
      (
        StoredNote,
        BaseReferences<_$NoteDatabase, $StoredNotesTable, StoredNote>,
      ),
      StoredNote,
      PrefetchHooks Function()
    >;
typedef $$StoredAttachmentsTableCreateCompanionBuilder =
    StoredAttachmentsCompanion Function({
      required String id,
      required String name,
      required String mimeType,
      required Uint8List bytes,
      Value<int> rowid,
    });
typedef $$StoredAttachmentsTableUpdateCompanionBuilder =
    StoredAttachmentsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> mimeType,
      Value<Uint8List> bytes,
      Value<int> rowid,
    });

class $$StoredAttachmentsTableFilterComposer
    extends Composer<_$NoteDatabase, $StoredAttachmentsTable> {
  $$StoredAttachmentsTableFilterComposer({
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

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoredAttachmentsTableOrderingComposer
    extends Composer<_$NoteDatabase, $StoredAttachmentsTable> {
  $$StoredAttachmentsTableOrderingComposer({
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

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoredAttachmentsTableAnnotationComposer
    extends Composer<_$NoteDatabase, $StoredAttachmentsTable> {
  $$StoredAttachmentsTableAnnotationComposer({
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

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);
}

class $$StoredAttachmentsTableTableManager
    extends
        RootTableManager<
          _$NoteDatabase,
          $StoredAttachmentsTable,
          StoredAttachment,
          $$StoredAttachmentsTableFilterComposer,
          $$StoredAttachmentsTableOrderingComposer,
          $$StoredAttachmentsTableAnnotationComposer,
          $$StoredAttachmentsTableCreateCompanionBuilder,
          $$StoredAttachmentsTableUpdateCompanionBuilder,
          (
            StoredAttachment,
            BaseReferences<
              _$NoteDatabase,
              $StoredAttachmentsTable,
              StoredAttachment
            >,
          ),
          StoredAttachment,
          PrefetchHooks Function()
        > {
  $$StoredAttachmentsTableTableManager(
    _$NoteDatabase db,
    $StoredAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoredAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoredAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoredAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<Uint8List> bytes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoredAttachmentsCompanion(
                id: id,
                name: name,
                mimeType: mimeType,
                bytes: bytes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String mimeType,
                required Uint8List bytes,
                Value<int> rowid = const Value.absent(),
              }) => StoredAttachmentsCompanion.insert(
                id: id,
                name: name,
                mimeType: mimeType,
                bytes: bytes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StoredAttachmentsTable, StoredAttachment>(table),
                  BaseReferences<
                    _$NoteDatabase,
                    $StoredAttachmentsTable,
                    StoredAttachment
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoredAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$NoteDatabase,
      $StoredAttachmentsTable,
      StoredAttachment,
      $$StoredAttachmentsTableFilterComposer,
      $$StoredAttachmentsTableOrderingComposer,
      $$StoredAttachmentsTableAnnotationComposer,
      $$StoredAttachmentsTableCreateCompanionBuilder,
      $$StoredAttachmentsTableUpdateCompanionBuilder,
      (
        StoredAttachment,
        BaseReferences<
          _$NoteDatabase,
          $StoredAttachmentsTable,
          StoredAttachment
        >,
      ),
      StoredAttachment,
      PrefetchHooks Function()
    >;

class $NoteDatabaseManager {
  final _$NoteDatabase _db;
  $NoteDatabaseManager(this._db);
  $$StoredNotesTableTableManager get storedNotes =>
      $$StoredNotesTableTableManager(_db, _db.storedNotes);
  $$StoredAttachmentsTableTableManager get storedAttachments =>
      $$StoredAttachmentsTableTableManager(_db, _db.storedAttachments);
}
