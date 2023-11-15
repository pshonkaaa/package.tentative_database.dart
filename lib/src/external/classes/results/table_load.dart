
import '../../abstract/table_request_result.dart';

class TableLoadResult<T> extends TableRequestResult<T> {
  final List<T> loaded = [];
  final List<T> stored = [];
  final List<int> notLoaded = [];

  @override
  late final List<T> entities;
  
  void prepareList() {
    entities = [...loaded, ...stored];
  }
  
  TableLoadResult();
}