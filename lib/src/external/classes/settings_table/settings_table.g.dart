// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_table.dart';

// **************************************************************************
// ExtensionGenerator
// **************************************************************************

// ignore_for_file: unused_local_variable, dead_code
bool _isEquals<T>(T a, T b) {
  if (T == List) return _listEquals(a as List, b as List);
  if (T == Map) return _mapEquals(a as Map, b as Map);
  return a == b;
}

/// from 'package:flutter/foundation.dart'
bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) {
    return b == null;
  }
  if (b == null || a.length != b.length) {
    return false;
  }
  if (identical(a, b)) {
    return true;
  }
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}

/// from 'package:flutter/foundation.dart'
bool _mapEquals<T, U>(Map<T, U>? a, Map<T, U>? b) {
  if (a == null) {
    return b == null;
  }
  if (b == null || a.length != b.length) {
    return false;
  }
  if (identical(a, b)) {
    return true;
  }
  for (final T key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) {
      return false;
    }
  }
  return true;
}

T _transform<T>(EntityColumnInfo<T> column, T value) {
  if (column.transformer == null) return value;
  return column.transformer!(value);
}

/*
export "generated.g.dart" show 
	QSettingEntity;
*/
class QSettingEntity extends BaseEntity {
  static const TAG = "QSettingEntity";

  static const ID = SettingsTable.COLUMN_ID;
  static const NAME = SettingsTable.COLUMN_NAME;
  static const VALUE = SettingsTable.COLUMN_VALUE;

  static const COLUMNS = [
    ID,
    NAME,
    VALUE,
  ];

  QSettingEntity.create({
    required this.name,
    required this.value,
  }) : super.create() {
    id = 0;
    setEdited(true, changed: COLUMNS);
  }

  QSettingEntity.fromTable(Map<String, dynamic> json) : super.fromTable(json) {
// checking if column not exists :|
    for (final column in COLUMNS) {
      if (!json.containsKey(column.name)) {
        throw 'Key not exists; key = ${column.name}';
      }
    }

    id = ValueParser.parseInteger(json[ID.name]);
    name = ValueParser.parseString(json[NAME.name]);
    value = json[VALUE.name] != null
        ? ValueParser.parseString(json[VALUE.name])
        : null;
  }

  late int id;
  late String name;
  late String? value;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool isIdentical(
    covariant QSettingEntity m, {
    List<EntityColumnInfo> include = const [],
    List<EntityColumnInfo> exclude = const [],
    List<ChangedColumn>? differences,
  }) {
    final src = this, dst = m;
    final List<EntityColumnInfo> changedList = [];
    bool changed = false;

    final list = BaseEntity.makeParamsList(COLUMNS, include, exclude);
    {
      bool flag = false;
//------------------------------------------------------------------------
      flag = list.remove(ID);
      if (flag && !_isEquals(dst.id, src.id)) {
        changedList.add(ID);
        differences?.add(ChangedColumn(ID, dst.id, src.id));
        dst.id = src.id;
        changed = true;
      }
//------------------------------------------------------------------------
      flag = list.remove(NAME);
      if (flag && !_isEquals(dst.id, src.id)) {
        changedList.add(NAME);
        differences?.add(ChangedColumn(NAME, dst.name, src.name));
        dst.name = src.name;
        changed = true;
      }
//------------------------------------------------------------------------
      flag = list.remove(VALUE);
      if (flag && !_isEquals(dst.id, src.id)) {
        changedList.add(VALUE);
        differences?.add(ChangedColumn(VALUE, dst.value, src.value));
        dst.value = src.value;
        changed = true;
      }
    }
    assert(
        list.isEmpty, "unknown columns = ${list.map((e) => e.name).toList()}");
    return changed;
  }

  @override
  bool copyTo(
    covariant QSettingEntity m, {
    List<EntityColumnInfo> include = const [],
    List<EntityColumnInfo> exclude = const [],
    List<ChangedColumn>? differences,
  }) {
    throw UnimplementedError();
  }

  @override
  bool copyChangesTo(
    covariant QSettingEntity m, {
    List<EntityColumnInfo> include = const [],
    List<EntityColumnInfo> exclude = const [],
    List<ChangedColumn>? differences,
  }) {
    final src = this, dst = m;

    differences ??= [];

    final identical = isIdentical(
      dst,
      include: include,
      exclude: exclude,
      differences: differences,
    );

    if (!identical) return false;

    final list = differences.map((e) => e.column).toList();

    {
      bool flag = false;
//------------------------------------------------------------------------
      flag = list.remove(ID);
      if (flag && dst.id != src.id) {
        dst.id = src.id;
      }
//------------------------------------------------------------------------
      flag = list.remove(NAME);
      if (flag && dst.id != src.id) {
        dst.name = src.name;
      }
//------------------------------------------------------------------------
      flag = list.remove(VALUE);
      if (flag && dst.id != src.id) {
        dst.value = src.value;
      }
    }
    assert(
        list.isEmpty, "unknown columns = ${list.map((e) => e.name).toList()}");
    m.setEdited(true, changed: differences.map((e) => e.column));
    return true;
  }

  @override
  RowInfo toTable({
    required ERequestType requestType,
    List<EntityColumnInfo> include = const [],
    List<EntityColumnInfo> exclude = const [],
  }) {
    final _list = BaseEntity.makeParamsList(COLUMNS, include, exclude);
    final _map = {
      if (_list.remove(ID) && requestType != ERequestType.insert)
        ID: _transform(ID, id),
      if (_list.remove(NAME)) NAME: _transform(NAME, name),
      if (_list.remove(VALUE)) VALUE: _transform(VALUE, value),
    };

    assert(_list.isEmpty,
        "unknown columns = ${_list.map((e) => e.name).toList()}");
    return RowInfo(_map);
  }
}
