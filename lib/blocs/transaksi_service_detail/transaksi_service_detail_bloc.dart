// lib/bloc/transaksi_service_detail/transaksi_service_detail_bloc.dart
import 'dart:async';

import 'package:bengkel/blocs/transaksi_service_detail/transaksi_detail_service_state.dart';
import 'package:bengkel/blocs/transaksi_service_detail/transaksi_service_detail_event.dart';
import 'package:bengkel/repository/transaksi_service_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransaksiServiceDetailBloc
    extends Bloc<TransaksiServiceDetailEvent, TransaksiServiceDetailState> {
  final TransaksiServiceRepository _repository;
  TransaksiServiceDetailBloc(this._repository)
    : super(TransaksiServiceDetailInitial()) {
    on<LoadTransaksiServiceDetail>(_onLoadTransaksiServiceDetail);
    on<LoadTransaksiService>(_onLoadTransaksiService);
    on<UpdateTransaksiServicePart>(_onUpdatePart);
    on<CetakKwitansi>(_cetakKwitansi);
    on<BatalCetakKwitansi>(_batalCetakKwitansi);
    on<BatalUpdateTransaksiServicePart>(_onBatalCetakPart);
    on<LoadTransaksiServiceDetailJasa>(_onLoadTransaksiServiceDetailJasa);
    on<LoadTransaksiServiceDetailPart>(_onLoadTransaksiServiceDetailPart);
  }
  Future<void> _onUpdatePart(
    UpdateTransaksiServicePart event,
    Emitter<TransaksiServiceDetailState> emit,
  ) async {
    emit(TransaksiServiceDetailLoading());
    try {
      await _repository.cetakDetailTransaksiSukuCadangServis(
        event.id,
        event.stok,
        event.idPart,
      );
      emit(TransaksiServiceLoaded());
    } catch (e) {
      emit(
        TransaksiServiceDetailError(
          'Gagal proses detail transaksi part: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onBatalCetakPart(
    BatalUpdateTransaksiServicePart event,
    Emitter<TransaksiServiceDetailState> emit,
  ) async {
    emit(TransaksiServiceDetailLoading());
    try {
      await _repository.batalcetakDetailTransaksiSukuCadangServis(
        event.id,
        event.stok,
        event.idPart,
      );
      emit(TransaksiServiceLoaded());
    } catch (e) {
      emit(
        TransaksiServiceDetailError(
          'Gagal proses detail transaksi part: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadTransaksiService(
    LoadTransaksiService event,
    Emitter<TransaksiServiceDetailState> emit,
  ) async {
    emit(TransaksiServiceDetailLoading());
    if (event.noc.isNotEmpty) {
      try {
        final history = await _repository.getAllTransaksiServiceCompbyNorangka(
          event.noc,
        );
        final resultJ = await _repository.getAllDetailJasaTransaksi();
        final resultp = await _repository.getAllDetailPartTransaksi();
        if (history.isNotEmpty) {
          emit(
            TransaksiServiceLoaded(his: history, jasa: resultJ, part: resultp),
          );
        } else {
          emit(const TransaksiServiceDetailError('Transaksi tidak ditemukan.'));
        }
      } catch (e) {
        emit(
          TransaksiServiceDetailError(
            'Gagal memuat detail transaksi: ${e.toString()}',
          ),
        );
      }
    }

    if (event.cetakPart > 0) {
      try {
        final resultp = await _repository.getAllDetailPartTransaksiServiceComp(
          event.cetakPart,
        );
        if (resultp.isNotEmpty) {
          emit(TransaksiServiceLoaded(part: resultp));
        } else {
          emit(const TransaksiServiceDetailError('Transaksi tidak ditemukan.'));
        }
      } catch (e) {
        emit(
          TransaksiServiceDetailError(
            'Gagal memuat detail transaksi: ${e.toString()}',
          ),
        );
      }
    } else {
      try {
        final result = await _repository.getAllTransaksiServiceComp(
          event.transaksiId,
        );

        final resultJ = await _repository.getAllDetailJasaTransaksiServiceComp(
          event.transaksiId,
        );
        final resultp = await _repository.getAllDetailPartTransaksiServiceComp(
          event.transaksiId,
        );

        if (result.isNotEmpty || resultJ.isNotEmpty) {
          emit(
            TransaksiServiceLoaded(data: result, jasa: resultJ, part: resultp),
          );
        } else {
          emit(const TransaksiServiceDetailError('Transaksi tidak ditemukan.'));
        }
      } catch (e) {
        emit(
          TransaksiServiceDetailError(
            'Gagal memuat detail transaksi: ${e.toString()}',
          ),
        );
      }
    }
  }

  Future<void> _onLoadTransaksiServiceDetailJasa(
    LoadTransaksiServiceDetailJasa event,
    Emitter<TransaksiServiceDetailState> emit,
  ) async {
    emit(TransaksiServiceDetailLoading());
    try {
      final result = await _repository.getAllTransaksiServiceComp(
        event.transaksiId,
      );
      if (result.isNotEmpty) {
        emit(TransaksiServiceLoadeds(jasa: result));
      } else {
        emit(const TransaksiServiceDetailError('Transaksi tidak ditemukan.'));
      }
    } catch (e) {
      emit(
        TransaksiServiceDetailError(
          'Gagal memuat detail transaksi: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadTransaksiServiceDetailPart(
    LoadTransaksiServiceDetailPart event,
    Emitter<TransaksiServiceDetailState> emit,
  ) async {
    emit(TransaksiServiceDetailLoading());
    try {
      final result = await _repository.getAllTransaksiServiceComp(
        event.transaksiId,
      );
      if (result.isNotEmpty) {
        emit(TransaksiServiceLoaded(data: result));
      } else {
        emit(const TransaksiServiceDetailError('Transaksi tidak ditemukan.'));
      }
    } catch (e) {
      emit(
        TransaksiServiceDetailError(
          'Gagal memuat detail transaksi: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadTransaksiServiceDetail(
    LoadTransaksiServiceDetail event,
    Emitter<TransaksiServiceDetailState> emit,
  ) async {
    emit(TransaksiServiceDetailLoading());
    try {
      final result = await _repository.getTransaksiServiceDetail(
        event.transaksiId,
      );
      if (result != null) {
        emit(TransaksiServiceDetailLoaded(data: result));
      } else {
        emit(const TransaksiServiceDetailError('Transaksi tidak ditemukan.'));
      }
    } catch (e) {
      emit(
        TransaksiServiceDetailError(
          'Gagal memuat detail transaksi: ${e.toString()}',
        ),
      );
    }
  }

  FutureOr<void> _cetakKwitansi(
    CetakKwitansi event,
    Emitter<TransaksiServiceDetailState> emit,
  ) async {
    emit(TransaksiServiceDetailLoading());
    try {
      await _repository.cetakKwitansiService(
        event.list,
        event.listJ,
        event.listP,
      );
    } catch (e) {
      emit(
        TransaksiServiceDetailError('Gagal cetak kwitansi: ${e.toString()}'),
      );
    }
  }

  FutureOr<void> _batalCetakKwitansi(
    BatalCetakKwitansi event,
    Emitter<TransaksiServiceDetailState> emit,
  ) async {
    emit(TransaksiServiceDetailLoading());
    try {
      await _repository.batalCetakKwitansi(event.list);
    } catch (e) {
      emit(
        TransaksiServiceDetailError('Gagal cetak kwitansi: ${e.toString()}'),
      );
    }
  }
}
