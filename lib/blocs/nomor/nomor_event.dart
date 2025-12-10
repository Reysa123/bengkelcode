import 'package:equatable/equatable.dart';

// --- Base Event ---
abstract class NomorEvent extends Equatable {
  const NomorEvent();

  @override
  List<Object> get props => [];
}

class LoadNomor extends NomorEvent {
  const LoadNomor();
}

class UpdateNomor extends NomorEvent {
  const UpdateNomor();
  @override
  List<Object> get props => [];
}

class UpdateNomorTrk extends NomorEvent {
  const UpdateNomorTrk();
  @override
  List<Object> get props => [];
}
