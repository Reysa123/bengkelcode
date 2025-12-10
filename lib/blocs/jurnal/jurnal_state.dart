import 'package:equatable/equatable.dart';
import '../../model/jurnal.dart'; // Pastikan path ini benar

// --- Base State ---
abstract class JurnalState extends Equatable {
  const JurnalState();

  @override
  List<Object> get props => [];
}

// --- States ---

// Initial state, saat BLoC pertama kali dibuat atau sebelum data dimuat
class JurnalInitial extends JurnalState {}

// State saat data sedang dimuat/diproses
class JurnalLoading extends JurnalState {}

// State saat daftar jurnal berhasil dimuat
class JurnalLoaded extends JurnalState {
  final List<Jurnal> jurnalList;

  const JurnalLoaded({this.jurnalList = const []});

  @override
  List<Object> get props => [jurnalList];
}

// State saat terjadi kesalahan
class JurnalError extends JurnalState {
  final String message;

  const JurnalError(this.message);

  @override
  List<Object> get props => [message];
}
