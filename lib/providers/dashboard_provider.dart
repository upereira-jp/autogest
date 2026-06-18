import 'package:flutter/foundation.dart';

import '../data/abastecimento_dao.dart';
import '../data/manutencao_dao.dart';
import '../data/veiculo_dao.dart';
import '../models/alerta.dart';
import '../models/veiculo.dart';
import '../services/autogest_service.dart';
import 'manutencao_provider.dart' show kJanelaAvisoPadrao;

/// Estado do dashboard (Início). Combina os registros brutos com os
/// números derivados do [AutogestService].
///
/// Importante: `km atual` e o nome/modelo do veículo são fatos brutos do
/// banco (mostrados de verdade). Já consumo médio, gasto do mês, custo/km
/// e o alerta resumido vêm do serviço → "—" enquanto o núcleo C não entra.
class DashboardProvider extends ChangeNotifier {
  DashboardProvider(
    this._veiculoDao,
    this._abastecimentoDao,
    this._manutencaoDao,
    this._service,
  ) {
    carregar();
  }

  final VeiculoDao _veiculoDao;
  final AbastecimentoDao _abastecimentoDao;
  final ManutencaoDao _manutencaoDao;
  final AutogestService _service;

  Veiculo? _veiculo;
  double? _kmAtual;
  double _consumoMedio = double.nan;
  double _gastoMes = double.nan;
  double _custoPorKm = double.nan;
  List<Alerta> _alertas = const [];
  bool _carregando = true;

  Veiculo? get veiculo => _veiculo;

  /// Km atual (maior km dos abastecimentos), `null` se ainda não há registro.
  double? get kmAtual => _kmAtual;

  /// Consumo médio geral (km/L) — derivado → "—" no mock.
  double get consumoMedio => _consumoMedio;

  /// Gasto do mês corrente — derivado → "—" no mock.
  double get gastoMes => _gastoMes;

  /// Custo por km — derivado → "—" no mock.
  double get custoPorKm => _custoPorKm;
  bool get carregando => _carregando;

  /// Alerta mais urgente (próxima manutenção), ou `null` se não há alertas.
  Alerta? get proximoAlerta => _alertas.isEmpty ? null : _alertas.first;

  Future<void> carregar() async {
    _carregando = true;
    notifyListeners();

    _veiculo = await _garantirVeiculo();
    _kmAtual = await _abastecimentoDao.kmAtual();

    final abastecimentos = await _abastecimentoDao.listar();
    final manutencoes = await _manutencaoDao.listar();

    final agora = DateTime.now();
    final inicioMes = DateTime(agora.year, agora.month);
    final fimMes = DateTime(agora.year, agora.month + 1)
        .subtract(const Duration(seconds: 1));

    _consumoMedio = _service.consumoMedioGeral(abastecimentos);
    _gastoMes = _service.gastoPeriodo(abastecimentos, inicioMes, fimMes);
    _custoPorKm = _service.custoPorKm(abastecimentos, 0, _kmAtual ?? 0);
    _alertas =
        _service.gerarAlertas(manutencoes, agora, kJanelaAvisoPadrao);

    _carregando = false;
    notifyListeners();
  }

  /// Substitui o veículo cadastrado (insere uma nova linha — padrão imutável).
  Future<void> salvarVeiculo(Veiculo v) async {
    await _veiculoDao.inserir(v);
    await carregar();
  }

  /// Garante que exista um veículo: na primeira execução cria um padrão
  /// editável pelo usuário no cabeçalho do dashboard.
  Future<Veiculo> _garantirVeiculo() async {
    final atual = await _veiculoDao.maisRecente();
    if (atual != null) return atual;
    const padrao = Veiculo(
      nome: 'Meu carro',
      placa: '',
      marca: '',
      modelo: '',
      ano: 0,
    );
    await _veiculoDao.inserir(padrao);
    return padrao;
  }
}
