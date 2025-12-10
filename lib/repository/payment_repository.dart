// lib/repositories/payment_repository.dart
import 'package:bengkel/blocs/payment/payment_state.dart';
import 'package:bengkel/database/databasehelper.dart';

class PaymentRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> updatePaymentStatus(
    int transaksiId,
    String status,
    double pembayaran,
  ) async {
    final db = await _databaseHelper.database;
    await db.update(
      'TransaksiServis',
      {'status': status},
      where: 'idpkb = ?',
      whereArgs: [transaksiId],
    );
    await db.update(
      'DetailTransaksiSukuCadangServis',
      {'status': status},
      where: 'transaksi_servis_id = ?',
      whereArgs: [transaksiId],
    );
    await db.update(
      'DetailTransaksiService',
      {'status': status},
      where: 'transaksi_servis_id = ?',
      whereArgs: [transaksiId],
    );
    final tanggalJurnal = DateTime.now().toIso8601String();
    final piutangUsahaAkun = await _databaseHelper.getAkunByName(
      'Piutang Usaha',
    );
    final kasAkun = await _databaseHelper.getAkunByName('Kas');
    if (piutangUsahaAkun == null || kasAkun == null) {
      throw ("Akun tidak tersedia");
    }
    final a = [
      {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Pembayaran Jasa Servis #$transaksiId',
        'referensi_transaksi_id': transaksiId,
        'tipe_referensi': 'Pembayaran Servis',
        'kredit': pembayaran,
        'debit': 0.0,
        'akun_id': piutangUsahaAkun['id'],
      },
      {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Pembayaran Jasa Servis #$transaksiId',
        'referensi_transaksi_id': transaksiId,
        'tipe_referensi': 'Pembayaran Servis',
        'debit': pembayaran,
        'kredit': 0.0,
        'akun_id': kasAkun['id'],
      },
    ];
    try {
      final batch = db.batch();
      for (var e in a) {
        batch.insert('Jurnal', e);
      }
      batch.commit();
    } catch (e) {
      Exception(e.toString());
    }
  }

  Future<void> updatePembelianPaymentStatus(
    int idTransaksi,
    double pembayaran,
    double total,
    String catatan,
    double disc,
  ) async {
    final db = await _databaseHelper.database;

    try {
      await db.update(
        'PenjualanSukuCadang',
        {'status': 'Lunas', 'catatan': 'Jumlah yang dibayar Rp. $catatan'},
        where: 'transaksi_id = ?',
        whereArgs: [idTransaksi],
      );

      final tanggalJurnal = DateTime.now().toIso8601String();
      final piutangUsahaAkun = await _databaseHelper.getAkunByName(
        'Piutang Usaha',
      );
      final labaAkun = await _databaseHelper.getAkunByName('Laba Ditahan');
      final kasAkun = await _databaseHelper.getAkunByName('Kas');
      if (piutangUsahaAkun == null || kasAkun == null || labaAkun == null) {
        throw ("Akun tidak tersedia");
      }
      final a = [
        {
          'tanggal': tanggalJurnal,
          'deskripsi':
              'Pembayaran Pelunasan Pembelian Suku Cadang #$idTransaksi',
          'referensi_transaksi_id': idTransaksi,
          'tipe_referensi': 'Pembayaran Pembelian Suku Cadang',
          'kredit': total,
          'debit': 0.0,
          'akun_id': piutangUsahaAkun['id'],
        },
        {
          'tanggal': tanggalJurnal,
          'deskripsi': 'Pembayaran Pembelian Suku Cadang #$idTransaksi',
          'referensi_transaksi_id': idTransaksi,
          'tipe_referensi': 'Pembayaran Pembelian Suku Cadang',
          'debit': pembayaran,
          'kredit': 0.0,
          'akun_id': kasAkun['id'],
        },
        {
          'tanggal': tanggalJurnal,
          'deskripsi':
              'Pembayaran Discount Pembelian Suku Cadang #$idTransaksi',
          'referensi_transaksi_id': idTransaksi,
          'tipe_referensi': 'Pembayaran Pembelian Suku Cadang',
          'debit': disc,
          'kredit': 0.0,
          'akun_id': labaAkun['id'],
        },
      ];
      final batch = db.batch();
      for (var e in a) {
        batch.insert('Jurnal', e);
      }
      batch.commit();
    } catch (e) {
      PaymentError(e.toString());
    }
  }
}
