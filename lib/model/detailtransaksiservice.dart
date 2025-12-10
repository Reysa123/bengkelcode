import 'package:equatable/equatable.dart'; // Import Equatable

class DetailTransaksiService extends Equatable {
  final int? id;
  final int transaksiServisId;
  final int jasaId;
  final int jumlah;
  final String? namaJasa;
  final double hargaJasaSaatItu;
  final double subTotal;
  final String? catatanLayanan;

  const DetailTransaksiService({
    this.id,
    this.namaJasa,
    required this.transaksiServisId,
    required this.jasaId,
    required this.jumlah,
    required this.hargaJasaSaatItu,
    required this.subTotal,
    this.catatanLayanan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaksi_servis_id': transaksiServisId,
      'jasa_id': jasaId,
      'jumlah': jumlah,
      'harga_jasa_saat_itu': hargaJasaSaatItu,
      'sub_total': subTotal,
      'catatan_layanan': catatanLayanan,
    };
  }

  factory DetailTransaksiService.fromMap(Map<String, dynamic> map) {
    return DetailTransaksiService(
      id: map['id'],
      transaksiServisId: map['transaksi_servis_id'],
      jasaId: map['jasa_id'],
      namaJasa: map['nama_jasa'],
      jumlah: map['jumlah'],
      hargaJasaSaatItu: map['harga_jasa_saat_itu'],
      subTotal: map['sub_total'],
      catatanLayanan: map['catatan_layanan'],
    );
  }

  DetailTransaksiService copyWith({
    int? id,
    int? transaksiServisId,
    int? jasaId,
    int? jumlah,
    double? hargaJasaSaatItu,
    double? subTotal,
    String? catatanLayanan,
  }) {
    return DetailTransaksiService(
      id: id ?? this.id,
      transaksiServisId: transaksiServisId ?? this.transaksiServisId,
      jasaId: jasaId ?? this.jasaId,
      jumlah: jumlah ?? this.jumlah,
      hargaJasaSaatItu: hargaJasaSaatItu ?? this.hargaJasaSaatItu,
      subTotal: subTotal ?? this.subTotal,
      catatanLayanan: catatanLayanan ?? this.catatanLayanan,
    );
  }

  @override
  List<Object?> get props => [
    id,
    transaksiServisId,
    jasaId,
    jumlah,
    hargaJasaSaatItu,
    subTotal,
    catatanLayanan,
  ]; // Properti yang digunakan untuk perbandingan Equatable

  @override
  String toString() {
    return 'DetailTransaksiService(id: $id, transaksiServisId: $transaksiServisId, jasaId: $jasaId, jumlah: $jumlah)';
  }
}
