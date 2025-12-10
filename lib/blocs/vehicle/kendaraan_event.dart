import 'package:equatable/equatable.dart';
import '../../model/kendaraan.dart'; // Pastikan path ini benar

// --- Base Event ---
abstract class KendaraanEvent extends Equatable {
  const KendaraanEvent();

  @override
  List<Object> get props => [];
}

// --- Events ---

// Event untuk memuat daftar kendaraan
class LoadKendaraan extends KendaraanEvent {
  const LoadKendaraan();
}

class LoadKendaraanById extends KendaraanEvent {
  final String noChasis;
  const LoadKendaraanById(this.noChasis);
  @override
  List<Object> get props => [noChasis];
}

class LoadKendaraanAllById extends KendaraanEvent {
  final int id;
  const LoadKendaraanAllById(this.id);
  @override
  List<Object> get props => [id];
}

// Event untuk menambahkan kendaraan baru
class AddKendaraan extends KendaraanEvent {
  final Kendaraan kendaraan;

  const AddKendaraan(this.kendaraan);

  @override
  List<Object> get props => [kendaraan];
}

// Event untuk memperbarui kendaraan yang sudah ada
class UpdateKendaraan extends KendaraanEvent {
  final Kendaraan kendaraan;

  const UpdateKendaraan(this.kendaraan);

  @override
  List<Object> get props => [kendaraan];
}

class UpdateKmKendaraan extends KendaraanEvent {
  final int km;
  final int kendaraanId;
  const UpdateKmKendaraan(this.km,this.kendaraanId);
  @override
  List<Object> get props => [km];
}

// Event untuk menghapus kendaraan
class DeleteKendaraan extends KendaraanEvent {
  final int id;

  const DeleteKendaraan(this.id);

  @override
  List<Object> get props => [id];
}
