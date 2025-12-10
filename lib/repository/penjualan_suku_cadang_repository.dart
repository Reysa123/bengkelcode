// lib/repositories/penjualan_suku_cadang_repository.dart
// Pastikan path ini benar

import 'package:bengkel/database/databasehelper.dart';
import 'package:bengkel/model/penjualansukucadang.dart';

class PenjualanSukuCadangRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Mendapatkan satu PenjualanSukuCadang berdasarkan ID
  Future<PenjualanSukuCadang?> getPenjualanSukuCadangById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'PenjualanSukuCadang',
      where: 'transaksi_id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PenjualanSukuCadang.fromMap(maps.first);
    }
    return null;
  }

  Future<List<PenjualanSukuCadang>> getPenjualanSukuCadangAllById(
    int id,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT PenjualanSukuCadang.id as id,pelanggan_id,tanggal_penjualan,total_penjualan,catatan,status,transaksi_id,nama_part,harga_beli,harga_jual,DetailPenjualanSukuCadang.jumlah as qty FROM PenjualanSukuCadang INNER JOIN DetailPenjualanSukuCadang ON DetailPenjualanSukuCadang.penjualan_id=PenjualanSukuCadang.transaksi_id INNER JOIN SukuCadang on DetailPenjualanSukuCadang.suku_cadang_id=SukuCadang.id WHERE transaksi_id=$id;',
    );

    return List.generate(maps.length, (i) {
      return PenjualanSukuCadang.fromMap(maps[i]);
    });
  }

  // Mendapatkan semua PenjualanSukuCadang
  Future<List<PenjualanSukuCadang>> getAllPenjualanSukuCadang() async {
    final db = await _databaseHelper.database;
    // Mengurutkan berdasarkan tanggal penjualan terbaru
    final List<Map<String, dynamic>> maps = await db.query(
      'PenjualanSukuCadang',
      orderBy: 'tanggal_penjualan DESC',
    );
    return List.generate(maps.length, (i) {
      return PenjualanSukuCadang.fromMap(maps[i]);
    });
  }

  // Menyisipkan PenjualanSukuCadang baru
  Future<int> insertPenjualanSukuCadang(
    PenjualanSukuCadang penjualanSukuCadang,
  ) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel (seperti PenjualanSukuCadang dengan detailnya),
    // insert ini akan dipanggil di dalam transaksi di BLoC.
    return await db.insert('PenjualanSukuCadang', penjualanSukuCadang.toMap());
  }

  // Memperbarui PenjualanSukuCadang yang sudah ada
  Future<int> updatePenjualanSukuCadang(
    PenjualanSukuCadang penjualanSukuCadang,
  ) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel, update ini akan dipanggil
    // di dalam transaksi di BLoC.
    return await db.update(
      'PenjualanSukuCadang',
      penjualanSukuCadang.toMap(),
      where: 'id = ?',
      whereArgs: [penjualanSukuCadang.id],
    );
  }

  // Menghapus PenjualanSukuCadang berdasarkan ID
  Future<int> deletePenjualanSukuCadang(int id) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel (dan revert stok/jurnal),
    // delete ini akan dipanggil di dalam transaksi di BLoC.
    return await db.delete(
      'PenjualanSukuCadang',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
