import '../models/abastecimento.dart';
import '../models/alerta.dart';
import '../models/manutencao.dart';
import '../models/resumo_gastos.dart';
import 'autogest_service.dart';

/// Implementação **futura** da camada de cálculo, ligada ao núcleo em C
/// via FFI. Esqueleto pronto para a Fase 2 — ainda NÃO implementada.
///
/// Passo a passo quando o backend compilar a `libautogest`:
///  1. `dart run ffigen` → gera `lib/src/ffi/autogest_bindings.dart`;
///  2. carregar a biblioteca (`DynamicLibrary.open(...)`) e instanciar
///     os bindings;
///  3. em cada método abaixo: converter as listas Dart para os arrays C
///     (malloc/Pointer), chamar a função indicada no comentário `// ffi ->`,
///     ler o retorno e liberar a memória (incl. `liberar_lista_alertas`);
///  4. trocar `MockService()` por `FfiService()` no `main.dart` — um ponto só.
///
/// A interface é idêntica à da [MockService]; a UI não percebe a troca.
class FfiService implements AutogestService {
  const FfiService();

  @override
  ResumoGastos resumoGastos(
    List<Abastecimento> abastecimentos,
    List<Manutencao> manutencoes,
  ) {
    // ffi -> calcular_resumo_gastos(abast, total_abast, manut, total_manut)
    throw UnimplementedError('FfiService.resumoGastos: pendente do núcleo C');
  }

  @override
  double consumoMedioGeral(List<Abastecimento> abastecimentos) {
    // ffi -> calcular_km_por_litro_geral(lista, total)
    throw UnimplementedError(
        'FfiService.consumoMedioGeral: pendente do núcleo C');
  }

  @override
  double kmPorLitroTrecho(double kmAtual, double kmAnterior, double litros) {
    // ffi -> calcular_km_por_litro(km_atual, km_anterior, litros)
    throw UnimplementedError(
        'FfiService.kmPorLitroTrecho: pendente do núcleo C');
  }

  @override
  double obterKmAtual(List<Abastecimento> abastecimentos) {
    // ffi -> obter_km_atual(lista, total)
    throw UnimplementedError('FfiService.obterKmAtual: pendente do núcleo C');
  }

  @override
  double custoPorKm(
    List<Abastecimento> abastecimentos,
    double kmInicio,
    double kmFim,
  ) {
    // ffi -> calcular_custo_por_km(lista, total, km_inicio, km_fim)
    throw UnimplementedError('FfiService.custoPorKm: pendente do núcleo C');
  }

  @override
  double gastoPeriodo(
    List<Abastecimento> abastecimentos,
    DateTime inicio,
    DateTime fim,
  ) {
    // ffi -> calcular_gasto_periodo(lista, total, inicio, fim)
    throw UnimplementedError('FfiService.gastoPeriodo: pendente do núcleo C');
  }

  @override
  List<Alerta> gerarAlertas(
    List<Manutencao> manutencoes,
    DateTime hoje,
    int janelaAviso,
  ) {
    // ffi -> gerar_lista_alertas(manut, total, hoje, janela, &total_alertas)
    //        ...e depois liberar_lista_alertas(lista)
    throw UnimplementedError('FfiService.gerarAlertas: pendente do núcleo C');
  }
}
