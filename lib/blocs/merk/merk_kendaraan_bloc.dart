// lib/bloc/Merk_kendaraan/Merk_kendaraan_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/merk_kendaraan_repository.dart';

import 'merk_kendaraan_event.dart';
import 'merk_kendaraan_state.dart';

class MerkKendaraanBloc extends Bloc<MerkKendaraanEvent, MerkKendaraanState> {
  final MerkKendaraanRepository _repository;

  MerkKendaraanBloc(this._repository) : super(MerkKendaraanInitial()) {
    on<LoadMerkKendaraan>(_onLoadMerkKendaraan);
    on<AddMerkKendaraan>(_onAddMerkKendaraan);
    on<UpdateMerkKendaraan>(_onUpdateMerkKendaraan);
    on<DeleteMerkKendaraan>(_onDeleteMerkKendaraan);
  }

  Future<void> _onLoadMerkKendaraan(
    LoadMerkKendaraan event,
    Emitter<MerkKendaraanState> emit,
  ) async {
    emit(MerkKendaraanLoading());
    try {
      final merks = await _repository.getAllMerkKendaraan();
      emit(MerkKendaraanLoaded(listmerks: merks));
    } catch (e) {
      emit(MerkKendaraanError('Gagal memuat merk kendaraan: ${e.toString()}'));
    }
  }

  Future<void> _onAddMerkKendaraan(
    AddMerkKendaraan event,
    Emitter<MerkKendaraanState> emit,
  ) async {
    try {
      await _repository.insertMerkKendaraan(event.type);
      add(const LoadMerkKendaraan([])); // Muat ulang daftar setelah penambahan
    } catch (e) {
      emit(
        MerkKendaraanError('Gagal menambahkan merk kendaraan: ${e.toString()}'),
      );
    }
  }

  Future<void> _onUpdateMerkKendaraan(
    UpdateMerkKendaraan event,
    Emitter<MerkKendaraanState> emit,
  ) async {
    try {
      await _repository.updateMerkKendaraan(event.type);
      add(const LoadMerkKendaraan([])); // Muat ulang daftar setelah pembaruan
    } catch (e) {
      emit(
        MerkKendaraanError('Gagal memperbarui merk kendaraan: ${e.toString()}'),
      );
    }
  }

  Future<void> _onDeleteMerkKendaraan(
    DeleteMerkKendaraan event,
    Emitter<MerkKendaraanState> emit,
  ) async {
    try {
      await _repository.deleteMerkKendaraan(event.id);
      add(const LoadMerkKendaraan([])); // Muat ulang daftar setelah penghapusan
    } catch (e) {
      emit(
        MerkKendaraanError('Gagal menghapus merk kendaraan: ${e.toString()}'),
      );
    }
  }
}
