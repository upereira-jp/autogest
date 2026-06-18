// Testes unitários básicos do AutoGest.
//
// Foco na camada de cálculo (placeholders do mock) e na formatação — as
// telas dependem do SQLite (plugin nativo), que não roda em widget test
// sem um backend ffi; por isso não há smoke test de UI aqui.

import 'package:flutter_application_1/models/resumo_gastos.dart';
import 'package:flutter_application_1/services/autogest_service.dart';
import 'package:flutter_application_1/services/mock_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter_application_1/theme/formatters.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR', null));

  group('MockService devolve placeholders', () {
    const AutogestService service = MockService();

    test('números derivados são NaN', () {
      expect(service.consumoMedioGeral(const []).isNaN, isTrue);
      expect(service.obterKmAtual(const []).isNaN, isTrue);
      expect(service.custoPorKm(const [], 0, 0).isNaN, isTrue);
    });

    test('lista de alertas vem vazia', () {
      expect(service.gerarAlertas(const [], DateTime(2026), 30), isEmpty);
    });

    test('resumo de gastos vem zerado e com tamanhos corretos', () {
      final r = service.resumoGastos(const [], const []);
      expect(r.gastoPorMes.length, 12);
      expect(r.totalGeral, 0);
    });
  });

  group('Fmt', () {
    test('NaN vira traço', () {
      expect(Fmt.numero(double.nan), Fmt.placeholder);
      expect(Fmt.consumo(double.nan), '${Fmt.placeholder} km/L');
    });

    test('número real é formatado', () {
      expect(Fmt.consumo(12.5), contains('12,5'));
    });
  });

  test('ResumoGastos.zero tem 12 meses', () {
    expect(ResumoGastos.zero().gastoPorMes.length, 12);
  });
}
