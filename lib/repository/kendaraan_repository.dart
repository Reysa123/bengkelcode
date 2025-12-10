import 'package:bengkel/model/kendararaanall.dart';
import 'package:sqflite/sqflite.dart';
import '../database/databasehelper.dart'; // Adjust path as needed
import '../model/kendaraan.dart'; // Import the Kendaraan model

class KendaraanRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // --- CREATE ---
  Future<int> insertKendaraan(Kendaraan kendaraan) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'Kendaraan',
      kendaraan.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm
              .replace, // Replace if license plate is unique and already exists
    );
  }

  // --- READ ---
  Future<List<Kendaraan>> getKendaraans() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Kendaraan');

    return List.generate(maps.length, (i) {
      return Kendaraan.fromMap(maps[i]);
    });
  }

  Future<List<Kendaraan>> getKendaraansById(int kendaraanId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Kendaraan',
      where: 'id = ?',
      whereArgs: [kendaraanId],
    );

    return List.generate(maps.length, (i) {
      return Kendaraan.fromMap(maps[i]);
    });
  }

  Future<List<KendaraanAll>> getKendaraanallById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT Kendaraan.id as ids,merk,model,tahun,plat_nomor,nomor_rangka,nomor_mesin,km,nama,alamat,telepon FROM Kendaraan INNER JOIN Pelanggan ON Pelanggan.id=Kendaraan.pelanggan_id WHERE Kendaraan.id=$id;',
    );

    return List.generate(maps.length, (i) {
      return KendaraanAll.fromMap(maps[i]);
    });
  }

  Future<Kendaraan?> getKendaraanById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Kendaraan',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Kendaraan.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Kendaraan>> getKendaraanByLicensePlate(
    String licensePlate,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Kendaraan',
      where: 'lower(plat_nomor) like ? OR lower(nomor_rangka) like ?',
      whereArgs: [
        '%${licensePlate.toLowerCase()}%',
        '%${licensePlate.toLowerCase()}%',
      ],
    );

    return List.generate(maps.length, (i) {
      return Kendaraan.fromMap(maps[i]);
    });
  }

  Future<bool> getKendaraanByLicensePlateSts(int idKend) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'TransaksiServis',
      where: 'kendaraan_id = ?',
      whereArgs: [idKend],
    );
    List<bool> ada = [];
    for (var e in maps) {
      if (e['status'].toString().contains('Lunas') ||
          e['status'].toString().contains('Komplit')) {
        ada.add(false);
      } else {
        ada.add(true);
      }
    }

    return ada.contains(true) ? true : false;
  }

  // --- UPDATE ---
  Future<int> updateKendaraan(Kendaraan kendaraan) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'Kendaraan',
      kendaraan.toMap(),
      where: 'id = ?',
      whereArgs: [kendaraan.id],
    );
  }

  Future<void> updateKMKendaraan(int km, int kendaraanId) async {
    final db = await _databaseHelper.database;
    await db.update(
      'Kendaraan',
      {'km': km},
      where: 'id = ?',
      whereArgs: [kendaraanId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- DELETE ---
  Future<int> deleteKendaraan(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('Kendaraan', where: 'id = ?', whereArgs: [id]);
  }
}
