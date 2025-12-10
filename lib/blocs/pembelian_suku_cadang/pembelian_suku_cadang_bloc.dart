import 'package:bengkel/database/databasehelper.dart';
import 'package:bengkel/repository/detail_pembelian_suku_cadang_repository.dart';
import 'package:bengkel/repository/pembelian_suku_cadang_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'pembelian_suku_cadang_event.dart';
import 'pembelian_suku_cadang_state.dart';

class PembelianSukuCadangBloc
    extends Bloc<PembelianSukuCadangEvent, PembelianSukuCadangState> {
  final PembelianSukuCadangRepository _pembelianSukuCadangRepository;
  final DetailPembelianSukuCadangRepository
  _detailPembelianSukuCadangRepository;
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // Untuk jurnal

  PembelianSukuCadangBloc(
    this._pembelianSukuCadangRepository,
    this._detailPembelianSukuCadangRepository,
  ) : super(PembelianSukuCadangInitial()) {
    on<LoadPembelianSukuCadang>(_onLoadPembelianSukuCadang);
    on<LoadPembelianSukuCadangDetail>(_onLoadPembelianSukuCadangDetail);
    on<AddPembelianSukuCadang>(_onAddPembelianSukuCadang);
    on<UpdatePembelianSukuCadang>(_onUpdatePembelianSukuCadang);
    on<DeletePembelianSukuCadang>(_onDeletePembelianSukuCadang);
  }

  // Handler untuk event LoadPembelianSukuCadang
  Future<void> _onLoadPembelianSukuCadang(
    LoadPembelianSukuCadang event,
    Emitter<PembelianSukuCadangState> emit,
  ) async {
    emit(PembelianSukuCadangLoading());
    try {
      final pembelianSukuCadangList =
          await _pembelianSukuCadangRepository.getAllPembelianSukuCadang();
      emit(
        PembelianSukuCadangLoaded(
          pembelianSukuCadangList: pembelianSukuCadangList,
        ),
      );
    } catch (e) {
      emit(
        PembelianSukuCadangError(
          'Gagal memuat pembelian suku cadang: ${e.toString()}',
        ),
      );
    }
  }

  // Handler untuk event LoadPembelianSukuCadangDetail (untuk mode edit)
  Future<void> _onLoadPembelianSukuCadangDetail(
    LoadPembelianSukuCadangDetail event,
    Emitter<PembelianSukuCadangState> emit,
  ) async {
    emit(PembelianSukuCadangLoading());
    try {
      final pembelian =
          await _pembelianSukuCadangRepository.getAllPembelianSukuCadang();

      final details =
          await _detailPembelianSukuCadangRepository.getDetailsByPembelian();
      emit(
        PembelianSukuCadangDetailLoaded(
          pembelianSukuCadangList: pembelian,
          detailSukuCadang: details,
        ),
      );
    } catch (e) {
      emit(
        PembelianSukuCadangError(
          'Gagal memuat detail pembelian: ${e.toString()}',
        ),
      );
    }
  }

  // Handler untuk event AddPembelianSukuCadang
  Future<void> _onAddPembelianSukuCadang(
    AddPembelianSukuCadang event,
    Emitter<PembelianSukuCadangState> emit,
  ) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert('PembelianSukuCadang', event.pembelianSukuCadang.toMap()).then((
        pembelianId,
      ) async {
        // 1. Insert PembelianSukuCadang utama

        // 2. Insert DetailPembelianSukuCadang dan update stok
        for (var detail in event.detailSukuCadang) {
          final detailMap = detail.toMap();
          detailMap['pembelian_id'] =
              pembelianId; // Kaitkan dengan ID pembelian baru
          await db.insert('DetailPembelianSukuCadang', detailMap);
          await db.insert('InOutSukuCadang', {
            'trkid': pembelianId,
            'sukucadangid': detail.sukuCadangId,
            'masuk': detail.jumlah,
          });
          // Tingkatkan stok suku cadang
          await db.execute(
            'UPDATE SukuCadang SET stok = stok + ? WHERE id = ?',
            [detail.jumlah, detail.sukuCadangId],
          );
        }

        // 3. Pencatatan Jurnal (Kas/Utang Usaha (K) vs Persediaan Suku Cadang (D))
        final tanggalJurnal = DateTime.now().toIso8601String();
        final persediaanAkun = await _databaseHelper.getAkunByName(
          'Persediaan Suku Cadang',
        );
        final kasAkun = await _databaseHelper.getAkunByName(
          'Kas',
        ); // Atau Utang Usaha jika pembelian kredit

        if (persediaanAkun == null || kasAkun == null) {
          throw Exception(
            "Akun akuntansi yang diperlukan (Persediaan Suku Cadang / Kas) tidak ditemukan.",
          );
        }

        // Debit Persediaan Suku Cadang
        await db.insert('Jurnal', {
          'tanggal': tanggalJurnal,
          'deskripsi': 'Pembelian Suku Cadang #$pembelianId',
          'referensi_transaksi_id': pembelianId,
          'tipe_referensi': 'Pembelian',
          'debit': event.pembelianSukuCadang.totalPembelian, // Total pembelian
          'kredit': 0.0,
          'akun_id': persediaanAkun['id'],
        });

        // Kredit Kas (asumsi tunai untuk contoh ini)
        await db.insert('Jurnal', {
          'tanggal': tanggalJurnal,
          'deskripsi': 'Pembayaran Pembelian Suku Cadang #$pembelianId',
          'referensi_transaksi_id': pembelianId,
          'tipe_referensi': 'Pembelian',
          'debit': 0.0,
          'kredit': event.pembelianSukuCadang.totalPembelian, // Total pembelian
          'akun_id': kasAkun['id'],
        });
      });

      add(
        const LoadPembelianSukuCadangDetail(),
      ); // Muat ulang daftar setelah berhasil
    } catch (e) {
      emit(
        PembelianSukuCadangError(
          'Gagal menambahkan pembelian suku cadang: ${e.toString()}',
        ),
      );
    }
  }

  // Handler untuk event UpdatePembelianSukuCadang
  Future<void> _onUpdatePembelianSukuCadang(
    UpdatePembelianSukuCadang event,
    Emitter<PembelianSukuCadangState> emit,
  ) async {
    try {
      final db = await _databaseHelper.database;

      final int pembelianId = event.pembelianSukuCadang.id!;

      // 1. Revert stok dan hapus detail lama
      final oldDetails = await _detailPembelianSukuCadangRepository
          .getDetailsByPembelianId(pembelianId);
      for (var detail in oldDetails) {
        await db.execute('UPDATE SukuCadang SET stok = stok - ? WHERE id = ?', [
          detail.jumlah,
          detail.sukuCadangId,
        ]);
      }
      await db.delete(
        'DetailPembelianSukuCadang',
        where: 'pembelian_id = ?',
        whereArgs: [pembelianId],
      );
      await db.delete(
        'InOutSukuCadang',
        where: 'trkid = ?',
        whereArgs: [pembelianId],
      );
      // 2. Update PembelianSukuCadang utama
      await db.update(
        'PembelianSukuCadang',
        event.pembelianSukuCadang.toMap(),
        where: 'id = ?',
        whereArgs: [pembelianId],
      );

      // 3. Insert detail baru dan update stok
      for (var detail in event.detailSukuCadang) {
        final detailMap = detail.toMap();
        detailMap['pembelian_id'] = pembelianId;
        await db.insert('DetailPembelianSukuCadang', detailMap);
        await db.insert('InOutSukuCadang', {
          'trkid': pembelianId,
          'sukucadangid': detail.sukuCadangId,
          'masuk': detail.jumlah,
        });
        // Tingkatkan stok suku cadang
        await db.execute('UPDATE SukuCadang SET stok = stok + ? WHERE id = ?', [
          detail.jumlah,
          detail.sukuCadangId,
        ]);
      }

      // 4. Sesuaikan Jurnal
      // Hapus entri jurnal lama terkait pembelian ini
      await db.delete(
        'Jurnal',
        where: 'referensi_transaksi_id = ? AND tipe_referensi = ?',
        whereArgs: [pembelianId, 'Pembelian'],
      );

      final tanggalJurnal = DateTime.now().toIso8601String();
      final persediaanAkun = await _databaseHelper.getAkunByName(
        'Persediaan Suku Cadang',
      );
      final kasAkun = await _databaseHelper.getAkunByName('Kas');

      if (persediaanAkun == null || kasAkun == null) {
        throw Exception(
          "Akun akuntansi yang diperlukan (Persediaan Suku Cadang / Kas) tidak ditemukan.",
        );
      }

      // Debit Persediaan Suku Cadang (baru)
      await db.insert('Jurnal', {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Pembelian Suku Cadang #$pembelianId (Update)',
        'referensi_transaksi_id': pembelianId,
        'tipe_referensi': 'Pembelian',
        'debit': event.pembelianSukuCadang.totalPembelian,
        'kredit': 0.0,
        'akun_id': persediaanAkun['id'],
      });

      // Kredit Kas (baru)
      await db.insert('Jurnal', {
        'tanggal': tanggalJurnal,
        'deskripsi': 'Pembayaran Pembelian Suku Cadang #$pembelianId (Update)',
        'referensi_transaksi_id': pembelianId,
        'tipe_referensi': 'Pembelian',
        'debit': 0.0,
        'kredit': event.pembelianSukuCadang.totalPembelian,
        'akun_id': kasAkun['id'],
      });

      add(
        const LoadPembelianSukuCadangDetail(),
      ); // Muat ulang daftar setelah berhasil
    } catch (e) {
      emit(
        PembelianSukuCadangError(
          'Gagal memperbarui pembelian suku cadang: ${e.toString()}',
        ),
      );
    }
  }

  // Handler untuk event DeletePembelianSukuCadang
  Future<void> _onDeletePembelianSukuCadang(
    DeletePembelianSukuCadang event,
    Emitter<PembelianSukuCadangState> emit,
  ) async {
    try {
      final db = await _databaseHelper.database;

      final int pembelianId = event.id;
      // 1. Revert stok suku cadang yang terkait dengan pembelian ini
      final details = await _detailPembelianSukuCadangRepository
          .getDetailsByPembelianId(pembelianId);
      for (var detail in details) {
        await db.execute(
          'UPDATE SukuCadang SET stok = stok - ? WHERE id = ?', // Kurangi stok karena pembelian dibatalkan
          [detail.jumlah, detail.sukuCadangId],
        );
      }

      // 2. Hapus entri jurnal terkait pembelian ini
      await db.delete(
        'Jurnal',
        where: 'referensi_transaksi_id = ? AND tipe_referensi = ?',
        whereArgs: [pembelianId, 'Pembelian'],
      );
      await db.delete(
        'DetailPembelianSukuCadang',
        where: 'pembelian_id = ?',
        whereArgs: [pembelianId],
      );
      // 3. Hapus pembelian suku cadang (CASCADE akan menghapus detailnya juga)
      await db.delete(
        'PembelianSukuCadang',
        where: 'id = ?',
        whereArgs: [pembelianId],
      );
      await db.delete(
        'InOutSukuCadang',
        where: 'trkid = ?',
        whereArgs: [pembelianId],
      );
      add(
        const LoadPembelianSukuCadangDetail(),
      ); // Muat ulang daftar setelah berhasil
    } catch (e) {
      emit(
        PembelianSukuCadangError(
          'Gagal menghapus pembelian suku cadang: ${e.toString()}',
        ),
      );
    }
  }
}
