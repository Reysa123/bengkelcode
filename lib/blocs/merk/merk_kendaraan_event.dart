// lib/bloc/type_kendaraan/type_kendaraan_event.dart
import 'package:bengkel/model/merk_kendaraan.dart';
import 'package:equatable/equatable.dart';


abstract class MerkKendaraanEvent extends Equatable {
  const MerkKendaraanEvent();

  @override
  List<Object> get props => [];
}

class LoadMerkKendaraan extends MerkKendaraanEvent {
  final List<MerkKendaraan> type;

 
const LoadMerkKendaraan(this.type);
  @override
  List<Object> get props => [type];
  
}

class AddMerkKendaraan extends MerkKendaraanEvent {
  final MerkKendaraan type;

  const AddMerkKendaraan(this.type);

  @override
  List<Object> get props => [type];
}

class UpdateMerkKendaraan extends MerkKendaraanEvent {
  final MerkKendaraan type;

  const UpdateMerkKendaraan(this.type);

  @override
  List<Object> get props => [type];
}

class DeleteMerkKendaraan extends MerkKendaraanEvent {
  final int id;

  const DeleteMerkKendaraan(this.id);

  @override
  List<Object> get props => [id];
}
