import 'package:flutter_bloc/flutter_bloc.dart';
// Untuk DateTime

import '../../repository/neraca_repository.dart'; // Repository untuk mendapatkan data mentah
import '../../model/jurnal.dart';
import '../../model/account.dart';

import 'neraca_event.dart';
import 'neraca_state.dart';

class NeracaBloc extends Bloc<NeracaEvent, NeracaState> {
  final NeracaRepository _neracaRepository;

  NeracaBloc(this._neracaRepository) : super(NeracaInitial()) {
    on<LoadNeraca>(_onLoadNeraca);
  }

  Future<void> _onLoadNeraca(
    LoadNeraca event,
    Emitter<NeracaState> emit,
  ) async {
    emit(NeracaLoading());
    try {
      final DateTime asOfDate =
          event.asOfDate ??
          DateTime.now(); // Ambil pada tanggal saat ini jika tidak ditentukan
      final List<Akun> allAkun = await _neracaRepository.getAllAkun();
      final List<Jurnal> allJurnal = await _neracaRepository.getAllJurnal(
        untilDate: asOfDate,
      );

      // Map untuk menyimpan saldo akhir setiap akun
      final Map<int, double> accountBalances = {};

      // Inisialisasi saldo semua akun ke 0
      for (var akun in allAkun) {
        accountBalances[akun.id!] = 0.0;
      }

      // Hitung saldo untuk setiap akun dari jurnal
      for (var jurnal in allJurnal) {
        if (accountBalances.containsKey(jurnal.akunId)) {
          // Debit meningkatkan saldo untuk akun aset/beban, mengurangi untuk kewajiban/ekuitas/pendapatan
          // Kredit mengurangi saldo untuk akun aset/beban, meningkatkan untuk kewajiban/ekuitas/pendapatan
          // Ini adalah konvensi akuntansi dasar.
          // Untuk neraca, kita perlu saldo akhir akun.
          // Aset = Debit - Kredit
          // Kewajiban = Kredit - Debit
          // Ekuitas = Kredit - Debit

          final Akun akun = allAkun.firstWhere(
            (a) => a.id == jurnal.akunId,
            orElse: () => Akun(id: -1, namaAkun: '', jenisAkun: ''),
          ); // Fallback
          if (akun.id != -1) {
            if (akun.jenisAkun == 'Asset' || akun.jenisAkun == 'Expense') {
              // Beban juga sifatnya debit, tapi di neraca hanya aset
              accountBalances[jurnal.akunId] =
                  (accountBalances[jurnal.akunId] ?? 0.0) +
                  jurnal.debit -
                  jurnal.kredit;
            } else if (akun.jenisAkun == 'Liability' ||
                akun.jenisAkun == 'Equity' ||
                akun.jenisAkun == 'Revenue') {
              // Pendapatan juga sifatnya kredit, tapi di neraca hanya kewajiban/ekuitas
              accountBalances[jurnal.akunId] =
                  (accountBalances[jurnal.akunId] ?? 0.0) +
                  jurnal.kredit -
                  jurnal.debit;
            }
          }
        }
      }

      // Kategorikan saldo ke Aset, Kewajiban, Ekuitas
      final Map<String, double> totalAset = {};
      final Map<String, double> totalKewajiban = {};
      final Map<String, double> totalEkuitas = {};

      double grandTotalAset = 0.0;
      double grandTotalKewajiban = 0.0;
      double grandTotalEkuitas = 0.0;

      for (var akun in allAkun) {
        final double balance = accountBalances[akun.id!] ?? 0.0;
        if (balance != 0) {
          // Hanya tampilkan akun dengan saldo tidak nol
          if (akun.jenisAkun == 'Asset') {
            totalAset[akun.namaAkun] = balance;
            grandTotalAset += balance;
          } else if (akun.jenisAkun == 'Liability') {
            totalKewajiban[akun.namaAkun] = balance;
            grandTotalKewajiban += balance;
          } else if (akun.jenisAkun == 'Equity') {
            totalEkuitas[akun.namaAkun] = balance;
            grandTotalEkuitas += balance;
          }
          // Akun Pendapatan dan Beban akan masuk ke Ekuitas (melalui Laba Ditahan/Modal)
          // Untuk neraca sederhana, kita bisa mengasumsikan saldo pendapatan/beban sudah masuk ke ekuitas
          // atau diabaikan jika hanya menampilkan akun neraca murni.
          // Untuk laporan neraca yang akurat, Laba/Rugi dari Pendapatan dan Beban akan ditambahkan ke Ekuitas.
          // Ini membutuhkan perhitungan Laba/Rugi terpisah atau agregasi langsung di sini.
          // Untuk kesederhanaan awal, kita hanya akan menampilkan akun Aset, Kewajiban, Ekuitas langsung.
        }
      }

      // Pastikan persamaan dasar akuntansi Aset = Kewajiban + Ekuitas
      // Jika tidak sama, ada masalah dalam perhitungan atau data jurnal.
      // Anda bisa menambahkan assert atau logging di sini.
      // assert(grandTotalAset == (grandTotalKewajiban + grandTotalEkuitas));

      final neracaData = NeracaData(
        totalAset: totalAset,
        totalKewajiban: totalKewajiban,
        totalEkuitas: totalEkuitas,
        grandTotalAset: grandTotalAset,
        grandTotalKewajiban: grandTotalKewajiban,
        grandTotalEkuitas: grandTotalEkuitas,
      );

      emit(NeracaLoaded(neracaData: neracaData, asOfDate: asOfDate));
    } catch (e) {
      emit(NeracaError('Gagal menghitung neraca: ${e.toString()}'));
    }
  }
}
