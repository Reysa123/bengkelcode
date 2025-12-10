// lib/repositories/detail_transaksi_service_repository.dart
import 'package:bengkel/database/databasehelper.dart';
import 'package:bengkel/model/detailtransaksiservice.dart';

// import '../models/detail_transaksi_service.dart'; // Pastikan path ini benar
// import '../helpers/database_helper.dart'; // Pastikan path ini benar

class DetailTransaksiServiceRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Mendapatkan satu DetailTransaksiService berdasarkan ID
  Future<DetailTransaksiService?> getDetailTransaksiServiceById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DetailTransaksiService',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DetailTransaksiService.fromMap(maps.first);
    }
    return null;
  }

  Future<List<DetailTransaksiService>> getDetailTransaksiService() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DetailTransaksiService',
    );

    return List.generate(maps.length, (i) {
      return DetailTransaksiService.fromMap(maps[i]);
    });
  }
  // Ambil detail transaksi service berdasarkan transaksiId
  // Future<List<DetailTransaksiService>> getDetailByTransaksiId(
  //   int transaksiId,
  // ) async {
  //   final db = await _databaseHelper.database;
  //   final List<Map<String, dynamic>> maps = await db.query(
  //     'detail_transaksi_service',
  //     where: 'transaksi_id = ?',
  //     whereArgs: [transaksiId],
  //   );
  //   return List.generate(maps.length, (i) {
  //     return DetailTransaksiService.fromMap(maps[i]);
  //   });
  // }

  // Mendapatkan semua DetailTransaksiService untuk ID transaksi servis tertentu
  Future<List<DetailTransaksiService>> getDetailsByTransaksiServisId(
    int transaksiId,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'DetailTransaksiService',
      where: 'transaksi_servis_id = ?',
      whereArgs: [transaksiId],
      orderBy: 'id ASC', // Mengurutkan berdasarkan ID untuk konsistensi
    );
    return List.generate(maps.length, (i) {
      return DetailTransaksiService.fromMap(maps[i]);
    });
  }

  // Memperbarui DetailTransaksiService yang sudah ada
  Future<int> updateDetailTransaksiService(
    DetailTransaksiService detail,
  ) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel, update ini akan dipanggil
    // di dalam transaksi di BLoC.
    return await db.update(
      'DetailTransaksiService',
      detail.toMap(),
      where: 'id = ?',
      whereArgs: [detail.id],
    );
  }

  // Menghapus DetailTransaksiService berdasarkan ID
  Future<int> deleteDetailTransaksiService(int id) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel, delete ini akan dipanggil
    // di dalam transaksi di BLoC.
    return await db.delete(
      'DetailTransaksiService',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Menghapus semua DetailTransaksiService untuk ID transaksi servis tertentu
  Future<int> deleteAllDetailsByTransaksiServisId(int transaksiServisId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'DetailTransaksiService',
      where: 'transaksi_servis_id = ?',
      whereArgs: [transaksiServisId],
    );
  }
}
