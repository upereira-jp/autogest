/// Seleciona o `databaseFactory` do sqflite conforme a plataforma.
///
/// - **Android / iOS**: usam o plugin `sqflite` padrão — nada a fazer.
/// - **Desktop (Windows / Linux / macOS)**: `sqflite_common_ffi`.
/// - **Web**: `sqflite_common_ffi_web`.
///
/// A escolha é feita por *imports condicionais*: cada alvo importa só o
/// arquivo compatível, então a web nunca puxa `dart:ffi`/`dart:io` e o
/// desktop nunca puxa o pacote web. Chame [initDatabaseFactory] uma vez,
/// no início do `main()`, antes de abrir o banco.
library;

export 'db_init_stub.dart'
    if (dart.library.io) 'db_init_io.dart'
    if (dart.library.html) 'db_init_web.dart';
