// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SettingsTable.dart';

// **************************************************************************
// ExtensionGenerator
// **************************************************************************

// ignore_for_file: unused_local_variable, dead_code
/*
export "generated.g.dart" show 
	QSettingEntity;
*/
class QSettingEntity extends IEntity {
  static const TAG = "QSettingEntity";

  late int id;
  late String name;
  late String? value;
  QSettingEntity.create({
    required this.name,
    required this.value,
  }) : super.create() {
    id = 0;
    setEdited(true, changed: COLUMNS);
  }

  QSettingEntity.fromTable(JsonObjectEx json) : super.fromTable(json) {
    id = json.getInteger(ID.name)!;
    name = json.getString(NAME.name)!;
    value = json.getString(VALUE.name);
  }

  static const ID = SettingsTable.COLUMN_ID;
  static const NAME = SettingsTable.COLUMN_NAME;
  static const VALUE = SettingsTable.COLUMN_VALUE;

  static const COLUMNS = [
    ID,
    NAME,
    VALUE,
  ];

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

    final list = IEntity.makeParamsList(COLUMNS, include, exclude);
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
    final list = IEntity.makeParamsList(COLUMNS, include, exclude);
    final map = {
      if (list.remove(ID) && requestType != ERequestType.insert)
        ID: _transform(ID, id),
      if (list.remove(NAME)) NAME: _transform(NAME, name),
      if (list.remove(VALUE)) VALUE: _transform(VALUE, value),
    };

    assert(
        list.isEmpty, "unknown columns = ${list.map((e) => e.name).toList()}");
    return RowInfo(map);
  }

  bool _isEquals<T>(T a, T b) {
    if (T == List) return listEquals(a as List, b as List);
    if (T == Map) return mapEquals(a as Map, b as Map);
    return a == b;
  }

  T _transform<T>(EntityColumnInfo<T> column, T value) {
    if (column.transformer == null) return value;
    return column.transformer!(value);
  }
}
