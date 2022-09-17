import 'package:ientity/library.dart';

import 'TentativeDatabase.dart';

class TableBuilder {
  final String name;
  final List<_TableBuilderValue> keys = [];


  TableBuilder({
    required this.name,
    ColumnInfo primaryKey = TentativeDatabase.DEFAULT_TABLE_PRIMARY_KEY,
  }) {
    if(primaryKey.name.isNotEmpty)
      keys.add(_TableBuilderValue(primaryKey.name, primaryKey.type.name + " PRIMARY KEY"));
  }
  
  TableBuilder insert(String name, ColumnType type) {
    if(keys.where((e) => e.key == name).isNotEmpty)
      return this;
    keys.add(_TableBuilderValue(name, type.name));
    return this;
  }

  TableBuilder insertAll(List<ColumnInfo> columns) {
    for(final column in columns) insert(column.name, column.type);
    return this;
  }

  String toRawSql() {
    final sb = new StringBuffer();
    for(final o in keys) {
      sb.write("${o.key} ${o.value},");
    }

    var data = sb.toString();
    data = data.substring(0, data.length - 1); // удаляем последнюю запятую
    return "CREATE TABLE $name ($data)";
  }
}



class _TableBuilderValue {
  final String key;
  final String value;
  const _TableBuilderValue(this.key, this.value);
}
