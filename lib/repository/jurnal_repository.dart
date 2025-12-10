// lib/repositories/jurnal_repository.dart
import 'package:bengkel/database/databasehelper.dart';
import '../model/jurnal.dart'; // Pastikan path ini benar
 // Pastikan path ini benar

class JurnalRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Mendapatkan semua entri Jurnal
  Future<List<Jurnal>> getAllJurnal() async {
    final db = await _databaseHelper.database;
    // Mengurutkan berdasarkan tanggal terbaru
    final List<Map<String, dynamic>> maps = await db.query('Jurnal', orderBy: 'tanggal DESC');
    return List.generate(maps.length, (i) {
      return Jurnal.fromMap(maps[i]);
    });
  }

  // Mendapatkan entri Jurnal berdasarkan rentang tanggal
  Future<List<Jurnal>> getJurnalByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    // Format tanggal ke string ISO 8601 untuk perbandingan di database
    final String startIso = startDate.toIso8601String();
    final String endIso = endDate.toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'Jurnal',
      where: 'tanggal BETWEEN ? AND ?',
      whereArgs: [startIso, endIso],
      orderBy: 'tanggal DESC', // Urutkan berdasarkan tanggal terbaru
    );
    return List.generate(maps.length, (i) {
      return Jurnal.fromMap(maps[i]);
    });
  }

  // Metode untuk menyisipkan jurnal (biasanya dipanggil dari BLoC transaksi lain)
  // Tidak perlu metode update/delete di sini karena jurnal biasanya tidak dimanipulasi manual
  Future<int> insertJurnal(Jurnal jurnal) async {
    final db = await _databaseHelper.database;
    
    return await db.insert('Jurnal', jurnal.toMap());
  }
}
