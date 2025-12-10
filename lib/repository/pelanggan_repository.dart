import 'package:bengkel/database/databasehelper.dart';

import '../model/pelanggan.dart'; // Pastikan path ke model Pelanggan Anda sudah benar
// Pastikan path ke DatabaseHelper Anda sudah benar

class PelangganRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Mendapatkan satu Pelanggan berdasarkan ID
  Future<List<Pelanggan>> getPelangganById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Pelanggan',
      where: 'id = ?',
      whereArgs: [id],
    );

    return List.generate(maps.length, (i) {
      return Pelanggan.fromMap(maps[i]);
    });
  }
Future<Pelanggan?> getPelangganByIds(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Pelanggan',
      where: 'id = ?',
      whereArgs: [id],
    );

    if(maps.isNotEmpty) {
      return Pelanggan.fromMap(maps.first);
    }return null;
  }
  // Mendapatkan semua Pelanggan
  Future<List<Pelanggan>> getAllPelanggan() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Pelanggan');
    return List.generate(maps.length, (i) {
      return Pelanggan.fromMap(maps[i]);
    });
  }

  // Menyisipkan Pelanggan baru
  Future<int> insertPelanggan(Pelanggan pelanggan) async {
    final db = await _databaseHelper.database;
    return await db.insert('Pelanggan', pelanggan.toMap());
  }

  // Memperbarui Pelanggan yang sudah ada
  Future<int> updatePelanggan(Pelanggan pelanggan) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'Pelanggan',
      pelanggan.toMap(),
      where: 'id = ?',
      whereArgs: [pelanggan.id],
    );
  }

  // Menghapus Pelanggan berdasarkan ID
  Future<int> deletePelanggan(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('Pelanggan', where: 'id = ?', whereArgs: [id]);
  }
}
