import 'package:equatable/equatable.dart';
import '../../model/mekanik.dart'; // Make sure this path is correct for your Mekanik model

// --- Base State ---
abstract class MekanikState extends Equatable {
  const MekanikState();

  @override
  List<Object> get props => [];
}

// --- States ---

// Initial state when the BLoC is first created or before data is loaded
class MekanikInitial extends MekanikState {}

// State when data is being loaded or processed
class MekanikLoading extends MekanikState {}

// State when data has been successfully loaded
class MekanikLoaded extends MekanikState {
  final List<Mekanik> mekanikList;

  const MekanikLoaded({this.mekanikList = const []});

  @override
  List<Object> get props => [mekanikList];
}
class MekanikLoadeds extends MekanikState {
  final List<Mekanik> mekanikList;

  const MekanikLoadeds({required this.mekanikList});

  @override
  List<Object> get props => [mekanikList];
}
// State when an error occurs
class MekanikError extends MekanikState {
  final String message;

  const MekanikError(this.message);

  @override
  List<Object> get props => [message];
}