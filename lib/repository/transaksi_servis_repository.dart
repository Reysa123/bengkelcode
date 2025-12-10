// lib/repositories/transaksi_servis_repository.dart
import 'package:bengkel/database/databasehelper.dart';
import 'package:bengkel/model/detailsukucadangservice.dart';
import 'package:bengkel/model/detailtransaksiservice.dart';
import 'package:bengkel/model/kendaraan.dart';
import 'package:bengkel/model/pelanggan.dart';
import 'package:bengkel/model/transaksi_service_detail.dart';
import 'package:bengkel/model/transaksiservice.dart';

// Pastikan path ini benar

class TransaksiServisRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Mendapatkan satu TransaksiServis berdasarkan ID
  Future<TransaksiServis?> getTransaksiServisById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'TransaksiServis',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TransaksiServis.fromMap(maps.first);
    }
    return null;
  }

  // Mendapatkan semua TransaksiServis
  Future<List<TransaksiServis>> getAllTransaksiServis() async {
    final db = await _databaseHelper.database;

    // Mengurutkan berdasarkan tanggal masuk terbaru
    final List<Map<String, dynamic>> maps = await db.query(
      'TransaksiServis',
      orderBy: 'tanggal_masuk DESC',
    );
    return List.generate(maps.length, (i) {
      return TransaksiServis.fromMap(maps[i]);
    });
  }

  // Metode baru: Mendapatkan TransaksiServis berdasarkan ID Kendaraan
  Future<List<TransaksiServis>> getTransaksiServisByKendaraanId() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'TransaksiServis',
      orderBy:
          'tanggal_masuk DESC', // Urutkan berdasarkan tanggal masuk terbaru
    );
    return List.generate(maps.length, (i) {
      return TransaksiServis.fromMap(maps[i]);
    });
  }

  Future<TransaksiServiceDetail?> getTransaksiServiceDetail(
    int transaksiId,
  ) async {
    final db = await _databaseHelper.database;
    // Ambil data transaksi utama
    final List<Map<String, dynamic>> transaksiMaps = await db.query(
      'TransaksiServis',
      where: 'id = ?',
      whereArgs: [transaksiId],
    );

    if (transaksiMaps.isEmpty) {
      return null;
    }

    final transaksi = TransaksiServis.fromMap(transaksiMaps.first);

    // Ambil data kendaraan (jika ada)
    Kendaraan? vehicle;
    if (transaksi.kendaraanId.isNaN) {
      final List<Map<String, dynamic>> vehicleMaps = await db.query(
        'Kendaraan',
        where: 'id = ?',
        whereArgs: [transaksi.kendaraanId],
      );
      if (vehicleMaps.isNotEmpty) {
        vehicle = Kendaraan.fromMap(vehicleMaps.first);
      }
    }
    // Ambil data pelanggan (jika ada)
    Pelanggan? customer;
    if (vehicle?.id != null) {
      final List<Map<String, dynamic>> customerMaps = await db.query(
        'Pelanggan',
        where: 'id = ?',
        whereArgs: [vehicle?.pelangganId],
      );
      if (customerMaps.isNotEmpty) {
        customer = Pelanggan.fromMap(customerMaps.first);
      }
    }
    // Ambil detail item service
    final List<Map<String, dynamic>> detailMaps = await db.query(
      'DetailTransaksiService',
      where: 'transaksi_id = ?',
      whereArgs: [transaksiId],
    );
    final details = List.generate(detailMaps.length, (i) {
      return DetailTransaksiService.fromMap(detailMaps[i]);
    });
    // Ambil detail item service
    final List<Map<String, dynamic>> detailMapsp = await db.query(
      'DetailTransaksiSukuCadangServis',
      where: 'transaksi_id = ?',
      whereArgs: [transaksiId],
    );
    final detailsp = List.generate(detailMapsp.length, (i) {
      return DetailTransaksiSukuCadangServis.fromMap(detailMapsp[i]);
    });

    return TransaksiServiceDetail(
      transaksi: transaksi,
      customer: customer,
      vehicle: vehicle,
      jasas: details,
      parts: detailsp,
    );
  }

  // Menyisipkan TransaksiServis baru
  Future<int> insertTransaksiServis(TransaksiServis transaksiServis) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel (seperti TransaksiServis dengan detailnya),
    // insert ini akan dipanggil di dalam transaksi di BLoC.
    return await db.insert('TransaksiServis', transaksiServis.toMap());
  }

  // Memperbarui TransaksiServis yang sudah ada
  Future<int> updateTransaksiServis(TransaksiServis transaksiServis) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel, update ini akan dipanggil
    // di dalam transaksi di BLoC.
    return await db.update(
      'TransaksiServis',
      transaksiServis.toMap(),
      where: 'id = ?',
      whereArgs: [transaksiServis.id],
    );
  }

  // Menghapus TransaksiServis berdasarkan ID
  Future<int> deleteTransaksiServis(int id) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel (dan revert stok/jurnal),
    // delete ini akan dipanggil di dalam transaksi di BLoC.
    return await db.delete('TransaksiServis', where: 'id = ?', whereArgs: [id]);
  }
}
