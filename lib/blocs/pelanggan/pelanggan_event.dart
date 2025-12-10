import 'package:equatable/equatable.dart';
import '../../model/pelanggan.dart'; // Pastikan path ini benar

// --- Base Event ---
abstract class PelangganEvent extends Equatable {
  const PelangganEvent();

  @override
  List<Object> get props => [];
}

// --- Events ---

// Event untuk memuat daftar pelanggan
class LoadPelanggan extends PelangganEvent {
  const LoadPelanggan();
}

// Event untuk menambahkan pelanggan baru
class AddPelanggan extends PelangganEvent {
  final Pelanggan pelanggan;

  const AddPelanggan(this.pelanggan);

  @override
  List<Object> get props => [pelanggan];
}

// Event untuk memperbarui pelanggan yang sudah ada
class UpdatePelanggan extends PelangganEvent {
  final Pelanggan pelanggan;

  const UpdatePelanggan(this.pelanggan);

  @override
  List<Object> get props => [pelanggan];
}

// Event untuk menghapus pelanggan
class DeletePelanggan extends PelangganEvent {
  final int id;

  const DeletePelanggan(this.id);

  @override
  List<Object> get props => [id];
}
