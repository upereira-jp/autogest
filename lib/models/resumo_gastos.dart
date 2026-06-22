import 'enums.dart';

/// Espelha a struct `ResumoGastos` do C (`native/autogest.h`).
///
/// Valor *calculado* (`calcular_resumo_gastos` no C). Não é persistido.
///  - [gastoPorMes]       tem 12 posições (índice 0 = janeiro);
///  - [gastoPorCategoria] tem [TipoManutencao.values.length] posições,
///    indexadas pelo `index` do tipo.
class ResumoGastos {
  const ResumoGastos({
    required this.gastoPorMes,
    required this.gastoPorCategoria,
    required this.totalAbastecimentos,
    required this.totalManutencoes,
    required this.totalGeral,
    required this.gastoPorMesCategoria,
  });

  final List<double> gastoPorMes;
  final List<double> gastoPorCategoria;
  final double totalAbastecimentos;
  final double totalManutencoes;
  final double totalGeral;
  final List<List<double>> gastoPorMesCategoria;
  /// Resumo zerado — usado pelo MockService como placeholder.
  factory ResumoGastos.zero() => ResumoGastos(
        gastoPorMes: List<double>.filled(12, 0),
        gastoPorCategoria:
            List<double>.filled(TipoManutencao.values.length, 0),
        totalAbastecimentos: 0,
        totalManutencoes: 0,
        totalGeral: 0,


        gastoPorMesCategoria: List.generate(
          12,
          (_) => List<double>.filled(
            TipoManutencao.values.length + 1,
            0,
          ),
        ),

      );
}
