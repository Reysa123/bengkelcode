// lib/repositories/type_kendaraan_repository.dart
import 'package:bengkel/database/databasehelper.dart';
import 'package:bengkel/model/merk_kendaraan.dart';
import 'package:sqflite/sqflite.dart';
import '../model/type_kendaraan.dart';

class TypeKendaraanRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Ambil semua tipe kendaraan
  Future<List<TypeKendaraan>> getAllTypeKendaraan() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('type_kendaraan');
    return List.generate(maps.length, (i) {
      return TypeKendaraan.fromMap(maps[i]);
    });
  }

  Future<TypeKendaraan?> getAllTypeKendaraanByName(String namaType) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'type_kendaraan',
      where: 'nama_tipe = ?',
      whereArgs: [namaType],
    );
    if (maps.isNotEmpty) {
      return TypeKendaraan.fromMap(maps[0]);
    }
    return null;
  }

  // Ambil model kendaraan berdasarkan ID tipe
  Future<List<MerkKendaraan>> getMerkKendaraanBymerkId() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('merk_kendaraan');
    return List.generate(maps.length, (i) {
      return MerkKendaraan.fromMap(maps[i]);
    });
  }

  // Tambahkan tipe kendaraan baru
  Future<int> insertTypeKendaraan(TypeKendaraan type) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'type_kendaraan',
      type.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Perbarui tipe kendaraan yang sudah ada
  Future<int> updateTypeKendaraan(TypeKendaraan type) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'type_kendaraan',
      type.toMap(),
      where: 'id = ?',
      whereArgs: [type.id],
    );
  }

  // Hapus tipe kendaraan
  Future<int> deleteTypeKendaraan(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('type_kendaraan', where: 'id = ?', whereArgs: [id]);
  }
}
