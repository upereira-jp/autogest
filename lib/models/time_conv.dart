/// Conversão entre [DateTime] (Dart) e timestamp Unix em **segundos** (int).
///
/// As datas são persistidas no SQLite como inteiro de segundos para casar
/// com o `time_t` do C e com a passagem por inteiro na ponte FFI.
library;

/// [DateTime] → segundos Unix (trunca milissegundos).
int dateTimeToUnix(DateTime data) => data.millisecondsSinceEpoch ~/ 1000;

/// Segundos Unix → [DateTime] local.
DateTime unixToDateTime(int segundos) =>
    DateTime.fromMillisecondsSinceEpoch(segundos * 1000);
