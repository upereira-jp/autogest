import 'package:sqflite_common/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Web: usa o sqflite sobre WASM (`sqflite_common_ffi_web`).
///
/// Requer os artefatos em `web/` (sqlite3.wasm + worker), gerados uma vez por:
///   dart run sqflite_common_ffi_web:setup
void initDatabaseFactory() {
  databaseFactory = databaseFactoryFfiWeb;
}
