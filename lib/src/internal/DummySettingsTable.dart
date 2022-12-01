import 'package:itable_ex/library.dart';
import 'package:logger_ex/library.dart';
import 'package:tentative_database/src/external/SettingsTable/SettingsTable.dart';

class DummySettingsTable extends SettingsTable {
  DummySettingsTable({
    required String name,
    required DatabaseExecutor database,
  }) : super(
    name: name,
    columns: [],
    database: database,
  );

  @override
  Future<void> initState() {
    super.initState();
    throw(_getException());
  }

  @override
  Future<void> dispose() {
    super.dispose();
    throw(_getException());
  }

  @override
  Future<String?> get(String name) async {
    throw(_getException());
  }

  @override
  Future<int> getInteger(String name, [int def = -1]) async {
    throw(_getException());
  }
  
  @override
  Future<bool> getBoolean(String name, [bool def = false]) async {
    throw(_getException());
  }
  
  
  @override
  Future<bool> set(
    String name,
    dynamic value, {
      LoggerContext? logger,
  }) async {
    throw(_getException());
  }
  
  @override
  Future<bool> setInteger(String name, int value) async {
    throw(_getException());
  }
  
  @override
  Future<bool> setBoolean(String name, bool value) async {
    throw(_getException());
  }
  
  @override
  Future<Map<String, dynamic>> values() {
    throw(_getException());
  }

  Exception _getException() {
    return Exception("Table '$name' havent settings table");
  }
}