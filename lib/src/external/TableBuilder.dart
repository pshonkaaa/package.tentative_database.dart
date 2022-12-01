import 'package:ientity/library.dart';

class TableBuilder {
  final String name;
  final List<EntityColumnInfo> keys = [];


  TableBuilder({
    required this.name,
    required EntityColumnInfo primaryKey,
  }) {
    keys.add(primaryKey);
  }
  
  TableBuilder insert(EntityColumnInfo column) {
    if(keys.where((e) => e.name == column.name).isNotEmpty)
      return this;
    keys.add(column);
    return this;
  }

  TableBuilder insertAll(List<EntityColumnInfo> columns) {
    for(final column in columns) insert(column);
    return this;
  }

  String toRawSql() {
    final sb = new StringBuffer();
    for(final o in keys) {
      sb.write("${o.name} ${o.type.name}");
      if(!o.isNullable)
        sb.write(" NOT NULL");
      if(o.defaultValue != null)
        sb.write(" DEFAULT '${o.defaultValue}'");
      if(o.isPrimaryKey)
        sb.write(" PRIMARY KEY");
      if(o.isAutoIncrement)
        sb.write(" AUTO_INCREMENT");
      sb.write(",");
    }

    var data = sb.toString();
    data = data.substring(0, data.length - 1); // удаляем последнюю запятую
    return "CREATE TABLE $name ($data)";
  }
}