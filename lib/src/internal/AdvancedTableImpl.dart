import 'dart:developer';
import 'dart:math';

import 'package:ientity/library.dart';
import 'package:itable_ex/library.dart';
import 'package:logger_ex/app/core/logger/Logger.dart';
import 'package:logger_ex/library.dart';
import 'package:tentative_database/src/external/AdvancedTable.dart';
import 'package:tentative_database/src/external/TentativeDatabase.dart';
import 'package:tentative_database/src/external/results/AdvancedTableSaveResult.dart';
import 'package:tentative_database/src/external/results/TableLoadResult.dart';
import 'package:tentative_database/src/external/results/TablePushResult.dart';
import 'package:tentative_database/src/external/results/TableRemoveResult.dart';
import 'package:tentative_database/src/external/typedef.dart';
import 'package:true_core/library.dart';

/// TODO MAKE A FULL TESTING
class AdvancedTableImpl<T extends IEntity<PARAM>, PARAM> extends AdvancedTable<T, PARAM> {
  static const String TAG = "AdvancedTable";
  /// TODO SMART LIST
  @override
  final List<T> storage = [];

  late final ITableEx<PARAM> table;
  RawTable get raw => table.raw;
  ColumnInfo<PARAM> get primaryKey => table.primaryKey;

  AdvancedTableImpl(this.table);

  @override
  Future<void> initState() async {
  }

  @override
  Future<void> dispose() async {
  }

  @override
  void optimizeStorage() {
    // final Profiler profiler = new Profiler("$TAG; optimizeStorage")..start();
    // final filtered = storage.toSet().toList();
    // storage.clear();
    // advanced.addToStorage(filtered);
    // print(set);
    // for(int i = 0; i < storage.length; i++) {
    //   for(int j = i + 1; j < storage.length; j++) {
    //     if(storage[i] == storage[j])
    //       storage.removeAt(j);
    //       // toDelete.add(j);
    //   }
    // } for(var o in toDelete)
    //   storage.remove(o);
    // _debugProfiler(profiler..stop());
  }

  @override
  void addToStorage(List<T> entities, [OnQueueModificationError? onError]) {
    final Profiler profiler = new Profiler("$TAG; addToStorage")..start();
    final List<T> dst = storage;
    final List<T> toAdd = [];
    final List<T> toError = [];

    for(final entity in entities) {
      if(entity.stored)
        continue;
      if(entity.state == EEntityState.QUEUE_DELETE) {
        toError.add(entity);
        continue;
      } toAdd.add(entity);
      entity.state += EEntityState.STORED;
    } dst.addAll(toAdd);

    _debugProfiler(profiler..stop());
    _handleQueueResult(toError, onError);
  }
  
  @override
  void addToInsertQueue(List<T> entities, [OnQueueModificationError? onError]) {
    final Profiler profiler = new Profiler("$TAG; addToInsertQueue")..start();
    final List<T> dst = queueInsert;
    final List<T> toAdd = [];
    final List<T> toError = [];

    for(final entity in entities) {
      if(entity.stored || entity.state == EEntityState.QUEUE_INSERT)
        continue;
      if(entity.state == EEntityState.QUEUE_DELETE) {
        toError.add(entity);
        continue;
      } toAdd.add(entity);
      entity.state += EEntityState.QUEUE_INSERT;
    } dst.addAll(toAdd);

    _debugProfiler(profiler..stop());
    _handleQueueResult(toError, onError);
  }

  @override
  void addToUpdateQueue(List<T> entities, [OnQueueModificationError? onError]) {
    final Profiler profiler = new Profiler("$TAG; addToUpdateQueue")..start();
    final List<T> dst = queueUpdate;
    final List<T> toAdd = [];
    final List<T> toError = [];

    for(final entity in entities) {
      if(entity.stored || entity.state == EEntityState.QUEUE_UPDATE
        || (entity.state == EEntityState.QUEUE_INSERT && entity.state != EEntityState.PROCESSING))
        continue;
      if(entity.state == EEntityState.QUEUE_DELETE) {
        toError.add(entity);
        continue;
      } toAdd.add(entity);
      entity.state += EEntityState.QUEUE_UPDATE;
    } dst.addAll(toAdd);

    _debugProfiler(profiler..stop());
    _handleQueueResult(toError, onError);
  }


