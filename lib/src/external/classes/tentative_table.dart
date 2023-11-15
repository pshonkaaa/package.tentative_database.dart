import 'package:ientity/library.dart';
import 'package:tentative_database/src/internal/interfaces/tentative_table.dart';
import 'package:tentative_database/src/internal/tentative_table_mixin.dart';

class TentativeTable<T extends BaseEntity> extends ITentativeTable<T> with TentativeTableMixin<T> {
  TentativeTable({
    required super.name,
    required super.columns,
    required super.database,
    required super.converter,
  });
}