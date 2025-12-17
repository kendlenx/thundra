// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StrikesTable extends Strikes with TableInfo<$StrikesTable, Strike> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrikesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
    'lon',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMillisMeta = const VerificationMeta(
    'timestampMillis',
  );
  @override
  late final GeneratedColumn<int> timestampMillis = GeneratedColumn<int>(
    'timestamp_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intensityMeta = const VerificationMeta(
    'intensity',
  );
  @override
  late final GeneratedColumn<double> intensity = GeneratedColumn<double>(
    'intensity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lat,
    lon,
    timestampMillis,
    intensity,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strikes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Strike> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
        _lonMeta,
        lon.isAcceptableOrUnknown(data['lon']!, _lonMeta),
      );
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('timestamp_millis')) {
      context.handle(
        _timestampMillisMeta,
        timestampMillis.isAcceptableOrUnknown(
          data['timestamp_millis']!,
          _timestampMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampMillisMeta);
    }
    if (data.containsKey('intensity')) {
      context.handle(
        _intensityMeta,
        intensity.isAcceptableOrUnknown(data['intensity']!, _intensityMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Strike map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Strike(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lon'],
      )!,
      timestampMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp_millis'],
      )!,
      intensity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}intensity'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $StrikesTable createAlias(String alias) {
    return $StrikesTable(attachedDatabase, alias);
  }
}