  @override
  void addToRemoveQueue(List<T> entities, [OnQueueModificationError? onError]) {
    final Profiler profiler = new Profiler("$TAG; addToRemoveQueue")..start();
    final List<T> dst = queueDelete;
    final List<T> toAdd = [];
    final List<T> toRemove = [];
    final List<T> toError = [];

    for(final entity in entities) {
      if(entity.state == EEntityState.QUEUE_DELETE)
        continue;
      if(entity.stored) {
        toError.add(entity);
        continue;
      } if(entity.state == EEntityState.QUEUE_INSERT || entity.state == EEntityState.QUEUE_UPDATE) {
        toRemove.add(entity);
      } toAdd.add(entity);
      entity.state += EEntityState.QUEUE_DELETE;
    } dst.addAll(toAdd);

    for(final entity in toRemove) {
      if(entity.state == EEntityState.QUEUE_INSERT) {
        queueInsert.remove(e);
        entity.state -= EEntityState.QUEUE_INSERT;
      }

      if(entity.state == EEntityState.QUEUE_UPDATE) {
        queueUpdate.remove(e);
        entity.state -= EEntityState.QUEUE_UPDATE;
      }
    }

    _debugProfiler(profiler..stop());
    _handleQueueResult(toError, onError);
  }

  @override
  void removeFromStorage(List<T> entities) {
    final Profiler profiler = new Profiler("$TAG; removeFromStorage")..start();
    final List<T> toRemove = entities.where((e) => e.stored).toList();
    storage.removeWhere((e) => toRemove.contains(e));
    
    for(final entity in toRemove)
      entity.state -= EEntityState.STORED;
    _debugProfiler(profiler..stop());
  }

  @override
  void disposeStorage() {
    final Profiler profiler = new Profiler("$TAG; disposeStorage")..start();
    final list = storage.toList();
    storage.clear();
    
    for(final entity in list) {
      entity.state -= EEntityState.STORED;
      entity.dispose();
    }
    _debugProfiler(profiler..stop());
  }




  void _handleQueueResult(List<T> entities, [OnQueueModificationError? onError]) {
    if(entities.isNotEmpty) {
      try {
        throw new QueueModificationError(entities: entities);
      } on QueueModificationError catch(e, s) {
        if(onError != null)
          onError(e, s);
        else rethrow;
      }
    }
  }

  void _debugProfiler(Profiler profiler) {
    const timeUnit = TimeUnits.MILLISECONDS;
    final int executionTime = profiler.time(timeUnit);
    if(executionTime > TentativeDatabase.MAX_EXECUTION_TIME_ADVANCED_TABLE)
      Logger.instance.warn(TAG, "${profiler.name} was executing $executionTime in times $timeUnit");
  }








  //==========================================================================//
  //      GETTING
  //--------------------------------------------------------------------------//


  @override
  Future<TablePushResult<T>> push({
    required List<T> entities,

    required List<ColumnInfo<PARAM>> columns,

    Profiler? pInsert,
    LoggerContext? logger,
  }) async {
    // entities = entities.toSet().toList();

    final result = new TablePushResult<T>();

    if(entities.isEmpty) {
      result.prepareList();
      return result;
    }

    
    pInsert?.start();
    
    final include = columns.map((e) => e.param).toList();
    final values = entities.map((e) => e.toTable(requestType: ERequestType.insert, include: include).toList(columns)).toList();
    final rawResult = await raw.insertAll(
      columns.map((e) => e.name).toList(),
      values,
      logger: logger,
    );
    result.transactions.add(rawResult);

    final int lastId = rawResult.output;

    int id = lastId - (entities.length - 1);
    for(int n = 0; n < entities.length; n++, id++) {
      final entity = entities[n];
      entity.params.pid = id;
      entity.setLoaded(true);
      entity.setEdited(false);
    } result.pushed.addAll(entities);
    result.prepareList();

    // for(final entity in entities) {
    //   final rawResult = await raw.insert(
    //     entity.toTable(type: ERequestType.insert).toMap(),
    //     logger: logger,
    //   );
    //   result.transactions.add(rawResult);

    //   final int id = rawResult.output;

    //   if(id != 0) {
    //     entity.params.primaryKey = id;
    //     entity.setLoaded(true);
    //     entity.setEdited(false);
    //     result.pushed.add(entity);
    //     continue;
    //   } else result.notPushed.add(entity);
    // }
    pInsert?.stop();
    return result;
  }
  



