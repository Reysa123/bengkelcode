import 'package:bengkel/database/databasehelper.dart';
import 'package:bengkel/model/kendaraan.dart';
import 'package:bengkel/model/pelanggan.dart';
import 'package:bengkel/repository/jasa_repository.dart';
import 'package:bengkel/repository/kendaraan_repository.dart';
import 'package:bengkel/repository/part_repository.dart';
import 'package:bengkel/repository/pelanggan_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import for transaction

import '../../repository/transaksi_servis_repository.dart'; // Anda perlu membuat ini
import '../../repository/detail_transaksi_service_repository.dart'; // Anda perlu membuat ini
import '../../repository/detail_transaksi_suku_cadang_servis_repository.dart'; // Anda perlu membuat ini
// Untuk mendapatkan harga jual

import 'transaksi_servis_event.dart';
import 'transaksi_servis_state.dart';

class TransaksiServisBloc
    extends Bloc<TransaksiServisEvent, TransaksiServisState> {
  final TransaksiServisRepository _transaksiServisRepository;
  final DetailTransaksiServiceRepository _detailTransaksiServiceRepository;
  final DetailTransaksiSukuCadangServisRepository
  _detailTransaksiSukuCadangServisRepository;
  final KendaraanRepository _kendaraanRepository;
  final PartRepository _partRepsitory;
  final JasaRepository _jasaRepository;
  final PelangganRepository _pelangganRepository;
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Untuk jurnal

  TransaksiServisBloc(
    this._transaksiServisRepository,
    this._detailTransaksiServiceRepository,
    this._detailTransaksiSukuCadangServisRepository,
    this._partRepsitory,
    this._kendaraanRepository,
    this._pelangganRepository,
    this._jasaRepository,
  ) : super(TransaksiServisInitial()) {
    on<LoadTransaksiServis>(_onLoadTransaksiServis);
    on<LoadTransaksiServisDetail>(_onLoadTransaksiServisDetail);
    on<LoadTransaksiServisByKendaraanId>(_onLoadTransaksiServisByKendaraanId);
    on<AddTransaksiServis>(_onAddTransaksiServis);
    on<UpdateTransaksiServis>(_onUpdateTransaksiServis);
    on<DeleteTransaksiServis>(_onDeleteTransaksiServis);
  }

  // Handler untuk event LoadTransaksiServis
  Future<void> _onLoadTransaksiServis(
    LoadTransaksiServis event,
    Emitter<TransaksiServisState> emit,
  ) async {
    emit(TransaksiServisLoading());
    try {
      final transaksiList =
          await _transaksiServisRepository.getAllTransaksiServis();
      final kend = await _kendaraanRepository.getKendaraans();
      final cust = await _pelangganRepository.getAllPelanggan();
      final jasa =
          await _detailTransaksiServiceRepository.getDetailTransaksiService();
      final part =
          await _detailTransaksiSukuCadangServisRepository
              .getDetailTransaksiSukuCadangServis();
      final jasas = await _jasaRepository.getAllJasa();
      final parts = await _partRepsitory.getParts();

      emit(
        TransaksiServisLoaded(
          transaksiServisList: transaksiList,
          kendServiceList: kend,
          pelangganList: cust,
          jasaServiceList: jasa,
          partServiceList: part,
          part: parts,
          jasa: jasas,
        ),
      );
    } catch (e) {
      emit(
        TransaksiServisError('Gagal memuat transaksi servis: ${e.toString()}'),
      );
    }
  }

  // Handler baru: Memuat transaksi servis berdasarkan ID Kendaraan
  Future<void> _onLoadTransaksiServisByKendaraanId(
    LoadTransaksiServisByKendaraanId event,
    Emitter<TransaksiServisState> emit,
  ) async {
    emit(TransaksiServisLoading());
    try {
      final transaksiList =
          await _transaksiServisRepository.getAllTransaksiServis();
      List<Kendaraan> kendList = [];
      List<Pelanggan> pelangganList = [];

      emit(TransaksiServisLoaded(transaksiServisList: transaksiList));
    } catch (e) {
      emit(
        TransaksiServisError(
          'Gagal memuat riwayat servis kendaraan: ${e.toString()}',
        ),
      );
    }
  }

  // Handler untuk event LoadTransaksiServisDetail (untuk mode edit/view)
  Future<void> _onLoadTransaksiServisDetail(
    LoadTransaksiServisDetail event,
    Emitter<TransaksiServisState> emit,
  ) async {
    emit(TransaksiServisLoading());
    try {
      final transaksi = await _transaksiServisRepository.getTransaksiServisById(
        event.transaksiId,
      );
      if (transaksi == null) {
        emit(TransaksiServisError('Transaksi servis tidak ditemukan.'));
        return;
      }
      // final detailJasa = await _detailTransaksiServiceRepository
      //     .getDetailsByTransaksiServisId(event.transaksiId);
      // final detailSukuCadang = await _detailTransaksiSukuCadangServisRepository
      //     .getDetailsByTransaksiServisId(event.transaksiId);

      emit(
        TransaksiServisDetailLoaded(
          transaksiServis: transaksi,
          // detailJasa: detailJasa,
          // detailSukuCadang: detailSukuCadang,
        ),
      );
    } catch (e) {
      emit(
        TransaksiServisError(
          'Gagal memuat detail transaksi servis: ${e.toString()}',
        ),
      );
    }
  }

  // Handler untuk event AddTransaksiServis
  Future<void> _onAddTransaksiServis(
    AddTransaksiServis event,
    Emitter<TransaksiServisState> emit,
  ) async {
    try {
      final db = await _databaseHelper.database;

      // 1. Insert TransaksiServis utama
      await db.insert('TransaksiServis', event.transaksiServis.toMap());

      // 2. Insert DetailTransaksiService
      for (var detail in event.detailJasa) {
        final detailMap = detail.toMap();
        // detailMap['transaksi_servis_id'] = event.transaksiServis.idpkb;
        await db.insert('DetailTransaksiService', detailMap);
      }

      // 3. Insert DetailTransaksiSukuCadangServis dan update stok
      for (var detail in event.detailSukuCadang) {
        final detailMap = detail.toMap();
        // detailMap['transaksi_servis_id'] = event.transaksiServis.idpkb;
        await db.insert('DetailTransaksiSukuCadangServis', detailMap);
        await db.insert('InOutSukuCadang', {
          'trkid': detail.transaksiServisId,
          'sukucadangid': detail.sukuCadangId,
          'keluar': detail.jumlah,
        });
        // Kurangi stok suku cadang
        await db.execute('UPDATE SukuCadang SET stok = stok - ? WHERE id = ?', [
          detail.jumlah,
          detail.sukuCadangId,
        ]);
      }

      add(const LoadTransaksiServis()); // Muat ulang daftar setelah berhasil
    } catch (e) {
      emit(
        TransaksiServisError(
          'Gagal menambahkan transaksi servis: ${e.toString()}',
        ),
      );
    }
  }

  // Handler untuk event UpdateTransaksiServis
  Future<void> _onUpdateTransaksiServis(
    UpdateTransaksiServis event,
    Emitter<TransaksiServisState> emit,
  ) async {
    try {
      final db = await _databaseHelper.database;

      final int transaksiId = event.transaksiServis.id!;

      // 1. Revert stok dan hapus detail lama (jasa & suku cadang)
      final oldDetailJasa = await _detailTransaksiServiceRepository
          .getDetailsByTransaksiServisId(transaksiId);
      await db.delete(
        'DetailTransaksiService',
        where: 'transaksi_servis_id = ?',
        whereArgs: [transaksiId],
      );

      final oldDetailSukuCadang =
          await _detailTransaksiSukuCadangServisRepository
              .getDetailsByTransaksiServisId(transaksiId);
      for (var detail in oldDetailSukuCadang) {
        await db.execute(
          'UPDATE SukuCadang SET stok = stok + ? WHERE id = ?', // Kembalikan stok
          [detail.jumlah, detail.sukuCadangId],
        );
      }
      await db.delete(
        'DetailTransaksiSukuCadangServis',
        where: 'transaksi_servis_id = ?',
        whereArgs: [transaksiId],
      );
      await db.delete(
        'InOutSukuCadang',
        where: 'trkid = ?',
        whereArgs: [transaksiId],
      );
      // 2. Update TransaksiServis utama
      await db.update(
        'TransaksiServis',
        event.transaksiServis.toMap(),
        where: 'idpkb = ?',
        whereArgs: [transaksiId],
      );

      // 3. Insert detail jasa baru
      for (var detail in event.detailJasa) {
        final detailMap = detail.toMap();
        detailMap['transaksi_servis_id'] = transaksiId;
        await db.insert('DetailTransaksiService', detailMap);
      }

      // 4. Insert detail suku cadang baru dan update stok
      for (var detail in event.detailSukuCadang) {
        final detailMap = detail.toMap();
        detailMap['transaksi_servis_id'] = transaksiId;
        await db.insert('DetailTransaksiSukuCadangServis', detailMap);
        await db.insert('InOutSukuCadang', {
          'trkid': transaksiId,
          'sukucadangid': detail.sukuCadangId,
          'keluar': detail.jumlah,
        });
        // Kurangi stok suku cadang
        await db.execute('UPDATE SukuCadang SET stok = stok - ? WHERE id = ?', [
          detail.jumlah,
          detail.sukuCadangId,
        ]);
      }

      // 5. Sesuaikan Jurnal
      // Hapus entri jurnal lama terkait transaksi ini
      // await db.delete(
      //   'Jurnal',
      //   where: 'referensi_transaksi_id = ? AND tipe_referensi = ?',
      //   whereArgs: [transaksiId, 'Servis'],
      // );

      // final tanggalJurnal = DateTime.now().toIso8601String();
      // final kasAkun = await _databaseHelper.getAkunByName('Kas');
      // final pendapatanServisAkun = await _databaseHelper.getAkunByName(
      //   'Pendapatan Servis',
      // );
      // final persediaanSukuCadangAkun = await _databaseHelper.getAkunByName(
      //   'Persediaan Suku Cadang',
      // );
      // final bebanPokokPenjualanAkun = await _databaseHelper.getAkunByName(
      //   'Beban Pokok Penjualan',
      // );

      // if (kasAkun == null ||
      //     pendapatanServisAkun == null ||
      //     persediaanSukuCadangAkun == null) {
      //   throw Exception("Akun akuntansi yang diperlukan tidak ditemukan.");
      // }

      // // Jurnal untuk Pendapatan Servis (Debit Kas, Kredit Pendapatan Servis)
      // if (event.transaksiServis.totalBiayaJasa > 0) {
      //   await db.insert('Jurnal', {
      //     'tanggal': tanggalJurnal,
      //     'deskripsi': 'Pendapatan Jasa Servis #${transaksiId} (Update)',
      //     'referensi_transaksi_id': transaksiId,
      //     'tipe_referensi': 'Servis',
      //     'debit': event.transaksiServis.totalBiayaJasa,
      //     'kredit': 0.0,
      //     'akun_id': kasAkun['id'],
      //   });
      //   await db.insert('Jurnal', {
      //     'tanggal': tanggalJurnal,
      //     'deskripsi': 'Pendapatan Jasa Servis #${transaksiId} (Update)',
      //     'referensi_transaksi_id': transaksiId,
      //     'tipe_referensi': 'Servis',
      //     'debit': 0.0,
      //     'kredit': event.transaksiServis.totalBiayaJasa,
      //     'akun_id': pendapatanServisAkun['id'],
      //   });
      // }

      // // Jurnal untuk Penjualan Suku Cadang (Debit Kas, Kredit Persediaan Suku Cadang & Beban Pokok Penjualan)
      // if (event.transaksiServis.totalBiayaSukuCadang > 0) {
      //   await db.insert('Jurnal', {
      //     'tanggal': tanggalJurnal,
      //     'deskripsi': 'Penjualan Suku Cadang Servis #${transaksiId} (Update)',
      //     'referensi_transaksi_id': transaksiId,
      //     'tipe_referensi': 'Servis',
      //     'debit': event.transaksiServis.totalBiayaSukuCadang,
      //     'kredit': 0.0,
      //     'akun_id': kasAkun['id'],
      //   });

      //   double totalHargaBeliSukuCadangTerjual = 0.0;
      //   for (var detail in event.detailSukuCadang) {
      //     final sukuCadang = await _partRepsitory.getPartById(
      //       detail.sukuCadangId,
      //     );
      //     if (sukuCadang != null) {
      //       totalHargaBeliSukuCadangTerjual +=
      //           sukuCadang.hargaBeli * detail.jumlah;
      //     }
      //   }

      //   if (bebanPokokPenjualanAkun != null) {
      //     await db.insert('Jurnal', {
      //       'tanggal': tanggalJurnal,
      //       'deskripsi':
      //           'Beban Pokok Penjualan Suku Cadang Servis #${transaksiId} (Update)',
      //       'referensi_transaksi_id': transaksiId,
      //       'tipe_referensi': 'Servis',
      //       'debit': totalHargaBeliSukuCadangTerjual,
      //       'kredit': 0.0,
      //       'akun_id': bebanPokokPenjualanAkun['id'],
      //     });
      //     await db.insert('Jurnal', {
      //       'tanggal': tanggalJurnal,
      //       'deskripsi':
      //           'Pengurangan Persediaan Suku Cadang Servis #${transaksiId} (Update)',
      //       'referensi_transaksi_id': transaksiId,
      //       'tipe_referensi': 'Servis',
      //       'debit': 0.0,
      //       'kredit': totalHargaBeliSukuCadangTerjual,
      //       'akun_id': persediaanSukuCadangAkun['id'],
      //     });
      //   } else {
      //     await db.insert('Jurnal', {
      //       'tanggal': tanggalJurnal,
      //       'deskripsi':
      //           'Penjualan Suku Cadang Servis #${transaksiId} (Update)',
      //       'referensi_transaksi_id': transaksiId,
      //       'tipe_referensi': 'Servis',
      //       'debit': 0.0,
      //       'kredit': event.transaksiServis.totalBiayaSukuCadang,
      //       'akun_id': persediaanSukuCadangAkun['id'],
      //     });
      //   }
      // }

      add(const LoadTransaksiServis()); // Muat ulang daftar setelah berhasil
    } catch (e) {
      emit(
        TransaksiServisError(
          'Gagal memperbarui transaksi servis: ${e.toString()}',
        ),
      );
    }
  }

  // Handler untuk event DeleteTransaksiServis
  Future<void> _onDeleteTransaksiServis(
    DeleteTransaksiServis event,
    Emitter<TransaksiServisState> emit,
  ) async {
    try {
      final db = await _databaseHelper.database;

      final int transaksiId = event.id;

      // 1. Revert stok suku cadang yang terkait dengan transaksi ini
      // final detailSukuCadang = await _detailTransaksiSukuCadangServisRepository
      //     .getDetailsByTransaksiServisId(transaksiId);
      // for (var detail in detailSukuCadang) {
      //   await db.execute(
      //     'UPDATE SukuCadang SET stok = stok + ? WHERE id = ?', // Kembalikan stok
      //     [detail.jumlah, detail.sukuCadangId],
      //   );
      // }

      // 2. Hapus entri jurnal terkait transaksi ini
      await db.delete(
        'Jurnal',
        where: 'referensi_transaksi_id = ? AND tipe_referensi = ?',
        whereArgs: [transaksiId, 'Servis'],
      );

      // 3. Hapus transaksi servis (CASCADE akan menghapus detail jasa & suku cadang juga)
      await db.delete(
        'TransaksiServis',
        where: 'id = ?',
        whereArgs: [transaksiId],
      );
      await db.delete(
        'InOutSukuCadang',
        where: 'trkid = ?',
        whereArgs: [transaksiId],
      );
      add(const LoadTransaksiServis()); // Muat ulang daftar setelah berhasil
    } catch (e) {
      emit(
        TransaksiServisError(
          'Gagal menghapus transaksi servis: ${e.toString()}',
        ),
      );
    }
  }
}
