import 'package:bengkel/model/jurnal.dart';
import 'package:equatable/equatable.dart';

// --- Base Event ---
abstract class JurnalEvent extends Equatable {
  const JurnalEvent();

  @override
  List<Object> get props => [];
}

// --- Events ---

// Event untuk memuat daftar jurnal
class LoadJurnal extends JurnalEvent {
  const LoadJurnal();
}

// Event untuk memuat jurnal berdasarkan rentang tanggal (opsional)
class LoadJurnalByDateRange extends JurnalEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadJurnalByDateRange({required this.startDate, required this.endDate});

  @override
  List<Object> get props => [startDate, endDate];
}

class AddJurnal extends JurnalEvent {
  final Jurnal jurnal;
  const AddJurnal({required this.jurnal});
  @override
  List<Object> get props => [jurnal];
}

// Anda bisa menambahkan event lain jika ada kebutuhan untuk manipulasi jurnal
// (misalnya, jika ada jurnal yang bisa diedit/dihapus secara manual, meskipun biasanya jurnal otomatis tidak diedit)