  //TODO TYPIZING List<ColumnInfo<PARAM>>?
  
  @override
  Future<TableLoadResult<TCUSTOM, ID>> loadCustomData<TCUSTOM, ID>({
    int limit = 0,
    List<ColumnInfo<PARAM>>? columns,
    String? where,
    List<Object?>? whereArgs,

    required EntityToCustomDataConverter<T, TCUSTOM> entityConverter,
    required MapToCustomDataConverter<TCUSTOM> mapConverter,

    Profiler? pSelect,
    LoggerContext? logger,
  }) async {
    if(limit < 0)
      throw(new Exception("limit < 0"));
    if(columns != null && !columns.contains(primaryKey))
      throw(new Exception("columns must contain primaryKey"));

    final result = new TableLoadResult<TCUSTOM, ID>();

    pSelect?.start();

    final rawColumns = columns?.map((e) => e.name).toList();
    final rawResult = await raw.query(
      columns: rawColumns,
      where: where,
      whereArgs: whereArgs,
      limit: limit == 0 ? null : limit,
      logger: logger,
    );
    result.transactions.add(rawResult);

    for(final row in rawResult.output) {
      final int rowId = row[primaryKey.name]! as int;
      var entity = isExistInStorage((e) => e.params.pid != 0 && e.params.pid == rowId);
      if(entity != null) {
        result.stored.add(entityConverter(entity));
        continue;
      }

      entity = queueDelete.tryFirstWhere((e) => e.params.pid == rowId);
      if(entity != null) {
        continue;
      }

      result.loaded.add(mapConverter(row));
    } result.prepareList();
    pSelect?.stop();
    return result;
  }
  
  @override
  Future<TableLoadResult<T, ID>> load<ID>({
    List<ID>? ids,
    int limit = 0,
    List<String>? columns,

    required ColumnInfo<PARAM> columnId,

    required EntityByIdPredicate<T, ID> predicate,
    required MapToEntityConverter<T> converter,

    Profiler? pSelect,
    LoggerContext? logger,
  }) async {
    final TableLoadResult<T, ID> result;
    if(ids == null) {
      result = await loadByLimit<ID>(
        limit: limit,
        columns: columns,

        converter: converter,
        
        pSelect: pSelect,
        logger: logger,
      );
    } else {
      result = await loadList<ID>(
        columns: columns,

        ids: ids,
        columnId: columnId,

        predicate: predicate,
        converter: converter,
        
        pSelect: pSelect,
        logger: logger,
      );
    } return result;
  }

  @override
  Future<TableLoadResult<T, ID>> loadByLimit<ID>({
    int limit = 0,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,

    required MapToEntityConverter<T> converter,
    Profiler? pSelect,
    LoggerContext? logger,
  }) async {
    if(limit < 0)
      throw(new Exception("limit < 0"));

    final result = new TableLoadResult<T, ID>();

    pSelect?.start();

    final rawResult = await raw.query(
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      limit: limit == 0 ? null : limit,
      logger: logger,
    );
    result.transactions.add(rawResult);

    // final debugProfiler = new Profiler("parsing")..start();
    for(final row in rawResult.output) {
      final int rowId = row[primaryKey.name]! as int;
      var entity = isExistInStorage((e) => e.params.pid != 0 && e.params.pid == rowId);
      if(entity != null) {
        result.stored.add(entity);
        continue;
      }

      entity = queueDelete.tryFirstWhere((e) => e.params.pid == rowId);
      if(entity != null) {
        continue;
      }

      entity = converter(row);
      entity.setLoaded(true);
      entity.setEdited(false);
      result.loaded.add(entity);
    } result.prepareList();
    // debugProfiler.stop();
    // debugger(when: debugProfiler.time(TimeUnits.MILLISECONDS) > 500);

    pSelect?.stop();
    return result;
  }

