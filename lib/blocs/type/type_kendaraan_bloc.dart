// lib/bloc/type_kendaraan/type_kendaraan_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/type_kendaraan_repository.dart';

import 'type_kendaraan_event.dart';
import 'type_kendaraan_state.dart';

class TypeKendaraanBloc extends Bloc<TypeKendaraanEvent, TypeKendaraanState> {
  final TypeKendaraanRepository _repository;

  TypeKendaraanBloc(this._repository) : super(TypeKendaraanInitial()) {
    on<LoadTypeKendaraan>(_onLoadTypeKendaraan);
    on<AddTypeKendaraan>(_onAddTypeKendaraan);
    on<UpdateTypeKendaraan>(_onUpdateTypeKendaraan);
    on<DeleteTypeKendaraan>(_onDeleteTypeKendaraan);
  }

  Future<void> _onLoadTypeKendaraan(
    LoadTypeKendaraan event,
    Emitter<TypeKendaraanState> emit,
  ) async {
    emit(TypeKendaraanLoading());
    try {
      final types = await _repository.getAllTypeKendaraan();
      final models = await _repository.getMerkKendaraanBymerkId();
      emit(TypeKendaraanLoaded(types: types, merks: models));
    } catch (e) {
      emit(TypeKendaraanError('Gagal memuat tipe kendaraan: ${e.toString()}'));
    }
  }

  Future<void> _onAddTypeKendaraan(
    AddTypeKendaraan event,
    Emitter<TypeKendaraanState> emit,
  ) async {
    try {
      await _repository.insertTypeKendaraan(event.type);
      add(const LoadTypeKendaraan()); // Muat ulang daftar setelah penambahan
    } catch (e) {
      emit(
        TypeKendaraanError('Gagal menambahkan tipe kendaraan: ${e.toString()}'),
      );
    }
  }

  Future<void> _onUpdateTypeKendaraan(
    UpdateTypeKendaraan event,
    Emitter<TypeKendaraanState> emit,
  ) async {
    try {
      await _repository.updateTypeKendaraan(event.type);
      add(const LoadTypeKendaraan()); // Muat ulang daftar setelah pembaruan
    } catch (e) {
      emit(
        TypeKendaraanError('Gagal memperbarui tipe kendaraan: ${e.toString()}'),
      );
    }
  }

  Future<void> _onDeleteTypeKendaraan(
    DeleteTypeKendaraan event,
    Emitter<TypeKendaraanState> emit,
  ) async {
    try {
      await _repository.deleteTypeKendaraan(event.id);
      add(const LoadTypeKendaraan()); // Muat ulang daftar setelah penghapusan
    } catch (e) {
      emit(
        TypeKendaraanError('Gagal menghapus tipe kendaraan: ${e.toString()}'),
      );
    }
  }
}
