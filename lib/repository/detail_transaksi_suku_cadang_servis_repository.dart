// lib/repositories/detail_transaksi_suku_cadang_servis_repository.dart
import 'package:bengkel/database/databasehelper.dart';
import 'package:bengkel/model/detailsukucadangservice.dart';

// Pastikan path ini benar

class DetailTransaksiSukuCadangServisRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Mendapatkan satu DetailTransaksiSukuCadangServis berdasarkan ID
  Future<DetailTransaksiSukuCadangServis?>
  getDetailTransaksiSukuCadangServisById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DetailTransaksiSukuCadangServis',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DetailTransaksiSukuCadangServis.fromMap(maps.first);
    }
    return null;
  }

  Future<List<DetailTransaksiSukuCadangServis>>
  getDetailTransaksiSukuCadangServis() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DetailTransaksiSukuCadangServis',
    );

    return List.generate(maps.length, (i) {
      return DetailTransaksiSukuCadangServis.fromMap(maps[i]);
    });
  }

  // Mendapatkan semua DetailTransaksiSukuCadangServis untuk ID transaksi servis tertentu
  Future<List<DetailTransaksiSukuCadangServis>> getDetailsByTransaksiServisId(
    int transaksiId,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DetailTransaksiSukuCadangServis',
      where: 'transaksi_servis_id = ?',
      whereArgs: [transaksiId],
      orderBy: 'id ASC', // Mengurutkan berdasarkan ID untuk konsistensi
    );
    return List.generate(maps.length, (i) {
      return DetailTransaksiSukuCadangServis.fromMap(maps[i]);
    });
  }

  // Menyisipkan DetailTransaksiSukuCadangServis baru
  Future<int> insertDetailTransaksiSukuCadangServis(
    DetailTransaksiSukuCadangServis detail,
  ) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel (seperti TransaksiServis dengan detailnya),
    // insert ini akan dipanggil di dalam transaksi di BLoC.
    return await db.insert('DetailTransaksiSukuCadangServis', detail.toMap());
  }

  // Memperbarui DetailTransaksiSukuCadangServis yang sudah ada
  Future<int> updateDetailTransaksiSukuCadangServis(
    DetailTransaksiSukuCadangServis detail,
  ) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel, update ini akan dipanggil
    // di dalam transaksi di BLoC.
    return await db.update(
      'DetailTransaksiSukuCadangServis',
      detail.toMap(),
      where: 'id = ?',
      whereArgs: [detail.id],
    );
  }

  // Menghapus DetailTransaksiSukuCadangServis berdasarkan ID
  Future<int> deleteDetailTransaksiSukuCadangServis(int id) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel, delete ini akan dipanggil
    // di dalam transaksi di BLoC.
    return await db.delete(
      'DetailTransaksiSukuCadangServis',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menghapus semua DetailTransaksiSukuCadangServis untuk ID transaksi servis tertentu
  Future<int> deleteAllDetailsByTransaksiServisId(int transaksiServisId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'DetailTransaksiSukuCadangServis',
      where: 'transaksi_servis_id = ?',
      whereArgs: [transaksiServisId],
    );
  }
}