  @override
  Future<TableLoadResult<T, ID>> loadList<ID>({
    List<String>? columns,

    required List<ID> ids,
    required ColumnInfo<PARAM> columnId,

    required EntityByIdPredicate<T, ID> predicate,
    required MapToEntityConverter<T> converter,
    Profiler? pSelect,
    LoggerContext? logger,
  }) async {

    ids = ids.toSet().toList();

    final result = new TableLoadResult<T, ID>();

    pSelect?.start();
    

    final List<ID> toLoad = [];

    for(final id in ids) {
      var entity = isExistInStorage((e) => predicate(e, id));
      if(entity != null) {
        result.stored.add(entity);
        continue;
      } 

      entity = queueDelete.tryFirstWhere((e) => predicate(e, id));
      if(entity != null) {
        continue;
      }
      
      toLoad.add(id);
    }

    if(toLoad.isNotEmpty) {
      final rawResult = await raw.query(
        columns: columns,
        where: "$columnId IN (?)",
        whereArgs: [
          toLoad,
        ],
        logger: logger,
      );
      result.transactions.add(rawResult);

      for(final row in rawResult.output) {
        final int rowId = row[primaryKey.name]! as int;
        var entity = queueDelete.tryFirstWhere((e) => e.params.pid == rowId);
        if(entity != null) {
          continue;
        }
        
        entity = converter(row);
        entity.setLoaded(true);
        entity.setEdited(false);
        result.loaded.add(entity);
      }
    } result.prepareList();

    if(result.entities.length < ids.length) {
      result.notLoaded.addAll(ids.where((id) => result.entities.tryFirstWhere((e) => predicate(e,id)) == null));
      // TODO TEST
      debugger(when: (pSelect?.elapsed.inMilliseconds ?? 0) > 5000);
    }
    pSelect?.stop();
    return result;
  }

  @override
  Future<TableRemoveResult<T, ID>> removeList<ID>({
    required List<ID> ids,
    required String columnId,

    required EntityByIdPredicate<T, ID> predicate,
    Profiler? pDelete,
    LoggerContext? logger,
  }) async {
    ids = ids.toSet().toList();

    final result = new TableRemoveResult<T, ID>();

    if(ids.isEmpty) {
      result.prepareList();
      return result;
    }
      
    pDelete?.start();
    

    final List<ID> toDelete = [];

    for(final id in ids) {
      final entity = isExistInStorage((entity) => predicate(entity, id));
      if(entity != null) {
        result.notRemoved.add(entity);
        continue;
      } toDelete.add(id);
    }

    if(toDelete.isNotEmpty) {
      final rawResult = await raw.delete(
        where: "$columnId IN (?)",
        whereArgs: [
          toDelete,
        ],
        logger: logger,
      );
      result.transactions.add(rawResult);
      
      result.removedCount = rawResult.output;
    } result.prepareList();
    pDelete?.stop();
    return result;
  }










  /// Returns nothing
  // @override
  // @Deprecated("TODO NEED TO FIX")
  // Future<bool> isExist(
  //   String where,
  //   List<dynamic> whereArgs, {
  //     List<String>? columns,
  //     Result<List<T>>? result,
  //     ModelConstructorFunction<T>? constructor,
  //     bool debug = false
  // }) async {
  //   raw._throwIfDisposed();
  //   List<Map<String, dynamic>> data = await raw.query(
  //     where: where,
  //     whereArgs: whereArgs,
  //     columns: columns,
  //     logger: logger,
  //   );
  //   if(data.isEmpty)
  //     return false;
  //   if(result != null && constructor != null) {
  //     result.value = data.map((map) => constructor(JsonObjectEx.fromMap(map))).toList();
  //   } return true;
  // }


