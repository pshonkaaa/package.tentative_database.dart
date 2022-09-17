
import 'ITableRequestResult.dart';

class TableLoadResult<T, ID> extends ITableRequestResult<T> {
  final List<T> loaded = [];
  final List<T> stored = [];
  final List<ID> notLoaded = [];

  @override
  late final List<T> entities;
  
  void prepareList() {
    entities = [...loaded, ...stored];
  }
  
  TableLoadResult();
}