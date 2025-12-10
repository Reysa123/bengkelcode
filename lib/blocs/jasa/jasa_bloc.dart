import 'package:bengkel/repository/jasa_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Anda perlu membuat JasaRepository ini
import 'jasa_event.dart';
import 'jasa_state.dart';

class JasaBloc extends Bloc<JasaEvent, JasaState> {
  final JasaRepository _jasaRepository;

  JasaBloc(this._jasaRepository) : super(JasaInitial()) {
    on<LoadJasa>(_onLoadJasa);
    on<AddJasa>(_onAddJasa);
    on<UpdateJasa>(_onUpdateJasa);
    on<DeleteJasa>(_onDeleteJasa);
  }

  // Handler untuk event LoadJasa
  Future<void> _onLoadJasa(LoadJasa event, Emitter<JasaState> emit) async {
    emit(JasaLoading()); // Emit state loading
    try {
      final jasaList = await _jasaRepository.getAllJasa();
      emit(JasaLoaded(jasaList: jasaList)); // Emit state loaded dengan data
    } catch (e) {
      emit(JasaError('Gagal memuat jasa: ${e.toString()}')); // Emit state error
    }
  }

  // Handler untuk event AddJasa
  Future<void> _onAddJasa(AddJasa event, Emitter<JasaState> emit) async {
    try {
      await _jasaRepository.insertJasa(event.jasa);
      // Setelah berhasil menambahkan, muat ulang daftar jasa
      add(const LoadJasa());
    } catch (e) {
      emit(JasaError('Gagal menambahkan jasa: ${e.toString()}'));
    }
  }

  // Handler untuk event UpdateJasa
  Future<void> _onUpdateJasa(UpdateJasa event, Emitter<JasaState> emit) async {
    try {
      await _jasaRepository.updateJasa(event.jasa);
      // Setelah berhasil memperbarui, muat ulang daftar jasa
      add(const LoadJasa());
    } catch (e) {
      emit(JasaError('Gagal memperbarui jasa: ${e.toString()}'));
    }
  }

  // Handler untuk event DeleteJasa
  Future<void> _onDeleteJasa(DeleteJasa event, Emitter<JasaState> emit) async {
    try {
      await _jasaRepository.deleteJasa(event.id);
      // Setelah berhasil menghapus, muat ulang daftar jasa
      add(const LoadJasa());
    } catch (e) {
      emit(JasaError('Gagal menghapus jasa: ${e.toString()}'));
    }
  }
}
