import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Abre (e cria, na primeira vez) o banco SQLite local do AutoGest.
///
/// Regras de persistência (ver briefing §6):
///  - três tabelas: `veiculo`, `abastecimento`, `manutencao`;
///  - **imutável** — a UI só faz INSERT e SELECT, nunca UPDATE/DELETE
///    (editar = inserir uma nova linha; o registro mais recente é o de
///    maior `id`);
///  - datas em INTEGER (segundos Unix) para casar com o `time_t` do C.
///
/// O schema espelha as structs do `native/autogest.h` e foi desenhado
/// para **não mudar** quando o núcleo em C entrar via FFI.
class AppDatabase {
  AppDatabase._();

  /// Instância única compartilhada pelos DAOs.
  static final AppDatabase instance = AppDatabase._();

  static const _nomeArquivo = 'autogest.db';
  static const _versao = 1;

  Database? _db;

  /// Retorna o banco aberto, abrindo-o sob demanda.
  Future<Database> get database async => _db ??= await _abrir();

  Future<Database> _abrir() async {
    final dir = await getDatabasesPath();
    final caminho = p.join(dir, _nomeArquivo);
    return openDatabase(caminho, version: _versao, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE veiculo (
        id INTEGER PRIMARY KEY,
        nome TEXT, placa TEXT, marca TEXT, modelo TEXT, ano INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE abastecimento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        data INTEGER, litros REAL, valor_total REAL, km REAL, combustivel TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE manutencao (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo INTEGER, descricao TEXT, data INTEGER, custo REAL,
        km_ultima REAL, intervalo_km REAL, intervalo_dias INTEGER, criterio INTEGER
      )
    ''');
  }
}
