// lib/repositories/transaksi_service_repository.dart
import 'package:bengkel/database/databasehelper.dart';
import 'package:bengkel/model/detailsukucadangservice.dart';
import 'package:bengkel/model/detailtransaksiservice.dart';
import 'package:bengkel/model/kendaraan.dart';
import 'package:bengkel/model/pelanggan.dart';
import 'package:bengkel/model/transaksi_service_detail.dart';
import 'package:bengkel/model/transaksiservice.dart';
import 'package:sqflite/sqflite.dart';

class TransaksiServiceRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Ambil daftar semua transaksi service
  Future<List<TransaksiServis>> getAllTransaksiService() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('transaksi_service');
    return List.generate(maps.length, (i) {
      return TransaksiServis.fromMap(maps[i]);
    });
  }

  //cetak kwitansi
  Future<void> cetakKwitansiService(
    Map<String, dynamic> list,
    List<Map<String, dynamic>> listJ,
    List<Map<String, dynamic>> listP,
  ) async {
    // 4. Pencatatan Jurnal
    final db = await _databaseHelper.database;
    final tanggalJurnal = DateTime.now().toIso8601String();

    final labaDitahanAkun = await _databaseHelper.getAkunByName('Laba Ditahan');
    final pendapatanServisAkun = await _databaseHelper.getAkunByName(
      'Pendapatan Jasa Servis',
    );
    final pendapatanSukuCadangAkun = await _databaseHelper.getAkunByName(
      'Pendapatan Suku Cadang Servis',
    );
    final persediaanSukuCadangAkun = await _databaseHelper.getAkunByName(
      'Persediaan Suku Cadang',
    );
    final bebanPokokPenjualanAkun = await _databaseHelper.getAkunByName(
      'Beban Pembelian Suku Cadang',
    ); // Jika ada
    final piutangUsahaAkun = await _databaseHelper.getAkunByName(
      'Piutang Usaha',
    );
    final bebanJasaPerbaikanAkun = await _databaseHelper.getAkunByName(
      'Beban Jasa Perbaikan',
    );
    if (bebanJasaPerbaikanAkun == null ||
        piutangUsahaAkun == null ||
        bebanPokokPenjualanAkun == null ||
        persediaanSukuCadangAkun == null ||
        pendapatanServisAkun == null ||
        pendapatanSukuCadangAkun == null ||
        labaDitahanAkun == null) {
      throw ("Akun tidak tersedia");
    }
    List<Map<String, dynamic>> dataToInsert = [
      {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Pendapatan Jasa Servis #${list['id']}',
        'referensi_transaksi_id': list['id'],
        'tipe_referensi': 'Servis',
        'debit': list['total_part'],
        'kredit': 0.0,
        'akun_id': pendapatanSukuCadangAkun['id'],
      },
      {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Pendapatan Jasa Servis #${list['id']}',
        'referensi_transaksi_id': list['id'],
        'tipe_referensi': 'Servis',
        'debit': list['total_jasa'],
        'kredit': 0.0,
        'akun_id': pendapatanServisAkun['id'],
      },
      {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Pendapatan Jasa Servis #${list['id']}',
        'referensi_transaksi_id': list['id'],
        'tipe_referensi': 'Servis',
        'kredit': list['total_laba'],
        'debit': 0.0,
        'akun_id': labaDitahanAkun['id'],
      },
      {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Pendapatan Jasa Servis #${list['id']}',
        'referensi_transaksi_id': list['id'],
        'tipe_referensi': 'Servis',
        'kredit': list['total_belipart'],
        'debit': 0.0,
        'akun_id': persediaanSukuCadangAkun['id'],
      },
      {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Pendapatan Jasa Servis #${list['id']}',
        'referensi_transaksi_id': list['id'],
        'tipe_referensi': 'Servis',
        'kredit': list['total_belipart'],
        'debit': 0.0,
        'akun_id': bebanPokokPenjualanAkun['id'],
      },
      {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Pendapatan Jasa Servis #${list['id']}',
        'referensi_transaksi_id': list['id'],
        'tipe_referensi': 'Servis',
        'debit': list['sub_total'],
        'kredit': 0.0,
        'akun_id': piutangUsahaAkun['id'],
      },
      {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Pendapatan Jasa Servis #${list['id']}',
        'referensi_transaksi_id': list['id'],
        'tipe_referensi': 'Servis',
        'kredit': list['total_belijasa'],
        'debit': 0.0,
        'akun_id': bebanJasaPerbaikanAkun['id'],
      },
    ];
    try {
      final batch = db.batch();
      for (var e in dataToInsert) {
        batch.insert('Jurnal', e);
      }

      await db.update(
        'TransaksiServis',
        {
          'status': 'Komplit',
          'total_biaya_jasa': list['total_jasa'],
          'total_biaya_suku_cadang': list['total_part'],
          'total_final': list['sub_total'],
        },
        where: 'idpkb = ?',
        whereArgs: [list['id']],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (var e in listP) {
        await db.update(
          'DetailTransaksiSukuCadangServis',
          e,
          where: 'id = ?',
          whereArgs: [e['id']],
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (var e in listJ) {
        await db.update(
          'DetailTransaksiService',
          e,
          where: 'id = ?',
          whereArgs: [e['id']],
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> batalCetakKwitansi(Map<String, dynamic> list) async {
    final db = await _databaseHelper.database;
    try {
      await db.delete(
        'Jurnal',
        where: 'referensi_transaksi_id = ?',
        whereArgs: [list['idpkb']],
      );
      await db.update(
        'TransaksiServis',
        {'status': 'In Proses'},
        where: 'idpkb = ?',
        whereArgs: [list['idpkb']],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await db.update(
        'DetailTransaksiSukuCadangServis',
        {'status': 'In Proses'},
        where: 'transaksi_servis_id = ?',
        whereArgs: [list['idpkb']],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await db.update(
        'DetailTransaksiService',
        {'status': 'In Proses'},
        where: 'transaksi_servis_id = ?',
        whereArgs: [list['idpkb']],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      Exception(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getAllTransaksiServiceComp(
    int transaksiId,
  ) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery(
      'SELECT TransaksiServis.id as ids,idpkb,TransaksiServis.km as kms,merk,model,Kendaraan.plat_nomor,Kendaraan.nomor_rangka,Kendaraan.nomor_mesin,Kendaraan.km,pelanggan_id,Pelanggan.nama as nama_pelanggan,Pelanggan.alamat,Pelanggan.telepon,tanggal_masuk,tanggal_selesai,status,total_biaya_jasa,total_biaya_suku_cadang,total_final,catatan FROM TransaksiServis LEFT JOIN Kendaraan ON TransaksiServis.kendaraan_id = Kendaraan.id LEFT JOIN Pelanggan ON Kendaraan.pelanggan_id = Pelanggan.id WHERE TransaksiServis.idpkb=$transaksiId;',
    );
  }

  Future<List<Map<String, dynamic>>> getAllTransaksiServiceCompbyNorangka(
    String norangka,
  ) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery(
      "SELECT TransaksiServis.id as ids,idpkb,TransaksiServis.km as kms,Kendaraan.plat_nomor,Kendaraan.nomor_rangka,Kendaraan.nomor_mesin,Kendaraan.km,Pelanggan.nama as nama_pelanggan,Pelanggan.alamat,Pelanggan.telepon,tanggal_masuk,tanggal_selesai,status,total_biaya_jasa,total_biaya_suku_cadang,total_final,merk,model,tahun,catatan FROM TransaksiServis LEFT JOIN Kendaraan ON TransaksiServis.kendaraan_id = Kendaraan.id LEFT JOIN Pelanggan ON Kendaraan.pelanggan_id = Pelanggan.id WHERE LOWER(Kendaraan.nomor_rangka) LIKE '%${norangka.toLowerCase()}%';",
    );
  }

  Future<List<Map<String, dynamic>>> getAllDetailJasaTransaksiServiceComp(
    int transaksiId,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DetailTransaksiService.transaksi_servis_id as ids,disc,DetailTransaksiService.id,Jasa.id as id_jasa,Jasa.nama_jasa,harga_jasa_saat_itu,Jasa.harga_beli,Jasa.harga_jual,DetailTransaksiService.jumlah,DetailTransaksiService.sub_total,catatan_layanan FROM DetailTransaksiService INNER JOIN Jasa ON DetailTransaksiService.jasa_id=Jasa.id WHERE DetailTransaksiService.transaksi_servis_id=$transaksiId;',
    );
    return maps;
  }

  Future<List<Map<String, dynamic>>> getAllDetailJasaTransaksi() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DetailTransaksiService.id as id_detail,DetailTransaksiService.transaksi_servis_id as ids,disc,Jasa.id,Jasa.id as id_jasa,Jasa.nama_jasa,harga_jasa_saat_itu,Jasa.harga_beli,Jasa.harga_jual,DetailTransaksiService.jumlah,DetailTransaksiService.sub_total,catatan_layanan FROM DetailTransaksiService INNER JOIN Jasa ON DetailTransaksiService.jasa_id=Jasa.id;',
    );
    return maps;
  }

  Future<List<Map<String, dynamic>>> getAllDetailPartTransaksi() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DetailTransaksiSukuCadangServis.id as id_detail,DetailTransaksiSukuCadangServis.transaksi_servis_id as ids,disc,DetailTransaksiSukuCadangServis.id,SukuCadang.id as id_part,kode_part,nama_part,stok,DetailTransaksiSukuCadangServis.harga_jual_saat_itu,harga_beli,harga_jual,DetailTransaksiSukuCadangServis.jumlah,DetailTransaksiSukuCadangServis.sub_total FROM DetailTransaksiSukuCadangServis INNER JOIN SukuCadang ON DetailTransaksiSukuCadangServis.suku_cadang_id=SukuCadang.id;',
    );
    return maps;
  }

  Future<void> cetakDetailTransaksiSukuCadangServis(
    int id,
    int stok,
    int idPart,
  ) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel, update ini akan dipanggil
    // di dalam transaksi di BLoC.
    await db.update(
      'DetailTransaksiSukuCadangServis',
      {'status': 'Komplit'},
      where: 'suku_cadang_id = ?',
      whereArgs: [id],
    );
    await db.update(
      'SukuCadang',
      {'stok': stok},
      where: 'id = ?',
      whereArgs: [idPart],
    );
  }

  Future<void> batalcetakDetailTransaksiSukuCadangServis(
    int id,
    int stok,
    int idPart,
  ) async {
    final db = await _databaseHelper.database;
    // Note: Untuk operasi yang melibatkan banyak tabel, update ini akan dipanggil
    // di dalam transaksi di BLoC.
    await db.update(
      'DetailTransaksiSukuCadangServis',
      {'status': 'In Proses'},
      where: 'id = ?',
      whereArgs: [id],
    );
    await db.update(
      'SukuCadang',
      {'stok': stok},
      where: 'id = ?',
      whereArgs: [idPart],
    );
  }

  Future<List<Map<String, dynamic>>> getAllDetailPartTransaksiServiceComp(
    int transaksiId,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DetailTransaksiSukuCadangServis.id as id,DetailTransaksiSukuCadangServis.transaksi_servis_id as ids,disc,SukuCadang.id as id_part,status,kode_part,nama_part,stok,DetailTransaksiSukuCadangServis.harga_jual_saat_itu,harga_beli,harga_jual,DetailTransaksiSukuCadangServis.jumlah,DetailTransaksiSukuCadangServis.sub_total FROM DetailTransaksiSukuCadangServis INNER JOIN SukuCadang ON DetailTransaksiSukuCadangServis.suku_cadang_id=SukuCadang.id WHERE DetailTransaksiSukuCadangServis.transaksi_servis_id=$transaksiId;',
    );

    return maps;
  }

  //
  // Ambil detail lengkap sebuah transaksi service berdasarkan ID
  Future<TransaksiServiceDetail?> getTransaksiServiceDetail(
    int transaksiId,
  ) async {
    final db = await _databaseHelper.database;

    // Ambil data transaksi utama
    final List<Map<String, dynamic>> transaksiMaps = await db.query(
      'TransaksiServis',
      where: 'idpkb = ?',
      whereArgs: [transaksiId],
    );

    if (transaksiMaps.isEmpty) {
      return null;
    }

    final transaksi = TransaksiServis.fromMap(transaksiMaps.first);

    // Ambil data kendaraan (jika ada)
    Kendaraan? vehicle;
    final List<Map<String, dynamic>> vehicleMaps = await db.query(
      'Kendaraan',
      where: 'id = ?',
      whereArgs: [transaksi.kendaraanId],
    );
    if (vehicleMaps.isNotEmpty) {
      vehicle = Kendaraan.fromMap(vehicleMaps.first);
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
    final List<Map<String, dynamic>> detailMaps = await db.rawQuery(
      'SELECT DetailTransaksiService.id as id,transaksi_servis_id,Jasa.id as jasa_id,nama_jasa,disc,jumlah,harga_jasa_saat_itu,sub_total FROM DetailTransaksiService INNER JOIN Jasa ON Jasa.id=DetailTransaksiService.jasa_id WHERE DetailTransaksiService.transaksi_servis_id=$transaksiId;',
    );
    final details = List.generate(detailMaps.length, (i) {
      return DetailTransaksiService.fromMap(detailMaps[i]);
    });
    // Ambil detail item service
    final List<Map<String, dynamic>> detailMapsp = await db.rawQuery(
      'SELECT DetailTransaksiSukuCadangServis.id,transaksi_servis_id,nama_part,jumlah,disc,harga_jual_saat_itu,sub_total,SukuCadang.id as suku_cadang_id FROM DetailTransaksiSukuCadangServis INNER JOIN SukuCadang ON SukuCadang.id=DetailTransaksiSukuCadangServis.suku_cadang_id WHERE transaksi_servis_id=$transaksiId;',
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

  // Tambahkan transaksi service baru
  Future<int> insertTransaksiService(TransaksiServis transaksi) async {
    final db = await _databaseHelper.database;
    return await db.insert('transaksi_service', transaksi.toMap());
  }

  // Perbarui transaksi service
  Future<int> updateTransaksiService(TransaksiServis transaksi) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'transaksi_service',
      transaksi.toMap(),
      where: 'id = ?',
      whereArgs: [transaksi.id],
    );
  }

  // Hapus transaksi service
  Future<int> deleteTransaksiService(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'transaksi_service',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
