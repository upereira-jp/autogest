import 'package:flutter/foundation.dart';

import '../data/abastecimento_dao.dart';
import '../models/abastecimento.dart';
import '../services/autogest_service.dart';

/// Estado da tela de Abastecimentos: junta o DAO (registros brutos do
/// SQLite) com o [AutogestService] (km/L derivado de cada trecho).
class AbastecimentoProvider extends ChangeNotifier {
  AbastecimentoProvider(this._dao, this._service) {
    carregar();
  }

  final AbastecimentoDao _dao;
  final AutogestService _service;

  List<Abastecimento> _itens = const [];
  Map<int, double> _kmPorLitro = const {}; // id do abastecimento -> km/L
  bool _carregando = true;

  /// Abastecimentos, do mais recente para o mais antigo.
  List<Abastecimento> get itens => _itens;
  bool get carregando => _carregando;

  /// Maior km já registrado — base para validar "km ≥ último registrado".
  /// `null` quando ainda não há abastecimentos.
  double? get ultimoKm =>
      _itens.isEmpty ? null : _itens.map((a) => a.km).reduce((a, b) => a > b ? a : b);

  /// km/L do trecho daquele abastecimento (derivado → placeholder no mock).
  double kmPorLitroDe(Abastecimento a) => _kmPorLitro[a.id] ?? double.nan;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    _itens = await _dao.listar();
    _kmPorLitro = _calcularKmPorLitro(_itens);

    _carregando = false;
    notifyListeners();
  }

  Future<void> adicionar(Abastecimento a) async {
    await _dao.inserir(a);
    await carregar();
  }

  /// Calcula o km/L de cada trecho via serviço. O trecho de um
  /// abastecimento vai do anterior (km menor) até ele; o primeiro registro
  /// não tem trecho. No mock o serviço devolve `NaN` → a UI mostra "—".
  Map<int, double> _calcularKmPorLitro(List<Abastecimento> itens) {
    final asc = [...itens]..sort((a, b) => a.km.compareTo(b.km));
    final mapa = <int, double>{};
    for (var i = 0; i < asc.length; i++) {
      final atual = asc[i];
      final chave = atual.id;
      if (chave == null) continue;
      if (i == 0) {
        mapa[chave] = double.nan; // sem trecho anterior
      } else {
        mapa[chave] = _service.kmPorLitroTrecho(
          atual.km,
          asc[i - 1].km,
          atual.litros,
        );
      }
    }
    return mapa;
  }
}
