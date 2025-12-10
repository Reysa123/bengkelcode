import 'package:equatable/equatable.dart'; // Import Equatable

class PembelianSukuCadang extends Equatable {
  final int? id;
  final int supplierId;
  final String? namaSupplier;
  final DateTime tanggalPembelian;
  final double totalPembelian;
  final String? status;
  final String? catatan;

  const PembelianSukuCadang({
    this.id,
    required this.supplierId,
    this.namaSupplier,
    required this.tanggalPembelian,
    required this.totalPembelian,
    this.status,
    this.catatan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplier_id': supplierId,
      //'nama_supplier':namaSupplier??"",
      'tanggal_pembelian': tanggalPembelian.toIso8601String(),
      'total_pembelian': totalPembelian,
      'status': status,
      'catatan': catatan,
    };
  }

  factory PembelianSukuCadang.fromMap(Map<String, dynamic> map) {
    return PembelianSukuCadang(
      id: map['id'],
      supplierId: map['supplier_id'],
      namaSupplier: map['nama_supplier'] ?? "",
      tanggalPembelian: DateTime.parse(map['tanggal_pembelian']),
      totalPembelian: map['total_pembelian'],
      status: map['status'],
      catatan: map['catatan'],
    );
  }

  PembelianSukuCadang copyWith({
    int? id,
    int? supplierId,
    DateTime? tanggalPembelian,
    double? totalPembelian,
    String? status,
    String? catatan,
  }) {
    return PembelianSukuCadang(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      tanggalPembelian: tanggalPembelian ?? this.tanggalPembelian,
      totalPembelian: totalPembelian ?? this.totalPembelian,
      status: status ?? this.status,
      catatan: catatan ?? this.catatan,
    );
  }

  @override
  List<Object?> get props => [
    id,
    supplierId,
    tanggalPembelian,
    totalPembelian,
    status,
    catatan,
  ]; // Properti yang digunakan untuk perbandingan Equatable

  @override
  String toString() {
    return 'PembelianSukuCadang(id: $id, supplierId: $supplierId, tanggalPembelian: $tanggalPembelian, totalPembelian: $totalPembelian,status:$status)';
  }
}
