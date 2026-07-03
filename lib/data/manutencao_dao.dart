import '../models/manutencao.dart';
import 'app_database.dart';

/// Acesso à tabela `manutencao`.
class ManutencaoDao {
  const ManutencaoDao(this._db);

  final AppDatabase _db;

  /// Insere uma manutenção e devolve o `id` gerado.
  Future<int> inserir(Manutencao m) async {
    final db = await _db.database;
    return db.insert('manutencao', m.toMap());
  }

  /// Atualiza uma manutenção existente.
  Future<int> atualizar(Manutencao m) async {
    final id = m.id;
    if (id == null) {
      throw ArgumentError('Manutenção sem id não pode ser atualizada.');
    }

    final db = await _db.database;
    return db.update('manutencao', m.toMap(), where: 'id = ?', whereArgs: [id]);
  }

  /// Lista todas as manutenções, da mais recente para a mais antiga
  /// (maior `id` primeiro).
  Future<List<Manutencao>> listar() async {
    final db = await _db.database;
    final linhas = await db.query('manutencao', orderBy: 'id DESC');
    return linhas.map(Manutencao.fromMap).toList();
  }
}
