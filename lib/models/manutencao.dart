import 'enums.dart';
import 'time_conv.dart';

/// Espelha a struct `Manutencao` do C (`native/autogest.h`).
///
/// Campos dormentes na Fase 1 (existem para casar com o header):
///  - [kmUltima]    → preenchido com o km atual no momento do cadastro;
///  - [intervaloKm] → reservado para a Fase 2 (default 0);
///  - [criterio]    → sempre [CriterioAlerta.porTempo] por enquanto.
///
/// [id] é nulo antes de inserir (AUTOINCREMENT). [data] (= `data_realizada`
/// no C) trafega no banco como segundos Unix.
class Manutencao {
  const Manutencao({
    this.id,
    required this.tipo,
    required this.descricao,
    required this.data,
    required this.custo,
    required this.intervaloDias,
    this.kmUltima = 0,
    this.intervaloKm = 0,
    this.criterio = CriterioAlerta.porTempo,
  });

  final int? id;
  final TipoManutencao tipo;
  final String descricao;
  final DateTime data;
  final double custo;
  final int intervaloDias;
  final double kmUltima;
  final double intervaloKm;
  final CriterioAlerta criterio;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'tipo': tipo.index,
        'descricao': descricao,
        'data': dateTimeToUnix(data),
        'custo': custo,
        'km_ultima': kmUltima,
        'intervalo_km': intervaloKm,
        'intervalo_dias': intervaloDias,
        'criterio': criterio.index,
      };

  factory Manutencao.fromMap(Map<String, Object?> map) => Manutencao(
        id: map['id'] as int?,
        tipo: TipoManutencao.values[(map['tipo'] as int?) ?? 0],
        descricao: map['descricao'] as String? ?? '',
        data: unixToDateTime((map['data'] as int?) ?? 0),
        custo: (map['custo'] as num?)?.toDouble() ?? 0,
        intervaloDias: (map['intervalo_dias'] as int?) ?? 0,
        kmUltima: (map['km_ultima'] as num?)?.toDouble() ?? 0,
        intervaloKm: (map['intervalo_km'] as num?)?.toDouble() ?? 0,
        criterio: CriterioAlerta.values[(map['criterio'] as int?) ?? 0],
      );
}
