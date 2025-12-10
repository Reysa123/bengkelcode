import 'package:bengkel/database/databasehelper.dart';
import 'package:bengkel/repository/detail_penjualan_suku_cadang_repository.dart';
import 'package:bengkel/repository/part_repository.dart';
import 'package:bengkel/repository/penjualan_suku_cadang_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import for transaction

// Untuk mendapatkan harga beli suku cadang

import 'penjualan_suku_cadang_event.dart';
import 'penjualan_suku_cadang_state.dart';

class PenjualanSukuCadangBloc
    extends Bloc<PenjualanSukuCadangEvent, PenjualanSukuCadangState> {
  final PenjualanSukuCadangRepository _penjualanSukuCadangRepository;
  final DetailPenjualanSukuCadangRepository
  _detailPenjualanSukuCadangRepository;
  final PartRepository _sukuCadangRepository;
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Untuk jurnal

  PenjualanSukuCadangBloc(
    this._penjualanSukuCadangRepository,
    this._detailPenjualanSukuCadangRepository,
    this._sukuCadangRepository,
  ) : super(PenjualanSukuCadangInitial()) {
    on<LoadPenjualanSukuCadang>(_onLoadPenjualanSukuCadang);
    on<LoadPenjualanSukuCadangById>(_onLoadPenjualanSukuCadangAllById);
    on<LoadPenjualanSukuCadangDetail>(_onLoadPenjualanSukuCadangDetail);
    on<AddPenjualanSukuCadang>(_onAddPenjualanSukuCadang);
    on<UpdatePenjualanSukuCadang>(_onUpdatePenjualanSukuCadang);
    on<DeletePenjualanSukuCadang>(_onDeletePenjualanSukuCadang);
  }

  // Handler untuk event LoadPenjualanSukuCadang
  Future<void> _onLoadPenjualanSukuCadang(
    LoadPenjualanSukuCadang event,
    Emitter<PenjualanSukuCadangState> emit,
  ) async {
    emit(PenjualanSukuCadangLoading());
    try {
      final penjualanList =
          await _penjualanSukuCadangRepository.getAllPenjualanSukuCadang();

      emit(PenjualanSukuCadangLoaded(penjualanSukuCadangList: penjualanList));
    } catch (e) {
      emit(
        PenjualanSukuCadangError(
          'Gagal memuat penjualan suku cadang: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadPenjualanSukuCadangAllById(
    LoadPenjualanSukuCadangById event,

    Emitter<PenjualanSukuCadangState> emit,
  ) async {
    emit(PenjualanSukuCadangLoading());
    try {
      final penjualanList = await _penjualanSukuCadangRepository
          .getPenjualanSukuCadangAllById(event.penjualanId);

      emit(PenjualanSukuCadangLoaded(penjualanSukuCadangList: penjualanList));
    } catch (e) {
      emit(
        PenjualanSukuCadangError(
          'Gagal memuat penjualan suku cadang: ${e.toString()}',
        ),
      );
    }
  }

  // Handler untuk event LoadPenjualanSukuCadangDetail (untuk mode edit/view)
  Future<void> _onLoadPenjualanSukuCadangDetail(
    LoadPenjualanSukuCadangDetail event,
    Emitter<PenjualanSukuCadangState> emit,
  ) async {
    emit(PenjualanSukuCadangLoading());
    try {
      final penjualan = await _penjualanSukuCadangRepository
          .getPenjualanSukuCadangById(event.penjualanId);
      if (penjualan == null) {
        emit(
          PenjualanSukuCadangError('Penjualan suku cadang tidak ditemukan.'),
        );
        return;
      }
      final details = await _detailPenjualanSukuCadangRepository
          .getDetailsByPenjualanId(event.penjualanId);

      emit(
        PenjualanSukuCadangDetailLoaded(
          penjualanSukuCadang: penjualan,
          detailSukuCadang: details,
        ),
      );
    } catch (e) {
      emit(
        PenjualanSukuCadangError(
          'Gagal memuat detail penjualan suku cadang: ${e.toString()}',
        ),
      );
    }
  }

  // Handler untuk event AddPenjualanSukuCadang
  Future<void> _onAddPenjualanSukuCadang(
    AddPenjualanSukuCadang event,
    Emitter<PenjualanSukuCadangState> emit,
  ) async {
    try {
      final db = await _databaseHelper.database;

      // 1. Insert PenjualanSukuCadang utama
      final int? penjualanId = event.penjualanSukuCadang.transaksiId;
      await db.insert('PenjualanSukuCadang', event.penjualanSukuCadang.toMap());

      // 2. Insert DetailPenjualanSukuCadang dan update stok
      double totalHargaBeliSukuCadangTerjual = 0.0;
      for (var detail in event.detailSukuCadang) {
        final detailMap = detail.toMap();
        detailMap['penjualan_id'] =
            penjualanId; // Kaitkan dengan ID penjualan baru
        await db.insert('DetailPenjualanSukuCadang', detailMap);
        await db.insert('InOutSukuCadang', {
          'trkid': penjualanId,
          'sukucadangid': detail.sukuCadangId,
          'keluar': detail.jumlah,
        });
        // Kurangi stok suku cadang
        await db.rawQuery(
          'UPDATE SukuCadang SET stok = stok - ? WHERE id = ?',
          [detail.jumlah, detail.sukuCadangId],
        );

        // Dapatkan harga beli suku cadang untuk perhitungan HPP
        final sukuCadang = await _sukuCadangRepository.getPartById(
          detail.sukuCadangId,
        );
        if (sukuCadang != null) {
          totalHargaBeliSukuCadangTerjual +=
              sukuCadang.hargaBeli * detail.jumlah;
        }
      }

      // 3. Pencatatan Jurnal
      final tanggalJurnal = DateTime.now().toIso8601String();
      final kasAkun = await _databaseHelper.getAkunByName('Piutang Usaha');
      final labaDitahanAkun = await _databaseHelper.getAkunByName(
        'Laba Ditahan',
      );
      final pendapatanPenjualanAkun = await _databaseHelper.getAkunByName(
        'Pendapatan Penjualan',
      );
      final persediaanSukuCadangAkun = await _databaseHelper.getAkunByName(
        'Persediaan Suku Cadang',
      );
      final bebanPokokPenjualanAkun = await _databaseHelper.getAkunByName(
        'Beban Pembelian Suku Cadang',
      );

      if (kasAkun == null ||
          labaDitahanAkun == null ||
          pendapatanPenjualanAkun == null ||
          persediaanSukuCadangAkun == null ||
          bebanPokokPenjualanAkun == null) {
        throw Exception(
          "Akun akuntansi yang diperlukan (Kas, Pendapatan Penjualan, Persediaan Suku Cadang, Beban Pokok Penjualan) tidak ditemukan.",
        );
      }
      double laba =
          event.penjualanSukuCadang.totalPenjualan -
          totalHargaBeliSukuCadangTerjual;
      // Jurnal untuk Penjualan (Debit Kas, Kredit Pendapatan Penjualan)
      await db.insert('Jurnal', {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Penjualan Suku Cadang #$penjualanId',
        'referensi_transaksi_id': penjualanId,
        'tipe_referensi': 'Penjualan',
        'debit': event.penjualanSukuCadang.totalPenjualan,
        'kredit': 0.0,
        'akun_id': kasAkun['id'],
      });
      await db.insert('Jurnal', {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Penjualan Suku Cadang #$penjualanId',
        'referensi_transaksi_id': penjualanId,
        'tipe_referensi': 'Penjualan',
        'kredit': laba,
        'debit': 0.0,
        'akun_id': labaDitahanAkun['id'],
      });
      await db.insert('Jurnal', {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Penjualan Suku Cadang #$penjualanId',
        'referensi_transaksi_id': penjualanId,
        'tipe_referensi': 'Penjualan',
        'debit': 0.0,
        'kredit': event.penjualanSukuCadang.totalPenjualan,
        'akun_id': pendapatanPenjualanAkun['id'],
      });

      // Jurnal untuk Beban Pokok Penjualan dan pengurangan Persediaan
      await db.insert('Jurnal', {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Beban Pokok Penjualan Suku Cadang #$penjualanId',
        'referensi_transaksi_id': penjualanId,
        'tipe_referensi': 'Penjualan',
        'debit': totalHargaBeliSukuCadangTerjual,
        'kredit': 0.0,
        'akun_id': bebanPokokPenjualanAkun['id'],
      });
      await db.insert('Jurnal', {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Pengurangan Persediaan Suku Cadang #$penjualanId',
        'referensi_transaksi_id': penjualanId,
        'tipe_referensi': 'Penjualan',
        'debit': 0.0,
        'kredit': totalHargaBeliSukuCadangTerjual,
        'akun_id': persediaanSukuCadangAkun['id'],
      });

      add(
        const LoadPenjualanSukuCadang(),
      ); // Muat ulang daftar setelah berhasil
    } catch (e) {
      emit(
        PenjualanSukuCadangError(
          'Gagal menambahkan penjualan suku cadang: ${e.toString()}',
        ),
      );
    }
  }

  // Handler untuk event UpdatePenjualanSukuCadang
  Future<void> _onUpdatePenjualanSukuCadang(
    UpdatePenjualanSukuCadang event,
    Emitter<PenjualanSukuCadangState> emit,
  ) async {
    try {
      final db = await _databaseHelper.database;

      final int penjualanId = event.penjualanSukuCadang.id!;

      // 1. Revert stok dan hapus detail lama
      final oldDetails = await _detailPenjualanSukuCadangRepository
          .getDetailsByPenjualanId(penjualanId);
      for (var detail in oldDetails) {
        await db.execute(
          'UPDATE SukuCadang SET stok = stok + ? WHERE id = ?', // Kembalikan stok
          [detail.jumlah, detail.sukuCadangId],
        );
      }
      await db.delete(
        'DetailPenjualanSukuCadang',
        where: 'penjualan_id = ?',
        whereArgs: [penjualanId],
      );
      await db.delete(
        'InOutSukuCadang',
        where: 'trkid = ?',
        whereArgs: [penjualanId],
      );
      // 2. Update PenjualanSukuCadang utama
      await db.update(
        'PenjualanSukuCadang',
        event.penjualanSukuCadang.toMap(),
        where: 'transaksi_id = ?',
        whereArgs: [penjualanId],
      );

      // 3. Insert detail baru dan update stok
      double totalHargaBeliSukuCadangTerjual = 0.0;
      for (var detail in event.detailSukuCadang) {
        final detailMap = detail.toMap();
        detailMap['penjualan_id'] = penjualanId;
        await db.insert('DetailPenjualanSukuCadang', detailMap);
        await db.insert('InOutSukuCadang', {
          'trkid': penjualanId,
          'sukucadangid': detail.sukuCadangId,
          'keluar': detail.jumlah,
        });
        // Kurangi stok suku cadang
        await db.execute('UPDATE SukuCadang SET stok = stok - ? WHERE id = ?', [
          detail.jumlah,
          detail.sukuCadangId,
        ]);

        final sukuCadang = await _sukuCadangRepository.getPartById(
          detail.sukuCadangId,
        );
        if (sukuCadang != null) {
          totalHargaBeliSukuCadangTerjual +=
              sukuCadang.hargaBeli * detail.jumlah;
        }
      }

      // 4. Sesuaikan Jurnal
      // Hapus entri jurnal lama terkait penjualan ini
      await db.delete(
        'Jurnal',
        where: 'referensi_transaksi_id = ? AND tipe_referensi = ?',
        whereArgs: [penjualanId, 'Penjualan'],
      );

      final tanggalJurnal = DateTime.now().toIso8601String();
      final kasAkun = await _databaseHelper.getAkunByName('Piutang Usaha');
      final labaDitahanAkun = await _databaseHelper.getAkunByName(
        'Laba Ditahan',
      );
      final pendapatanPenjualanAkun = await _databaseHelper.getAkunByName(
        'Pendapatan Penjualan',
      );
      final persediaanSukuCadangAkun = await _databaseHelper.getAkunByName(
        'Persediaan Suku Cadang',
      );
      final bebanPokokPenjualanAkun = await _databaseHelper.getAkunByName(
        'Beban Pokok Penjualan',
      );

      if (kasAkun == null ||
          labaDitahanAkun == null ||
          pendapatanPenjualanAkun == null ||
          persediaanSukuCadangAkun == null ||
          bebanPokokPenjualanAkun == null) {
        throw Exception("Akun akuntansi yang diperlukan tidak ditemukan.");
      }

      // Jurnal untuk Penjualan (Debit Kas, Kredit Pendapatan Penjualan)
      await db.insert('Jurnal', {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Penjualan Suku Cadang #$penjualanId (Update)',
        'referensi_transaksi_id': penjualanId,
        'tipe_referensi': 'Penjualan',
        'debit': event.penjualanSukuCadang.totalPenjualan,
        'kredit': 0.0,
        'akun_id': kasAkun['id'],
      });
      await db.insert('Jurnal', {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Penjualan Suku Cadang #$penjualanId (Update)',
        'referensi_transaksi_id': penjualanId,
        'tipe_referensi': 'Penjualan',
        'debit':
            event.penjualanSukuCadang.totalPenjualan -
            totalHargaBeliSukuCadangTerjual,
        'kredit': 0.0,
        'akun_id': labaDitahanAkun['id'],
      });
      await db.insert('Jurnal', {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Penjualan Suku Cadang #$penjualanId (Update)',
        'referensi_transaksi_id': penjualanId,
        'tipe_referensi': 'Penjualan',
        'debit': 0.0,
        'kredit': event.penjualanSukuCadang.totalPenjualan,
        'akun_id': pendapatanPenjualanAkun['id'],
      });

      // Jurnal untuk Beban Pokok Penjualan dan pengurangan Persediaan
      await db.insert('Jurnal', {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Beban Pokok Penjualan Suku Cadang #$penjualanId (Update)',
        'referensi_transaksi_id': penjualanId,
        'tipe_referensi': 'Penjualan',
        'debit': totalHargaBeliSukuCadangTerjual,
        'kredit': 0.0,
        'akun_id': bebanPokokPenjualanAkun['id'],
      });
      await db.insert('Jurnal', {
        'tanggal': tanggalJurnal,
        'deskripsi':
            'Pengurangan Persediaan Suku Cadang #$penjualanId (Update)',
        'referensi_transaksi_id': penjualanId,
        'tipe_referensi': 'Penjualan',
        'debit': 0.0,
        'kredit': totalHargaBeliSukuCadangTerjual,
        'akun_id': persediaanSukuCadangAkun['id'],
      });

      add(
        const LoadPenjualanSukuCadang(),
      ); // Muat ulang daftar setelah berhasil
    } catch (e) {
      emit(
        PenjualanSukuCadangError(
          'Gagal memperbarui penjualan suku cadang: ${e.toString()}',
        ),
      );
    }
  }

  // Handler untuk event DeletePenjualanSukuCadang
  Future<void> _onDeletePenjualanSukuCadang(
    DeletePenjualanSukuCadang event,
    Emitter<PenjualanSukuCadangState> emit,
  ) async {
    try {
      final db = await _databaseHelper.database;

      final int penjualanId = event.id;

      // 1. Revert stok suku cadang yang terkait dengan penjualan ini
      final details = await _detailPenjualanSukuCadangRepository
          .getDetailsByPenjualanId(penjualanId);
      for (var detail in details) {
        await db.execute(
          'UPDATE SukuCadang SET stok = stok + ? WHERE id = ?', // Kembalikan stok
          [detail.jumlah, detail.sukuCadangId],
        );
      }

      // 2. Hapus entri jurnal terkait penjualan ini
      await db.delete(
        'Jurnal',
        where: 'referensi_transaksi_id = ? AND tipe_referensi = ?',
        whereArgs: [penjualanId, 'Penjualan'],
      );

      // 3. Hapus penjualan suku cadang (CASCADE akan menghapus detailnya juga)
      await db.delete(
        'PenjualanSukuCadang',
        where: 'transaksi_id = ?',
        whereArgs: [penjualanId],
      );
      await db.delete(
        'InOutSukuCadang',
        where: 'trkid = ?',
        whereArgs: [penjualanId],
      );
      await db.delete(
        'DetailPenjualanSukuCadang',
        where: 'penjualan_id = ?',
        whereArgs: [penjualanId],
      );
      add(
        const LoadPenjualanSukuCadang(),
      ); // Muat ulang daftar setelah berhasil
    } catch (e) {
      emit(
        PenjualanSukuCadangError(
          'Gagal menghapus penjualan suku cadang: ${e.toString()}',
        ),
      );
    }
  }
}
