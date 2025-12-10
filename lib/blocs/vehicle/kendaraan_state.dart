import 'package:bengkel/model/kendararaanall.dart';
import 'package:bengkel/model/merk_kendaraan.dart';
import 'package:bengkel/model/pelanggan.dart';
import 'package:bengkel/model/type_kendaraan.dart';
import 'package:equatable/equatable.dart';
import '../../model/kendaraan.dart'; // Pastikan path ini benar

// --- Base State ---
abstract class KendaraanState extends Equatable {
  const KendaraanState();

  @override
  List<Object> get props => [];
}

// --- States ---

// Initial state, saat BLoC pertama kali dibuat atau sebelum data dimuat
class KendaraanInitial extends KendaraanState {}

// State saat data sedang dimuat/diproses
class KendaraanLoading extends KendaraanState {}

// State saat data berhasil dimuat
class KendaraanLoaded extends KendaraanState {
  final List<Kendaraan> kendaraanList;
  final List<Pelanggan> pelangganList;
  final List<MerkKendaraan> merkList;
  final List<TypeKendaraan> typeList;
  const KendaraanLoaded({
    this.kendaraanList = const [],
    this.pelangganList = const [],
    this.merkList = const [],
    this.typeList = const [],
  });

  @override
  List<Object> get props => [kendaraanList, pelangganList];
}

class KendaraanLoadedAllById extends KendaraanState {
  final List<KendaraanAll> kendaraanList;
  const KendaraanLoadedAllById({required this.kendaraanList});

  @override
  List<Object> get props => [kendaraanList];
}

class KendaraanLoadedById extends KendaraanState {
  final List<Kendaraan> kendaraanList;
  final List<Pelanggan> pelangganList;
  final bool? ada;
  const KendaraanLoadedById({
    required this.kendaraanList,
    required this.pelangganList,
    this.ada = false,
  });

  @override
  List<Object> get props => [kendaraanList, pelangganList, ada??false];
}

// State saat terjadi kesalahan
class KendaraanError extends KendaraanState {
  final String message;

  const KendaraanError(this.message);

  @override
  List<Object> get props => [message];
}
