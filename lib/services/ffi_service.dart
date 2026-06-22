import '../models/abastecimento.dart';
import '../models/alerta.dart';
import '../models/manutencao.dart';
import '../models/resumo_gastos.dart';
import 'autogest_service.dart';
import 'dart:ffi';
import 'dart:io';

import '../src/ffi/autogest_bindings.dart' as native;
import 'package:ffi/ffi.dart';
import '../models/enums.dart';

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
  FfiService() : _bindings = native.AutogestBindings(_abrirBiblioteca());

  Pointer<native.Abastecimento> _alocarAbastecimentos(
    List<Abastecimento> abastecimentos,
  ) {
    // Alocamos uma posição mesmo para a lista vazia.
    // O C receberá total = 0 e ignorará essa posição.
    final quantidade = abastecimentos.isEmpty ? 1 : abastecimentos.length;

    final lista = calloc<native.Abastecimento>(quantidade);

    for (var i = 0; i < abastecimentos.length; i++) {
      final origem = abastecimentos[i];
      final destino = (lista + i).ref;

      destino.id = origem.id ?? 0;
      destino.data = origem.data.millisecondsSinceEpoch ~/ 1000;
      destino.litros = origem.litros;
      destino.valor_total = origem.valorTotal;
      destino.km = origem.km;

      // O campo combustível não é usado pelos cálculos atuais.
      // Como usamos calloc, ele já começa preenchido com zeros.
    }

    return lista;
  }

  Pointer<native.Manutencao> _alocarManutencoes(List<Manutencao> manutencoes) {
    final quantidade = manutencoes.isEmpty ? 1 : manutencoes.length;

    final lista = calloc<native.Manutencao>(quantidade);

    for (var i = 0; i < manutencoes.length; i++) {
      final origem = manutencoes[i];
      final destino = (lista + i).ref;

      destino.id = origem.id ?? 0;
      destino.tipoAsInt = origem.tipo.index;
      destino.data_realizada = origem.data.millisecondsSinceEpoch ~/ 1000;
      destino.custo = origem.custo;
      destino.km_ultima = origem.kmUltima;
      destino.intervalo_km = origem.intervaloKm;
      destino.intervalo_dias = origem.intervaloDias;
      destino.criterioAsInt = origem.criterio.index;

      // A descrição não é usada pelo motor de alertas.
      // O calloc já deixou esse campo zerado.
    }

    return lista;
  }

  final native.AutogestBindings _bindings;

  static DynamicLibrary _abrirBiblioteca() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libautogest.so');
    }

    throw UnsupportedError(
      'FfiService disponível apenas no Android por enquanto.',
    );
  }

  @override
  ResumoGastos resumoGastos(
    List<Abastecimento> abastecimentos,
    List<Manutencao> manutencoes,
  ) {
    final listaAbastecimentos = _alocarAbastecimentos(abastecimentos);
    final listaManutencoes = _alocarManutencoes(manutencoes);

    try {
      final resumoNativo = _bindings.calcular_resumo_gastos(
        listaAbastecimentos,
        abastecimentos.length,
        listaManutencoes,
        manutencoes.length,
      );

      final gastoPorMes = List<double>.generate(
        12,
        (mes) => resumoNativo.gasto_por_mes[mes],
      );

      final gastoPorCategoria = List<double>.generate(
        TipoManutencao.values.length,
        (categoria) => resumoNativo.gasto_por_categoria[categoria],
      );

      final gastoPorMesCategoria = List<List<double>>.generate(
        12,
        (mes) => List<double>.generate(
          TipoManutencao.values.length + 1,
          (categoria) => resumoNativo.gasto_por_mes_categoria[mes][categoria],
        ),
      );

      return ResumoGastos(
        gastoPorMes: gastoPorMes,
        gastoPorCategoria: gastoPorCategoria,
        gastoPorMesCategoria: gastoPorMesCategoria,
        totalAbastecimentos: resumoNativo.total_abastecimentos,
        totalManutencoes: resumoNativo.total_manutencoes,
        totalGeral: resumoNativo.total_geral,
      );
    } finally {
      calloc.free(listaAbastecimentos);
      calloc.free(listaManutencoes);
    }
  }

  @override
  double consumoMedioGeral(List<Abastecimento> abastecimentos) {
    final lista = _alocarAbastecimentos(abastecimentos);

    try {
      return _bindings.calcular_km_por_litro_geral(
        lista,
        abastecimentos.length,
      );
    } finally {
      calloc.free(lista);
    }
  }

  @override
  double kmPorLitroTrecho(double kmAtual, double kmAnterior, double litros) {
    return _bindings.calcular_km_por_litro(kmAtual, kmAnterior, litros);
  }

  @override
  double obterKmAtual(List<Abastecimento> abastecimentos) {
    final lista = _alocarAbastecimentos(abastecimentos);

    try {
      return _bindings.obter_km_atual(lista, abastecimentos.length);
    } finally {
      calloc.free(lista);
    }
  }

  @override
  double custoPorKm(
    List<Abastecimento> abastecimentos,
    double kmInicio,
    double kmFim,
  ) {
    final lista = _alocarAbastecimentos(abastecimentos);

    try {
      return _bindings.calcular_custo_por_km(
        lista,
        abastecimentos.length,
        kmInicio,
        kmFim,
      );
    } finally {
      calloc.free(lista);
    }
  }

  @override
  double gastoPeriodo(
    List<Abastecimento> abastecimentos,
    DateTime inicio,
    DateTime fim,
  ) {
    final lista = _alocarAbastecimentos(abastecimentos);

    try {
      return _bindings.calcular_gasto_periodo(
        lista,
        abastecimentos.length,
        inicio.millisecondsSinceEpoch ~/ 1000,
        fim.millisecondsSinceEpoch ~/ 1000,
      );
    } finally {
      calloc.free(lista);
    }
  }

  @override
  List<Alerta> gerarAlertas(
    List<Manutencao> manutencoes,
    DateTime hoje,
    int janelaAviso,
  ) {
    final lista = _alocarManutencoes(manutencoes);
    final totalAlertas = calloc<Int>();

    try {
      final alertasNativos = _bindings.gerar_lista_alertas(
        lista,
        manutencoes.length,
        hoje.millisecondsSinceEpoch ~/ 1000,
        janelaAviso,
        totalAlertas,
      );

      try {
        final resultado = <Alerta>[];

        for (var i = 0; i < totalAlertas.value; i++) {
          final alertaNativo = (alertasNativos + i).ref;

          resultado.add(
            Alerta(
              manutencaoId: alertaNativo.id_manutencao,
              tipo: TipoManutencao.values[alertaNativo.tipoAsInt],
              status: StatusAlerta.values[alertaNativo.statusAsInt],
              diasRestantes: alertaNativo.dias_restantes,
              dataProxima: DateTime.fromMillisecondsSinceEpoch(
                alertaNativo.data_proxima * 1000,
              ),
            ),
          );
        }

        return resultado;
      } finally {
        if (alertasNativos.address != 0) {
          _bindings.liberar_lista_alertas(alertasNativos);
        }
      }
    } finally {
      calloc.free(totalAlertas);
      calloc.free(lista);
    }
  }
}
