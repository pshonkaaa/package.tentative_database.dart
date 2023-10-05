import 'package:ientity/library.dart';
import 'package:itable_ex/library.dart';
import 'package:tentative_database/src/internal/TentativeDatabaseImpl.dart';

import 'DatabaseListeners.dart';
import 'TentativeTable.dart';
import 'SettingsTable/SettingsTable.dart';

abstract class TentativeDatabase {
  static const int MAX_INSERTS_PER_REQUEST = 1000;
  static const int MAX_UPDATES_PER_REQUEST = 1000;
  static const int MAX_DELETES_PER_REQUEST = 1000;

  static const int MAX_EXECUTION_TIME_ADVANCED_TABLE = 100;
  

  factory TentativeDatabase({
    required DatabaseMediator executor,
    required OnConfigureFunction onConfigure,
    required OnOpenFunction onOpen,
    required OnCreateFunction onCreate,
    required OnUpgradeFunction onUpgrade,
    required OnDowngradeFunction onDowngrade,
  }) => TentativeDatabaseImpl(
    executor: executor,
    onConfigure: onConfigure,
    onOpen: onOpen,
    onCreate: onCreate,
    onUpgrade: onUpgrade,
    onDowngrade: onDowngrade,
  );


  DatabaseExecutor get executor;

  bool get connected;

  // Logger logger = Logger.instance;

  DatabaseListeners get listeners;


  Future<bool> connect({
    required IConnectionParams connectionParams,
  });

  Future<void> close();

  Future<void> execute(String sql);


  Future<T> createOrLoadTable<T extends TentativeTable<IEntity>>(
    T table, {
      bool createSettingsTable = true,
  });

  Future<SettingsTable> createOrLoadSettingsTable(
    String name
  );

  Future<List<String>> getTables({
    bool excludeInternalTables = true,
  });
  
  Future<T?> loadTable<T extends TentativeTable<IEntity>>(
    T table,
  );

  Future<bool> isExistTable(
    String name,
  );
  
  Future<void> dropTable<T extends IEntity>(
    String name, {
      bool dropSettingsTable = true,
  });

  



  

  static String generateSettingsTableName(String parentTableName)
    => TentativeDatabaseImpl.generateSettingsTableName(parentTableName);










  static String listToSqlList(
    Iterable<Object> list,
  ) {
    final sb = new StringBuffer();

    if(list is List<int>) {
      for(final v in list)
        sb.write("$v, ");
    } else {
      for(final v in list)
        sb.write("'$v', ");
    } 

    String out = sb.toString();
    if(out.length > 2)
      out = out.substring(0, out.length - 2); // удаляем последнюю запятую и пробел
    return out;
  }
}

