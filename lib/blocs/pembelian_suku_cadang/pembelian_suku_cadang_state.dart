import 'package:bengkel/model/detail_pembelian_suku_cadang.dart';
import 'package:equatable/equatable.dart';
import '../../model/pembelian_suku_cadang.dart'; // Pastikan path ini benar

// --- Base State ---
abstract class PembelianSukuCadangState extends Equatable {
  const PembelianSukuCadangState();

  @override
  List<Object> get props => [];
}

// --- States ---

// Initial state, saat BLoC pertama kali dibuat atau sebelum data dimuat
class PembelianSukuCadangInitial extends PembelianSukuCadangState {}

// State saat data sedang dimuat/diproses
class PembelianSukuCadangLoading extends PembelianSukuCadangState {}

// State saat data berhasil dimuat
class PembelianSukuCadangLoaded extends PembelianSukuCadangState {
  final List<PembelianSukuCadang> pembelianSukuCadangList;

  const PembelianSukuCadangLoaded({this.pembelianSukuCadangList = const []});

  @override
  List<Object> get props => [pembelianSukuCadangList];
}

// State saat detail pembelian suku cadang berhasil dimuat (untuk edit)
class PembelianSukuCadangDetailLoaded extends PembelianSukuCadangState {
  final List<PembelianSukuCadang> pembelianSukuCadangList;
  final List<DetailPembelianSukuCadang> detailSukuCadang;

  const PembelianSukuCadangDetailLoaded({
    this.pembelianSukuCadangList = const [],
    this.detailSukuCadang = const [],
  });

  @override
  List<Object> get props => [pembelianSukuCadangList, detailSukuCadang];
}

// State saat terjadi kesalahan
class PembelianSukuCadangError extends PembelianSukuCadangState {
  final String message;

  const PembelianSukuCadangError(this.message);

  @override
  List<Object> get props => [message];
}
