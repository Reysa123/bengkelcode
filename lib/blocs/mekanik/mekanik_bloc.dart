import 'package:bengkel/repository/mekanik_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import '../../repositories/mekanik_repository.dart'; // You will need to create this MekanikRepository
import 'mekanik_event.dart';
import 'mekanik_state.dart'; // Import Mekanik model

class MekanikBloc extends Bloc<MekanikEvent, MekanikState> {
  final MekanikRepository _mekanikRepository;

  MekanikBloc(this._mekanikRepository) : super(MekanikInitial()) {
    on<LoadMekanik>(_onLoadMekanik);
    on<LoadMekaniks>(_onLoadMekaniks);
    on<AddMekanik>(_onAddMekanik);
    on<UpdateMekanik>(_onUpdateMekanik);
    on<DeleteMekanik>(_onDeleteMekanik);
  }

  // Handler for LoadMekanik event
  Future<void> _onLoadMekanik(
    LoadMekanik event,
    Emitter<MekanikState> emit,
  ) async {
    emit(MekanikLoading()); // Emit loading state
    try {
      final mekanikList = await _mekanikRepository.getAllMekanik();
      emit(
        MekanikLoaded(mekanikList: mekanikList),
      ); // Emit loaded state with data
    } catch (e) {
      emit(
        MekanikError('Failed to load mechanics: ${e.toString()}'),
      ); // Emit error state
    }
  }

  Future<void> _onLoadMekaniks(
    LoadMekaniks event,
    Emitter<MekanikState> emit,
  ) async {
    emit(MekanikLoading()); // Emit loading state
    try {
      final mekanikList = await _mekanikRepository.getAllMekanik();
      emit(
        MekanikLoadeds(mekanikList: mekanikList),
      ); // Emit loaded state with data
    } catch (e) {
      emit(
        MekanikError('Failed to load mechanics: ${e.toString()}'),
      ); // Emit error state
    }
  }

  // Handler for AddMekanik event
  Future<void> _onAddMekanik(
    AddMekanik event,
    Emitter<MekanikState> emit,
  ) async {
    try {
      await _mekanikRepository.insertMekanik(event.mekanik);
      // After successful addition, reload the list of mechanics
      add(const LoadMekanik());
    } catch (e) {
      emit(MekanikError('Failed to add mechanic: ${e.toString()}'));
    }
  }

  // Handler for UpdateMekanik event
  Future<void> _onUpdateMekanik(
    UpdateMekanik event,
    Emitter<MekanikState> emit,
  ) async {
    try {
      await _mekanikRepository.updateMekanik(event.mekanik);
      // After successful update, reload the list of mechanics
      add(const LoadMekanik());
    } catch (e) {
      emit(MekanikError('Failed to update mechanic: ${e.toString()}'));
    }
  }

  // Handler for DeleteMekanik event
  Future<void> _onDeleteMekanik(
    DeleteMekanik event,
    Emitter<MekanikState> emit,
  ) async {
    try {
      await _mekanikRepository.deleteMekanik(event.id);
      // After successful deletion, reload the list of mechanics
      add(const LoadMekanik());
    } catch (e) {
      emit(MekanikError('Failed to delete mechanic: ${e.toString()}'));
    }
  }
}
