
import 'package:ientity/library.dart';

import '../../abstract/table_request_result.dart';

class TablePushResult<T extends IEntity> extends TableRequestResult<T> {
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