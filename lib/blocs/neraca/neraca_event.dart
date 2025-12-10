import 'package:equatable/equatable.dart';

// --- Base Event ---
abstract class NeracaEvent extends Equatable {
  const NeracaEvent();

  @override
  List<Object> get props => [];
}

// --- Events ---

// Event untuk memuat data Neraca
// Neraca biasanya diambil pada tanggal tertentu, jadi kita tambahkan tanggal opsional
class LoadNeraca extends NeracaEvent {
  final DateTime? asOfDate; // Tanggal posisi neraca

  const LoadNeraca({this.asOfDate});

  @override
  List<Object> get props => [asOfDate ?? DateTime(0)]; // Menggunakan DateTime(0) untuk perbandingan Equatable jika null
}
