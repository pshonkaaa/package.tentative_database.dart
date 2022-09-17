import 'package:ientity/library.dart';
import 'package:logger_ex/app/core/logger/Logger.dart';
import 'package:logger_ex/library.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tentative_database/src/internal/TentativeDatabaseImpl.dart';

import 'DatabaseListeners.dart';
import 'ITentativeTable.dart';
import 'SettingsTable/SettingsTable.dart';
import 'SqlColumnTypes.dart';
import 'TableBuilder.dart';
import 'typedef.dart';

abstract class TentativeDatabase {
  static const ColumnInfo DEFAULT_TABLE_PRIMARY_KEY = ColumnInfo(Object(), "_id", SqlColumnTypes.integer);
  static const int MAX_INSERTS_PER_REQUEST = 1000;
  static const int MAX_UPDATES_PER_REQUEST = 1000;
  static const int MAX_DELETES_PER_REQUEST = 1000;

  static const int MAX_EXECUTION_TIME_ADVANCED_TABLE = 100;
  

  factory TentativeDatabase({
    required OnConfigureFunction onConfigure,
    required OnOpenFunction onOpen,
    required OnCreateFunction onCreate,
    required OnUpgradeFunction onUpgrade,
    required OnDowngradeFunction onDowngrade,
  }) => TentativeDatabaseImpl(
    onConfigure: onConfigure,
    onOpen: onOpen,
    onCreate: onCreate,
    onUpgrade: onUpgrade,
    onDowngrade: onDowngrade,
  );

  LoggerContext logger = Logger.instance;

  DatabaseListeners get listeners;

  bool get closed;

  Database get raw;


  Future<void> init(String dbPath, int dbVersion);

  Future<void> close();

  Future<void> execute(String sql);


  Future<T> createOrLoadTable<T extends ITentativeTable<E, P>, E extends IEntity<P>, P>(
    TableBuilder builder,
    T table, {
      bool cacheSettings = true,
  });

  Future<SettingsTable> createOrLoadSettingsTable(
    String name, {
      bool cacheValues = true,
  });

  Future<List<String>> getTables({
    bool excludeInternalTables = true,
  });
  
  Future<T?> loadTable<T extends ITentativeTable<IEntity<P>, P>, P>(
    String name,
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

