import 'package:bengkel/database/databasehelper.dart';
import '../model/jasa.dart'; // Pastikan path ke model Jasa Anda sudah benar
 // Pastikan path ke DatabaseHelper Anda sudah benar

class JasaRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Mendapatkan satu Jasa berdasarkan ID
  Future<Jasa?> getJasaById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Jasa',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Jasa.fromMap(maps.first);
    }
    return null;
  }

  // Mendapatkan semua Jasa
  Future<List<Jasa>> getAllJasa() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Jasa');
    return List.generate(maps.length, (i) {
      return Jasa.fromMap(maps[i]);
    });
  }

  // Menyisipkan Jasa baru
  Future<int> insertJasa(Jasa jasa) async {
    final db = await _databaseHelper.database;
    return await db.insert('Jasa', jasa.toMap());
  }

  // Memperbarui Jasa yang sudah ada
  Future<int> updateJasa(Jasa jasa) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'Jasa',
      jasa.toMap(),
      where: 'id = ?',
      whereArgs: [jasa.id],
    );
  }

  // Menghapus Jasa berdasarkan ID
  Future<int> deleteJasa(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'Jasa',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}