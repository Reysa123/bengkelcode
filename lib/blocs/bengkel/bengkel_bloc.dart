import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/bengkel_repsitory.dart'; // Adjust path
// Adjust path
import 'bengkel_event.dart'; // Adjust path
import 'bengkel_state.dart'; // Adjust path

class BengkelBloc extends Bloc<BengkelEvent, BengkelState> {
  final BengkelRepository _bengkelRepository;

  BengkelBloc(this._bengkelRepository) : super(BengkelInitial()) {
    on<LoadBengkels>(_onLoadBengkels);
    on<AddBengkel>(_onAddBengkel);
    on<UpdateBengkel>(_onUpdateBengkel);
  }

  // Event Handler for LoadBengkels
  Future<void> _onLoadBengkels(
    LoadBengkels event,
    Emitter<BengkelState> emit,
  ) async {
    emit(BengkelLoading());
    try {
      final bengkels = await _bengkelRepository.getBengkel();
      if (bengkels != null) {
        emit(BengkelsLoaded(bengkels: bengkels));
      } else {
        emit(BengkelError('Failed to load Bengkels'));
      }
    } catch (e) {
      emit(BengkelError('Failed to load Bengkels: ${e.toString()}'));
    }
  }

  // Event Handler for AddBengkel
  Future<void> _onAddBengkel(
    AddBengkel event,
    Emitter<BengkelState> emit,
  ) async {
    emit(BengkelLoading()); // Or a more specific 'BengkelAdding' state
    try {
      await _bengkelRepository.setBengkel(event.bengkel);
      // After a successful operation, reload Bengkels to update the UI
      add(const LoadBengkels());
    } catch (e) {
      emit(BengkelError('Failed to add Bengkel: ${e.toString()}'));
    }
  }

  // Event Handler for UpdateBengkel
  Future<void> _onUpdateBengkel(
    UpdateBengkel event,
    Emitter<BengkelState> emit,
  ) async {
    emit(BengkelLoading()); // Or 'BengkelUpdating'
    try {
      await _bengkelRepository.updateBengkel(event.bengkel);
      // emit(const BengkelOperationSuccess('Bengkel updated successfully!'));
      add(const LoadBengkels());
    } catch (e) {
      emit(BengkelError('Failed to update Bengkel: ${e.toString()}'));
    }
  }

  // Event Handler for DeleteBengkel
  // Future<void> _onDeleteBengkel(
  //   DeleteBengkel event,
  //   Emitter<BengkelState> emit,
  // ) async {
  //   emit(BengkelLoading()); // Or 'BengkelDeleting'
  //   try {
  //     await _bengkelRepository.(event.bengkelId);
  //     //emit(const BengkelOperationSuccess('Bengkel deleted successfully!'));
  //     add(const LoadBengkels());
  //   } catch (e) {
  //     emit(BengkelError('Failed to delete Bengkel: ${e.toString()}'));
  //   }
  // }
}
