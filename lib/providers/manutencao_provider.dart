import 'package:flutter/foundation.dart';

import '../data/abastecimento_dao.dart';
import '../data/manutencao_dao.dart';
import '../models/alerta.dart';
import '../models/manutencao.dart';
import '../services/autogest_service.dart';

/// Janela de antecedência (dias) do status "próximo" — `JANELA_AVISO_PADRAO`
/// do header C.
const int kJanelaAvisoPadrao = 30;

/// Estado da tela de Manutenções: lista de manutenções realizadas (SQLite)
/// + alertas classificados pelo [AutogestService] (derivado → placeholder).
class ManutencaoProvider extends ChangeNotifier {
  ManutencaoProvider(this._dao, this._abastecimentoDao, this._service) {
    carregar();
  }

  final ManutencaoDao _dao;
  final AbastecimentoDao _abastecimentoDao;
  final AutogestService _service;

  List<Manutencao> _itens = const [];
  List<Alerta> _alertas = const [];
  bool _carregando = true;

  /// Manutenções, da mais recente para a mais antiga.
  List<Manutencao> get itens => _itens;

  /// Alertas (vazio no mock até o núcleo C entrar).
  List<Alerta> get alertas => _alertas;
  bool get carregando => _carregando;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    _itens = await _dao.listar();
    _alertas = _service.gerarAlertas(_itens, DateTime.now(), kJanelaAvisoPadrao);

    _carregando = false;
    notifyListeners();
  }

  /// Insere a manutenção preenchendo o campo dormente `km_ultima` com o km
  /// atual do veículo (maior km dos abastecimentos), conforme o header C.
  Future<void> adicionar(Manutencao m) async {
    final kmAtual = await _abastecimentoDao.kmAtual() ?? 0;
    final completa = Manutencao(
      tipo: m.tipo,
      descricao: m.descricao,
      data: m.data,
      custo: m.custo,
      intervaloDias: m.intervaloDias,
      kmUltima: kmAtual,
    );
    await _dao.inserir(completa);
    await carregar();
  }
}
