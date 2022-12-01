import 'package:itable_ex/library.dart';
import 'package:logger_ex/library.dart';
import 'package:tentative_database/src/external/SettingsTable/SettingsTable.dart';

class SettingsTableImpl extends SettingsTable {
  final bool cacheValues;
  final Map<String, String?> cache = {};

  SettingsTableImpl({
    required String name,
    required this.cacheValues,
    required DatabaseExecutor database,
  }) : super(
    name: name,
    columns: SettingsTable.COLUMNS,
    database: database,
  );  

  @override
  Future<String?> get(String name) async {
    // if(name == COLUMN_QID.name) throw(Exception("name should not be $COLUMN_QID"));

    final rawResult = await raw.query(
      where: "${SettingsTable.COLUMN_NAME} = ?",
      whereArgs: [name],
      columns: [SettingsTable.COLUMN_VALUE.name],
      limit: 1,
    );
    final list = rawResult.output;
    if(list.isEmpty)
      return null;
    return cache[name] = list[0][SettingsTable.COLUMN_VALUE.name] as String;
  }
  
  @override
  Future<int> getInteger(String name, [int def = -1]) async {
    final value = await get(name);
    return value == null ? def : (int.tryParse(value) ?? def);
  }

  @override
  Future<bool> getBoolean(String name, [bool def = false]) async {
    final value = await getInteger(name, -1);
    return value == -1 ? def : (value == 0 ? false : true);
  }

  @override
  Future<bool> set(
    String name,
    dynamic value, {
      LoggerContext? logger,
  }) async {
    // if(name == COLUMN_QID) {
    //   throw(Exception("name should not be $COLUMN_QID"));
    // }

    bool exists = false;
    if(cache.containsKey(name)) {
      exists = true;
    } else {
      final rawResult = await raw.query(
        where: "${SettingsTable.COLUMN_NAME} = ?",
        whereArgs: [name],
        columns: [SettingsTable.COLUMN_VALUE.name],
        limit: 1,
      );
      exists = rawResult.output.isNotEmpty;
    }
    int updated = 0;
    if(exists) {
      final rawResult = await raw.update({
          SettingsTable.COLUMN_VALUE.name: value,
        },
        where: "${SettingsTable.COLUMN_NAME} = ?",
        whereArgs: [name],
      );
      updated = rawResult.output;

      if(updated == 0) {
        exists = false;
      }
    } if(!exists) {
      final rawResult = await raw.insert({
          SettingsTable.COLUMN_NAME.name: name,
          SettingsTable.COLUMN_VALUE.name: value,
        },
      );
      updated = rawResult.output;
    }
    
    // if(updated > 1) {
    //   final rawResult = await raw.delete(
    //     where: "${SettingsTable.COLUMN_ID} NOT IN (SELECT MIN(${SettingsTable.COLUMN_ID}) FROM ${raw.name})",
    //     logger: logger,
    //   );
    //   final deleted = rawResult.output;
    //   updated -= deleted;
    // }

    if(updated != 0) {
      cache[name] = value;
      return true;
    } return false;
  }

  @override
  Future<bool> setInteger(String name, int value) async {
    return set(name, value.toString());
  }

  @override
  Future<bool> setBoolean(String name, bool value) {
    return set(name, value ? "true" : "false");
  }

  @override
  Future<Map<String, dynamic>> values() async {
    final values = <String, dynamic>{};
    final rawResult = await raw.query(
      columns: [SettingsTable.COLUMN_NAME.name, SettingsTable.COLUMN_VALUE.name],
    );
    for(final item in rawResult.output) {
      final name = item[SettingsTable.COLUMN_NAME.name] as String;
      final value = item[SettingsTable.COLUMN_VALUE.name] as String;
      cache[name] = value;
      values[name] = item[value];
    } return values;
  }
}