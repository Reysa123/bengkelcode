import 'package:bengkel/model/detailpenjualansukucadang.dart';
import 'package:bengkel/model/penjualansukucadang.dart';
import 'package:equatable/equatable.dart';

// --- Base State ---
abstract class PenjualanSukuCadangState extends Equatable {
  const PenjualanSukuCadangState();

  @override
  List<Object> get props => [];
}

// --- States ---

// Initial state, saat BLoC pertama kali dibuat atau sebelum data dimuat
class PenjualanSukuCadangInitial extends PenjualanSukuCadangState {}

// State saat data sedang dimuat/diproses
class PenjualanSukuCadangLoading extends PenjualanSukuCadangState {}

// State saat daftar penjualan suku cadang berhasil dimuat
class PenjualanSukuCadangLoaded extends PenjualanSukuCadangState {
  final List<PenjualanSukuCadang> penjualanSukuCadangList;
 

  const PenjualanSukuCadangLoaded({this.penjualanSukuCadangList = const []});

  @override
  List<Object> get props => [penjualanSukuCadangList];
}

// State saat detail penjualan suku cadang berhasil dimuat (untuk edit)
class PenjualanSukuCadangDetailLoaded extends PenjualanSukuCadangState {
  final PenjualanSukuCadang penjualanSukuCadang;
  final List<DetailPenjualanSukuCadang> detailSukuCadang;

  const PenjualanSukuCadangDetailLoaded({
    required this.penjualanSukuCadang,
    this.detailSukuCadang = const [],
  });

  @override
  List<Object> get props => [penjualanSukuCadang, detailSukuCadang];
}

// State saat terjadi kesalahan
class PenjualanSukuCadangError extends PenjualanSukuCadangState {
  final String message;

  const PenjualanSukuCadangError(this.message);

  @override
  List<Object> get props => [message];
}
