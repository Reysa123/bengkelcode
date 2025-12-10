// lib/repositories/neraca_repository.dart
// Repository ini bertindak sebagai orkestrator untuk data yang dibutuhkan NeracaBloc.
// Neraca sendiri adalah Laporan, bukan entitas yang disimpan.
import 'package:bengkel/database/databasehelper.dart';// Hanya jika ada operasi DB langsung, yang tidak diharapkan di sini
 // Untuk akses ke database jika diperlukan
import '../model/account.dart';
import '../model/jurnal.dart';

class NeracaRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Metode untuk mendapatkan semua akun
  Future<List<Akun>> getAllAkun() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Akun');
    return List.generate(maps.length, (i) {
      return Akun.fromMap(maps[i]);
    });
  }

  // Metode untuk mendapatkan semua jurnal (hingga tanggal tertentu jika diperlukan)
  Future<List<Jurnal>> getAllJurnal({DateTime? untilDate}) async {
    final db = await _databaseHelper.database;
    List<Map<String, dynamic>> maps;

    if (untilDate != null) {
      final String isoDate = untilDate.toIso8601String();
      maps = await db.query(
        'Jurnal',
        where: 'tanggal <= ?',
        whereArgs: [isoDate],
        orderBy: 'tanggal ASC', // Urutkan untuk memastikan perhitungan saldo yang benar
      );
    } else {
      maps = await db.query('Jurnal', orderBy: 'tanggal ASC');
    }

    return List.generate(maps.length, (i) {
      return Jurnal.fromMap(maps[i]);
    });
  }
}
