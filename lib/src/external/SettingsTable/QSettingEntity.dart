import 'package:ientity/library.dart';
import 'package:json_ex/library.dart';

import 'SettingsTable.dart';

enum QSettingEntityParam {
  id,
  name,
  value,
}

class QSettingEntityParams extends IEntityParams<QSettingEntityParam> {
  int? id;
  String? name;
  Object? value;

  @override
  int get pid => id ?? 0;
  
  @override
  set pid(int v) => id = v;
}

class QSettingEntity extends IEntity<QSettingEntityParam> {
  static const String TAG = "QSettingEntity";

  @override
  final QSettingEntityParams params = new QSettingEntityParams();
  
  QSettingEntity.create() : super.create() {
    setEdited(true, changed: QSettingEntityParam.values);
  }

  QSettingEntity.fromTable(JsonObjectEx json) : super.fromTable(json) {
    params.id             = json.getInteger(SettingsTable.COLUMN_ID.name);
    params.name           = json.getString(SettingsTable.COLUMN_NAME.name);
    params.value          = json.getDynamic(SettingsTable.COLUMN_VALUE.name);
  }
  
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
    covariant QSettingEntity entity, {
      List<QSettingEntityParam> include = const [],
      List<QSettingEntityParam> exclude = const [],
      List<QSettingEntityParam>? changedParams,
  }) {
    throw UnimplementedError();
  }

  @override
  void copyTo(
    covariant QSettingEntity entity, {
      List<QSettingEntityParam> include = const [],
      List<QSettingEntityParam> exclude = const [],
      List<QSettingEntityParam>? changedParams,
  }) {
    throw UnimplementedError();
  }

  @override
  bool copyChangesTo(
    covariant QSettingEntity entity, {
      List<QSettingEntityParam> include = const [],
      List<QSettingEntityParam> exclude = const [],
      List<QSettingEntityParam>? changedParams,
  }) {
    // final QSettingEntityParams src = this.params, dst = entity.params;
    // final List<DebugChangedParam<QSettingEntityParam>> debugChanges = [];
    // changedParams ??= [];
    // bool flag;
    
    // final list = IEntity.makeParamsList(QSettingEntityParam.values, include, exclude);
    // {
    //   //------------------------------------------------------------------------
    //   flag = list.remove(QSettingEntityParam.id);
    //   if(flag && dst.id != src.id) {
    //     changedParams.add(QSettingEntityParam.id);
    //     debugChanges.add(new DebugChangedParam(QSettingEntityParam.id, dst.id, src.id));
    //     dst.id = src.id;
    //   }
    //   //------------------------------------------------------------------------
    //   flag = list.remove(QSettingEntityParam.name);
    //   if(flag && dst.name != src.name) {
    //     changedParams.add(QSettingEntityParam.name);
    //     debugChanges.add(new DebugChangedParam(QSettingEntityParam.name, dst.name, src.name));
    //     dst.name = src.name;
    //   }
    //   //------------------------------------------------------------------------
    //   flag = list.remove(QSettingEntityParam.value);
    //   if(flag && dst.value != src.value) {
    //     changedParams.add(QSettingEntityParam.value);
    //     debugChanges.add(new DebugChangedParam(QSettingEntityParam.value, dst.value, src.value));
    //     dst.value = src.value;
    //   }
    //   //------------------------------------------------------------------------
    // }

    // if(list.isNotEmpty)
    //   Logger.instance.warn(TAG, "copyChangesTo; not all cases processed; list = $list");

    // if(changedParams.isNotEmpty) {
    //   Logger.instance.debug(TAG, "copyChangesTo; true; changes = $debugChanges");
    //   entity.setEdited(true, changed: changedParams);
    // } return changedParams.isNotEmpty;
    return false;
  }
  
  @override
  RowInfo<QSettingEntityParam> toTable({
    required ERequestType requestType,
    List<QSettingEntityParam> include = const [],
    List<QSettingEntityParam> exclude = const [],
  }) {
    final list = IEntity.makeColumnsFromParamsList(SettingsTable.COLUMNS_ALL, [...include, ...changedParams], exclude);

    list.remove(SettingsTable.COLUMN_ID);
    final map = {
      if(requestType != ERequestType.insert)
        SettingsTable.COLUMN_ID:          params.id,
      if(list.remove(SettingsTable.COLUMN_NAME))
        SettingsTable.COLUMN_NAME:        params.name,
      if(list.remove(SettingsTable.COLUMN_VALUE))
        SettingsTable.COLUMN_VALUE:       params.value,
    };

    // if(list.isNotEmpty)
    //   Logger.instance.warn(TAG, "toTable; not all cases processed; list = $list");
    return RowInfo(map);
  }
}