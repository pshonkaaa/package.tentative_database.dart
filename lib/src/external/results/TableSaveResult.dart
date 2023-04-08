import 'package:ientity/library.dart';

import 'ITableRequestResult.dart';

class TableSaveResult<T extends IEntity> extends ITableRequestResult<T> {
  final List<T> inserted = [];
  final List<T> updated = [];
  final List<T> deleted = [];

  @override
  List<T> get entities => throw(new Exception("UNUSED"));
  
  TableSaveResult();
}