import 'package:equatable/equatable.dart'; // Import Equatable

class DetailPenjualanSukuCadang extends Equatable {
  final int? id;
  final int penjualanId;
  final int sukuCadangId;
  final int jumlah;
  final double hargaJualSaatItu;
  final double subTotal;

  const DetailPenjualanSukuCadang({
    this.id,
    required this.penjualanId,
    required this.sukuCadangId,
    required this.jumlah,
    required this.hargaJualSaatItu,
    required this.subTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'penjualan_id': penjualanId,
      'suku_cadang_id': sukuCadangId,
      'jumlah': jumlah,
      'harga_jual_saat_itu': hargaJualSaatItu,
      'sub_total': subTotal,
    };
  }

  factory DetailPenjualanSukuCadang.fromMap(Map<String, dynamic> map) {
    return DetailPenjualanSukuCadang(
      id: map['id'],
      penjualanId: map['penjualan_id'],
      sukuCadangId: map['suku_cadang_id'],
      jumlah: map['jumlah'],
      hargaJualSaatItu: map['harga_jual_saat_itu'],
      subTotal: map['sub_total'],
    );
  }

  DetailPenjualanSukuCadang copyWith({
    int? id,
    int? penjualanId,
    int? sukuCadangId,
    int? jumlah,
    double? hargaJualSaatItu,
    double? subTotal,
  }) {
    return DetailPenjualanSukuCadang(
      id: id ?? this.id,
      penjualanId: penjualanId ?? this.penjualanId,
      sukuCadangId: sukuCadangId ?? this.sukuCadangId,
      jumlah: jumlah ?? this.jumlah,
      hargaJualSaatItu: hargaJualSaatItu ?? this.hargaJualSaatItu,
      subTotal: subTotal ?? this.subTotal,
    );
  }

  @override
  List<Object?> get props => [
        id,
        penjualanId,
        sukuCadangId,
        jumlah,
        hargaJualSaatItu,
        subTotal,
      ]; // Properti yang digunakan untuk perbandingan Equatable

  @override
  String toString() {
    return 'DetailPenjualanSukuCadang(id: $id, penjualanId: $penjualanId, sukuCadangId: $sukuCadangId, jumlah: $jumlah)';
  }
}
