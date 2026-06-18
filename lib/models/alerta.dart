import 'enums.dart';

/// Espelha a struct `Alerta` do C (`native/autogest.h`).
///
/// Não é persistido: é um valor *calculado* pelo motor de alertas
/// (`gerar_lista_alertas` no C → [AutogestService.gerarAlertas]).
class Alerta {
  const Alerta({
    required this.manutencaoId,
    required this.tipo,
    required this.status,
    required this.diasRestantes,
    required this.dataProxima,
  });

  final int manutencaoId;
  final TipoManutencao tipo;
  final StatusAlerta status;
  final int diasRestantes;
  final DateTime dataProxima;
}
