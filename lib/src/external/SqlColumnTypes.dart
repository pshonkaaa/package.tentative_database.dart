import 'package:ientity/library.dart';

abstract class SqlColumnTypes {
  static const DATABASE_NAME = "sqlite";

  static const integer  = ColumnType(database: DATABASE_NAME, name: "integer", sinceVersion: "0.1", deprecatedVersion: "");
  static const text     = ColumnType(database: DATABASE_NAME, name: "text", sinceVersion: "0.1", deprecatedVersion: "");
}