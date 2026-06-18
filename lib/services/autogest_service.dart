import '../models/abastecimento.dart';
import '../models/alerta.dart';
import '../models/manutencao.dart';
import '../models/resumo_gastos.dart';

/// Contrato da camada de cálculo — os números *derivados* do app.
///
/// É a fronteira da "regra de ouro": a UI depende SÓ desta interface,
/// nunca da implementação. Hoje existe a [MockService] (placeholders);
/// quando o núcleo em C compilar, entra a `FfiService` com a MESMA
/// interface — trocar mock ↔ ffi é uma única linha em `main.dart`,
/// e a UI não muda.
///
/// Cada método corresponde a uma função do `native/autogest.h`
/// (Grupos 3 — cálculos — e 4 — motor de alertas).
abstract class AutogestService {
  /// `calcular_resumo_gastos` — gasto por mês/categoria e totais.
  ResumoGastos resumoGastos(
    List<Abastecimento> abastecimentos,
    List<Manutencao> manutencoes,
  );

  /// `calcular_km_por_litro_geral` — consumo médio geral (km/L).
  double consumoMedioGeral(List<Abastecimento> abastecimentos);

  /// `calcular_km_por_litro` — km/L de um trecho isolado.
  double kmPorLitroTrecho(double kmAtual, double kmAnterior, double litros);

  /// `obter_km_atual` — maior km registrado nos abastecimentos.
  double obterKmAtual(List<Abastecimento> abastecimentos);

  /// `calcular_custo_por_km` — custo por km num intervalo de hodômetro.
  double custoPorKm(
    List<Abastecimento> abastecimentos,
    double kmInicio,
    double kmFim,
  );

  /// `calcular_gasto_periodo` — total gasto entre duas datas.
  double gastoPeriodo(
    List<Abastecimento> abastecimentos,
    DateTime inicio,
    DateTime fim,
  );

  /// `gerar_lista_alertas` — alertas de manutenção classificados por status.
  ///
  /// [janelaAviso] = dias de antecedência para o status "próximo"
  /// (padrão do C: `JANELA_AVISO_PADRAO` = 30).
  List<Alerta> gerarAlertas(
    List<Manutencao> manutencoes,
    DateTime hoje,
    int janelaAviso,
  );
}
