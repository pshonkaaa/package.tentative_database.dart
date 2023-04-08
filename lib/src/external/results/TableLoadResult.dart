
import 'ITableRequestResult.dart';

class TableLoadResult<T> extends ITableRequestResult<T> {
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