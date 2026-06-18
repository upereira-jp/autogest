import '../models/veiculo.dart';
import 'app_database.dart';

/// Acesso à tabela `veiculo` (apenas INSERT e SELECT).
///
/// O km atual do veículo NÃO mora aqui — é derivado do maior `km` da
/// tabela de abastecimentos (ver [AutogestService.obterKmAtual]).
class VeiculoDao {
  const VeiculoDao(this._db);

  final AppDatabase _db;

  /// Insere/registra um veículo e devolve o `id` gerado.
  Future<int> inserir(Veiculo v) async {
    final db = await _db.database;
    return db.insert('veiculo', v.toMap());
  }

  /// Lista os veículos cadastrados (maior `id` primeiro).
  Future<List<Veiculo>> listar() async {
    final db = await _db.database;
    final linhas = await db.query('veiculo', orderBy: 'id DESC');
    return linhas.map(Veiculo.fromMap).toList();
  }

  /// Veículo mais recente, ou `null` se nenhum foi cadastrado.
  Future<Veiculo?> maisRecente() async {
    final db = await _db.database;
    final linhas = await db.query('veiculo', orderBy: 'id DESC', limit: 1);
    return linhas.isEmpty ? null : Veiculo.fromMap(linhas.first);
  }
}
