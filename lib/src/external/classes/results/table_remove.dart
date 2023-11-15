
import 'package:ientity/library.dart';

import '../../abstract/table_request_result.dart';

class TableRemoveResult<T extends IEntity> extends TableRequestResult<T> {
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