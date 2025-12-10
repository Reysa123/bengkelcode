import 'package:bengkel/database/databasehelper.dart';

import '../model/detail_pembelian_suku_cadang.dart'; // Pastikan path ini benar

class DetailPembelianSukuCadangRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Mendapatkan satu DetailPembelianSukuCadang berdasarkan ID
  Future<DetailPembelianSukuCadang?> getDetailPembelianSukuCadangById(
    int id,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DetailPembelianSukuCadang',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DetailPembelianSukuCadang.fromMap(maps.first);
    }
    return null;
  }

  Future<List<DetailPembelianSukuCadang>> getDetailsByPembelian() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'Select DetailPembelianSukuCadang.id as id,pembelian_id,suku_cadang_id,SukuCadang.id as ids,nama_part,kode_part,jumlah,harga_beli_saat_itu,sub_total FROM DetailPembelianSukuCadang INNER JOIN SukuCadang ON suku_cadang_id=SukuCadang.id;',
    );
    return List.generate(maps.length, (i) {
      return DetailPembelianSukuCadang.fromMap(maps[i]);
    });
  }

  // Mendapatkan semua DetailPembelianSukuCadang untuk ID pembelian tertentu
  Future<List<DetailPembelianSukuCadang>> getDetailsByPembelianId(
    int pembelianId,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DetailPembelianSukuCadang',
      where: 'pembelian_id = ?',
      whereArgs: [pembelianId],
    );
    return List.generate(maps.length, (i) {
      return DetailPembelianSukuCadang.fromMap(maps[i]);
    });
  }

  // Menyisipkan DetailPembelianSukuCadang baru
  Future<int> insertDetailPembelianSukuCadang(
    DetailPembelianSukuCadang detail,
  ) async {
    final db = await _databaseHelper.database;
    return await db.insert('DetailPembelianSukuCadang', detail.toMap());
  }

  // Memperbarui DetailPembelianSukuCadang yang sudah ada
  Future<int> updateDetailPembelianSukuCadang(
    DetailPembelianSukuCadang detail,
  ) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'DetailPembelianSukuCadang',
      detail.toMap(),
      where: 'id = ?',
      whereArgs: [detail.id],
    );
  }

  // Menghapus DetailPembelianSukuCadang berdasarkan ID
  Future<int> deleteDetailPembelianSukuCadang(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'DetailPembelianSukuCadang',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menghapus semua DetailPembelianSukuCadang untuk ID pembelian tertentu
  Future<int> deleteAllDetailsByPembelianId(int pembelianId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'DetailPembelianSukuCadang',
      where: 'pembelian_id = ?',
      whereArgs: [pembelianId],
    );
  }
}
