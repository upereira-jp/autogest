import '../models/abastecimento.dart';
import '../models/alerta.dart';
import '../models/manutencao.dart';
import '../models/resumo_gastos.dart';
import 'autogest_service.dart';

/// Implementação **placeholder** da camada de cálculo (Fase 1).
///
/// Não calcula nada de verdade — quem calcula é o núcleo em C, que ainda
/// não existe. Os números derivados voltam como `double.nan` (a UI
/// formata `NaN` como "—", ver `formatters.dart`), o resumo vem zerado e
/// a lista de alertas vem vazia.
///
/// Será substituída pela `FfiService` (mesma interface) quando o C
/// compilar. A UI não muda.
class MockService implements AutogestService {
  const MockService();

  @override
  ResumoGastos resumoGastos(
    List<Abastecimento> abastecimentos,
    List<Manutencao> manutencoes,
  ) =>
      ResumoGastos.zero();

  @override
  double consumoMedioGeral(List<Abastecimento> abastecimentos) => double.nan;

  @override
  double kmPorLitroTrecho(double kmAtual, double kmAnterior, double litros) =>
      double.nan;

  @override
  double obterKmAtual(List<Abastecimento> abastecimentos) => double.nan;

  @override
  double custoPorKm(
    List<Abastecimento> abastecimentos,
    double kmInicio,
    double kmFim,
  ) =>
      double.nan;

  @override
  double gastoPeriodo(
    List<Abastecimento> abastecimentos,
    DateTime inicio,
    DateTime fim,
  ) =>
      double.nan;

  @override
  List<Alerta> gerarAlertas(
    List<Manutencao> manutencoes,
    DateTime hoje,
    int janelaAviso,
  ) =>
      const [];
}
