// import 'package:logger_ex/library.dart';

// import 'results/RawDeleteRequestResult.dart';
// import 'results/RawDropTableRequestResult.dart';
// import 'results/RawInsertRequestResult.dart';
// import 'results/RawQueryRequestResult.dart';
// import 'results/RawUpdateRequestResult.dart';

// abstract class TableExecutorProxy {
  
//   final List<TableExecutorProxy> proxies = [];
//   Future<RawQueryRequestResult> query({
//       required RawQueryRequestResult result,
//       required List<String>? columns,
//       required Logger? logger,
//   });



//   void addProxy(TableExecutorProxy proxy);
//   void removeProxy(TableExecutorProxy proxy);
//   @override
//   void addProxy(TableExecutorProxy proxy) {
//     proxies.add(proxy);
//   }

//   @override
//   void removeProxy(TableExecutorProxy proxy) {
//     proxies.remove(proxy);
//   }

//   Future<RawInsertRequestResult> insert(
//     JsonObject values, {
//       required RawInsertRequestResult result,
//       String? nullColumnHack,
//       ConflictAlgorithm? conflictAlgorithm,
//       Logger? logger,
//   });

//   /// Executes SQL INSERT INTO
//   /// 
//   /// Returns [PRIMARY_KEY] of last inserted
//   Future<RawInsertRequestResult> insertAll(
//     List<String> columns,
//     List<List<Object?>> list, {
//       String? nullColumnHack,
//       ConflictAlgorithm? conflictAlgorithm,

//       DatabaseExecutor? database,
//       Logger? logger,
//   });


//   /// Executes INSERT INTO ON CONFLICT() DO UPDATE SET
//   /// 
//   /// Returns number of changed rows
//   Future<RawUpdateRequestResult> update(
//     Map<String, dynamic> values, {
//       String? where,
//       List<Object?>? whereArgs,
//       ConflictAlgorithm? conflictAlgorithm,
//       Logger? logger,
//   });

//   /// Executes SQL UPDATE
//   /// 
//   /// Returns number of changed rows
//   Future<RawInsertRequestResult> updateAll(
//     List<String> columns,
//     List<List<Object?>> list, {
//       String? nullColumnHack,
//       ConflictAlgorithm? conflictAlgorithm,

//       DatabaseExecutor? database,
//       Logger? logger,
//   });

//   Future<RawUpdateRequestResult> rawUpdate(
//     String sql, {
//       List<Object?>? arguments,

//       DatabaseExecutor? database,
//       Logger? logger,
//   });
  
//   /// Executes SQL DELETE
//   /// 
//   /// Returns amount of deleted rows
//   Future<RawDeleteRequestResult> delete({
//     String? where,
//     List<Object?>? whereArgs,
//     Logger? logger,
//   });

//   /// Executes SQL DROP TABLE
//   /// 
//   /// Dropping table
//   Future<RawDropTableRequestResult> drop();

//   /// Executes SQL SELECT
//   Future<List<String>> toStringTable({
//     int size = 999,
//     offset = 0,
//   });
// }