  @override
  T? isExistInStorage(EntityPredicate<T> predicate) {
    // raw._throwIfDisposed();
    
    final List<T> out = [];
    bool b = isExistsInStorage(
      predicate,
      out,
      singleMatch: true,
    );

    if(b)
      return out.first;
    return null;
  }

  @override
  bool isExistsInStorage(
    EntityPredicate<T> predicate,
    List<T> out, {
      bool singleMatch = false,
  }) {
    final Profiler profiler = new Profiler("$TAG; isExistsInStorage")..start();
    // raw._throwIfDisposed();

    for(var m2 in storage) {
      if(predicate(m2)) {
        out.add(m2);
        if(singleMatch)
          break;
      }
    } _debugProfiler(profiler..stop());
    
    if(out.isNotEmpty) {
      return true;
    } return false;
  }
  



  // Future<Map<String,dynamic>?> getRowById(
  //   int id, {
  //     List<String>? columns,
  // }) async {
  //   _raw._throwIfDisposed();
  //   List<Map<String, dynamic>> data = await _raw.query(
  //     where: _table.primaryKey + " = ?",
  //     whereArgs: [id],
  //     columns: columns,
  //   );
  //   if(data.length == 0)
  //     return null;
  //   return data[0];
  // }

  // Future<int> removeRowById(int id) async {
  //   _raw._throwIfDisposed();
  //   return await _raw.delete(
  //     where: _table.primaryKey + " = ?",
  //     whereArgs: [id],
  //   );
  // }


