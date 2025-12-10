import 'package:equatable/equatable.dart'; // Import Equatable

class PenjualanSukuCadang extends Equatable {
  final int? id;
  final int? transaksiId;
  final int? pelangganId; // Bisa null jika penjualan tunai
  final DateTime tanggalPenjualan;
  final double totalPenjualan;
  final String? namaPart;
  final double? hargaBeli;
  final double? hargaJual;
  final int? qty;

  final String? status;
  final String? catatan;

  const PenjualanSukuCadang({
    this.id,
    this.transaksiId,
    this.pelangganId,
    required this.tanggalPenjualan,
    required this.totalPenjualan,
    this.namaPart,
    this.hargaBeli,
    this.hargaJual,
    this.qty,
    this.status,
    this.catatan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaksi_id': transaksiId,
      'pelanggan_id': pelangganId,
      'tanggal_penjualan': tanggalPenjualan.toIso8601String(),
      'total_penjualan': totalPenjualan,
      'status': status,
      'catatan': catatan,
    };
  }

  factory PenjualanSukuCadang.fromMap(Map<String, dynamic> map) {
    return PenjualanSukuCadang(
      id: map['id'],
      transaksiId: map['transaksi_id'],
      pelangganId: map['pelanggan_id'],
      tanggalPenjualan: DateTime.parse(map['tanggal_penjualan']),
      totalPenjualan: map['total_penjualan'],
      namaPart: map['nama_part'] ?? '',
      hargaBeli: map['harga_beli'] ?? 0,
      hargaJual: map['harga_jual'] ?? 0,
      qty: map['qty'] ?? 0,
      status: map['status'],
      catatan: map['catatan'],
    );
  }

  PenjualanSukuCadang copyWith({
    int? id,
    int? transaksiId,
    int? pelangganId,
    DateTime? tanggalPenjualan,
    double? totalPenjualan,
    String? status,
    String? catatan,
  }) {
    return PenjualanSukuCadang(
      id: id ?? this.id,
      transaksiId: transaksiId ?? this.transaksiId,
      pelangganId: pelangganId ?? this.pelangganId,
      tanggalPenjualan: tanggalPenjualan ?? this.tanggalPenjualan,
      totalPenjualan: totalPenjualan ?? this.totalPenjualan,
      status: status ?? this.status,
      catatan: catatan ?? this.catatan,
    );
  }

  @override
  List<Object?> get props => [
    id,
    transaksiId,
    pelangganId,
    tanggalPenjualan,
    totalPenjualan,
    status,
    catatan,
  ]; // Properti yang digunakan untuk perbandingan Equatable

  @override
  String toString() {
    return 'PenjualanSukuCadang(id: $id, transaksiId: $transaksiId, tanggalPenjualan: $tanggalPenjualan, totalPenjualan: $totalPenjualan, status:$status)';
  }
}
