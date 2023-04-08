import 'package:ientity/library.dart';
import 'package:itable_ex/library.dart';
import 'package:logger_ex/library.dart';
import 'package:tentative_database/src/external/SettingsTable/SettingsTable.dart';
import 'package:tentative_database/src/external/results/TableLoadResult.dart';
import 'package:tentative_database/src/external/results/TablePushResult.dart';
import 'package:tentative_database/src/external/results/TableRemoveResult.dart';
import 'package:tentative_database/src/external/results/TableSaveResult.dart';
import 'package:tentative_database/src/external/typedef.dart';
import 'package:tentative_database/src/internal/TentativeTableMixin.dart';
import 'package:true_core/library.dart';

abstract class ITentativeTable<T extends IEntity> extends ITableEx {
  final MapToEntityConverter<T> converter;
  ITentativeTable({
    required super.name,
    required super.columns,
    required super.database,
    required this.converter,
  });

  Iterable<T> get storage;

  void addProxy(TableExecutorProxy proxy);
  
  void removeProxy(TableExecutorProxy proxy);

  /// Removing identical entities from storage
  void optimizeStorage();

  /// Adding entities to storage
  void addToStorage(
    List<T> entities,
    [OnQueueModificationError? onError]
  );

  /// Adding entities to SQL.INSERT queue
  /// 
  /// throwing error if entities exists in SQL.REMOVE queue
  void addToInsertQueue(
    List<T> entities,
    [OnQueueModificationError? onError]
  );

  /// Adding entities to SQL.UPDATE queue
  /// 
  /// throwing error if entities exists in SQL.REMOVE queue
  void addToUpdateQueue(
    List<T> entities,
    [OnQueueModificationError? onError]
  );

  /// Adding entities to SQL.REMOVE queue, and removing from SQL.INSERT/SQL.UPDATE queue if exists
  /// 
  /// throwing error if entities exists in storage
  void addToRemoveQueue(
    List<T> entities,
    [OnQueueModificationError? onError]
  );

  /// Removing entities from storage
  void removeFromStorage(
    List<T> entities,
  );

  /// Removing and disposing entities in storage
  void disposeStorage();


  Future<TablePushResult<T>> push({
    required List<T> entities,

    required List<EntityColumnInfo> columns,
    // required bool checkIsExists,
    required EntityComparison<T> comparison,

    Profiler? pInsert,
    LoggerContext? logger,
  });
  
  /// Load entities using [limit]
  /// Must contains PRIMARY_KEY
  Future<TableLoadResult<TCUSTOM>> loadCustomData<TCUSTOM>({
    int limit = 0,
    List<EntityColumnInfo>? columns,
    String? where,
    List<Object?>? whereArgs,

    required EntityToCustomDataConverter<T, TCUSTOM> entityConverter,
    required MapToCustomDataConverter<TCUSTOM> mapConverter,

    Profiler? pSelect,
    LoggerContext? logger,
  });
  
  // Future<TableLoadResult<T, ID>> load<ID>({
  //   List<ID>? ids,
  //   int limit = 0,
  //   List<String>? columns,

  //   required EntityColumnInfo columnId,

  //   required EntityByIdPredicate<T, ID> predicate,
  //   required MapToEntityConverter<T> converter,

  //   Profiler? pSelect,
  //   LoggerContext? logger,
  // });

  /// Load entities using [limit]
  Future<TableLoadResult<T>> loadByLimit({
    int limit = 0,
    List<EntityColumnInfo>? columns,
    String? where,
    List<Object?>? whereArgs,

    required MapToEntityConverter<T> converter,
    Profiler? pSelect,
    LoggerContext? logger,
  });

  /// Load entities by [ids]
  Future<TableLoadResult<T>> loadByIds({
    required List<int> ids,

    List<String>? columns,

    Profiler? pSelect,
    LoggerContext? logger,
  });

  /// Remove entities by [ids]
  Future<TableRemoveResult<T>> removeByIds({
    required List<int> ids,

    Profiler? pDelete,
    LoggerContext? logger,
  });






  /// Returns nothing
  // Future<bool> isExist(
  //   String where,
  //   List<dynamic> whereArgs, {
  //     List<String>? columns,
  //     Result<List<T>>? result,
  //     ModelConstructorFunction<T>? constructor,
  //     bool debug = false
  // });

  /// Returns nothing
  // Future<bool> isExists(
  //   String where,
  //   List<dynamic> whereArgs, {
  //     List<String>? columns,
  //     Result<List<T>>? result,
  //     ModelConstructorFunction<T>? constructor,
  //     bool debug = false
  // }) async {
    
  // }

  // Возвращает Map[id: qid], найденых rows
  // Future<Map<String, int>> isExists(
  //   List<String> ids, {
  //     List<String>? notFounded,
  // }) async {
  //   var map = <String, int>{};
  //   var rows = await raw.query(
  //     where: "$COLUMN_ID in (?)",
  //     whereArgs: [ids],
  //     columns: [CoinsTable.COLUMN_QID.name, CoinsTable.COLUMN_ID.name],
  //   );

  //   for(var id in ids) {
  //     var row = rows.tryFirstWhere((row) => id == row[CoinsTable.COLUMN_ID]);
  //     if(row == null) {
  //       notFounded?.add(id);
  //       continue;
  //     } map[id] = row[CoinsTable.COLUMN_QID] as int;
  //   } return RowInfo(map);
  // }

  /// Returns
  /// - [null],       if not found      
  /// - [IEntity],    if found
  T? isExistInStorage(int id);

  /// Returns
  /// - [null],             if not found
  /// - [List<IEntity>],    if found
  // bool isExistsInStorage(
  //   EntityPredicate<T> predicate,
  //   List<T> out, {
  //     bool singleMatch = false,
  // });


  Future<TableSaveResult<T>> save({
    Profiler? pInsert,
    Profiler? pUpdate,
    Profiler? pDelete,
    LoggerContext? logger,
  });

  late final SettingsTable? _settings;
}