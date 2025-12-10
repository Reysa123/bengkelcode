import 'package:equatable/equatable.dart'; // Import Equatable

class DetailTransaksiSukuCadangServis extends Equatable {
  final int? id;
  final int transaksiServisId;
  final int sukuCadangId;
  final String? namaSukuCadang;
  final int jumlah;
  final double hargaJualSaatItu;
  final double subTotal;

  const DetailTransaksiSukuCadangServis({
    this.id,
    this.namaSukuCadang,
    required this.transaksiServisId,
    required this.sukuCadangId,
    required this.jumlah,
    required this.hargaJualSaatItu,
    required this.subTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaksi_servis_id': transaksiServisId,
      'suku_cadang_id': sukuCadangId,
      'jumlah': jumlah,
      'harga_jual_saat_itu': hargaJualSaatItu,
      'sub_total': subTotal,
    };
  }

  factory DetailTransaksiSukuCadangServis.fromMap(Map<String, dynamic> map) {
    return DetailTransaksiSukuCadangServis(
      id: map['id'],
      transaksiServisId: map['transaksi_servis_id'],
      sukuCadangId: map['suku_cadang_id'],
      namaSukuCadang: map['nama_part'],
      jumlah: map['jumlah'],
      hargaJualSaatItu: map['harga_jual_saat_itu'],
      subTotal: map['sub_total'],
    );
  }

  DetailTransaksiSukuCadangServis copyWith({
    int? id,
    int? transaksiServisId,
    int? sukuCadangId,
    int? jumlah,
    double? hargaJualSaatItu,
    double? subTotal,
  }) {
    return DetailTransaksiSukuCadangServis(
      id: id ?? this.id,
      transaksiServisId: transaksiServisId ?? this.transaksiServisId,
      sukuCadangId: sukuCadangId ?? this.sukuCadangId,
      jumlah: jumlah ?? this.jumlah,
      hargaJualSaatItu: hargaJualSaatItu ?? this.hargaJualSaatItu,
      subTotal: subTotal ?? this.subTotal,
    );
  }

  @override
  List<Object?> get props => [
    id,
    transaksiServisId,
    sukuCadangId,
    jumlah,
    hargaJualSaatItu,
    subTotal,
  ]; // Properti yang digunakan untuk perbandingan Equatable

  @override
  String toString() {
    return 'DetailTransaksiSukuCadangServis(id: $id, transaksiServisId: $transaksiServisId, sukuCadangId: $sukuCadangId, jumlah: $jumlah)';
  }
}
