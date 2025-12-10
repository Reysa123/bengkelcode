import 'package:bengkel/model/detailsukucadangservice.dart';
import 'package:bengkel/model/detailtransaksiservice.dart';
import 'package:bengkel/model/jasa.dart';
import 'package:bengkel/model/kendaraan.dart';
import 'package:bengkel/model/part.dart';
import 'package:bengkel/model/pelanggan.dart';
import 'package:bengkel/model/transaksiservice.dart';
import 'package:equatable/equatable.dart';

// --- Base State ---
abstract class TransaksiServisState extends Equatable {
  const TransaksiServisState();

  @override
  List<Object> get props => [];
}

// --- States ---

// Initial state, saat BLoC pertama kali dibuat atau sebelum data dimuat
class TransaksiServisInitial extends TransaksiServisState {}

// State saat data sedang dimuat/diproses
class TransaksiServisLoading extends TransaksiServisState {}

// State saat daftar transaksi servis berhasil dimuat
class TransaksiServisLoaded extends TransaksiServisState {
  final List<TransaksiServis> transaksiServisList;
  final List<DetailTransaksiService> jasaServiceList;
  final List<DetailTransaksiSukuCadangServis> partServiceList;
  final List<Pelanggan> pelangganList;
  final List<Kendaraan> kendServiceList;
  final List<Jasa> jasa;
  final List<SukuCadang> part;
  const TransaksiServisLoaded({
    this.transaksiServisList = const [],
    this.jasaServiceList = const [],
    this.partServiceList = const [],
    this.kendServiceList = const [],
    this.pelangganList = const [],
    this.jasa = const [],
    this.part=const[],
  });

  @override
  List<Object> get props => [
    transaksiServisList,
    jasaServiceList,
    partServiceList,
    kendServiceList,
    pelangganList,
  ];
}

// State saat detail transaksi servis berhasil dimuat (untuk edit/view)
class TransaksiServisDetailLoaded extends TransaksiServisState {
  final TransaksiServis transaksiServis;
  final List<DetailTransaksiService> detailJasa;
  final List<DetailTransaksiSukuCadangServis> detailSukuCadang;

  const TransaksiServisDetailLoaded({
    required this.transaksiServis,
    this.detailJasa = const [],
    this.detailSukuCadang = const [],
  });

  @override
  List<Object> get props => [transaksiServis, detailJasa, detailSukuCadang];
}

// State saat terjadi kesalahan
class TransaksiServisError extends TransaksiServisState {
  final String message;

  const TransaksiServisError(this.message);

  @override
  List<Object> get props => [message];
}
