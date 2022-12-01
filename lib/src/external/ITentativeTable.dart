import 'package:ientity/library.dart';
import 'package:itable_ex/library.dart';
import 'package:tentative_database/src/internal/AdvancedTableImpl.dart';

import 'AdvancedTable.dart';
import 'SettingsTable/SettingsTable.dart';

abstract class ITentativeTable<T extends IEntity> extends ITableEx {
  ITentativeTable({
    required String name,
    required List<EntityColumnInfo> columns,
    required DatabaseExecutor database,
  }) : super(name: name, columns: columns, database: database);

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

  AdvancedTable<T> get advanced => _advanced;
  SettingsTable get settings => _settings;

  late final AdvancedTable<T>  _advanced;
  late final SettingsTable _settings;
}

abstract class TentativeTableHelper {
  static void setSettingsTable(ITentativeTable table, SettingsTable s)
    => table._settings = s;
}