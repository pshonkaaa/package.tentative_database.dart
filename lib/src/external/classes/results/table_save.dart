import 'package:ientity/library.dart';

import '../../abstract/table_request_result.dart';

class TableSaveResult<T extends IEntity> extends TableRequestResult<T> {
  final List<T> inserted = [];
  final List<T> updated = [];
  final List<T> deleted = [];

  @override
  List<T> get entities => throw(new Exception("UNUSED"));
  
  TableSaveResult();
}