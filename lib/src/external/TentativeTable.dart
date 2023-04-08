import 'package:ientity/library.dart';
import 'package:tentative_database/src/internal/ITentativeTable.dart';
import 'package:tentative_database/src/internal/TentativeTableMixin.dart';

import 'SettingsTable/SettingsTable.dart';

class TentativeTable<T extends IEntity> extends ITentativeTable<T> with TentativeTableMixin<T> {
  SettingsTable get settings => _settings!;

  TentativeTable({
    required super.name,
    required super.columns,
    required super.database,
    required super.converter,
  });

  @override
  Future<void> initState() async {
    await super.initState();
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
  }

  late final SettingsTable? _settings;
}

abstract class TentativeTableHelper {
  static void setSettingsTable(TentativeTable table, SettingsTable? s)
    => table._settings = s;
}