import 'package:equatable/equatable.dart';
import '../../model/jasa.dart'; // Pastikan path ini benar

// --- Base State ---
abstract class JasaState extends Equatable {
  const JasaState();

  @override
  List<Object> get props => [];
}

// --- States ---

// Initial state, saat BLoC pertama kali dibuat atau sebelum data dimuat
class JasaInitial extends JasaState {}

// State saat data sedang dimuat/diproses
class JasaLoading extends JasaState {}

// State saat data berhasil dimuat
class JasaLoaded extends JasaState {
  final List<Jasa> jasaList;

  const JasaLoaded({this.jasaList = const []});

  @override
  List<Object> get props => [jasaList];
}

// State saat terjadi kesalahan
class JasaError extends JasaState {
  final String message;

  const JasaError(this.message);

  @override
  List<Object> get props => [message];
}
