import 'package:ientity/library.dart';

class TableBuilder<PARAM> {
  final String name;
  final List<ColumnInfo<PARAM>> keys = [];


  TableBuilder({
    required this.name,
    required ColumnInfo<PARAM> primaryKey,
  }) {
    keys.add(primaryKey);
  }
  
  TableBuilder insert(ColumnInfo<PARAM> column) {
    if(keys.where((e) => e.name == column.name).isNotEmpty)
      return this;
    keys.add(column);
    return this;
  }

  TableBuilder insertAll(List<ColumnInfo<PARAM>> columns) {
    for(final column in columns) insert(column);
    return this;
  }

  String toRawSql() {
    final sb = new StringBuffer();
    for(final o in keys) {
      sb.write("${o.name} ${o.type.name}");
      if(o.primaryKey)
        sb.write(" PRIMARY KEY");
      sb.write(",");
    }

    var data = sb.toString();
    data = data.substring(0, data.length - 1); // удаляем последнюю запятую
    return "CREATE TABLE $name ($data)";
  }
}