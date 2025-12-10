import 'package:bengkel/model/detailpenjualansukucadang.dart';
import 'package:bengkel/model/penjualansukucadang.dart';
import 'package:equatable/equatable.dart';// Import model detail penjualan

// --- Base Event ---
abstract class PenjualanSukuCadangEvent extends Equatable {
  const PenjualanSukuCadangEvent();

  @override
  List<Object> get props => [];
}

// --- Events ---

// Event untuk memuat daftar penjualan suku cadang
class LoadPenjualanSukuCadang extends PenjualanSukuCadangEvent {
  const LoadPenjualanSukuCadang();
}

class LoadPenjualanSukuCadangById extends PenjualanSukuCadangEvent {
  final int penjualanId;

  const LoadPenjualanSukuCadangById(this.penjualanId);

  @override
  List<Object> get props => [penjualanId];
}
// Event untuk memuat detail penjualan suku cadang untuk transaksi tertentu
class LoadPenjualanSukuCadangDetail extends PenjualanSukuCadangEvent {
  final int penjualanId;

  const LoadPenjualanSukuCadangDetail(this.penjualanId);

  @override
  List<Object> get props => [penjualanId];
}

// Event untuk menambahkan penjualan suku cadang baru
class AddPenjualanSukuCadang extends PenjualanSukuCadangEvent {
  final PenjualanSukuCadang penjualanSukuCadang;
  final List<DetailPenjualanSukuCadang> detailSukuCadang; // Tambahan: detail item yang dijual

  const AddPenjualanSukuCadang(this.penjualanSukuCadang, {this.detailSukuCadang = const []});

  @override
  List<Object> get props => [penjualanSukuCadang, detailSukuCadang];
}

// Event untuk memperbarui penjualan suku cadang yang sudah ada
class UpdatePenjualanSukuCadang extends PenjualanSukuCadangEvent {
  final PenjualanSukuCadang penjualanSukuCadang;
  final List<DetailPenjualanSukuCadang> detailSukuCadang; // Tambahan: detail item yang diperbarui

  const UpdatePenjualanSukuCadang(this.penjualanSukuCadang, {this.detailSukuCadang = const []});

  @override
  List<Object> get props => [penjualanSukuCadang, detailSukuCadang];
}

// Event untuk menghapus penjualan suku cadang
class DeletePenjualanSukuCadang extends PenjualanSukuCadangEvent {
  final int id;

  const DeletePenjualanSukuCadang(this.id);

  @override
  List<Object> get props => [id];
}