  @override
  Future<AdvancedTableSaveResult<T>> save({
    Profiler? pInsert,
    Profiler? pUpdate,
    Profiler? pDelete,
    LoggerContext? logger,
  }) async {
    final Profiler profiler = new Profiler("$TAG; save; working with entities")..start();
    // raw._throwIfDisposed();

    final result = new AdvancedTableSaveResult<T>();
    
    final List<T> toInsert = queueInsert.toList();
    final List<T> toUpdate = queueUpdate.toList();
    final List<T> toDelete = queueDelete.toList();

    queueInsert.clear();
    queueUpdate.clear();
    queueDelete.clear();

    for(final entity in storage) {
      if(!entity.loaded)
        toInsert.add(entity);
      else if(entity.loaded && entity.edited)
        toUpdate.add(entity);
    }

    // toInsert.addAll(queueInsert);
    // toUpdate.addAll(queueUpdate);
    // toDelete.addAll(queueDelete);
    
    // queueInsert.clear();
    // queueUpdate.clear();
    // queueDelete.clear();
    //   // for(int start = 0, end = 0; start < toInsert.length; start = end) {
    //   //   end += TentativeDatabase.MAX_INSERTS_PER_REQUEST;

    for(final entity in toInsert)
      entity.state += EEntityState.PROCESSING;
    for(final entity in queueUpdate)
      entity.state += EEntityState.PROCESSING;
    for(final entity in queueDelete)
      entity.state += EEntityState.PROCESSING;
    
    _debugProfiler(profiler..stop());


    // TODO: сделать проверку результата
    int lastId;

    // INSERT
    //--------------------------------------------------------------------------
    pInsert?.start();
    {
      final list = toInsert;
      int end = 0;
      final columnInfos = table.columns;
      final columns = columnInfos.map((e) => e.name).toList();
      final include = columnInfos.map((e) => e.param).toList();
      while(list.isNotEmpty) {
        final entities = list.getRange(0, end = min(list.length, TentativeDatabase.MAX_INSERTS_PER_REQUEST)).toList();

        list.removeRange(0, end);

        final values = entities.map((e) => e.toTable(requestType: ERequestType.insert, include: include).toList(columnInfos)).toList();
        final rawResult = await raw.insertAll(
          columns,
          values,
          logger: logger,
        );
        result.transactions.add(rawResult);

        lastId = rawResult.output;

        int id = lastId - (entities.length - 1);
        for(int n = 0; n < entities.length; n++, id++) {
          final entity = entities[n];
          entity.state -= EEntityState.QUEUE_INSERT;
          entity.state -= EEntityState.PROCESSING;
          entity.params.pid = id;
          entity.setLoaded(true);
          entity.setEdited(false);
        }
        result.inserted.addAll(entities);
      }
    }
    pInsert?.stop();
    //--------------------------------------------------------------------------


    // UPDATE
    //--------------------------------------------------------------------------
    pUpdate?.start();
    {
      final list = toUpdate;
      int end = 0;
      final columnInfos = table.columns;
      final columns = columnInfos.map((e) => e.name).toList();
      final include = columnInfos.map((e) => e.param).toList();
      while(list.isNotEmpty) {
        final entities = list.getRange(0, end = min(list.length, TentativeDatabase.MAX_UPDATES_PER_REQUEST)).toList();

        list.removeRange(0, end);

        final values = entities.map((e) => e.toTable(requestType: ERequestType.update, include: include).toList(columnInfos)).toList();
        final rawResult = await raw.updateAll(
          columns,
          values,
          logger: logger,
        );
        result.transactions.add(rawResult);

        lastId = rawResult.output;

        int id = lastId - (entities.length - 1);
        for(int n = 0; n < entities.length; n++, id++) {
          final entity = entities[n];
          entity.state -= EEntityState.QUEUE_UPDATE;
          entity.state -= EEntityState.PROCESSING;
          entity.setLoaded(true);
          entity.setEdited(false);
        }
        result.updated.addAll(entities);
      }
    }
    pUpdate?.stop();
    //--------------------------------------------------------------------------

    // UPDATE
    //--------------------------------------------------------------------------
    // pUpdate?.start();
    // for(int start = 0, end = TentativeDatabase.MAX_UPDATES_PER_REQUEST; start < toUpdate.length; start = end, end += TentativeDatabase.MAX_UPDATES_PER_REQUEST) {
    //   final entities = toUpdate.getRange(start, min(toUpdate.length, end)).toList();
    //   // final map = entity.toTable(type: ERequestType.update).toMap();

    //   // UPDATE depthsCurrent SET qid = 543099, price = 50550.0, amount = 4.777850000000001, updateDate = 1640301300033 WHERE qid = 543099
    //   // UPDATE depthsCurrent SET qid = 543104, price = 50540.0, amount = 0.7780400000000003, updateDate = 1640301300033 WHERE qid = 543104
    //   // UPDATE depthsCurrent SET qid = 543109, price = 50530.0, amount = 3.8682799999999995, updateDate = 1640301300033 WHERE qid = 543109
    //   final sqlBuilder = StringBuffer();
    //   final arguments = <Object?>[];
    //   final columns = table._columns;
    //   final include = columns.map((e) => e.param).toList();
    //   final primaryKeyIndex = columns.indexOf(table._primaryKey);
    //   for(final entity in entities) {
    //     sqlBuilder.write("UPDATE ${raw.name} SET ");
    //     final row = entity.toTable(type: ERequestType.update, include: include).toList(columns);
        
    //     for(int i = 0; i < columns.length; i++) {
    //       if(i > 0)
    //         sqlBuilder.write(", ");
    //       sqlBuilder.write("${columns[i].name} = ?");
    //     }
    //     // sqlBuilder.write(columns.map((e) => e.name).join(", "));
    //     arguments.addAll(row);
    //     sqlBuilder.write(" WHERE ${table._primaryKey.name} = ?");
    //     debugger(when: row[primaryKeyIndex] == null);
    //     arguments.add(row[primaryKeyIndex]);
    //     sqlBuilder.write("\n");
    //   }
    //   debugger();
    //   final rawResult = await raw.rawUpdate(
    //     sqlBuilder.toString(),
    //     arguments: arguments,
    //     logger: logger,
    //   );
    //   result.transactions.add(rawResult.transactionId);

    //   lastId = rawResult.output;

    //   // entity.state -= EEntityState.QUEUE_UPDATE;
    //   // entity.state -= EEntityState.PROCESSING;
    //   // entity.setEdited(false);
    //   // result.updated.add(entity);
    // }
    // pUpdate?.stop();
    
    // pUpdate?.start();
    // for(final entity in toUpdate) {
    //   final map = entity.toTable(type: ERequestType.update).toMap();

    //   final rawResult = await raw.update(
    //     map,
    //     where: "${table._primaryKey} = ?",
    //     whereArgs: [
    //       map[table._primaryKey.name],
    //     ],
    //     logger: logger,
    //   );
    //   result.transactions.add(rawResult.transactionId);

    //   lastId = rawResult.output;

    //   entity.state -= EEntityState.QUEUE_UPDATE;
    //   entity.state -= EEntityState.PROCESSING;
    //   entity.setEdited(false);
    //   result.updated.add(entity);
    // }
    // pUpdate?.stop();
    //--------------------------------------------------------------------------
    

    // DELETE
    //--------------------------------------------------------------------------
    pDelete?.start();
    {
      final list = toDelete;
      int end = 0;
      while(list.isNotEmpty) {
        final entities = list.getRange(0, end = min(list.length, TentativeDatabase.MAX_UPDATES_PER_REQUEST)).toList();

        list.removeRange(0, end);

        final ids = entities.map((e) => e.toTable(requestType: ERequestType.delete).toList([table.primaryKey]).first).toList();
        final rawResult = await raw.delete(
          where: "${table.primaryKey} in (?)",
          whereArgs: [
            ids,
          ],
          logger: logger,
        );
        result.transactions.add(rawResult);

        lastId = rawResult.output;

        int id = lastId - (entities.length - 1);
        for(int n = 0; n < entities.length; n++, id++) {
          final entity = entities[n];
          entity.state -= EEntityState.QUEUE_DELETE;
          entity.state -= EEntityState.PROCESSING;
          entity.params.pid = 0;
          entity.setLoaded(false);
          entity.setEdited(false);
        }
        result.deleted.addAll(entities);
      }
    }
    pDelete?.stop();
    //--------------------------------------------------------------------------
    
    optimizeStorage();
    return result;
  }





















