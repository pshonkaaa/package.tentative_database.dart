import 'dart:developer';
import 'dart:math' as math;

import 'package:ientity/library.dart';
import 'package:logger_ex/library.dart';
import 'package:tentative_database/src/external/TentativeDatabase.dart';
import 'package:tentative_database/src/external/results/TableLoadResult.dart';
import 'package:tentative_database/src/external/results/TablePushResult.dart';
import 'package:tentative_database/src/external/results/TableRemoveResult.dart';
import 'package:tentative_database/src/external/results/TableSaveResult.dart';
import 'package:tentative_database/src/external/typedef.dart';
import 'package:true_core/library.dart';

import 'ITentativeTable.dart';

mixin TentativeTableMixin<T extends IEntity> on ITentativeTable<T> {
  static const TAG = "TentativeTableMixin";

  final List<T> queueInsert = [];
  final List<T> queueUpdate = [];
  final List<T> queueDelete = [];


  final List<TableExecutorProxy> _proxies = [];
  final Map<int, T> _storage = Map();
  final List<T> queueToInsertAndToStorage = [];



  @override
  Iterable<T> get storage => [..._storage.values, ...queueToInsertAndToStorage];

  @override
  void addProxy(TableExecutorProxy proxy) {
    _proxies.add(proxy);
  }

  @override
  void removeProxy(TableExecutorProxy proxy) {
    _proxies.remove(proxy);
  }

  @override
  Future<void> initState() async {
    await super.initState();
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
  }

  @override
  void optimizeStorage() {
    // final Profiler profiler = Profiler("$TAG; optimizeStorage")..start();
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
    final Profiler profiler = Profiler("$TAG; addToStorage")..start();
    final List<T> toAdd = [];
    final List<T> toError = [];

    for(final entity in entities) {
      if(entity.getOptions().stored)
        continue;
      if(entity.getOptions().state == EEntityState.QUEUE_DELETE) {
        toError.add(entity);
        continue;
      } toAdd.add(entity);
      entity.getOptions().state += EEntityState.STORED;
    } 
    
    for(final entity in toAdd) {
      if(entity.id == 0)
        queueToInsertAndToStorage.add(entity);
      else _storage[entity.id] = entity;
    }

    _debugProfiler(profiler..stop());
    _handleQueueResult(toError, onError);
  }
  
  @override
  void addToInsertQueue(List<T> entities, [OnQueueModificationError? onError]) {
    final Profiler profiler = Profiler("$TAG; addToInsertQueue")..start();
    final List<T> dst = queueInsert;
    final List<T> toAdd = [];
    final List<T> toError = [];

    for(final entity in entities) {
      if(entity.getOptions().stored || entity.getOptions().state == EEntityState.QUEUE_INSERT)
        continue;
      if(entity.getOptions().state == EEntityState.QUEUE_DELETE) {
        toError.add(entity);
        continue;
      } toAdd.add(entity);
      entity.getOptions().state += EEntityState.QUEUE_INSERT;
    } dst.addAll(toAdd);

    _debugProfiler(profiler..stop());
    _handleQueueResult(toError, onError);
  }

  @override
  void addToUpdateQueue(List<T> entities, [OnQueueModificationError? onError]) {
    final Profiler profiler = Profiler("$TAG; addToUpdateQueue")..start();
    final List<T> dst = queueUpdate;
    final List<T> toAdd = [];
    final List<T> toError = [];

    for(final entity in entities) {
      if(entity.getOptions().stored || entity.getOptions().state == EEntityState.QUEUE_UPDATE
        || (entity.getOptions().state == EEntityState.QUEUE_INSERT && entity.getOptions().state != EEntityState.PROCESSING))
        continue;
      if(entity.getOptions().state == EEntityState.QUEUE_DELETE) {
        toError.add(entity);
        continue;
      } toAdd.add(entity);
      entity.getOptions().state += EEntityState.QUEUE_UPDATE;
    } dst.addAll(toAdd);

    _debugProfiler(profiler..stop());
    _handleQueueResult(toError, onError);
  }

  @override
  void addToRemoveQueue(List<T> entities, [OnQueueModificationError? onError]) {
    final Profiler profiler = Profiler("$TAG; addToRemoveQueue")..start();
    final List<T> dst = queueDelete;
    final List<T> toAdd = [];
    final List<T> toRemove = [];
    final List<T> toError = [];

    for(final entity in entities) {
      if(entity.getOptions().state == EEntityState.QUEUE_DELETE)
        continue;
      if(entity.getOptions().stored) {
        toError.add(entity);
        continue;
      } if(entity.getOptions().state == EEntityState.QUEUE_INSERT || entity.getOptions().state == EEntityState.QUEUE_UPDATE) {
        toRemove.add(entity);
      } toAdd.add(entity);
      entity.getOptions().state += EEntityState.QUEUE_DELETE;
    } dst.addAll(toAdd);

    for(final entity in toRemove) {
      if(entity.getOptions().state == EEntityState.QUEUE_INSERT) {
        queueInsert.remove(entity);
        entity.getOptions().state -= EEntityState.QUEUE_INSERT;
      }

      if(entity.getOptions().state == EEntityState.QUEUE_UPDATE) {
        queueUpdate.remove(entity);
        entity.getOptions().state -= EEntityState.QUEUE_UPDATE;
      }
    }

    _debugProfiler(profiler..stop());
    _handleQueueResult(toError, onError);
  }

  @override
  void removeFromStorage(List<T> entities) {
    final Profiler profiler = Profiler("$TAG; removeFromStorage")..start();
    final List<T> toRemove = entities.where((e) => e.getOptions().stored).toList();
    
    for(final entity in toRemove) {
      if(entity.getOptions().state != EEntityState.STORED)
        continue;      
      if(entity.id == 0) {
        queueToInsertAndToStorage.remove(entity);
        queueInsert.add(entity);
      } else _storage.remove(entity.id);

      entity.getOptions().state -= EEntityState.STORED;
    }
    _debugProfiler(profiler..stop());
  }

  @override
  void disposeStorage() {
    final Profiler profiler = Profiler("$TAG; disposeStorage")..start();
    final list = _storage.values.toList();
    _storage.clear();
    
    for(final entity in list) {
      entity.getOptions().state -= EEntityState.STORED;
      entity.dispose();
    }
    _debugProfiler(profiler..stop());
  }




  void _handleQueueResult(List<T> entities, [OnQueueModificationError? onError]) {
    if(entities.isNotEmpty) {
      try {
        throw QueueModificationError(entities: entities);
      } on QueueModificationError catch(e, s) {
        if(onError != null)
          onError(e, s);
        else rethrow;
      }
    }
  }

  void _debugProfiler(Profiler profiler) {
    // const timeUnit = TimeUnits.MILLISECONDS;
    // final int executionTime = profiler.time(timeUnit);
    // if(executionTime > TentativeDatabase.MAX_EXECUTION_TIME_ADVANCED_TABLE)
      // Logger.instance.warn(TAG, "${profiler.name} was executing $executionTime in times $timeUnit");
  }








  //==========================================================================//
  //      GETTING
  //--------------------------------------------------------------------------//


  @override
  Future<TablePushResult<T>> push({
    required List<T> entities,

    required List<EntityColumnInfo> columns,
    required EntityComparison<T> comparison,

    Profiler? pSelect,
    Profiler? pInsert,
    LoggerContext? logger,
  }) async {
    final result = TablePushResult<T>();

    if(entities.isEmpty) {
      result.prepareList();
      return result;
    }

    // entities = entities.toSet().toList();
    columns = columns.toList()..remove(primaryKey);

    
    pSelect?.start();
    {
      final tmp = entities;
      entities = [];
      for(final entity in tmp) {
        final exist = isExistInStorage(-1, (e2) => comparison(entity, e2));
        if(exist != null)
          result.stored.add(exist);
        else entities.add(entity);
      }
    }
    pSelect?.stop();


    pInsert?.start();
    if(entities.isNotEmpty) {
      final values = entities.map((e) => e.toTable(
          requestType: ERequestType.insert,
          include: columns.toList(),
        ).toList(columns),
      ).toList();

      final rawResult = await executor.insertAll(
        columns.map((e) => e.name).toList(),
        values,
        logger: logger,
      );
      result.transactions.add(rawResult);

      final int lastId = rawResult.output;

      int id = lastId - (entities.length - 1);
      for(int n = 0; n < entities.length; n++, id++) {
        final entity = entities[n];
        entity.id = id;
        entity.setLoaded(true);
        entity.setEdited(false);
      } result.pushed.addAll(entities);
      result.prepareList();
    }
    pInsert?.stop();
    return result;
  }
  



  //TODO TYPIZING List<ColumnInfo>?
  
  @override
  Future<TableLoadResult<TCUSTOM>> loadCustomData<TCUSTOM>({
    int limit = 0,
    List<EntityColumnInfo>? columns,
    String? where,
    List<Object?>? whereArgs,

    required EntityToCustomDataConverter<T, TCUSTOM> entityConverter,
    required MapToCustomDataConverter<TCUSTOM> mapConverter,

    Profiler? pSelect,
    LoggerContext? logger,
  }) async {
    if(limit < 0)
      throw(Exception("limit < 0"));
      
    if(columns != null && !columns.contains(primaryKey))
      throw(Exception("columns must contain primaryKey"));

    final result = TableLoadResult<TCUSTOM>();

    pSelect?.start();
    {
      final rawResult = await executor.query(
        columns: columns?.map((e) => e.name).toList(),
        where: where,
        whereArgs: whereArgs,
        limit: limit == 0 ? null : limit,
        logger: logger,
      );
      result.transactions.add(rawResult);

      for(final row in rawResult.output) {
        final int id = row[primaryKey.name]! as int;
        var entity = isExistInStorage(id);
        if(entity != null) {
          result.stored.add(entityConverter(entity));
          continue;
        }

        entity = queueDelete.tryFirstWhere((e) => e.id == id);
        if(entity != null) {
          continue;
        }

        result.loaded.add(mapConverter(row));
      } result.prepareList();
    }
    pSelect?.stop();
    return result;
  }
  
  // Future<TableLoadResult<T, ID>> load<ID>({
  //   List<ID>? ids,
  //   int limit = 0,
  //   List<String>? columns,

  //   required EntityColumnInfo columnId,

  //   required EntityByIdPredicate<T, ID> predicate,
  //   required MapToEntityConverter<T> converter,

  //   Profiler? pSelect,
  //   LoggerContext? logger,
  // }) async {
  //   final TableLoadResult<T, ID> result;
  //   if(ids == null) {
  //     result = await loadByLimit<ID>(
  //       limit: limit,
  //       columns: columns,

  //       converter: converter,
        
  //       pSelect: pSelect,
  //       logger: logger,
  //     );
  //   } else {
  //     result = await loadList<ID>(
  //       columns: columns,

  //       ids: ids,
  //       columnId: columnId,

  //       predicate: predicate,
  //       converter: converter,
        
  //       pSelect: pSelect,
  //       logger: logger,
  //     );
  //   } return result;
  // }

  @override
  Future<TableLoadResult<T>> loadByLimit({
    int limit = 0,
    List<EntityColumnInfo>? columns,
    String? where,
    List<Object?>? whereArgs,

    required MapToEntityConverter<T> converter,
    Profiler? pSelect,
    LoggerContext? logger,
  }) async {
    if(limit < 0)
      throw(Exception("limit < 0"));
      
    if(columns != null && !columns.contains(primaryKey))
      throw(Exception("columns must contain primaryKey"));

    final result = TableLoadResult<T>();

    pSelect?.start();
    {
      final rawResult = await executor.query(
        columns: columns?.map((e) => e.name).toList(),
        where: where,
        whereArgs: whereArgs,
        limit: limit == 0 ? null : limit,
        logger: logger,
      );
      result.transactions.add(rawResult);

      // final debugProfiler = Profiler("parsing")..start();
      for(final row in rawResult.output) {
        final int id = row[primaryKey.name]! as int;
        var entity = isExistInStorage(id);
        if(entity != null) {
          result.stored.add(entity);
          continue;
        }

        entity = queueDelete.tryFirstWhere((e) => e.id == id);
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
    }
    pSelect?.stop();
    return result;
  }

  @override
  Future<TableLoadResult<T>> loadByIds({
    required List<int> ids,

    List<String>? columns,

    Profiler? pSelect,
    LoggerContext? logger,
  }) async {
    final result = TableLoadResult<T>();


    ids = ids.toSet().toList();
    

    pSelect?.start();
    {
      final List<int> toLoad = [];
      final List<int> toRemoveIds = [];

      for(final id in ids) {
        var entity = isExistInStorage(id);
        if(entity != null) {
          result.stored.add(entity);
          continue;
        } 

        entity = queueDelete.tryFirstWhere((e) => e.id == id);
        if(entity != null) {
          toRemoveIds.add(id);
          continue;
        }
        
        toLoad.add(id);
      }

      for(final id in toRemoveIds) {
        ids.remove(id);
      } result.notLoaded.addAll(toRemoveIds);

      if(toLoad.isNotEmpty) {
        final rawResult = await executor.query(
          columns: columns,
          where: "$primaryKey IN (?)",
          whereArgs: [
            toLoad,
          ],
          logger: logger,
        );
        result.transactions.add(rawResult);

        for(final row in rawResult.output) {
          final int rowId = row[primaryKey.name]! as int;
          var entity = queueDelete.tryFirstWhere((e) => e.id == rowId);
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
        result.notLoaded.addAll(ids.where((id) => result.entities.tryFirstWhere((e) => e.id == id) == null));
        // TODO TEST
        debugger(when: (pSelect?.elapsed.inMilliseconds ?? 0) > 5000);
      }
    }
    pSelect?.stop();
    return result;
  }

  @override
  Future<TableRemoveResult<T>> removeByIds({
    required List<int> ids,

    // required EntityByIdPredicate<T> predicate,
    Profiler? pDelete,
    LoggerContext? logger,
  }) async {
    ids = ids.toSet().toList();

    final result = TableRemoveResult<T>();

    if(ids.isEmpty) {
      result.prepareList();
      return result;
    }
      
    pDelete?.start();
    

    final List<int> toDelete = [];

    for(final id in ids) {
      final entity = isExistInStorage(id);
      if(entity != null) {
        result.notRemoved.add(entity);
        continue;
      } toDelete.add(id);
    }

    if(toDelete.isNotEmpty) {
      final rawResult = await executor.delete(
        where: "$primaryKey IN (?)",
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
  //   executor._throwIfDisposed();
  //   List<Map<String, dynamic>> data = await executor.query(
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
  T? isExistInStorage(int id, [EntityPredicate<T>? predicate]) {
    // executor._throwIfDisposed();
    
    T? entity;

    
    final profiler = Profiler("$TAG; isExistsInStorage")..start();
    {
      if(id == -1) {
        for(final e in storage) {
          if(predicate!(e)) {
            entity = e;
            break;
          }
        }
      } else {
        entity = _storage[id];
      }
    }
    _debugProfiler(profiler..stop());
    
    return entity;
  }

  // @override
  // bool isExistsInStorage(
  //   EntityPredicate<T> predicate,
  //   List<T> out, {
  //     bool singleMatch = false,
  // }) {
  //   final Profiler profiler = Profiler("$TAG; isExistsInStorage")..start();
  //   // executor._throwIfDisposed();

  //   for(var m2 in storage) {
  //     if(predicate(m2)) {
  //       out.add(m2);
  //       if(singleMatch)
  //         break;
  //     }
  //   } _debugProfiler(profiler..stop());
    
  //   if(out.isNotEmpty) {
  //     return true;
  //   } return false;
  // }
  



  // Future<Map<String,dynamic>?> getRowById(
  //   int id, {
  //     List<String>? columns,
  // }) async {
  //   _executor._throwIfDisposed();
  //   List<Map<String, dynamic>> data = await _executor.query(
  //     where: _table.primaryKey + " = ?",
  //     whereArgs: [id],
  //     columns: columns,
  //   );
  //   if(data.length == 0)
  //     return null;
  //   return data[0];
  // }

  // Future<int> removeRowById(int id) async {
  //   _executor._throwIfDisposed();
  //   return await _executor.delete(
  //     where: _table.primaryKey + " = ?",
  //     whereArgs: [id],
  //   );
  // }


  @override
  @Deprecated("REVIEW")
  Future<TableSaveResult<T>> save({
    Profiler? pInsert,
    Profiler? pUpdate,
    Profiler? pDelete,
    LoggerContext? logger,
  }) async {
    final Profiler profiler = Profiler("$TAG; save; working with entities")..start();
    // executor._throwIfDisposed();

    final result = TableSaveResult<T>();
    
    final List<T> toInsertAndToStorage = queueToInsertAndToStorage.toList();
    final List<T> toInsert = queueInsert.toList();
    final List<T> toUpdate = queueUpdate.toList();
    final List<T> toDelete = queueDelete.toList();

    queueInsert.clear();
    queueUpdate.clear();
    queueDelete.clear();


    toInsert.addAll(toInsertAndToStorage);

    for(final entity in _storage.values) {
      if(!entity.getOptions().loaded)
        toInsert.add(entity);
      else if(entity.getOptions().loaded && entity.getOptions().edited)
        toUpdate.add(entity);
    }


    //   // for(int start = 0, end = 0; start < toInsert.length; start = end) {
    //   //   end += TentativeDatabase.MAX_INSERTS_PER_REQUEST;

    for(final entity in toInsert)
      entity.getOptions().state += EEntityState.PROCESSING;
    for(final entity in toUpdate)
      entity.getOptions().state += EEntityState.PROCESSING;
    for(final entity in toDelete)
      entity.getOptions().state += EEntityState.PROCESSING;
    
    _debugProfiler(profiler..stop());


    // TODO: сделать проверку результата
    int lastId;

    // INSERT
    //--------------------------------------------------------------------------
    pInsert?.start();
    {
      final list = toInsert;
      int end = 0;
      final columnInfos = this.columns.toList()..remove(primaryKey);
      final columns = columnInfos.map((e) => e.name).toList();
      final include = columnInfos.toList();
      while(list.isNotEmpty) {
        final entities = list.getRange(0, end = math.min(list.length, TentativeDatabase.MAX_INSERTS_PER_REQUEST)).toList();

        list.removeRange(0, end);

        final values = entities.map((e) => e.toTable(requestType: ERequestType.insert, include: include).toList(columnInfos)).toList();
        final rawResult = await executor.insertAll(
          columns,
          values,
          logger: logger,
        );
        result.transactions.add(rawResult);

        lastId = rawResult.output;

        int id = lastId - (entities.length - 1);
        for(int n = 0; n < entities.length; n++, id++) {
          final entity = entities[n];
          entity.getOptions().state -= EEntityState.QUEUE_INSERT;
          entity.getOptions().state -= EEntityState.PROCESSING;
          entity.id = id;
          entity.setLoaded(true);
          entity.setEdited(false);
        }
        result.inserted.addAll(entities);
      }

      queueToInsertAndToStorage.removeWhere((e) => toInsertAndToStorage.contains(e));
      _storage.addEntries(toInsertAndToStorage.map((e) => MapEntry(e.id, e)));
    }
    pInsert?.stop();
    //--------------------------------------------------------------------------


    // UPDATE
    //--------------------------------------------------------------------------
    pUpdate?.start();
    {
      final list = toUpdate;
      int end = 0;
      final columnInfos = this.columns;
      final columns = columnInfos.map((e) => e.name).toList();
      final include = columnInfos.toList();
      while(list.isNotEmpty) {
        final entities = list.getRange(0, end = math.min(list.length, TentativeDatabase.MAX_UPDATES_PER_REQUEST)).toList();

        list.removeRange(0, end);

        final values = entities.map((e) => e.toTable(requestType: ERequestType.update, include: include).toList(columnInfos)).toList();
        final rawResult = await executor.updateAll(
          columns,
          values,
          logger: logger,
        );
        result.transactions.add(rawResult);

        lastId = rawResult.output;

        int id = lastId - (entities.length - 1);
        for(int n = 0; n < entities.length; n++, id++) {
          final entity = entities[n];
          entity.getOptions().state -= EEntityState.QUEUE_UPDATE;
          entity.getOptions().state -= EEntityState.PROCESSING;
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
    //     sqlBuilder.write("UPDATE ${executor.name} SET ");
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
    //   final rawResult = await executor.rawUpdate(
    //     sqlBuilder.toString(),
    //     arguments: arguments,
    //     logger: logger,
    //   );
    //   result.transactions.add(rawResult.transactionId);

    //   lastId = rawResult.output;

    //   // entity.getOptions().state -= EEntityState.QUEUE_UPDATE;
    //   // entity.getOptions().state -= EEntityState.PROCESSING;
    //   // entity.setEdited(false);
    //   // result.updated.add(entity);
    // }
    // pUpdate?.stop();
    
    // pUpdate?.start();
    // for(final entity in toUpdate) {
    //   final map = entity.toTable(type: ERequestType.update).toMap();

    //   final rawResult = await executor.update(
    //     map,
    //     where: "${table._primaryKey} = ?",
    //     whereArgs: [
    //       map[table._primaryKey.name],
    //     ],
    //     logger: logger,
    //   );
    //   result.transactions.add(rawResult.transactionId);

    //   lastId = rawResult.output;

    //   entity.getOptions().state -= EEntityState.QUEUE_UPDATE;
    //   entity.getOptions().state -= EEntityState.PROCESSING;
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
        final entities = list.getRange(0, end = math.min(list.length, TentativeDatabase.MAX_UPDATES_PER_REQUEST)).toList();

        list.removeRange(0, end);

        final ids = entities.map((e) => e.toTable(requestType: ERequestType.delete).toList([primaryKey]).first).toList();
        final rawResult = await executor.delete(
          where: "$primaryKey in (?)",
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
          entity.getOptions().state -= EEntityState.QUEUE_DELETE;
          entity.getOptions().state -= EEntityState.PROCESSING;
          entity.id = 0;
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





















  // List<INeonCachedModel>      _cache            = List();
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
  //   _cache = List();
  //   cols.forEach((map) {
  //     _cache.add(_constructor.call(map));
  //   });
  // }
}









































































































abstract class TableExecutorProxy {
  
  // Future<RawQueryRequestResult> query({
  //     required RawQueryRequestResult result,
  //     required List<String>? columns,
  //     required LoggerContext? logger,
  // });



  // Future<RawInsertRequestResult> insert(
  //   JsonObject values, {
  //     required RawInsertRequestResult result,
  //     String? nullColumnHack,
  //     ConflictAlgorithm? conflictAlgorithm,
  //     LoggerContext? logger,
  // });

  // /// Executes SQL INSERT INTO
  // /// 
  // /// Returns [PRIMARY_KEY] of last inserted
  // Future<RawInsertRequestResult> insertAll(
  //   List<String> columns,
  //   List<List<Object?>> list, {
  //     String? nullColumnHack,
  //     ConflictAlgorithm? conflictAlgorithm,

  //     DatabaseExecutor? database,
  //     LoggerContext? logger,
  // });


  // /// Executes INSERT INTO ON CONFLICT() DO UPDATE SET
  // /// 
  // /// Returns number of changed rows
  // Future<RawUpdateRequestResult> update(
  //   Map<String, dynamic> values, {
  //     String? where,
  //     List<Object?>? whereArgs,
  //     ConflictAlgorithm? conflictAlgorithm,
  //     LoggerContext? logger,
  // });

  // /// Executes SQL UPDATE
  // /// 
  // /// Returns number of changed rows
  // Future<RawInsertRequestResult> updateAll(
  //   List<String> columns,
  //   List<List<Object?>> list, {
  //     String? nullColumnHack,
  //     ConflictAlgorithm? conflictAlgorithm,

  //     DatabaseExecutor? database,
  //     LoggerContext? logger,
  // });

  // Future<RawUpdateRequestResult> rawUpdate(
  //   String sql, {
  //     List<Object?>? arguments,

  //     DatabaseExecutor? database,
  //     LoggerContext? logger,
  // });
  
  // /// Executes SQL DELETE
  // /// 
  // /// Returns amount of deleted rows
  // Future<RawDeleteRequestResult> delete({
  //   String? where,
  //   List<Object?>? whereArgs,
  //   LoggerContext? logger,
  // });

  // /// Executes SQL DROP TABLE
  // /// 
  // /// Dropping table
  // Future<RawDropTableRequestResult> drop();

  // /// Executes SQL SELECT
  // Future<List<String>> toStringTable({
  //   int size = 999,
  //   offset = 0,
  // });
}