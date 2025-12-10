import 'package:bengkel/repository/kendaraan_repository.dart';
import 'package:bengkel/repository/merk_kendaraan_repository.dart';
import 'package:bengkel/repository/pelanggan_repository.dart';
import 'package:bengkel/repository/type_kendaraan_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'kendaraan_event.dart';
import 'kendaraan_state.dart'; // Import model Kendaraan

class KendaraanBloc extends Bloc<KendaraanEvent, KendaraanState> {
  final KendaraanRepository _kendaraanRepository;
  final PelangganRepository _pelangganRepository;
  final MerkKendaraanRepository _merkKendaraanRepository;
  final TypeKendaraanRepository _typeKendaraanRepository;
  KendaraanBloc(
    this._kendaraanRepository,
    this._pelangganRepository,
    this._merkKendaraanRepository,
    this._typeKendaraanRepository,
  ) : super(KendaraanInitial()) {
    on<LoadKendaraan>(_onLoadKendaraan);
    on<LoadKendaraanById>(_onLoadKendaraanById);
    on<LoadKendaraanAllById>(_onLoadKendaraanAllById);
    on<AddKendaraan>(_onAddKendaraan);
    on<UpdateKendaraan>(_onUpdateKendaraan);
    on<UpdateKmKendaraan>(_onUpdateKmKendaraan);
    on<DeleteKendaraan>(_onDeleteKendaraan);
  }
  Future<void> _onLoadKendaraanAllById(
    LoadKendaraanAllById event,
    Emitter<KendaraanState> emit,
  ) async {
    emit(KendaraanLoading()); // Emit state loading
    try {
      final kendaraanList = await _kendaraanRepository.getKendaraanallById(
        event.id,
      );

      emit(
        KendaraanLoadedAllById(kendaraanList: kendaraanList),
      ); // Emit state loaded dengan data
    } catch (e) {
      emit(
        KendaraanError('Gagal memuat kendaraan: ${e.toString()}'),
      ); // Emit state error
    }
  }

  Future<void> _onLoadKendaraanById(
    LoadKendaraanById event,
    Emitter<KendaraanState> emit,
  ) async {
    emit(KendaraanLoading()); // Emit state loading
    try {
      final kendaraanList = await _kendaraanRepository
          .getKendaraanByLicensePlate(event.noChasis);
      final ada = await _kendaraanRepository.getKendaraanByLicensePlateSts(
        kendaraanList.firstOrNull?.id ?? 0,
      );
      final pelangganList = await _pelangganRepository.getAllPelanggan();

      emit(
        KendaraanLoadedById(
          kendaraanList: kendaraanList,
          pelangganList: pelangganList,
          ada: ada,
        ),
      ); // Emit state loaded dengan data
    } catch (e) {
      emit(
        KendaraanError('Gagal memuat kendaraan: ${e.toString()}'),
      ); // Emit state error
    }
  }

  // Handler untuk event LoadKendaraan
  Future<void> _onLoadKendaraan(
    LoadKendaraan event,
    Emitter<KendaraanState> emit,
  ) async {
    emit(KendaraanLoading()); // Emit state loading
    try {
      final kendaraanList = await _kendaraanRepository.getKendaraans();
      final pelangganList = await _pelangganRepository.getAllPelanggan();
      final merkList = await _merkKendaraanRepository.getAllMerkKendaraan();
      final typeList = await _typeKendaraanRepository.getAllTypeKendaraan();
      emit(
        KendaraanLoaded(
          kendaraanList: kendaraanList,
          pelangganList: pelangganList,
          typeList: typeList,
          merkList: merkList,
        ),
      ); // Emit state loaded dengan data
    } catch (e) {
      emit(
        KendaraanError('Gagal memuat kendaraan: ${e.toString()}'),
      ); // Emit state error
    }
  }

  // Handler untuk event AddKendaraan
  Future<void> _onAddKendaraan(
    AddKendaraan event,
    Emitter<KendaraanState> emit,
  ) async {
    try {
      await _kendaraanRepository.insertKendaraan(event.kendaraan);
      // Setelah berhasil menambahkan, muat ulang daftar kendaraan
      add(const LoadKendaraan());
    } catch (e) {
      emit(KendaraanError('Gagal menambahkan kendaraan: ${e.toString()}'));
    }
  }

  // Handler untuk event UpdateKendaraan
  Future<void> _onUpdateKendaraan(
    UpdateKendaraan event,
    Emitter<KendaraanState> emit,
  ) async {
    try {
      await _kendaraanRepository.updateKendaraan(event.kendaraan);
      // Setelah berhasil memperbarui, muat ulang daftar kendaraan
      add(const LoadKendaraan());
    } catch (e) {
      emit(KendaraanError('Gagal memperbarui kendaraan: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateKmKendaraan(
    UpdateKmKendaraan event,
    Emitter<KendaraanState> emit,
  ) async {
    try {
      await _kendaraanRepository.updateKMKendaraan(event.km, event.kendaraanId);
      // Setelah berhasil memperbarui, muat ulang daftar kendaraan
      add(const LoadKendaraan());
    } catch (e) {
      emit(KendaraanError('Gagal memperbarui kilometer: ${e.toString()}'));
    }
  }

  // Handler untuk event DeleteKendaraan
  Future<void> _onDeleteKendaraan(
    DeleteKendaraan event,
    Emitter<KendaraanState> emit,
  ) async {
    try {
      await _kendaraanRepository.deleteKendaraan(event.id);
      // Setelah berhasil menghapus, muat ulang daftar kendaraan
      add(const LoadKendaraan());
    } catch (e) {
      emit(KendaraanError('Gagal menghapus kendaraan: ${e.toString()}'));
    }
  }
}
