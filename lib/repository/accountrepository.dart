

import 'package:bengkel/database/databasehelper.dart';
import 'package:bengkel/model/account.dart';
import 'package:sqflite/sqflite.dart';

class AkunRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // --- CREATE ---
  Future<int> insertAkun(Akun akun) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'Akun',
      akun.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Handle potential conflicts
    );
  }

  // --- READ ---
  Future<List<Akun>> getAkun() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Akun');

    return List.generate(maps.length, (i) {
      return Akun.fromMap(maps[i]);
    });
  }

  Future<Akun?> getAkunById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Akun',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Akun.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Akun>> getAkunsByType(String type) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Akun',
      where: 'jenis_akun = ?',
      whereArgs: [type],
    );

    return List.generate(maps.length, (i) {
      return Akun.fromMap(maps[i]);
    });
  }

  // --- UPDATE ---
  Future<int> updateAkun(Akun akun) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'Akun',
      akun.toMap(),
      where: 'id = ?',
      whereArgs: [akun.id],
    );
  }

  // --- DELETE ---
  Future<int> deleteAkun(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'Akun',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}