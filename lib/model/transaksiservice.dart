import 'package:equatable/equatable.dart'; // Import Equatable

class TransaksiServis extends Equatable {
  final int? id;
  final int idpkb;
  final int kendaraanId;
  final int km;
  final int? mekanikId;
  final DateTime tanggalMasuk;
  final DateTime? tanggalSelesai;
  final String
  status; // Contoh: 'Pending', 'In Progress', 'Completed', 'Cancelled'
  final double totalBiayaJasa;
  final double totalBiayaSukuCadang;
  final double totalFinal;
  final String? catatan;

  const TransaksiServis({
    this.id,
    required this.idpkb,
    required this.kendaraanId,
    required this.km,
    this.mekanikId,
    required this.tanggalMasuk,
    this.tanggalSelesai,
    required this.status,
    this.totalBiayaJasa = 0.0,
    this.totalBiayaSukuCadang = 0.0,
    this.totalFinal = 0.0,
    this.catatan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idpkb': idpkb,
      'kendaraan_id': kendaraanId,
      'km': km,
      'mekanik_id': mekanikId,
      'tanggal_masuk': tanggalMasuk.toIso8601String(),
      'tanggal_selesai': tanggalSelesai?.toIso8601String(),
      'status': status,
      'total_biaya_jasa': totalBiayaJasa,
      'total_biaya_suku_cadang': totalBiayaSukuCadang,
      'total_final': totalFinal,
      'catatan': catatan,
    };
  }

  factory TransaksiServis.fromMap(Map<String, dynamic> map) {
    return TransaksiServis(
      id: map['id'],
      idpkb: map['idpkb'],
      kendaraanId: map['kendaraan_id'],
      km: map['km'],
      mekanikId: map['mekanik_id'],
      tanggalMasuk: DateTime.parse(map['tanggal_masuk']),
      tanggalSelesai:
          map['tanggal_selesai'] != null
              ? DateTime.parse(map['tanggal_selesai'])
              : null,
      status: map['status'],
      totalBiayaJasa: map['total_biaya_jasa'] ?? 0.0,
      totalBiayaSukuCadang: map['total_biaya_suku_cadang'] ?? 0.0,
      totalFinal: map['total_final'] ?? 0.0,
      catatan: map['catatan'],
    );
  }

  TransaksiServis copyWith({
    int? id,
    int? idpkb,
    int? kendaraanId,
    int? km,
    int? mekanikId,
    DateTime? tanggalMasuk,
    DateTime? tanggalSelesai,
    String? status,
    double? totalBiayaJasa,
    double? totalBiayaSukuCadang,
    double? totalFinal,
    String? catatan,
  }) {
    return TransaksiServis(
      id: id ?? this.id,
      idpkb: idpkb ?? this.idpkb,
      kendaraanId: kendaraanId ?? this.kendaraanId,
      km: km ?? this.km,
      mekanikId: mekanikId ?? this.mekanikId,
      tanggalMasuk: tanggalMasuk ?? this.tanggalMasuk,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      status: status ?? this.status,
      totalBiayaJasa: totalBiayaJasa ?? this.totalBiayaJasa,
      totalBiayaSukuCadang: totalBiayaSukuCadang ?? this.totalBiayaSukuCadang,
      totalFinal: totalFinal ?? this.totalFinal,
      catatan: catatan ?? this.catatan,
    );
  }

  @override
  List<Object?> get props => [
    id,
    kendaraanId,
    km,
    mekanikId,
    tanggalMasuk,
    tanggalSelesai,
    status,
    totalBiayaJasa,
    totalBiayaSukuCadang,
    totalFinal,
    catatan,
  ]; // Properti yang digunakan untuk perbandingan Equatable

  @override
  String toString() {
    return 'TransaksiServis(id: $id, kendaraanId: $kendaraanId,idpkb:$idpkb status: $status, totalFinal: $totalFinal)';
  }
}
