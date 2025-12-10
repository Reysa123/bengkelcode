import 'package:bengkel/database/databasehelper.dart';

import '../model/pembelian_suku_cadang.dart'; // Pastikan path ke model PembelianSukuCadang Anda sudah benar

class PembelianSukuCadangRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Mendapatkan satu PembelianSukuCadang berdasarkan ID
  Future<PembelianSukuCadang?> getPembelianSukuCadangById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'PembelianSukuCadang',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PembelianSukuCadang.fromMap(maps.first);
    }
    return null;
  }

  // Mendapatkan semua PembelianSukuCadang
  Future<List<PembelianSukuCadang>> getAllPembelianSukuCadang() async {
    final db = await _databaseHelper.database;
    // Mengurutkan berdasarkan tanggal pembelian terbaru
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT PembelianSukuCadang.id as id,Supplier.id as sup_id,PembelianSukuCadang.status as status,supplier_id,tanggal_pembelian,total_pembelian,catatan,status,nama_supplier FROM PembelianSukuCadang INNER JOIN Supplier ON supplier_id=Supplier.id ORDER BY tanggal_pembelian DESC;',
    );
    return List.generate(maps.length, (i) {
      return PembelianSukuCadang.fromMap(maps[i]);
    });
  }

  // Menyisipkan PembelianSukuCadang baru
  Future<int> insertPembelianSukuCadang(
    PembelianSukuCadang pembelianSukuCadang,
  ) async {
    final db = await _databaseHelper.database;
    return await db.insert('PembelianSukuCadang', pembelianSukuCadang.toMap());
  }

  // Memperbarui PembelianSukuCadang yang sudah ada
  Future<int> updatePembelianSukuCadang(
    PembelianSukuCadang pembelianSukuCadang,
  ) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'PembelianSukuCadang',
      pembelianSukuCadang.toMap(),
      where: 'id = ?',
      whereArgs: [pembelianSukuCadang.id],
    );
  }

  // Menghapus PembelianSukuCadang berdasarkan ID
  Future<int> deletePembelianSukuCadang(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'PembelianSukuCadang',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
