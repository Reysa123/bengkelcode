import 'package:equatable/equatable.dart';
import '../../model/jasa.dart'; // Pastikan path ini benar

// --- Base Event ---
abstract class JasaEvent extends Equatable {
  const JasaEvent();

  @override
  List<Object> get props => [];
}

// --- Events ---

// Event untuk memuat daftar jasa
class LoadJasa extends JasaEvent {
  const LoadJasa();
}

// Event untuk menambahkan jasa baru
class AddJasa extends JasaEvent {
  final Jasa jasa;

  const AddJasa(this.jasa);

  @override
  List<Object> get props => [jasa];
}

// Event untuk memperbarui jasa yang sudah ada
class UpdateJasa extends JasaEvent {
  final Jasa jasa;

  const UpdateJasa(this.jasa);

  @override
  List<Object> get props => [jasa];
}

// Event untuk menghapus jasa
class DeleteJasa extends JasaEvent {
  final int id;

  const DeleteJasa(this.id);

  @override
  List<Object> get props => [id];
}
