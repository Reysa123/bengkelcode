import 'package:sqflite/sqflite.dart';
import '../database/databasehelper.dart'; // Adjust path as needed
import '../model/part.dart'; // Import the Part model

class PartRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // --- CREATE ---
  Future<int> insertPart(SukuCadang part) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'SukuCadang',
      part.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Replace if SKU is unique and exists
    );
  }

  // --- READ ---
  Future<List<SukuCadang>> getParts() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('SukuCadang');

    return List.generate(maps.length, (i) {
      return SukuCadang.fromMap(maps[i]);
    });
  }

  Future<SukuCadang?> getPartById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'SukuCadang',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return SukuCadang.fromMap(maps.first);
    }
    return null;
  }

  Future<SukuCadang?> getPartByno(String kodePart) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'SukuCadang',
      where: 'kode_part = ?',
      whereArgs: [kodePart],
    );

    if (maps.isNotEmpty) {
      return SukuCadang.fromMap(maps.first);
    }
    return null;
  }

  // --- UPDATE ---
  Future<int> updatePart(SukuCadang part) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'SukuCadang',
      part.toMap(),
      where: 'id = ?',
      whereArgs: [part.id],
    );
  }

  // Method to update stock quantity
  Future<int> updatePartStock(int partId, int quantityChange) async {
    final db = await _databaseHelper.database;
    // Get current part to determine new stock
    SukuCadang? part = await getPartById(partId);
    if (part == null) {
      throw Exception('Part with ID $partId not found.');
    }

    final newStock = part.stok + quantityChange;
    if (newStock < 0) {
      // Optional: Prevent negative stock if desired
      throw Exception(
        'Cannot reduce stock below zero. Current stock: ${part.stok}, Change: $quantityChange',
      );
    }

    return await db.update(
      'SukuCadang',
      {'stok': newStock},
      where: 'id = ?',
      whereArgs: [partId],
    );
  }

  // --- DELETE ---
  Future<int> deletePart(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('SukuCadang', where: 'id = ?', whereArgs: [id]);
  }
}
