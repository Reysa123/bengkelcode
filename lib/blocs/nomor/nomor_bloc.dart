import 'dart:async';

import 'package:bengkel/blocs/nomor/nomor_event.dart';
import 'package:bengkel/blocs/nomor/nomor_state.dart';
import 'package:bengkel/repository/nomor_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NomorBloc extends Bloc<NomorEvent, NomorState> {
  final NomorRepository _nomorRepository;

  NomorBloc(this._nomorRepository) : super(NomorInitial()) {
    on<LoadNomor>(_onLoadNomor);
    on<UpdateNomor>(_onUpdateNomor);
    on<UpdateNomorTrk>(_onUpdateNomorTrk);
  }

  FutureOr<void> _onLoadNomor(LoadNomor event, Emitter<NomorState> emit) async {
    try {
      final noPkb = await _nomorRepository.getNoPKB();
      final noTrx = await _nomorRepository.getNoTrx();
      emit(NomorLoaded(noPkb: noPkb, notrx: noTrx));
    } catch (e) {
      emit(NomorError('Gagal memuat nomor transaksi servis: ${e.toString()}'));
    }
  }

  FutureOr<void> _onUpdateNomor(
    UpdateNomor event,
    Emitter<NomorState> emit,
  ) async {
    try {
      final noPkb = await _nomorRepository.updateNoPKB();
      emit(NomorLoaded(noPkb: noPkb));
    } catch (e) {
      emit(NomorError('Gagal memuat nomor transaksi servis: ${e.toString()}'));
    }
  }

  FutureOr<void> _onUpdateNomorTrk(
    UpdateNomorTrk event,
    Emitter<NomorState> emit,
  ) async {
    try {
      final noPkb = await _nomorRepository.updateNoTrk();
      emit(NomorLoaded(noPkb: noPkb));
    } catch (e) {
      emit(NomorError('Gagal memuat nomor transaksi part: ${e.toString()}'));
    }
  }
}
