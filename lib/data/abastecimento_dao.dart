import '../models/abastecimento.dart';
import 'app_database.dart';

/// Acesso à tabela `abastecimento` (apenas INSERT e SELECT).
class AbastecimentoDao {
  const AbastecimentoDao(this._db);

  final AppDatabase _db;

  /// Insere um abastecimento e devolve o `id` gerado.
  Future<int> inserir(Abastecimento a) async {
    final db = await _db.database;
    return db.insert('abastecimento', a.toMap());
  }

  /// Lista todos os abastecimentos, do mais recente para o mais antigo
  /// (maior `id` primeiro).
  Future<List<Abastecimento>> listar() async {
    final db = await _db.database;
    final linhas = await db.query('abastecimento', orderBy: 'id DESC');
    return linhas.map(Abastecimento.fromMap).toList();
  }

  /// Km atual do veículo = maior `km` registrado (regra de persistência do
  /// briefing §6). Retorna `null` se ainda não há abastecimentos.
  ///
  /// É um fato bruto do banco — por isso fica na camada de dados e NÃO é
  /// um placeholder (diferente dos números derivados, que vêm do serviço).
  Future<double?> kmAtual() async {
    final db = await _db.database;
    final r = await db.rawQuery('SELECT MAX(km) AS km FROM abastecimento');
    return (r.first['km'] as num?)?.toDouble();
  }
}
