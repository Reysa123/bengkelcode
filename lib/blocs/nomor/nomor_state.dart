import 'package:equatable/equatable.dart';
// Import model Akun untuk detail akun

// Model untuk menyimpan data Nomor
abstract class NomorState extends Equatable {
  const NomorState();

  @override
  List<Object> get props => [];
}

class NomorLoaded extends NomorState {
  final int noPkb;
  final int? notrx;
  const NomorLoaded({required this.noPkb, this.notrx});

  @override
  List<Object> get props => [noPkb];
}

class NomorInitial extends NomorState {
  
}

class NomorError extends NomorState {
  final String message;

  const NomorError(this.message);

  @override
  List<Object> get props => [message];
}
