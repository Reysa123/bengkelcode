import 'package:equatable/equatable.dart';
import '../../model/pelanggan.dart'; // Pastikan path ini benar

// --- Base State ---
abstract class PelangganState extends Equatable {
  const PelangganState();

  @override
  List<Object> get props => [];
}

// --- States ---

// Initial state, saat BLoC pertama kali dibuat atau sebelum data dimuat
class PelangganInitial extends PelangganState {}

// State saat data sedang dimuat/diproses
class PelangganLoading extends PelangganState {}

// State saat data berhasil dimuat
class PelangganLoaded extends PelangganState {
  final List<Pelanggan> pelangganList;

  const PelangganLoaded({this.pelangganList = const []});

  @override
  List<Object> get props => [pelangganList];
}

// State saat terjadi kesalahan
class PelangganError extends PelangganState {
  final String message;

  const PelangganError(this.message);

  @override
  List<Object> get props => [message];
}
