// lib/repositories/detail_penjualan_suku_cadang_repository.dart
// Pastikan path ini benar

import 'package:bengkel/database/databasehelper.dart';
import 'package:bengkel/model/detailpenjualansukucadang.dart';

class DetailPenjualanSukuCadangRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Mendapatkan satu DetailPenjualanSukuCadang berdasarkan ID
  Future<DetailPenjualanSukuCadang?> getDetailPenjualanSukuCadangById(
    int id,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DetailPenjualanSukuCadang',
      where: 'penjualan_id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DetailPenjualanSukuCadang.fromMap(maps.first);
    }
    return null;
  }

  // Mendapatkan semua DetailPenjualanSukuCadang untuk ID penjualan tertentu
  Future<List<DetailPenjualanSukuCadang>> getDetailsByPenjualanId(
    int penjualanId,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DetailPenjualanSukuCadang',
      where: 'penjualan_id = ?',
      whereArgs: [penjualanId],
      orderBy: 'id ASC', // Mengurutkan berdasarkan ID untuk konsistensi
    );
    return List.generate(maps.length, (i) {
      return DetailPenjualanSukuCadang.fromMap(maps[i]);
    });
  }

  // Menyisipkan DetailPenjualanSukuCadang baru
  Future<int> insertDetailPenjualanSukuCadang(
    DetailPenjualanSukuCadang detail,
  ) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel (seperti PenjualanSukuCadang dengan detailnya),
    // insert ini akan dipanggil di dalam transaksi di BLoC.
    return await db.insert('DetailPenjualanSukuCadang', detail.toMap());
  }

  // Memperbarui DetailPenjualanSukuCadang yang sudah ada
  Future<int> updateDetailPenjualanSukuCadang(
    DetailPenjualanSukuCadang detail,
  ) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel, update ini akan dipanggil
    // di dalam transaksi di BLoC.
    return await db.update(
      'DetailPenjualanSukuCadang',
      detail.toMap(),
      where: 'id = ?',
      whereArgs: [detail.id],
    );
  }

  // Menghapus DetailPenjualanSukuCadang berdasarkan ID
  Future<int> deleteDetailPenjualanSukuCadang(int id) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel, delete ini akan dipanggil
    // di dalam transaksi di BLoC.
    return await db.delete(
      'DetailPenjualanSukuCadang',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menghapus semua DetailPenjualanSukuCadang untuk ID penjualan tertentu
  Future<int> deleteAllDetailsByPenjualanId(int penjualanId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'DetailPenjualanSukuCadang',
      where: 'penjualan_id = ?',
      whereArgs: [penjualanId],
    );
  }
}
