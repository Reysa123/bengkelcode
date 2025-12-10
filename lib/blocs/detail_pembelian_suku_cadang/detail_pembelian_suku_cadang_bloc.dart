import 'package:bengkel/repository/detail_pembelian_suku_cadang_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'detail_pembelian_suku_cadang_event.dart';
import 'detail_pembelian_suku_cadang_state.dart';

class DetailPembelianSukuCadangBloc extends Bloc<DetailPembelianSukuCadangEvent, DetailPembelianSukuCadangState> {
  final DetailPembelianSukuCadangRepository _repository;

  DetailPembelianSukuCadangBloc(this._repository) : super(DetailPembelianSukuCadangInitial()) {
    on<LoadDetailsByPembelianId>(_onLoadDetailsByPembelianId);
    on<AddDetailPembelianSukuCadang>(_onAddDetailPembelianSukuCadang);
    on<UpdateDetailPembelianSukuCadang>(_onUpdateDetailPembelianSukuCadang);
    on<DeleteDetailPembelianSukuCadang>(_onDeleteDetailPembelianSukuCadang);
    on<DeleteAllDetailsByPembelianId>(_onDeleteAllDetailsByPembelianId);
  }

  Future<void> _onLoadDetailsByPembelianId(
    LoadDetailsByPembelianId event,
    Emitter<DetailPembelianSukuCadangState> emit,
  ) async {
    emit(DetailPembelianSukuCadangLoading());
    try {
      final details = await _repository.getDetailsByPembelianId(event.pembelianId);
      emit(DetailPembelianSukuCadangLoaded(detailsList: details));
    } catch (e) {
      emit(DetailPembelianSukuCadangError('Gagal memuat detail pembelian: ${e.toString()}'));
    }
  }

  Future<void> _onAddDetailPembelianSukuCadang(
    AddDetailPembelianSukuCadang event,
    Emitter<DetailPembelianSukuCadangState> emit,
  ) async {
    try {
      await _repository.insertDetailPembelianSukuCadang(event.detail);
      emit(const DetailPembelianSukuCadangOperationSuccess('Detail berhasil ditambahkan.'));
      // Setelah operasi berhasil, Anda mungkin ingin memuat ulang daftar detail
      // atau memicu event di BLoC PembelianSukuCadang utama untuk refresh total
    } catch (e) {
      emit(DetailPembelianSukuCadangError('Gagal menambahkan detail: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateDetailPembelianSukuCadang(
    UpdateDetailPembelianSukuCadang event,
    Emitter<DetailPembelianSukuCadangState> emit,
  ) async {
    try {
      await _repository.updateDetailPembelianSukuCadang(event.detail);
      emit(const DetailPembelianSukuCadangOperationSuccess('Detail berhasil diperbarui.'));
    } catch (e) {
      emit(DetailPembelianSukuCadangError('Gagal memperbarui detail: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteDetailPembelianSukuCadang(
    DeleteDetailPembelianSukuCadang event,
    Emitter<DetailPembelianSukuCadangState> emit,
  ) async {
    try {
      await _repository.deleteDetailPembelianSukuCadang(event.id);
      emit(const DetailPembelianSukuCadangOperationSuccess('Detail berhasil dihapus.'));
    } catch (e) {
      emit(DetailPembelianSukuCadangError('Gagal menghapus detail: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteAllDetailsByPembelianId(
    DeleteAllDetailsByPembelianId event,
    Emitter<DetailPembelianSukuCadangState> emit,
  ) async {
    try {
      await _repository.deleteAllDetailsByPembelianId(event.pembelianId);
      emit(const DetailPembelianSukuCadangOperationSuccess('Semua detail pembelian berhasil dihapus.'));
    } catch (e) {
      emit(DetailPembelianSukuCadangError('Gagal menghapus semua detail pembelian: ${e.toString()}'));
    }
  }
}
