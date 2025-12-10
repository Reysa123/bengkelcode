import 'package:equatable/equatable.dart';
import '../../model/suplier.dart'; // Adjust path

abstract class VendorState extends Equatable {
  const VendorState();

  @override
  List<Object> get props => [];
}

class VendorInitial extends VendorState {}

class VendorLoading extends VendorState {}

class VendorsLoaded extends VendorState {
  final List<Supplier> vendors;
  const VendorsLoaded({this.vendors = const []});

  @override
  List<Object> get props => [vendors];
}

class VendorError extends VendorState {
  final String message;
  const VendorError(this.message);

  @override
  List<Object> get props => [message];
}

class VendorOperationSuccess extends VendorState {
  final String message;
  const VendorOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
