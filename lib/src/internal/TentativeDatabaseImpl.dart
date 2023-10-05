import 'package:ientity/library.dart';
import 'package:itable_ex/library.dart';
import 'package:tentative_database/src/external/DatabaseListeners.dart';
import 'package:tentative_database/src/external/TentativeTable.dart';
import 'package:tentative_database/src/external/SettingsTable/SettingsTable.dart';
import 'package:tentative_database/src/external/TentativeDatabase.dart';

import 'SettingsTableImpl.dart';

class TentativeDatabaseImpl implements TentativeDatabase {
  static const String SUFFIX_SETTING_TABLE = r"$$settings";
  
  @override
  final DatabaseMediator executor;
  final OnConfigureFunction onConfigure;
  final OnOpenFunction onOpen;
  final OnCreateFunction onCreate;
  final OnUpgradeFunction onUpgrade;
  final OnDowngradeFunction onDowngrade;

  TentativeDatabaseImpl({
    required this.executor,
    required this.onConfigure,
    required this.onOpen,
    required this.onCreate,
    required this.onUpgrade,
    required this.onDowngrade,
  });

  @override
  bool get connected => executor.connected;
  
  // @override
  // Logger logger = Logger.instance;

  @override
  final DatabaseListeners listeners = DatabaseListeners();

  @override
  Future<bool> connect({
    required IConnectionParams connectionParams,
  }) async {
    return await executor.connect(
      connectionParams: connectionParams,
      onConfigure: () async {
        await onConfigure();
      },
      onOpen: () async {
        await onOpen();
        listeners.onOpen.notifyAll();
      },
      onCreate: (version) async {
        await onCreate(version);
      },
      onUpgrade: (oldVersion, newVersion) async {
        await onUpgrade(oldVersion, newVersion);
      },
      onDowngrade: (oldVersion, newVersion) async {
        await onDowngrade(oldVersion, newVersion);
      },
    );
  }

  @override
  Future<bool> close() async {
    listeners.onClose.notifyAll();
    return await executor.close();
  }


  @override
  Future<void> execute(String sql) => executor.execute(sql);

  @override
  Future<T> createOrLoadTable<T extends TentativeTable<IEntity>>(
    T table, {
      bool createSettingsTable = true,
  }) async {
    if(!(await isExistTable(table.name)))
      await executor.execute(table.toSql());
      
    return (await loadTable(
      table,
      createSettingsTable: createSettingsTable,
    ))!;
  }

  @override
  Future<SettingsTable> createOrLoadSettingsTable(
    String name
  ) async {
    final table = SettingsTableImpl(
      name: name,
      database: executor,
    );
    if(!(await isExistTable(name))) {
      await executor.execute(table.toSql());
    }

    
    await table.initState();
    return table;
  }

  @override
  Future<List<String>> getTables({
    bool excludeInternalTables = true,
  }) async {
    final tables = await executor.getTables();
    if(excludeInternalTables)
      tables.retainWhere((e) => !isSettingsTable(e));
    return tables;
  }
  
  @override
  Future<T?> loadTable<T extends TentativeTable<IEntity>>(
    T table, {
      bool createSettingsTable = true,
  }) async {
    final tables = await executor.getTables();
    if(!tables.contains(table.name))
      return null;

    final SettingsTable? settingsTable;
    if(createSettingsTable) {
      settingsTable = await createOrLoadSettingsTable(
        generateSettingsTableName(table.name),
      );
    } else settingsTable = null;
    // else {
    //   settingsTable = DummySettingsTable(
    //     name: name,
    //     database: executor,
    //   );
    // }
    TentativeTableHelper.setSettingsTable(table, settingsTable);
    
    await table.initState();
    return table;
  }
  
  @override
  Future<bool> isExistTable(
    String name,
  ) async {
    final tables = await executor.getTables();
    return tables.contains(name);
  }
  
  @override
  Future<void> dropTable<T extends IEntity>(
    String name, {
      bool dropSettingsTable = true,
  }) async {
    await executor.execute("DROP TABLE IF EXISTS $name");
    if(dropSettingsTable) {
      await executor.execute("DROP TABLE IF EXISTS ${generateSettingsTableName(name)}");
    }
  }

  static String generateSettingsTableName(String parentTableName)
    => parentTableName + SUFFIX_SETTING_TABLE;
  
  static bool isSettingsTable(String parentTableName)
    => parentTableName.endsWith(SUFFIX_SETTING_TABLE);
}