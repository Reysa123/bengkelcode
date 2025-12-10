import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/jurnal_repository.dart'; // Anda perlu membuat JurnalRepository ini
import '../../repository/accountrepository.dart'; // Untuk mendapatkan nama akun
// Import model Jurnal
// Import model Akun

import 'jurnal_event.dart';
import 'jurnal_state.dart';

class JurnalBloc extends Bloc<JurnalEvent, JurnalState> {
  final JurnalRepository _jurnalRepository;
  final AkunRepository _accountRepository; // Untuk membantu resolusi nama akun

  JurnalBloc(this._jurnalRepository, this._accountRepository)
    : super(JurnalInitial()) {
    on<LoadJurnal>(_onLoadJurnal);
    on<AddJurnal>(_addJurnal);
    on<LoadJurnalByDateRange>(_onLoadJurnalByDateRange);
  }

  // Handler untuk event LoadJurnal
  Future<void> _onLoadJurnal(
    LoadJurnal event,
    Emitter<JurnalState> emit,
  ) async {
    emit(JurnalLoading()); // Emit state loading
    try {
      final jurnalList = await _jurnalRepository.getAllJurnal();
      emit(
        JurnalLoaded(jurnalList: jurnalList),
      ); // Emit state loaded dengan data
    } catch (e) {
      emit(
        JurnalError('Gagal memuat jurnal: ${e.toString()}'),
      ); // Emit state error
    }
  }

  // Handler untuk event LoadJurnalByDateRange
  Future<void> _onLoadJurnalByDateRange(
    LoadJurnalByDateRange event,
    Emitter<JurnalState> emit,
  ) async {
    emit(JurnalLoading());
    try {
      final jurnalList = await _jurnalRepository.getJurnalByDateRange(
        event.startDate,
        event.endDate,
      );
      emit(JurnalLoaded(jurnalList: jurnalList));
    } catch (e) {
      emit(
        JurnalError(
          'Gagal memuat jurnal berdasarkan rentang tanggal: ${e.toString()}',
        ),
      );
    }
  }

  // Metode helper untuk mendapatkan nama akun dari ID (akan digunakan di UI)
  Future<String> getAccountName(int akunId) async {
    final akun = await _accountRepository.getAkunById(akunId);
    return akun?.namaAkun ?? 'Akun Tidak Dikenal';
  }

  FutureOr<void> _addJurnal(AddJurnal event, Emitter<JurnalState> emit) async {
     await _jurnalRepository.insertJurnal(event.jurnal);
  }
}
