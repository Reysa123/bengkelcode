// lib/bloc/Model_kendaraan/Model_kendaraan_state.dart
import 'package:equatable/equatable.dart';
import '../../model/merk_kendaraan.dart';

abstract class MerkKendaraanState extends Equatable {
  const MerkKendaraanState();

  @override
  List<Object> get props => [];
}

class MerkKendaraanInitial extends MerkKendaraanState {}

class MerkKendaraanLoading extends MerkKendaraanState {}

class MerkKendaraanLoaded extends MerkKendaraanState {
  final List<MerkKendaraan> listmerks;

  const MerkKendaraanLoaded({required this.listmerks});

  @override
  List<Object> get props => [listmerks];
}

class MerkKendaraanError extends MerkKendaraanState {
  final String message;

  const MerkKendaraanError(this.message);

  @override
  List<Object> get props => [message];
}
