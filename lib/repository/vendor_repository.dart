import 'package:sqflite/sqflite.dart';
import '../database/databasehelper.dart'; // Adjust path as needed
import '../model/suplier.dart'; // Import the Supplier model

class SupplierRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // --- CREATE ---
  Future<int> insertSupplier(Supplier supplier) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'Supplier',
      supplier.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- READ ---
  Future<List<Supplier>> getSuppliers() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Supplier',
    );

    return List.generate(maps.length, (i) {
      return Supplier.fromMap(maps[i]);
    });
  }

  Future<Supplier?> getSupplierById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Supplier',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Supplier.fromMap(maps.first);
    }
    return null;
  }

  Future<Supplier?> getSupplierByName(String name) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Supplier',
      where: 'nama_supplier = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return Supplier.fromMap(maps.first);
    }
    return null;
  }

  // --- UPDATE ---
  Future<int> updateSupplier(Supplier supplier) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'Supplier',
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  // --- DELETE ---
  Future<int> deleteSupplier(int id) async {
    final db = await _databaseHelper.database;
    // Note: If you have parts linked to this Supplier, consider what should happen.
    // SQL's FOREIGN KEY ON DELETE SET NULL or CASCADE might be configured.
    // In our DatabaseHelper, the part's Supplier_id will become null if a Supplier is deleted.
    return await db.delete(
      'Supplier',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
