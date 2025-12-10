import 'package:bengkel/model/detailsukucadangservice.dart';
import 'package:bengkel/model/detailtransaksiservice.dart';
import 'package:bengkel/model/transaksiservice.dart';
import 'package:equatable/equatable.dart';

// --- Base Event ---
abstract class TransaksiServisEvent extends Equatable {
  const TransaksiServisEvent();

  @override
  List<Object> get props => [];
}

// --- Events ---

// Event untuk memuat daftar transaksi servis
class LoadTransaksiServis extends TransaksiServisEvent {
  const LoadTransaksiServis();
}
// Event untuk memuat transaksi servis berdasarkan ID Kendaraan
class LoadTransaksiServisByKendaraanId extends TransaksiServisEvent {
  

  const LoadTransaksiServisByKendaraanId();


}
// Event untuk memuat detail transaksi servis (untuk tampilan/edit)
class LoadTransaksiServisDetail extends TransaksiServisEvent {
  final int transaksiId;

  const LoadTransaksiServisDetail(this.transaksiId);

  @override
  List<Object> get props => [transaksiId];
}

// Event untuk menambahkan transaksi servis baru
class AddTransaksiServis extends TransaksiServisEvent {
  final TransaksiServis transaksiServis;
  final List<DetailTransaksiService> detailJasa;
  final List<DetailTransaksiSukuCadangServis> detailSukuCadang;

  const AddTransaksiServis(this.transaksiServis, {
    this.detailJasa = const [],
    this.detailSukuCadang = const [],
  });

  @override
  List<Object> get props => [transaksiServis, detailJasa, detailSukuCadang];
}

// Event untuk memperbarui transaksi servis yang sudah ada
class UpdateTransaksiServis extends TransaksiServisEvent {
  final TransaksiServis transaksiServis;
  final List<DetailTransaksiService> detailJasa;
  final List<DetailTransaksiSukuCadangServis> detailSukuCadang;

  const UpdateTransaksiServis(this.transaksiServis, {
    this.detailJasa = const [],
    this.detailSukuCadang = const [],
  });

  @override
  List<Object> get props => [transaksiServis, detailJasa, detailSukuCadang];
}

// Event untuk menghapus transaksi servis
class DeleteTransaksiServis extends TransaksiServisEvent {
  final int id;

  const DeleteTransaksiServis(this.id);

  @override
  List<Object> get props => [id];
}
