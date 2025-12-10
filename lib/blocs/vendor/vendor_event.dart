import 'package:equatable/equatable.dart';
import '../../model/suplier.dart'; // Adjust path

abstract class VendorEvent extends Equatable {
  const VendorEvent();

  @override
  List<Object> get props => [];
}

class LoadVendors extends VendorEvent {
  const LoadVendors();
}

class AddVendor extends VendorEvent {
  final Supplier vendor;
  const AddVendor(this.vendor);

  @override
  List<Object> get props => [vendor];
}

class UpdateVendor extends VendorEvent {
  final Supplier vendor;
  const UpdateVendor(this.vendor);

  @override
  List<Object> get props => [vendor];
}

class DeleteVendor extends VendorEvent {
  final int vendorId;
  const DeleteVendor(this.vendorId);

  @override
  List<Object> get props => [vendorId];
}