class Strike extends DataClass implements Insertable<Strike> {
  final String id;
  final double lat;
  final double lon;
  final int timestampMillis;
  final double? intensity;
  final String source;
  const Strike({
    required this.id,
    required this.lat,
    required this.lon,
    required this.timestampMillis,
    this.intensity,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['timestamp_millis'] = Variable<int>(timestampMillis);
    if (!nullToAbsent || intensity != null) {
      map['intensity'] = Variable<double>(intensity);
    }
    map['source'] = Variable<String>(source);
    return map;
  }

  StrikesCompanion toCompanion(bool nullToAbsent) {
    return StrikesCompanion(
      id: Value(id),
      lat: Value(lat),
      lon: Value(lon),
      timestampMillis: Value(timestampMillis),
      intensity: intensity == null && nullToAbsent
          ? const Value.absent()
          : Value(intensity),
      source: Value(source),
    );
  }

  factory Strike.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Strike(
      id: serializer.fromJson<String>(json['id']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      timestampMillis: serializer.fromJson<int>(json['timestampMillis']),
      intensity: serializer.fromJson<double?>(json['intensity']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'timestampMillis': serializer.toJson<int>(timestampMillis),
      'intensity': serializer.toJson<double?>(intensity),
      'source': serializer.toJson<String>(source),
    };
  }

  Strike copyWith({
    String? id,
    double? lat,
    double? lon,
    int? timestampMillis,
    Value<double?> intensity = const Value.absent(),
    String? source,
  }) => Strike(
    id: id ?? this.id,
    lat: lat ?? this.lat,
    lon: lon ?? this.lon,
    timestampMillis: timestampMillis ?? this.timestampMillis,
    intensity: intensity.present ? intensity.value : this.intensity,
    source: source ?? this.source,
  );
  Strike copyWithCompanion(StrikesCompanion data) {
    return Strike(
      id: data.id.present ? data.id.value : this.id,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      timestampMillis: data.timestampMillis.present
          ? data.timestampMillis.value
          : this.timestampMillis,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Strike(')
          ..write('id: $id, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('timestampMillis: $timestampMillis, ')
          ..write('intensity: $intensity, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, lat, lon, timestampMillis, intensity, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Strike &&
          other.id == this.id &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.timestampMillis == this.timestampMillis &&
          other.intensity == this.intensity &&
          other.source == this.source);
}

class StrikesCompanion extends UpdateCompanion<Strike> {
  final Value<String> id;
  final Value<double> lat;
  final Value<double> lon;
  final Value<int> timestampMillis;
  final Value<double?> intensity;
  final Value<String> source;
  final Value<int> rowid;
  const StrikesCompanion({
    this.id = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.timestampMillis = const Value.absent(),
    this.intensity = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StrikesCompanion.insert({
    required String id,
    required double lat,
    required double lon,
    required int timestampMillis,
    this.intensity = const Value.absent(),
    required String source,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lat = Value(lat),
       lon = Value(lon),
       timestampMillis = Value(timestampMillis),
       source = Value(source);
  static Insertable<Strike> custom({
    Expression<String>? id,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<int>? timestampMillis,
    Expression<double>? intensity,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (timestampMillis != null) 'timestamp_millis': timestampMillis,
      if (intensity != null) 'intensity': intensity,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StrikesCompanion copyWith({
    Value<String>? id,
    Value<double>? lat,
    Value<double>? lon,
    Value<int>? timestampMillis,
    Value<double?>? intensity,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return StrikesCompanion(
      id: id ?? this.id,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      timestampMillis: timestampMillis ?? this.timestampMillis,
      intensity: intensity ?? this.intensity,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (timestampMillis.present) {
      map['timestamp_millis'] = Variable<int>(timestampMillis.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<double>(intensity.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrikesCompanion(')
          ..write('id: $id, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('timestampMillis: $timestampMillis, ')
          ..write('intensity: $intensity, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertSettingsTableTable extends AlertSettingsTable
    with TableInfo<$AlertSettingsTableTable, AlertSettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _radiusKmMeta = const VerificationMeta(
    'radiusKm',
  );
  @override
  late final GeneratedColumn<int> radiusKm = GeneratedColumn<int>(
    'radius_km',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _windowMinutesMeta = const VerificationMeta(
    'windowMinutes',
  );
  @override
  late final GeneratedColumn<int> windowMinutes = GeneratedColumn<int>(
    'window_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _quietHoursEnabledMeta = const VerificationMeta(
    'quietHoursEnabled',
  );
  @override
  late final GeneratedColumn<bool> quietHoursEnabled = GeneratedColumn<bool>(
    'quiet_hours_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("quiet_hours_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _quietStartMinutesMeta = const VerificationMeta(
    'quietStartMinutes',
  );
  @override
  late final GeneratedColumn<int> quietStartMinutes = GeneratedColumn<int>(
    'quiet_start_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(22 * 60),
  );
  static const VerificationMeta _quietEndMinutesMeta = const VerificationMeta(
    'quietEndMinutes',
  );
  @override
  late final GeneratedColumn<int> quietEndMinutes = GeneratedColumn<int>(
    'quiet_end_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7 * 60),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    enabled,
    radiusKm,
    windowMinutes,
    quietHoursEnabled,
    quietStartMinutes,
    quietEndMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alert_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlertSettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('radius_km')) {
      context.handle(
        _radiusKmMeta,
        radiusKm.isAcceptableOrUnknown(data['radius_km']!, _radiusKmMeta),
      );
    }
    if (data.containsKey('window_minutes')) {
      context.handle(
        _windowMinutesMeta,
        windowMinutes.isAcceptableOrUnknown(
          data['window_minutes']!,
          _windowMinutesMeta,
        ),
      );
    }
    if (data.containsKey('quiet_hours_enabled')) {
      context.handle(
        _quietHoursEnabledMeta,
        quietHoursEnabled.isAcceptableOrUnknown(
          data['quiet_hours_enabled']!,
          _quietHoursEnabledMeta,
        ),
      );
    }
    if (data.containsKey('quiet_start_minutes')) {
      context.handle(
        _quietStartMinutesMeta,
        quietStartMinutes.isAcceptableOrUnknown(
          data['quiet_start_minutes']!,
          _quietStartMinutesMeta,
        ),
      );
    }
    if (data.containsKey('quiet_end_minutes')) {
      context.handle(
        _quietEndMinutesMeta,
        quietEndMinutes.isAcceptableOrUnknown(
          data['quiet_end_minutes']!,
          _quietEndMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlertSettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertSettingsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      radiusKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}radius_km'],
      )!,
      windowMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}window_minutes'],
      )!,
      quietHoursEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}quiet_hours_enabled'],
      )!,
      quietStartMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiet_start_minutes'],
      )!,
      quietEndMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiet_end_minutes'],
      )!,
    );
  }

  @override
  $AlertSettingsTableTable createAlias(String alias) {
    return $AlertSettingsTableTable(attachedDatabase, alias);
  }
}

class AlertSettingsTableData extends DataClass
    implements Insertable<AlertSettingsTableData> {
  final int id;
  final bool enabled;
  final int radiusKm;
  final int windowMinutes;
  final bool quietHoursEnabled;
  final int quietStartMinutes;
  final int quietEndMinutes;
  const AlertSettingsTableData({
    required this.id,
    required this.enabled,
    required this.radiusKm,
    required this.windowMinutes,
    required this.quietHoursEnabled,
    required this.quietStartMinutes,
    required this.quietEndMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['enabled'] = Variable<bool>(enabled);
    map['radius_km'] = Variable<int>(radiusKm);
    map['window_minutes'] = Variable<int>(windowMinutes);
    map['quiet_hours_enabled'] = Variable<bool>(quietHoursEnabled);
    map['quiet_start_minutes'] = Variable<int>(quietStartMinutes);
    map['quiet_end_minutes'] = Variable<int>(quietEndMinutes);
    return map;
  }

  AlertSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return AlertSettingsTableCompanion(
      id: Value(id),
      enabled: Value(enabled),
      radiusKm: Value(radiusKm),
      windowMinutes: Value(windowMinutes),
      quietHoursEnabled: Value(quietHoursEnabled),
      quietStartMinutes: Value(quietStartMinutes),
      quietEndMinutes: Value(quietEndMinutes),
    );
  }

  factory AlertSettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertSettingsTableData(
      id: serializer.fromJson<int>(json['id']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      radiusKm: serializer.fromJson<int>(json['radiusKm']),
      windowMinutes: serializer.fromJson<int>(json['windowMinutes']),
      quietHoursEnabled: serializer.fromJson<bool>(json['quietHoursEnabled']),
      quietStartMinutes: serializer.fromJson<int>(json['quietStartMinutes']),
      quietEndMinutes: serializer.fromJson<int>(json['quietEndMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'enabled': serializer.toJson<bool>(enabled),
      'radiusKm': serializer.toJson<int>(radiusKm),
      'windowMinutes': serializer.toJson<int>(windowMinutes),
      'quietHoursEnabled': serializer.toJson<bool>(quietHoursEnabled),
      'quietStartMinutes': serializer.toJson<int>(quietStartMinutes),
      'quietEndMinutes': serializer.toJson<int>(quietEndMinutes),
    };
  }

  AlertSettingsTableData copyWith({
    int? id,
    bool? enabled,
    int? radiusKm,
    int? windowMinutes,
    bool? quietHoursEnabled,
    int? quietStartMinutes,
    int? quietEndMinutes,
  }) => AlertSettingsTableData(
    id: id ?? this.id,
    enabled: enabled ?? this.enabled,
    radiusKm: radiusKm ?? this.radiusKm,
    windowMinutes: windowMinutes ?? this.windowMinutes,
    quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
    quietStartMinutes: quietStartMinutes ?? this.quietStartMinutes,
    quietEndMinutes: quietEndMinutes ?? this.quietEndMinutes,
  );
  AlertSettingsTableData copyWithCompanion(AlertSettingsTableCompanion data) {
    return AlertSettingsTableData(
      id: data.id.present ? data.id.value : this.id,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      radiusKm: data.radiusKm.present ? data.radiusKm.value : this.radiusKm,
      windowMinutes: data.windowMinutes.present
          ? data.windowMinutes.value
          : this.windowMinutes,
      quietHoursEnabled: data.quietHoursEnabled.present
          ? data.quietHoursEnabled.value
          : this.quietHoursEnabled,
      quietStartMinutes: data.quietStartMinutes.present
          ? data.quietStartMinutes.value
          : this.quietStartMinutes,
      quietEndMinutes: data.quietEndMinutes.present
          ? data.quietEndMinutes.value
          : this.quietEndMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlertSettingsTableData(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('radiusKm: $radiusKm, ')
          ..write('windowMinutes: $windowMinutes, ')
          ..write('quietHoursEnabled: $quietHoursEnabled, ')
          ..write('quietStartMinutes: $quietStartMinutes, ')
          ..write('quietEndMinutes: $quietEndMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    enabled,
    radiusKm,
    windowMinutes,
    quietHoursEnabled,
    quietStartMinutes,
    quietEndMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertSettingsTableData &&
          other.id == this.id &&
          other.enabled == this.enabled &&
          other.radiusKm == this.radiusKm &&
          other.windowMinutes == this.windowMinutes &&
          other.quietHoursEnabled == this.quietHoursEnabled &&
          other.quietStartMinutes == this.quietStartMinutes &&
          other.quietEndMinutes == this.quietEndMinutes);
}

class AlertSettingsTableCompanion
    extends UpdateCompanion<AlertSettingsTableData> {
  final Value<int> id;
  final Value<bool> enabled;
  final Value<int> radiusKm;
  final Value<int> windowMinutes;
  final Value<bool> quietHoursEnabled;
  final Value<int> quietStartMinutes;
  final Value<int> quietEndMinutes;
  const AlertSettingsTableCompanion({
    this.id = const Value.absent(),
    this.enabled = const Value.absent(),
    this.radiusKm = const Value.absent(),
    this.windowMinutes = const Value.absent(),
    this.quietHoursEnabled = const Value.absent(),
    this.quietStartMinutes = const Value.absent(),
    this.quietEndMinutes = const Value.absent(),
  });
  AlertSettingsTableCompanion.insert({
    this.id = const Value.absent(),
    this.enabled = const Value.absent(),
    this.radiusKm = const Value.absent(),
    this.windowMinutes = const Value.absent(),
    this.quietHoursEnabled = const Value.absent(),
    this.quietStartMinutes = const Value.absent(),
    this.quietEndMinutes = const Value.absent(),
  });
  static Insertable<AlertSettingsTableData> custom({
    Expression<int>? id,
    Expression<bool>? enabled,
    Expression<int>? radiusKm,
    Expression<int>? windowMinutes,
    Expression<bool>? quietHoursEnabled,
    Expression<int>? quietStartMinutes,
    Expression<int>? quietEndMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (enabled != null) 'enabled': enabled,
      if (radiusKm != null) 'radius_km': radiusKm,
      if (windowMinutes != null) 'window_minutes': windowMinutes,
      if (quietHoursEnabled != null) 'quiet_hours_enabled': quietHoursEnabled,
      if (quietStartMinutes != null) 'quiet_start_minutes': quietStartMinutes,
      if (quietEndMinutes != null) 'quiet_end_minutes': quietEndMinutes,
    });
  }

  AlertSettingsTableCompanion copyWith({
    Value<int>? id,
    Value<bool>? enabled,
    Value<int>? radiusKm,
    Value<int>? windowMinutes,
    Value<bool>? quietHoursEnabled,
    Value<int>? quietStartMinutes,
    Value<int>? quietEndMinutes,
  }) {
    return AlertSettingsTableCompanion(
      id: id ?? this.id,
      enabled: enabled ?? this.enabled,
      radiusKm: radiusKm ?? this.radiusKm,
      windowMinutes: windowMinutes ?? this.windowMinutes,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStartMinutes: quietStartMinutes ?? this.quietStartMinutes,
      quietEndMinutes: quietEndMinutes ?? this.quietEndMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (radiusKm.present) {
      map['radius_km'] = Variable<int>(radiusKm.value);
    }
    if (windowMinutes.present) {
      map['window_minutes'] = Variable<int>(windowMinutes.value);
    }
    if (quietHoursEnabled.present) {
      map['quiet_hours_enabled'] = Variable<bool>(quietHoursEnabled.value);
    }
    if (quietStartMinutes.present) {
      map['quiet_start_minutes'] = Variable<int>(quietStartMinutes.value);
    }
    if (quietEndMinutes.present) {
      map['quiet_end_minutes'] = Variable<int>(quietEndMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('radiusKm: $radiusKm, ')
          ..write('windowMinutes: $windowMinutes, ')
          ..write('quietHoursEnabled: $quietHoursEnabled, ')
          ..write('quietStartMinutes: $quietStartMinutes, ')
          ..write('quietEndMinutes: $quietEndMinutes')
          ..write(')'))
        .toString();
  }
}

class $AlertEventsTable extends AlertEvents
    with TableInfo<$AlertEventsTable, AlertEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _triggeredAtMillisMeta = const VerificationMeta(
    'triggeredAtMillis',
  );
  @override
  late final GeneratedColumn<int> triggeredAtMillis = GeneratedColumn<int>(
    'triggered_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceKmMeta = const VerificationMeta(
    'distanceKm',
  );
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
    'distance_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _radiusKmMeta = const VerificationMeta(
    'radiusKm',
  );
  @override
  late final GeneratedColumn<int> radiusKm = GeneratedColumn<int>(
    'radius_km',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    triggeredAtMillis,
    distanceKm,
    radiusKm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alert_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlertEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('triggered_at_millis')) {
      context.handle(
        _triggeredAtMillisMeta,
        triggeredAtMillis.isAcceptableOrUnknown(
          data['triggered_at_millis']!,
          _triggeredAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggeredAtMillisMeta);
    }
    if (data.containsKey('distance_km')) {
      context.handle(
        _distanceKmMeta,
        distanceKm.isAcceptableOrUnknown(data['distance_km']!, _distanceKmMeta),
      );
    } else if (isInserting) {
      context.missing(_distanceKmMeta);
    }
    if (data.containsKey('radius_km')) {
      context.handle(
        _radiusKmMeta,
        radiusKm.isAcceptableOrUnknown(data['radius_km']!, _radiusKmMeta),
      );
    } else if (isInserting) {
      context.missing(_radiusKmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlertEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      triggeredAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}triggered_at_millis'],
      )!,
      distanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_km'],
      )!,
      radiusKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}radius_km'],
      )!,
    );
  }

  @override
  $AlertEventsTable createAlias(String alias) {
    return $AlertEventsTable(attachedDatabase, alias);
  }
}

class AlertEvent extends DataClass implements Insertable<AlertEvent> {
  final int id;
  final int triggeredAtMillis;
  final double distanceKm;
  final int radiusKm;
  const AlertEvent({
    required this.id,
    required this.triggeredAtMillis,
    required this.distanceKm,
    required this.radiusKm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['triggered_at_millis'] = Variable<int>(triggeredAtMillis);
    map['distance_km'] = Variable<double>(distanceKm);
    map['radius_km'] = Variable<int>(radiusKm);
    return map;
  }

  AlertEventsCompanion toCompanion(bool nullToAbsent) {
    return AlertEventsCompanion(
      id: Value(id),
      triggeredAtMillis: Value(triggeredAtMillis),
      distanceKm: Value(distanceKm),
      radiusKm: Value(radiusKm),
    );
  }

  factory AlertEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertEvent(
      id: serializer.fromJson<int>(json['id']),
      triggeredAtMillis: serializer.fromJson<int>(json['triggeredAtMillis']),
      distanceKm: serializer.fromJson<double>(json['distanceKm']),
      radiusKm: serializer.fromJson<int>(json['radiusKm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'triggeredAtMillis': serializer.toJson<int>(triggeredAtMillis),
      'distanceKm': serializer.toJson<double>(distanceKm),
      'radiusKm': serializer.toJson<int>(radiusKm),
    };
  }

  AlertEvent copyWith({
    int? id,
    int? triggeredAtMillis,
    double? distanceKm,
    int? radiusKm,
  }) => AlertEvent(
    id: id ?? this.id,
    triggeredAtMillis: triggeredAtMillis ?? this.triggeredAtMillis,
    distanceKm: distanceKm ?? this.distanceKm,
    radiusKm: radiusKm ?? this.radiusKm,
  );
  AlertEvent copyWithCompanion(AlertEventsCompanion data) {
    return AlertEvent(
      id: data.id.present ? data.id.value : this.id,
      triggeredAtMillis: data.triggeredAtMillis.present
          ? data.triggeredAtMillis.value
          : this.triggeredAtMillis,
      distanceKm: data.distanceKm.present
          ? data.distanceKm.value
          : this.distanceKm,
      radiusKm: data.radiusKm.present ? data.radiusKm.value : this.radiusKm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlertEvent(')
          ..write('id: $id, ')
          ..write('triggeredAtMillis: $triggeredAtMillis, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('radiusKm: $radiusKm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, triggeredAtMillis, distanceKm, radiusKm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertEvent &&
          other.id == this.id &&
          other.triggeredAtMillis == this.triggeredAtMillis &&
          other.distanceKm == this.distanceKm &&
          other.radiusKm == this.radiusKm);
}

class AlertEventsCompanion extends UpdateCompanion<AlertEvent> {
  final Value<int> id;
  final Value<int> triggeredAtMillis;
  final Value<double> distanceKm;
  final Value<int> radiusKm;
  const AlertEventsCompanion({
    this.id = const Value.absent(),
    this.triggeredAtMillis = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.radiusKm = const Value.absent(),
  });
  AlertEventsCompanion.insert({
    this.id = const Value.absent(),
    required int triggeredAtMillis,
    required double distanceKm,
    required int radiusKm,
  }) : triggeredAtMillis = Value(triggeredAtMillis),
       distanceKm = Value(distanceKm),
       radiusKm = Value(radiusKm);
  static Insertable<AlertEvent> custom({
    Expression<int>? id,
    Expression<int>? triggeredAtMillis,
    Expression<double>? distanceKm,
    Expression<int>? radiusKm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (triggeredAtMillis != null) 'triggered_at_millis': triggeredAtMillis,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (radiusKm != null) 'radius_km': radiusKm,
    });
  }

  AlertEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? triggeredAtMillis,
    Value<double>? distanceKm,
    Value<int>? radiusKm,
  }) {
    return AlertEventsCompanion(
      id: id ?? this.id,
      triggeredAtMillis: triggeredAtMillis ?? this.triggeredAtMillis,
      distanceKm: distanceKm ?? this.distanceKm,
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (triggeredAtMillis.present) {
      map['triggered_at_millis'] = Variable<int>(triggeredAtMillis.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    if (radiusKm.present) {
      map['radius_km'] = Variable<int>(radiusKm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertEventsCompanion(')
          ..write('id: $id, ')
          ..write('triggeredAtMillis: $triggeredAtMillis, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('radiusKm: $radiusKm')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StrikesTable strikes = $StrikesTable(this);
  late final $AlertSettingsTableTable alertSettingsTable =
      $AlertSettingsTableTable(this);
  late final $AlertEventsTable alertEvents = $AlertEventsTable(this);
  late final StrikesDao strikesDao = StrikesDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    strikes,
    alertSettingsTable,
    alertEvents,
  ];
}

typedef $$StrikesTableCreateCompanionBuilder =
    StrikesCompanion Function({
      required String id,
      required double lat,
      required double lon,
      required int timestampMillis,
      Value<double?> intensity,
      required String source,
      Value<int> rowid,
    });
typedef $$StrikesTableUpdateCompanionBuilder =
    StrikesCompanion Function({
      Value<String> id,
      Value<double> lat,
      Value<double> lon,
      Value<int> timestampMillis,
      Value<double?> intensity,
      Value<String> source,
      Value<int> rowid,
    });

class $$StrikesTableFilterComposer
    extends Composer<_$AppDatabase, $StrikesTable> {
  $$StrikesTableFilterComposer({
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

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestampMillis => $composableBuilder(
    column: $table.timestampMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StrikesTableOrderingComposer
    extends Composer<_$AppDatabase, $StrikesTable> {
  $$StrikesTableOrderingComposer({
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

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lon => $composableBuilder(
    column: $table.lon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestampMillis => $composableBuilder(
    column: $table.timestampMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StrikesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrikesTable> {
  $$StrikesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<int> get timestampMillis => $composableBuilder(
    column: $table.timestampMillis,
    builder: (column) => column,
  );

  GeneratedColumn<double> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$StrikesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrikesTable,
          Strike,
          $$StrikesTableFilterComposer,
          $$StrikesTableOrderingComposer,
          $$StrikesTableAnnotationComposer,
          $$StrikesTableCreateCompanionBuilder,
          $$StrikesTableUpdateCompanionBuilder,
          (Strike, BaseReferences<_$AppDatabase, $StrikesTable, Strike>),
          Strike,
          PrefetchHooks Function()
        > {
  $$StrikesTableTableManager(_$AppDatabase db, $StrikesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrikesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrikesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StrikesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lon = const Value.absent(),
                Value<int> timestampMillis = const Value.absent(),
                Value<double?> intensity = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StrikesCompanion(
                id: id,
                lat: lat,
                lon: lon,
                timestampMillis: timestampMillis,
                intensity: intensity,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required double lat,
                required double lon,
                required int timestampMillis,
                Value<double?> intensity = const Value.absent(),
                required String source,
                Value<int> rowid = const Value.absent(),
              }) => StrikesCompanion.insert(
                id: id,
                lat: lat,
                lon: lon,
                timestampMillis: timestampMillis,
                intensity: intensity,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StrikesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrikesTable,
      Strike,
      $$StrikesTableFilterComposer,
      $$StrikesTableOrderingComposer,
      $$StrikesTableAnnotationComposer,
      $$StrikesTableCreateCompanionBuilder,
      $$StrikesTableUpdateCompanionBuilder,
      (Strike, BaseReferences<_$AppDatabase, $StrikesTable, Strike>),
      Strike,
      PrefetchHooks Function()
    >;
typedef $$AlertSettingsTableTableCreateCompanionBuilder =
    AlertSettingsTableCompanion Function({
      Value<int> id,
      Value<bool> enabled,
      Value<int> radiusKm,
      Value<int> windowMinutes,
      Value<bool> quietHoursEnabled,
      Value<int> quietStartMinutes,
      Value<int> quietEndMinutes,
    });
typedef $$AlertSettingsTableTableUpdateCompanionBuilder =
    AlertSettingsTableCompanion Function({
      Value<int> id,
      Value<bool> enabled,
      Value<int> radiusKm,
      Value<int> windowMinutes,
      Value<bool> quietHoursEnabled,
      Value<int> quietStartMinutes,
      Value<int> quietEndMinutes,
    });

class $$AlertSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AlertSettingsTableTable> {
  $$AlertSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get radiusKm => $composableBuilder(
    column: $table.radiusKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get windowMinutes => $composableBuilder(
    column: $table.windowMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get quietHoursEnabled => $composableBuilder(
    column: $table.quietHoursEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quietStartMinutes => $composableBuilder(
    column: $table.quietStartMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quietEndMinutes => $composableBuilder(
    column: $table.quietEndMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlertSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertSettingsTableTable> {
  $$AlertSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get radiusKm => $composableBuilder(
    column: $table.radiusKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get windowMinutes => $composableBuilder(
    column: $table.windowMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get quietHoursEnabled => $composableBuilder(
    column: $table.quietHoursEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietStartMinutes => $composableBuilder(
    column: $table.quietStartMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quietEndMinutes => $composableBuilder(
    column: $table.quietEndMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlertSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertSettingsTableTable> {
  $$AlertSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get radiusKm =>
      $composableBuilder(column: $table.radiusKm, builder: (column) => column);

  GeneratedColumn<int> get windowMinutes => $composableBuilder(
    column: $table.windowMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get quietHoursEnabled => $composableBuilder(
    column: $table.quietHoursEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quietStartMinutes => $composableBuilder(
    column: $table.quietStartMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quietEndMinutes => $composableBuilder(
    column: $table.quietEndMinutes,
    builder: (column) => column,
  );
}

class $$AlertSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertSettingsTableTable,
          AlertSettingsTableData,
          $$AlertSettingsTableTableFilterComposer,
          $$AlertSettingsTableTableOrderingComposer,
          $$AlertSettingsTableTableAnnotationComposer,
          $$AlertSettingsTableTableCreateCompanionBuilder,
          $$AlertSettingsTableTableUpdateCompanionBuilder,
          (
            AlertSettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $AlertSettingsTableTable,
              AlertSettingsTableData
            >,
          ),
          AlertSettingsTableData,
          PrefetchHooks Function()
        > {
  $$AlertSettingsTableTableTableManager(
    _$AppDatabase db,
    $AlertSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertSettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> radiusKm = const Value.absent(),
                Value<int> windowMinutes = const Value.absent(),
                Value<bool> quietHoursEnabled = const Value.absent(),
                Value<int> quietStartMinutes = const Value.absent(),
                Value<int> quietEndMinutes = const Value.absent(),
              }) => AlertSettingsTableCompanion(
                id: id,
                enabled: enabled,
                radiusKm: radiusKm,
                windowMinutes: windowMinutes,
                quietHoursEnabled: quietHoursEnabled,
                quietStartMinutes: quietStartMinutes,
                quietEndMinutes: quietEndMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> radiusKm = const Value.absent(),
                Value<int> windowMinutes = const Value.absent(),
                Value<bool> quietHoursEnabled = const Value.absent(),
                Value<int> quietStartMinutes = const Value.absent(),
                Value<int> quietEndMinutes = const Value.absent(),
              }) => AlertSettingsTableCompanion.insert(
                id: id,
                enabled: enabled,
                radiusKm: radiusKm,
                windowMinutes: windowMinutes,
                quietHoursEnabled: quietHoursEnabled,
                quietStartMinutes: quietStartMinutes,
                quietEndMinutes: quietEndMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlertSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertSettingsTableTable,
      AlertSettingsTableData,
      $$AlertSettingsTableTableFilterComposer,
      $$AlertSettingsTableTableOrderingComposer,
      $$AlertSettingsTableTableAnnotationComposer,
      $$AlertSettingsTableTableCreateCompanionBuilder,
      $$AlertSettingsTableTableUpdateCompanionBuilder,
      (
        AlertSettingsTableData,
        BaseReferences<
          _$AppDatabase,
          $AlertSettingsTableTable,
          AlertSettingsTableData
        >,
      ),
      AlertSettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$AlertEventsTableCreateCompanionBuilder =
    AlertEventsCompanion Function({
      Value<int> id,
      required int triggeredAtMillis,
      required double distanceKm,
      required int radiusKm,
    });
typedef $$AlertEventsTableUpdateCompanionBuilder =
    AlertEventsCompanion Function({
      Value<int> id,
      Value<int> triggeredAtMillis,
      Value<double> distanceKm,
      Value<int> radiusKm,
    });

class $$AlertEventsTableFilterComposer
    extends Composer<_$AppDatabase, $AlertEventsTable> {
  $$AlertEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get triggeredAtMillis => $composableBuilder(
    column: $table.triggeredAtMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get radiusKm => $composableBuilder(
    column: $table.radiusKm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlertEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertEventsTable> {
  $$AlertEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get triggeredAtMillis => $composableBuilder(
    column: $table.triggeredAtMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get radiusKm => $composableBuilder(
    column: $table.radiusKm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlertEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertEventsTable> {
  $$AlertEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get triggeredAtMillis => $composableBuilder(
    column: $table.triggeredAtMillis,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get radiusKm =>
      $composableBuilder(column: $table.radiusKm, builder: (column) => column);
}

class $$AlertEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertEventsTable,
          AlertEvent,
          $$AlertEventsTableFilterComposer,
          $$AlertEventsTableOrderingComposer,
          $$AlertEventsTableAnnotationComposer,
          $$AlertEventsTableCreateCompanionBuilder,
          $$AlertEventsTableUpdateCompanionBuilder,
          (
            AlertEvent,
            BaseReferences<_$AppDatabase, $AlertEventsTable, AlertEvent>,
          ),
          AlertEvent,
          PrefetchHooks Function()
        > {
  $$AlertEventsTableTableManager(_$AppDatabase db, $AlertEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> triggeredAtMillis = const Value.absent(),
                Value<double> distanceKm = const Value.absent(),
                Value<int> radiusKm = const Value.absent(),
              }) => AlertEventsCompanion(
                id: id,
                triggeredAtMillis: triggeredAtMillis,
                distanceKm: distanceKm,
                radiusKm: radiusKm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int triggeredAtMillis,
                required double distanceKm,
                required int radiusKm,
              }) => AlertEventsCompanion.insert(
                id: id,
                triggeredAtMillis: triggeredAtMillis,
                distanceKm: distanceKm,
                radiusKm: radiusKm,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlertEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertEventsTable,
      AlertEvent,
      $$AlertEventsTableFilterComposer,
      $$AlertEventsTableOrderingComposer,
      $$AlertEventsTableAnnotationComposer,
      $$AlertEventsTableCreateCompanionBuilder,
      $$AlertEventsTableUpdateCompanionBuilder,
      (
        AlertEvent,
        BaseReferences<_$AppDatabase, $AlertEventsTable, AlertEvent>,
      ),
      AlertEvent,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StrikesTableTableManager get strikes =>
      $$StrikesTableTableManager(_db, _db.strikes);
  $$AlertSettingsTableTableTableManager get alertSettingsTable =>
      $$AlertSettingsTableTableTableManager(_db, _db.alertSettingsTable);
  $$AlertEventsTableTableManager get alertEvents =>
      $$AlertEventsTableTableManager(_db, _db.alertEvents);
}
