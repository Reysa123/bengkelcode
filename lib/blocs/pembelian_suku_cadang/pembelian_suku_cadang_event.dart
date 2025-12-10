import 'package:bengkel/model/detail_pembelian_suku_cadang.dart';
import 'package:bengkel/model/pembelian_suku_cadang.dart';
import 'package:equatable/equatable.dart';

// --- Base Event ---
abstract class PembelianSukuCadangEvent extends Equatable {
  const PembelianSukuCadangEvent();

  @override
  List<Object> get props => [];
}

// --- Events ---

// Event untuk memuat daftar pembelian suku cadang
class LoadPembelianSukuCadang extends PembelianSukuCadangEvent {
  const LoadPembelianSukuCadang();
}

// Event untuk memuat detail pembelian suku cadang untuk transaksi tertentu
class LoadPembelianSukuCadangDetail extends PembelianSukuCadangEvent {
  const LoadPembelianSukuCadangDetail();

  @override
  List<Object> get props => [];
}

// Event untuk menambahkan pembelian suku cadang baru
class AddPembelianSukuCadang extends PembelianSukuCadangEvent {
  final PembelianSukuCadang pembelianSukuCadang;
  final List<DetailPembelianSukuCadang>
  detailSukuCadang; // Tambahan: detail item yang dibeli

  const AddPembelianSukuCadang(
    this.pembelianSukuCadang, {
    this.detailSukuCadang = const [],
  });

  @override
  List<Object> get props => [pembelianSukuCadang, detailSukuCadang];
}

// Event untuk memperbarui pembelian suku cadang yang sudah ada
class UpdatePembelianSukuCadang extends PembelianSukuCadangEvent {
  final PembelianSukuCadang pembelianSukuCadang;
  final List<DetailPembelianSukuCadang>
  detailSukuCadang; // Tambahan: detail item yang diperbarui

  const UpdatePembelianSukuCadang(
    this.pembelianSukuCadang, {
    this.detailSukuCadang = const [],
  });

  @override
  List<Object> get props => [pembelianSukuCadang, detailSukuCadang];
}

// Event untuk menghapus pembelian suku cadang
class DeletePembelianSukuCadang extends PembelianSukuCadangEvent {
  final int id;

  const DeletePembelianSukuCadang(this.id);

  @override
  List<Object> get props => [id];
}
