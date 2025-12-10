// lib/bloc/transaksi_service_detail/transaksi_service_detail_state.dart
import 'package:equatable/equatable.dart';
import '../../model/transaksi_service_detail.dart';

abstract class TransaksiServiceDetailState extends Equatable {
  const TransaksiServiceDetailState();

  @override
  List<Object> get props => [];
}

class TransaksiServiceDetailInitial extends TransaksiServiceDetailState {}

class TransaksiServiceDetailLoading extends TransaksiServiceDetailState {}

class TransaksiServiceDetailLoaded extends TransaksiServiceDetailState {
  final TransaksiServiceDetail data;

  const TransaksiServiceDetailLoaded({required this.data});

  @override
  List<Object> get props => [data];
}

class TransaksiServiceLoaded extends TransaksiServiceDetailState {
  final List<Map<String, dynamic>> jasa;
  final List<Map<String, dynamic>> part;
  final List<Map<String, dynamic>> data;
  final List<Map<String, dynamic>> his;
  const TransaksiServiceLoaded({this.data=const [], this.part=const[], this.jasa=const[],this.his=const[]});

  @override
  List<Object> get props => [data, part, jasa];
}
class TransaksiServiceLoadeds extends TransaksiServiceDetailState {
  final List<Map<String, dynamic>> jasa;
  const TransaksiServiceLoadeds({this.jasa=const[]});

  @override
  List<Object> get props => [jasa];
}
class TransaksiServiceLoadedJasa extends TransaksiServiceDetailState {
  final List<Map<String, dynamic>> data;

  const TransaksiServiceLoadedJasa({required this.data});

  @override
  List<Object> get props => [data];
}

class TransaksiServiceLoadedPart extends TransaksiServiceDetailState {
  final List<Map<String, dynamic>> data;

  const TransaksiServiceLoadedPart({required this.data});

  @override
  List<Object> get props => [data];
}

class TransaksiServiceDetailError extends TransaksiServiceDetailState {
  final String message;

  const TransaksiServiceDetailError(this.message);

  @override
  List<Object> get props => [message];
}
