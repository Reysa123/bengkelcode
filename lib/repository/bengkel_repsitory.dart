import 'package:bengkel/database/databasehelper.dart';
import 'package:bengkel/model/bengkel.dart';

class BengkelRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Future<Bengkel?> getBengkel() async {
    final db = await _databaseHelper.database;
    final map = await db.query('Bengkel');
    if (map.isNotEmpty) {
      return Bengkel.fromMap(map.first);
    }
    return null;
  }

  Future<int?> setBengkel(Bengkel bengkel) async {
    final db = await _databaseHelper.database;
    return await db.insert('Bengkel', bengkel.toMap());
  }

  Future<int?> updateBengkel(Bengkel bengkel) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'Bengkel',
      bengkel.toMap(),
      where: 'id = ?',
      whereArgs: [bengkel.id],
    );
  }
}
