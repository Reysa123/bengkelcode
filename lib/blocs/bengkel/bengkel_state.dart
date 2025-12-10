import 'package:equatable/equatable.dart';
import '../../model/bengkel.dart'; // Adjust path

abstract class BengkelState extends Equatable {
  const BengkelState();

  @override
  List<Object> get props => [];
}

class BengkelInitial extends BengkelState {}

class BengkelLoading extends BengkelState {}

class BengkelsLoaded extends BengkelState {
  final Bengkel bengkels;
  const BengkelsLoaded({required this.bengkels});

  @override
  List<Object> get props => [bengkels];
}

class BengkelError extends BengkelState {
  final String message;
  const BengkelError(this.message);

  @override
  List<Object> get props => [message];
}