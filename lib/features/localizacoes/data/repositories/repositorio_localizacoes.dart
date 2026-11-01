import '../../models/localizacao.dart';
import '../database/banco_localizacoes.dart';

class RepositorioLocalizacoes {
  RepositorioLocalizacoes({BancoLocalizacoes? banco})
    : _banco = banco ?? BancoLocalizacoes.instance;

  final BancoLocalizacoes _banco;

  Future<int> inserir(Localizacao localizacao) async {
    final db = await _banco.database;
    final dados = localizacao.toMap()..remove('id');

    return db.insert('localizacoes', dados);
  }

  Future<List<Localizacao>> buscarUltimas({int limite = 100}) async {
    final db = await _banco.database;

    final registros = await db.query(
      'localizacoes',
      orderBy: 'instante DESC',
      limit: limite,
    );

    return registros.map(Localizacao.fromMap).toList();
  }

  Future<int> limpar() async {
    final db = await _banco.database;
    return db.delete('localizacoes');
  }
}
