import 'package:bengkel/database/databasehelper.dart';

import '../model/mekanik.dart'; // Pastikan path ke model Mekanik Anda sudah benar
// Pastikan path ke DatabaseHelper Anda sudah benar

class MekanikRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Mendapatkan satu Mekanik berdasarkan ID
  Future<Mekanik?> getMekanikById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Mekanik',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Mekanik.fromMap(maps.first);
    }
    return null;
  }

  // Mendapatkan semua Mekanik
  Future<List<Mekanik>> getAllMekanik() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Mekanik');
    return List.generate(maps.length, (i) {
      return Mekanik.fromMap(maps[i]);
    });
  }

  Future<Mekanik?> getAllMekaniks() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Mekanik');
    if (maps.isNotEmpty) {
      return Mekanik.fromMap(maps.first);
    }
    return null;
  }

  // Menyisipkan Mekanik baru
  Future<int> insertMekanik(Mekanik mekanik) async {
    final db = await _databaseHelper.database;
    return await db.insert('Mekanik', mekanik.toMap());
  }

  // Memperbarui Mekanik yang sudah ada
  Future<int> updateMekanik(Mekanik mekanik) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'Mekanik',
      mekanik.toMap(),
      where: 'id = ?',
      whereArgs: [mekanik.id],
    );
  }

  // Menghapus Mekanik berdasarkan ID
  Future<int> deleteMekanik(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('Mekanik', where: 'id = ?', whereArgs: [id]);
  }
}
