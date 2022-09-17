import 'package:ientity/library.dart';
import 'package:itable_ex/library.dart';
import 'package:logger_ex/library.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tentative_database/src/external/SqlColumnTypes.dart';

import 'QSettingEntity.dart';

abstract class SettingsTable extends ITableEx<QSettingEntityParam> {
  static const COLUMN_ID                = ColumnInfo(QSettingEntityParam.id, "id", SqlColumnTypes.integer, primaryKey: true);
  static const COLUMN_NAME              = ColumnInfo(QSettingEntityParam.name, "name", SqlColumnTypes.text);
  static const COLUMN_VALUE             = ColumnInfo(QSettingEntityParam.value, "value", SqlColumnTypes.text);
  

  static const COLUMNS_ALL = [
    COLUMN_ID,
    COLUMN_NAME,
    COLUMN_VALUE,
  ];
  
  SettingsTable({
    required String name,
    required List<ColumnInfo<QSettingEntityParam>> columns,
    required Database db,
  }) : super(
    name: name,
    columns: columns,
    db: db,
  );

  Future<String?> get(String name);
  
  Future<int> getInteger(
    String name, [
      int def = -1,
  ]);

  Future<bool> getBoolean(
    String name, [
      bool def = false,
  ]);
  
  Future<bool> set(
    String name,
    dynamic value, {
      LoggerContext? logger,
  });

  Future<bool> setInteger(
    String name,
    int value,
  );

  Future<bool> setBoolean(
    String name,
    bool value,
  );
  
  Future<Map<String, dynamic>> values();
}