// lib/repositories/merk_kendaraan_repository.dart
import 'package:bengkel/database/databasehelper.dart';
import 'package:sqflite/sqflite.dart';
import '../model/merk_kendaraan.dart';

class MerkKendaraanRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Ambil semua tipe kendaraan
  Future<List<MerkKendaraan>> getAllMerkKendaraan() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('merk_kendaraan');
    return List.generate(maps.length, (i) {
      return MerkKendaraan.fromMap(maps[i]);
    });
  }
 Future<MerkKendaraan?> getAllMerkKendaraanByName(String namaMerk) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('merk_kendaraan',where: 'nama_merk = ?',whereArgs: [namaMerk]);
   if(maps.isNotEmpty) {
      return MerkKendaraan.fromMap(maps[0]);
    }return null;
  }
  // Tambahkan tipe kendaraan baru
  Future<int> insertMerkKendaraan(MerkKendaraan type) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'merk_kendaraan',
      type.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Perbarui tipe kendaraan yang sudah ada
  Future<int> updateMerkKendaraan(MerkKendaraan type) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'merk_kendaraan',
      type.toMap(),
      where: 'id = ?',
      whereArgs: [type.id],
    );
  }

  // Hapus tipe kendaraan
  Future<int> deleteMerkKendaraan(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'merk_kendaraan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
