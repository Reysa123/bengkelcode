import 'package:equatable/equatable.dart'; // Import Equatable

class DetailPembelianSukuCadang extends Equatable {
  final int? id;
  final int pembelianId;
  final int sukuCadangId;
  final String? namaPart;
  final String? nomorPart;
  final int jumlah;
  final double hargaBeliSaatItu;
  final double subTotal;

  const DetailPembelianSukuCadang({
    this.id,
    required this.pembelianId,
    required this.sukuCadangId,
    this.nomorPart,
    this.namaPart,
    required this.jumlah,
    required this.hargaBeliSaatItu,
    required this.subTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pembelian_id': pembelianId,
      //'nama_part': namaPart ?? "",
      //'kode_part': nomorPart ?? "",
      'suku_cadang_id': sukuCadangId,
      'jumlah': jumlah,
      'harga_beli_saat_itu': hargaBeliSaatItu,
      'sub_total': subTotal,
    };
  }

  factory DetailPembelianSukuCadang.fromMap(Map<String, dynamic> map) {
    return DetailPembelianSukuCadang(
      id: map['id'],
      pembelianId: map['pembelian_id'],
      sukuCadangId: map['suku_cadang_id'],
      nomorPart: map['kode_part'] ?? "",
      namaPart: map['nama_part'] ?? "",
      jumlah: map['jumlah'],
      hargaBeliSaatItu: map['harga_beli_saat_itu'],
      subTotal: map['sub_total'],
    );
  }

  DetailPembelianSukuCadang copyWith({
    int? id,
    int? pembelianId,
    int? sukuCadangId,
    int? jumlah,
    double? hargaBeliSaatItu,
    double? subTotal,
  }) {
    return DetailPembelianSukuCadang(
      id: id ?? this.id,
      pembelianId: pembelianId ?? this.pembelianId,
      sukuCadangId: sukuCadangId ?? this.sukuCadangId,
      jumlah: jumlah ?? this.jumlah,
      hargaBeliSaatItu: hargaBeliSaatItu ?? this.hargaBeliSaatItu,
      subTotal: subTotal ?? this.subTotal,
    );
  }

  @override
  List<Object?> get props => [
    id,
    pembelianId,
    sukuCadangId,
    jumlah,
    hargaBeliSaatItu,
    subTotal,
  ]; // Properti yang digunakan untuk perbandingan Equatable

  @override
  String toString() {
    return 'DetailPembelianSukuCadang(id: $id, pembelianId: $pembelianId, sukuCadangId: $sukuCadangId, jumlah: $jumlah)';
  }
}
