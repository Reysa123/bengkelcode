import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/vendor_repository.dart'; // Adjust path
// Adjust path
import 'vendor_event.dart'; // Adjust path
import 'vendor_state.dart'; // Adjust path

class VendorBloc extends Bloc<VendorEvent, VendorState> {
  final SupplierRepository _vendorRepository;

  VendorBloc(this._vendorRepository) : super(VendorInitial()) {
    on<LoadVendors>(_onLoadVendors);
    on<AddVendor>(_onAddVendor);
    on<UpdateVendor>(_onUpdateVendor);
    on<DeleteVendor>(_onDeleteVendor);
  }

  // Event Handler for LoadVendors
  Future<void> _onLoadVendors(
    LoadVendors event,
    Emitter<VendorState> emit,
  ) async {
    emit(VendorLoading());
    try {
      final vendors = await _vendorRepository.getSuppliers();
      emit(VendorsLoaded(vendors: vendors));
    } catch (e) {
      emit(VendorError('Failed to load vendors: ${e.toString()}'));
    }
  }

  // Event Handler for AddVendor
  Future<void> _onAddVendor(AddVendor event, Emitter<VendorState> emit) async {
    emit(VendorLoading()); // Or a more specific 'VendorAdding' state
    try {
      await _vendorRepository.insertSupplier(event.vendor);
      emit(const VendorOperationSuccess('Vendor added successfully!'));
      // After a successful operation, reload vendors to update the UI
      add(const LoadVendors());
    } catch (e) {
      emit(VendorError('Failed to add vendor: ${e.toString()}'));
    }
  }

  // Event Handler for UpdateVendor
  Future<void> _onUpdateVendor(
    UpdateVendor event,
    Emitter<VendorState> emit,
  ) async {
    emit(VendorLoading()); // Or 'VendorUpdating'
    try {
      await _vendorRepository.updateSupplier(event.vendor);
      emit(const VendorOperationSuccess('Vendor updated successfully!'));
      add(const LoadVendors());
    } catch (e) {
      emit(VendorError('Failed to update vendor: ${e.toString()}'));
    }
  }

  // Event Handler for DeleteVendor
  Future<void> _onDeleteVendor(
    DeleteVendor event,
    Emitter<VendorState> emit,
  ) async {
    emit(VendorLoading()); // Or 'VendorDeleting'
    try {
      await _vendorRepository.deleteSupplier(event.vendorId);
      emit(const VendorOperationSuccess('Vendor deleted successfully!'));
      add(const LoadVendors());
    } catch (e) {
      emit(VendorError('Failed to delete vendor: ${e.toString()}'));
    }
  }
}
