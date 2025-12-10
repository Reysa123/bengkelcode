import 'package:equatable/equatable.dart';
// Import model Akun untuk detail akun

// Model untuk menyimpan data Neraca
class NeracaData extends Equatable {
  final Map<String, double> totalAset; // Contoh: {'Kas': 10000.0, 'Persediaan': 5000.0}
  final Map<String, double> totalKewajiban; // Contoh: {'Utang Usaha': 3000.0}
  final Map<String, double> totalEkuitas; // Contoh: {'Modal': 12000.0}

  final double grandTotalAset;
  final double grandTotalKewajiban;
  final double grandTotalEkuitas;

  const NeracaData({
    required this.totalAset,
    required this.totalKewajiban,
    required this.totalEkuitas,
    required this.grandTotalAset,
    required this.grandTotalKewajiban,
    required this.grandTotalEkuitas,
  });

  @override
  List<Object> get props => [
        totalAset,
        totalKewajiban,
        totalEkuitas,
        grandTotalAset,
        grandTotalKewajiban,
        grandTotalEkuitas,
      ];
}

// --- Base State ---
abstract class NeracaState extends Equatable {
  const NeracaState();

  @override
  List<Object> get props => [];
}

// --- States ---

// Initial state, saat BLoC pertama kali dibuat atau sebelum data dimuat
class NeracaInitial extends NeracaState {}

// State saat data sedang dimuat/diproses
class NeracaLoading extends NeracaState {}

// State saat data Neraca berhasil dimuat
class NeracaLoaded extends NeracaState {
  final NeracaData neracaData;
  final DateTime asOfDate;

  const NeracaLoaded({required this.neracaData, required this.asOfDate});

  @override
  List<Object> get props => [neracaData, asOfDate];
}

// State saat terjadi kesalahan
class NeracaError extends NeracaState {
  final String message;

  const NeracaError(this.message);

  @override
  List<Object> get props => [message];
}
