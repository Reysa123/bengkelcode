import 'package:bengkel/repository/pelanggan_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import '../../repositories/pelanggan_repository.dart'; // Anda perlu membuat PelangganRepository ini
import 'pelanggan_event.dart';
import 'pelanggan_state.dart';// Import model Pelanggan

class PelangganBloc extends Bloc<PelangganEvent, PelangganState> {
  final PelangganRepository _pelangganRepository;

  PelangganBloc(this._pelangganRepository) : super(PelangganInitial()) {
    on<LoadPelanggan>(_onLoadPelanggan);
    on<AddPelanggan>(_onAddPelanggan);
    on<UpdatePelanggan>(_onUpdatePelanggan);
    on<DeletePelanggan>(_onDeletePelanggan);
  }

  // Handler untuk event LoadPelanggan
  Future<void> _onLoadPelanggan(
    LoadPelanggan event,
    Emitter<PelangganState> emit,
  ) async {
    emit(PelangganLoading()); // Emit state loading
    try {
      final pelangganList = await _pelangganRepository.getAllPelanggan();
      emit(PelangganLoaded(pelangganList: pelangganList)); // Emit state loaded dengan data
    } catch (e) {
      emit(PelangganError('Gagal memuat pelanggan: ${e.toString()}')); // Emit state error
    }
  }

  // Handler untuk event AddPelanggan
  Future<void> _onAddPelanggan(
    AddPelanggan event,
    Emitter<PelangganState> emit,
  ) async {
    try {
      await _pelangganRepository.insertPelanggan(event.pelanggan);
      // Setelah berhasil menambahkan, muat ulang daftar pelanggan
      add(const LoadPelanggan());
    } catch (e) {
      emit(PelangganError('Gagal menambahkan pelanggan: ${e.toString()}'));
    }
  }

  // Handler untuk event UpdatePelanggan
  Future<void> _onUpdatePelanggan(
    UpdatePelanggan event,
    Emitter<PelangganState> emit,
  ) async {
    try {
      await _pelangganRepository.updatePelanggan(event.pelanggan);
      // Setelah berhasil memperbarui, muat ulang daftar pelanggan
      add(const LoadPelanggan());
    } catch (e) {
      emit(PelangganError('Gagal memperbarui pelanggan: ${e.toString()}'));
    }
  }

  // Handler untuk event DeletePelanggan
  Future<void> _onDeletePelanggan(
    DeletePelanggan event,
    Emitter<PelangganState> emit,
  ) async {
    try {
      await _pelangganRepository.deletePelanggan(event.id);
      // Setelah berhasil menghapus, muat ulang daftar pelanggan
      add(const LoadPelanggan());
    } catch (e) {
      emit(PelangganError('Gagal menghapus pelanggan: ${e.toString()}'));
    }
  }
}
