import 'package:equatable/equatable.dart';
import '../../model/bengkel.dart'; // Adjust path

abstract class BengkelEvent extends Equatable {
  const BengkelEvent();

  @override
  List<Object> get props => [];
}

class LoadBengkels extends BengkelEvent {
  const LoadBengkels();
}

class AddBengkel extends BengkelEvent {
  final Bengkel bengkel;
  const AddBengkel(this.bengkel);

  @override
  List<Object> get props => [Bengkel];
}

class UpdateBengkel extends BengkelEvent {
  final Bengkel bengkel;
  const UpdateBengkel(this.bengkel);

  @override
  List<Object> get props => [Bengkel];
}

class DeleteBengkel extends BengkelEvent {
  final int bengkelId;
  const DeleteBengkel(this.bengkelId);

  @override
  List<Object> get props => [bengkelId];
}
