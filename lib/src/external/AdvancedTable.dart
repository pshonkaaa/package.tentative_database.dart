import 'package:ientity/library.dart';
import 'package:itable_ex/library.dart';
import 'package:logger_ex/library.dart';
import 'package:tentative_database/src/internal/AdvancedTableImpl.dart';
import 'package:true_core/library.dart';

import 'results/AdvancedTableSaveResult.dart';
import 'results/TableLoadResult.dart';
import 'results/TablePushResult.dart';
import 'results/TableRemoveResult.dart';
import 'typedef.dart';

abstract class AdvancedTable<T extends IEntity<PARAM>, PARAM> {
  static AdvancedTable create(
    ITableEx table,
  ) {
    return AdvancedTableImpl(table);    
  }


  Iterable<T> get storage;

  //TODO MOVE
  final List<T> queueInsert = [];
  final List<T> queueUpdate = [];
  final List<T> queueDelete = [];

  /// Removing identical entities from storage
  void optimizeStorage();

  /// Adding entities to storage
  void addToStorage(List<T> entities, [OnQueueModificationError? onError]);

  /// Adding entities to SQL.INSERT queue
  /// 
  /// throwing error if entities exists in SQL.REMOVE queue
  void addToInsertQueue(List<T> entities, [OnQueueModificationError? onError]);

  /// Adding entities to SQL.UPDATE queue
  /// 
  /// throwing error if entities exists in SQL.REMOVE queue
  void addToUpdateQueue(List<T> entities, [OnQueueModificationError? onError]);

  /// Adding entities to SQL.REMOVE queue, and removing from SQL.INSERT/SQL.UPDATE queue if exists
  /// 
  /// throwing error if entities exists in storage
  void addToRemoveQueue(List<T> entities, [OnQueueModificationError? onError]);

  /// Removing entities from storage
  void removeFromStorage(List<T> entities);

  /// Removing and disposing entities in storage
  void disposeStorage();



  Future<void> initState();
  
  Future<void> dispose();







  Future<TablePushResult<T>> push({
    required List<T> entities,

    required List<ColumnInfo<PARAM>> columns,

    Profiler? pInsert,
    LoggerContext? logger,
  });
  
  /// Load entities using [limit]
  /// Must contains PRIMARY_KEY
  Future<TableLoadResult<TCUSTOM, ID>> loadCustomData<TCUSTOM, ID>({
    int limit = 0,
    List<ColumnInfo<PARAM>>? columns,
    String? where,
    List<Object?>? whereArgs,

    required EntityToCustomDataConverter<T, TCUSTOM> entityConverter,
    required MapToCustomDataConverter<TCUSTOM> mapConverter,

    Profiler? pSelect,
    LoggerContext? logger,
  });
  
  Future<TableLoadResult<T, ID>> load<ID>({
    List<ID>? ids,
    int limit = 0,
    List<String>? columns,

    required ColumnInfo<PARAM> columnId,

    required EntityByIdPredicate<T, ID> predicate,
    required MapToEntityConverter<T> converter,

    Profiler? pSelect,
    LoggerContext? logger,
  });

  /// Load entities using [limit]
  Future<TableLoadResult<T, ID>> loadByLimit<ID>({
    int limit = 0,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,

    required MapToEntityConverter<T> converter,
    Profiler? pSelect,
    LoggerContext? logger,
  });

  /// Load entities by [ids]
  Future<TableLoadResult<T, ID>> loadList<ID>({
    List<String>? columns,

    required List<ID> ids,
    required ColumnInfo<PARAM> columnId,

    required EntityByIdPredicate<T, ID> predicate,
    required MapToEntityConverter<T> converter,
    Profiler? pSelect,
    LoggerContext? logger,
  });

  /// Remove entities by [ids]
  Future<TableRemoveResult<T, ID>> removeList<ID>({
    required List<ID> ids,
    required String columnId,

    required EntityByIdPredicate<T, ID> predicate,
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
  T? isExistInStorage(EntityPredicate<T> predicate);

  /// Returns
  /// - [null],             if not found
  /// - [List<IEntity>],    if found
  bool isExistsInStorage(
    EntityPredicate<T> predicate,
    List<T> out, {
      bool singleMatch = false,
  });


  Future<AdvancedTableSaveResult<T>> save({
    Profiler? pInsert,
    Profiler? pUpdate,
    Profiler? pDelete,
    LoggerContext? logger,
  });























  






  // Future<int> push(
  //   List<QCoinEntity> inEntities, {
  //     required List<QCoinEntity> pushed,
  //     required List<QCoinEntity> stored,
  //     required List<QCoinEntity> exists,
  //     required List<QCoinEntity> notPushed,
  // }) async {
  //   //==========================================================================
  //   final Profiler p1s, p2s;
  //   Profiler p1, p2;
  //   //==========================================================================
    
  //   p1s   = new Profiler("$TAG isExist");
  //   p2s   = new Profiler("$TAG insert");

  //   final List<QCoinEntity> pushing;
  //   {
  //     var ids = inEntities.map((e) => e.params.id!).toSet();
  //     pushing = inEntities.toList()..retainWhere((e) => ids.remove(e.params.id!));
  //   }

  //   p1 = Profiler.create();
  //   {
  //     for(var entity in pushing) {
  //       var result = new Result<QCoinEntity>();
  //       if((await isExistInStorage(entity.params.id!, result)) != -1)
  //         stored.add(result.value!);
  //     } pushing.removeWhere((e) => stored.contains(e));
  //   }

  //   {
  //     var exist = (await isExists(pushing.map((e) => e.params.id!).toList())).keys;
  //     exists.addAll(pushing.where((e) => exist.contains(e.params.id!)));
  //     pushing.removeWhere((e) => exist.contains(e.params.id!));
  //   }
  //   p1.end().addTo(p1s);
    
  //   for(var entity in pushing) {
  //     int qid;
  //     p2 = Profiler.create();
  //     qid = await raw.insert(entity.toTable().toMap());
  //     p2.end().addTo(p2s);

  //     if(qid != -1) {
  //       entity.params.id = qid;
  //       entity.setLoaded(true);
  //       entity.setEdited(false);
  //       pushed.add(entity);
  //       continue;
  //     } else notPushed.add(entity);
  //   }
  //   Logger.i(TAG, "push");
  //   Logger.i(TAG, "====================");
  //   Logger.i(TAG, p1s.stringify(TimeUnits.MILLISECONDS));
  //   Logger.i(TAG, p2s.stringify(TimeUnits.MILLISECONDS));
  //   Logger.i(TAG, "====================");
  //   return notPushed.length;
  // }
}