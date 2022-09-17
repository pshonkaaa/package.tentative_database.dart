import 'package:ientity/library.dart';
import 'package:logger_ex/app/core/logger/Logger.dart';
import 'package:logger_ex/library.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tentative_database/src/external/DatabaseListeners.dart';
import 'package:tentative_database/src/external/ITentativeTable.dart';
import 'package:tentative_database/src/external/SettingsTable/SettingsTable.dart';
import 'package:tentative_database/src/external/TableBuilder.dart';
import 'package:tentative_database/src/external/TentativeDatabase.dart';
import 'package:tentative_database/src/external/typedef.dart';

import 'DummySettingsTable.dart';
import 'SettingsTableImpl.dart';

class TentativeDatabaseImpl implements TentativeDatabase {
  static const String SUFFIX_SETTING_TABLE = r"$$settings";
  
  final OnConfigureFunction onConfigure;
  final OnOpenFunction onOpen;
  final OnCreateFunction onCreate;
  final OnUpgradeFunction onUpgrade;
  final OnDowngradeFunction onDowngrade;

  TentativeDatabaseImpl({
    required this.onConfigure,
    required this.onOpen,
    required this.onCreate,
    required this.onUpgrade,
    required this.onDowngrade,
  });

  @override
  LoggerContext logger = Logger.instance;

  @override
  final DatabaseListeners listeners = DatabaseListeners();

  @override
  bool get closed => raw.isOpen;

  @override
  late Database raw;

  @override
  Future<void> init(String dbPath, int dbVersion) async {
    raw = await openDatabase(dbPath,
      version: dbVersion,
      onConfigure: (db) async {
        raw = db;
        await onConfigure();
      },
      onOpen: (db) async {
        await onOpen();
        listeners.onOpen.notifyAll();
      },
      onCreate: (db, version) async {
        await onCreate(version);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await onUpgrade(oldVersion, newVersion);
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        await onDowngrade(oldVersion, newVersion);
      },
    );
  }

  @override
  Future<void> close() async {
    listeners.onClose.notifyAll();
  }


  @override
  Future<void> execute(String sql) => raw.execute(sql);

  @override
  Future<T> createOrLoadTable<T extends ITentativeTable<E, P>, E extends IEntity<P>, P>(
    TableBuilder builder,
    T table, {
      bool createSettingsTable = true,
      bool cacheSettings = true,
  }) async {
    if(!(await isExistTable(builder.name)))
      await raw.execute(builder.toRawSql());
      
    return (await loadTable(
      builder.name,
      table,
      createSettingsTable: createSettingsTable,
      cacheSettings: cacheSettings,
    ))!;
  }

  @override
  Future<SettingsTable> createOrLoadSettingsTable(
    String name, {
      bool cacheValues = true,
  }) async {
    name = generateSettingsTableName(name);
    if(!(await isExistTable(name))) {
      final builder = TableBuilder(name: name, primaryKey: SettingsTable.COLUMN_ID)
      ..insertAll([
        SettingsTable.COLUMN_NAME,
        SettingsTable.COLUMN_VALUE,
      ]);
      await raw.execute(builder.toRawSql());
    }

    final table = SettingsTableImpl(
      name: name,
      cacheValues: cacheValues,
      db: raw,
    );
    
    await table.initState();
    return table;
  }

  @override
  Future<List<String>> getTables({
    bool excludeInternalTables = true,
  }) async {
    final List<String> tables = [];
    final rows = await raw.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");
    for(final row in rows) {
      final name = row["name"] as String;
      if(excludeInternalTables && isSettingsTable(name)) {
        continue;
      } tables.add(name);
    } return tables;
  }
  
  @override
  Future<T?> loadTable<T extends ITentativeTable<IEntity<P>, P>, P>(
    String name,
    T table, {
      bool createSettingsTable = true,
      bool cacheSettings = true,
  }) async {
    final data = await raw.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='" + name + "';");
    if(data.isEmpty)
      return null;

    final SettingsTable settingsTable;
    if(createSettingsTable) {
      settingsTable = await createOrLoadSettingsTable(
        name,
        cacheValues: cacheSettings,
      );
    } else {
      settingsTable = DummySettingsTable(
        name: name,
        db: raw,
      );
    } TentativeTableHelper.setSettingsTable(table, settingsTable);
    
    await table.initState();
    return table;
  }
  
  @override
  Future<bool> isExistTable(
    String name,
  ) async {
    var data = await raw.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='" + name + "';");
    return data.isNotEmpty;
  }
  
  @override
  Future<void> dropTable<T extends IEntity>(
    String name, {
      bool dropSettingsTable = true,
  }) async {
    await raw.execute("DROP TABLE IF EXISTS $name");
    if(dropSettingsTable) {
      await raw.execute("DROP TABLE IF EXISTS ${generateSettingsTableName(name)}");
    }
  }

  static String generateSettingsTableName(String parentTableName)
    => parentTableName + SUFFIX_SETTING_TABLE;
  
  static bool isSettingsTable(String parentTableName)
    => parentTableName.endsWith(SUFFIX_SETTING_TABLE);
}