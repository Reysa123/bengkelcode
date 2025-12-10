import 'package:equatable/equatable.dart';
import '../../model/detail_pembelian_suku_cadang.dart'; // Pastikan path ini benar

// --- Base Event ---
abstract class DetailPembelianSukuCadangEvent extends Equatable {
  const DetailPembelianSukuCadangEvent();

  @override
  List<Object> get props => [];
}

// --- Events ---

// Event untuk memuat detail suku cadang berdasarkan ID pembelian
class LoadDetailsByPembelianId extends DetailPembelianSukuCadangEvent {
  final int pembelianId;

  const LoadDetailsByPembelianId(this.pembelianId);

  @override
  List<Object> get props => [pembelianId];
}

// Event untuk menambahkan satu detail suku cadang
class AddDetailPembelianSukuCadang extends DetailPembelianSukuCadangEvent {
  final DetailPembelianSukuCadang detail;

  const AddDetailPembelianSukuCadang(this.detail);

  @override
  List<Object> get props => [detail];
}

// Event untuk memperbarui satu detail suku cadang
class UpdateDetailPembelianSukuCadang extends DetailPembelianSukuCadangEvent {
  final DetailPembelianSukuCadang detail;

  const UpdateDetailPembelianSukuCadang(this.detail);

  @override
  List<Object> get props => [detail];
}

// Event untuk menghapus satu detail suku cadang
class DeleteDetailPembelianSukuCadang extends DetailPembelianSukuCadangEvent {
  final int id;

  const DeleteDetailPembelianSukuCadang(this.id);

  @override
  List<Object> get props => [id];
}

// Event untuk menghapus semua detail suku cadang untuk suatu pembelian
class DeleteAllDetailsByPembelianId extends DetailPembelianSukuCadangEvent {
  final int pembelianId;

  const DeleteAllDetailsByPembelianId(this.pembelianId);

  @override
  List<Object> get props => [pembelianId];
}
