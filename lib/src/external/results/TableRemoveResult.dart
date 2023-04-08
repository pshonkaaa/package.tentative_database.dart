
import 'package:ientity/library.dart';

import 'ITableRequestResult.dart';

class TableRemoveResult<T extends IEntity> extends ITableRequestResult<T> {
  // final List<T> maybeRemoved = [];
  // final List<T> removed = [];
  final List<T> notRemoved = [];

  int removedCount = 0;

  @override
  late final List<T> entities;
  
  void prepareList() {
    entities = [];
  }
  
  TableRemoveResult();
}