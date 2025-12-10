// lib/bloc/type_kendaraan/type_kendaraan_state.dart
import 'package:bengkel/model/merk_kendaraan.dart';
import 'package:equatable/equatable.dart';
import '../../model/type_kendaraan.dart';

abstract class TypeKendaraanState extends Equatable {
  const TypeKendaraanState();

  @override
  List<Object> get props => [];
}

class TypeKendaraanInitial extends TypeKendaraanState {}

class TypeKendaraanLoading extends TypeKendaraanState {}

class TypeKendaraanLoaded extends TypeKendaraanState {
  final List<TypeKendaraan> types;
final List<MerkKendaraan> merks;
  const TypeKendaraanLoaded({required this.types,required this.merks});

  @override
  List<Object> get props => [types];
}

class TypeKendaraanError extends TypeKendaraanState {
  final String message;

  const TypeKendaraanError(this.message);

  @override
  List<Object> get props => [message];
}
