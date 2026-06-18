import 'time_conv.dart';

/// Espelha a struct `Abastecimento` do C (`native/autogest.h`).
///
/// [id] é nulo antes de inserir (a coluna é AUTOINCREMENT no SQLite).
/// [data] trafega no banco como segundos Unix (ver [time_conv]).
class Abastecimento {
  const Abastecimento({
    this.id,
    required this.data,
    required this.litros,
    required this.valorTotal,
    required this.km,
    required this.combustivel,
  });

  final int? id;
  final DateTime data;
  final double litros;
  final double valorTotal;
  final double km;
  final String combustivel;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'data': dateTimeToUnix(data),
        'litros': litros,
        'valor_total': valorTotal,
        'km': km,
        'combustivel': combustivel,
      };

  factory Abastecimento.fromMap(Map<String, Object?> map) => Abastecimento(
        id: map['id'] as int?,
        data: unixToDateTime((map['data'] as int?) ?? 0),
        litros: (map['litros'] as num?)?.toDouble() ?? 0,
        valorTotal: (map['valor_total'] as num?)?.toDouble() ?? 0,
        km: (map['km'] as num?)?.toDouble() ?? 0,
        combustivel: map['combustivel'] as String? ?? '',
      );
}