  // List<INeonCachedModel>      _cache            = new List();
  // ///returns nothing
  // Future<bool> isExist(dynamic value, String column) async {
  //   List<Map<String, dynamic>> data = await _table.query(
  //     where: "$column = ?",
  //     whereArgs: [value]
  //   );
  //   if(data.length == 0)
  //     return false;
  //   return true;
  // }


  // ///returns
  // /// - [nothing],                  if not found      
  // /// - [List<INeonCachedModel>],   if found
  // Future<bool> isExistUsingCache(
  //   bool Function(INeonCachedModel model) fMatch,
  //   Result<List<INeonCachedModel>> out, {
  //     bool onlyOneMatch = false,
  // }) async {
  //   //////////////////
  //   if(onlyOneMatch) {
  //     for(INeonCachedModel model in _cache) {
  //       if(fMatch.call(model)) {
  //         if(out != null)
  //           out.set([model]);
  //         return true;
  //       }
  //     } return false;
  //   } 
  //   //////////////////
  //   List<INeonCachedModel> list = [];
  //   for(INeonCachedModel model in _cache) {
  //     if(fMatch.call(model)) {
  //       list.add(model);
  //     }
  //   } if(list.length > 0) {
  //       if(out != null)
  //         out.set(list);
  //     return true;
  //   } return false;
  // }


  // void setEnableCaching(bool b) { _bEnableCaching = b; }
  // bool isEnableCaching() { return _bEnableCaching; }

  // Future<void> cacheEverything({bool bClearPrevious = true}) async {
  //   List<Map<String, dynamic>> cols = await _table.query(
  //     columns: (_columns.length == 0 ? null : _columns),
  //   );
  //   _cache = new List();
  //   cols.forEach((map) {
  //     _cache.add(_constructor.call(map));
  //   });
  // }

}