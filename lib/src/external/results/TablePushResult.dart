
import 'package:ientity/library.dart';

import 'ITableRequestResult.dart';

class TablePushResult<T extends IEntity> extends ITableRequestResult<T> {
  final List<T> pushed = [];
  final List<T> stored = [];
  final List<T> notPushed = [];

  @override
  late final List<T> entities;
  
  void prepareList() {
    entities = [...pushed];
  }
  
  TablePushResult();
}