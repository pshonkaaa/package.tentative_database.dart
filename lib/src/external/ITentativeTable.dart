import 'package:ientity/library.dart';
import 'package:itable_ex/library.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:tentative_database/src/internal/AdvancedTableImpl.dart';

import 'AdvancedTable.dart';
import 'SettingsTable/SettingsTable.dart';

abstract class ITentativeTable<T extends IEntity<PARAM>, PARAM> extends ITableEx<PARAM> {
  ITentativeTable({
    required String name,
    required List<ColumnInfo<PARAM>> columns,
    required Database db,
  }) : super(name: name, columns: columns, db: db);

  @override
  Future<void> initState() async {
    await super.initState();

    _advanced = AdvancedTableImpl(this);
    await _advanced.initState();
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    
    await _advanced.dispose();
  }

  AdvancedTable<T, PARAM> get advanced => _advanced;
  SettingsTable get settings => _settings;

  late final AdvancedTable<T, PARAM>  _advanced;
  late final SettingsTable _settings;
}

abstract class TentativeTableHelper {
  static void setSettingsTable(ITentativeTable table, SettingsTable s)
    => table._settings = s;
}