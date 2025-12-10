import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/part_repository.dart'; // Adjust path
// Adjust path
import 'part_event.dart'; // Adjust path
import 'part_state.dart'; // Adjust path

class SukuCadangBloc extends Bloc<PartEvent, PartState> {
  final PartRepository _partRepository;

  SukuCadangBloc(this._partRepository) : super(PartInitial()) {
    on<LoadParts>(_onLoadParts);
    on<AddPart>(_onAddPart);
    on<UpdatePart>(_onUpdatePart);
    on<DeletePart>(_onDeletePart);
    on<AdjustPartStock>(_onAdjustPartStock);
  }

  // Event Handler for LoadParts
  Future<void> _onLoadParts(LoadParts event, Emitter<PartState> emit) async {
    emit(PartLoading());
    try {
      final parts = await _partRepository.getParts();
      emit(PartsLoaded(parts: parts));
    } catch (e) {
      emit(PartError('Failed to load parts: ${e.toString()}'));
    }
  }

  // Event Handler for AddPart
  Future<void> _onAddPart(AddPart event, Emitter<PartState> emit) async {
    emit(PartLoading()); // Or a more specific 'PartAdding' state
    try {
      await _partRepository.insertPart(event.part);
      emit(const PartOperationSuccess('Part added successfully!'));
      // After a successful operation, reload parts to update the UI
      add(const LoadParts());
    } catch (e) {
      emit(PartError('Failed to add part: ${e.toString()}'));
    }
  }

  // Event Handler for UpdatePart
  Future<void> _onUpdatePart(UpdatePart event, Emitter<PartState> emit) async {
    emit(PartLoading()); // Or 'PartUpdating'
    try {
      await _partRepository.updatePart(event.part);
      emit(const PartOperationSuccess('Part updated successfully!'));
      add(const LoadParts());
    } catch (e) {
      emit(PartError('Failed to update part: ${e.toString()}'));
    }
  }

  // Event Handler for DeletePart
  Future<void> _onDeletePart(DeletePart event, Emitter<PartState> emit) async {
    emit(PartLoading()); // Or 'PartDeleting'
    try {
      await _partRepository.deletePart(event.partId);
      emit(const PartOperationSuccess('Part deleted successfully!'));
      add(const LoadParts());
    } catch (e) {
      emit(PartError('Failed to delete part: ${e.toString()}'));
    }
  }

  // Event Handler for AdjustPartStock
  Future<void> _onAdjustPartStock(
    AdjustPartStock event,
    Emitter<PartState> emit,
  ) async {
    emit(PartLoading()); // Or 'PartStockAdjusting'
    try {
      await _partRepository.updatePartStock(event.partId, event.quantityChange);
      emit(const PartOperationSuccess('Part stock adjusted successfully!'));
      add(const LoadParts()); // Reload to show updated stock
    } catch (e) {
      emit(PartError('Failed to adjust part stock: ${e.toString()}'));
    }
  }
}
