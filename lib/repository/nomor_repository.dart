import 'package:bengkel/database/databasehelper.dart';

class NomorRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Future<int> getNoPKB() async {
    var db = await _databaseHelper.database;
    final noPKB = await db.query('Nomor');
    final int idPkb = int.parse(noPKB.first['id_pkb'].toString());
    return idPkb;
  }

  Future<int> getNoTrx() async {
    var db = await _databaseHelper.database;
    final noPKB = await db.query('Nomor');
    final int idPkb = int.parse(noPKB.first['id_kwt'].toString());
    return idPkb;
  }

  Future<int> updateNoPKB() async {
    var db = await _databaseHelper.database;
    final noPKB = await db.query('Nomor');
    final int idPkb = int.parse(noPKB.first['id_pkb'].toString());
    final nomor = await db.update('Nomor', {'id_pkb': idPkb + 1});
    return nomor;
  }

  Future<int> updateNoTrk() async {
    var db = await _databaseHelper.database;
    final noPKB = await db.query('Nomor');
    final int idPkb = int.parse(noPKB.first['id_kwt'].toString());
    final nomor = await db.update('Nomor', {'id_kwt': idPkb + 1});
    return nomor;
  }
}
