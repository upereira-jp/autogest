import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Plataformas nativas (`dart:io`).
///
/// Em desktop (Windows/Linux/macOS) o `sqflite` padrão não tem implementação,
/// então usamos a FFI (`sqflite_common_ffi`). Em Android/iOS o plugin padrão
/// funciona — não tocamos no `databaseFactory`.
void initDatabaseFactory() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
