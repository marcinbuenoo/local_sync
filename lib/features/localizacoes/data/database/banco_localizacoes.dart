import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class BancoLocalizacoes {
  BancoLocalizacoes._();

  static final BancoLocalizacoes instance = BancoLocalizacoes._();

  static const _nomeBanco = 'localizacoes.db';
  static const _versaoBanco = 1;

  Future<Database>? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = _abrirBanco();

    try {
      return await _database!;
    } catch (_) {
      _database = null;
      rethrow;
    }
  }

  Future<Database> _abrirBanco() async {
    final diretorio = await getDatabasesPath();
    final caminho = p.join(diretorio, _nomeBanco);

    return openDatabase(
      caminho,
      version: _versaoBanco,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE localizacoes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            precisao REAL NOT NULL,
            instante TEXT NOT NULL
          )
        ''');
      },
    );
  }
}
