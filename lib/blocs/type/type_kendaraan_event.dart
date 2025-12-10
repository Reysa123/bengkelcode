// lib/bloc/type_kendaraan/type_kendaraan_event.dart
import 'package:equatable/equatable.dart';
import '../../model/type_kendaraan.dart';

abstract class TypeKendaraanEvent extends Equatable {
  const TypeKendaraanEvent();

  @override
  List<Object> get props => [];
}

class LoadTypeKendaraan extends TypeKendaraanEvent {
  const LoadTypeKendaraan();
}

class AddTypeKendaraan extends TypeKendaraanEvent {
  final TypeKendaraan type;
  const AddTypeKendaraan(this.type);

  @override
  List<Object> get props => [type];
}

class UpdateTypeKendaraan extends TypeKendaraanEvent {
  final TypeKendaraan type;

  const UpdateTypeKendaraan(this.type);

  @override
  List<Object> get props => [type];
}

class DeleteTypeKendaraan extends TypeKendaraanEvent {
  final int id;

  const DeleteTypeKendaraan(this.id);

  @override
  List<Object> get props => [id];
}
