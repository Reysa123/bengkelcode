import 'package:equatable/equatable.dart';
import '../../model/detail_pembelian_suku_cadang.dart'; // Pastikan path ini benar

// --- Base State ---
abstract class DetailPembelianSukuCadangState extends Equatable {
  const DetailPembelianSukuCadangState();

  @override
  List<Object> get props => [];
}

// --- States ---

// Initial state, saat BLoC pertama kali dibuat atau sebelum data dimuat
class DetailPembelianSukuCadangInitial extends DetailPembelianSukuCadangState {}

// State saat data sedang dimuat/diproses
class DetailPembelianSukuCadangLoading extends DetailPembelianSukuCadangState {}

// State saat daftar detail suku cadang berhasil dimuat
class DetailPembelianSukuCadangLoaded extends DetailPembelianSukuCadangState {
  final List<DetailPembelianSukuCadang> detailsList;

  const DetailPembelianSukuCadangLoaded({this.detailsList = const []});

  @override
  List<Object> get props => [detailsList];
}

// State saat terjadi kesalahan
class DetailPembelianSukuCadangError extends DetailPembelianSukuCadangState {
  final String message;

  const DetailPembelianSukuCadangError(this.message);

  @override
  List<Object> get props => [message];
}

// State saat operasi (tambah/update/hapus) berhasil
class DetailPembelianSukuCadangOperationSuccess extends DetailPembelianSukuCadangState {
  final String message;

  const DetailPembelianSukuCadangOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
