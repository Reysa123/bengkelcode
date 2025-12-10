import 'package:equatable/equatable.dart';
import '../../model/part.dart'; // Adjust path

abstract class PartState extends Equatable {
  const PartState();

  @override
  List<Object> get props => [];
}

class PartInitial extends PartState {}

class PartLoading extends PartState {}

class PartsLoaded extends PartState {
  final List<SukuCadang> parts;
  const PartsLoaded({this.parts = const []});

  @override
  List<Object> get props => [parts];
}

class PartError extends PartState {
  final String message;
  const PartError(this.message);

  @override
  List<Object> get props => [message];
}

class PartOperationSuccess extends PartState {
  final String message;
  const PartOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}