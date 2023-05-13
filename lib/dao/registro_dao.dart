import '../database/database_provider.dart';
import '../model/ponto_eletronico.dart';

class RegistroDao {

  final databaseProvider = DatabaseProvider.instance;



  Future<bool> salvar(PontoEletronico pe) async {
    final database = await databaseProvider.database;
    final valores = pe.toMap();
    if (pe.id == 0) {
      pe.id = await database.insert(PontoEletronico.nomeTabela, valores);
      return true;
    } else {
      final registrosAtualizados = await database.update(
        PontoEletronico.nomeTabela,
        valores,
        where: '${PontoEletronico.campoId} = ?',
        whereArgs: [pe.id],
      );
      return registrosAtualizados > 0;
    }
  }

  Future<bool> remover(int id) async {
    final database = await databaseProvider.database;
    final registrosAtualizados = await database.delete(
      PontoEletronico.nomeTabela,
      where: '${PontoEletronico.campoId} = ?',
      whereArgs: [id],
    );
    return registrosAtualizados > 0;
  }


  Future<List<PontoEletronico>> listar() async {
    final database = await databaseProvider.database;
    final resultado = await database.query(
      PontoEletronico.nomeTabela,
      columns: [
        PontoEletronico.campoId,
        PontoEletronico.campoLatitude,
        PontoEletronico.campoLongitude,
        PontoEletronico.campoData

      ],
    );
    return resultado.map((m) => PontoEletronico.fromMap(m)).toList();
  }
}
