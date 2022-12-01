import 'package:ientity/library.dart';

abstract class SqliteColumnTypes {
  static const DATABASE_NAME = "sqlite";

  static const ALL = [
    integer,
    real,
    text,
    blob,
  ];

  static const integer  = ColumnType(database: DATABASE_NAME, name: "integer", sinceVersion: "0.1", deprecatedVersion: "");
  static const real     = ColumnType(database: DATABASE_NAME, name: "real", sinceVersion: "0.1", deprecatedVersion: "");
  static const text     = ColumnType(database: DATABASE_NAME, name: "text", sinceVersion: "0.1", deprecatedVersion: "");
  static const blob     = ColumnType(database: DATABASE_NAME, name: "blob", sinceVersion: "0.1", deprecatedVersion: "");
}