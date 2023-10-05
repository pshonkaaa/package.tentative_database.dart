import 'package:flutter/foundation.dart';
import 'package:ientity/library.dart';
import 'package:itable_ex/library.dart';
import 'package:json_ex/library.dart';
import 'package:logger/logger.dart';

part 'SettingsTable.g.dart';

@AnTable(entityName: "QSettingEntity")
abstract class SettingsTable extends ITableEx {
  static const COLUMN_ID                = EntityColumnInfo<int>("id", SqliteColumnTypes.integer, isPrimaryKey: true);
  static const COLUMN_NAME              = EntityColumnInfo<String>("name", SqliteColumnTypes.text);
  static const COLUMN_VALUE             = EntityColumnInfo<String?>("value", SqliteColumnTypes.text, isNullable: true);
  

  static const COLUMNS = [
    COLUMN_ID,
    COLUMN_NAME,
    COLUMN_VALUE,
  ];
  
  SettingsTable({
    required String name,
    required List<EntityColumnInfo> columns,
    required DatabaseExecutor database,
  }) : super(
    name: name,
    columns: columns,
    database: database,
  );

  Future<String?> get(
    String name, {
      bool useCache = true,
  });
  
  Future<int> getInteger(
    String name, {
      int def = -1,
      bool useCache = true,
  });

  Future<bool> getBoolean(
    String name, {
      bool def = false,
      bool useCache = true,
  });
  
  Future<bool> set(
    String name,
    dynamic value, {
      Logger? logger,
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