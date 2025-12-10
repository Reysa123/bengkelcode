import 'package:equatable/equatable.dart'; // Import Equatable

class Jurnal extends Equatable {
  final int? id;
  final DateTime tanggal;
  final String deskripsi;
  final int? referensiTransaksiId; // ID transaksi terkait (Servis, Penjualan, Pembelian)
  final String? tipeReferensi; // 'Servis', 'Penjualan', 'Pembelian'
  final double debit;
  final double kredit;
  final int akunId;

  const Jurnal({
    this.id,
    required this.tanggal,
    required this.deskripsi,
    this.referensiTransaksiId,
    this.tipeReferensi,
    required this.debit,
    required this.kredit,
    required this.akunId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal.toIso8601String(), // Simpan sebagai string ISO 8601
      'deskripsi': deskripsi,
      'referensi_transaksi_id': referensiTransaksiId,
      'tipe_referensi': tipeReferensi,
      'debit': debit,
      'kredit': kredit,
      'akun_id': akunId,
    };
  }

  factory Jurnal.fromMap(Map<String, dynamic> map) {
    return Jurnal(
      id: map['id'],
      tanggal: DateTime.parse(map['tanggal']),
      deskripsi: map['deskripsi'],
      referensiTransaksiId: map['referensi_transaksi_id'],
      tipeReferensi: map['tipe_referensi'],
      debit: map['debit'],
      kredit: map['kredit'],
      akunId: map['akun_id'],
    );
  }

  Jurnal copyWith({
    int? id,
    DateTime? tanggal,
    String? deskripsi,
    int? referensiTransaksiId,
    String? tipeReferensi,
    double? debit,
    double? kredit,
    int? akunId,
  }) {
    return Jurnal(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      deskripsi: deskripsi ?? this.deskripsi,
      referensiTransaksiId: referensiTransaksiId ?? this.referensiTransaksiId,
      tipeReferensi: tipeReferensi ?? this.tipeReferensi,
      debit: debit ?? this.debit,
      kredit: kredit ?? this.kredit,
      akunId: akunId ?? this.akunId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tanggal,
        deskripsi,
        referensiTransaksiId,
        tipeReferensi,
        debit,
        kredit,
        akunId,
      ]; // Properti yang digunakan untuk perbandingan Equatable

  @override
  String toString() {
    return 'Jurnal(id: $id, tanggal: $tanggal, deskripsi: $deskripsi, debit: $debit, kredit: $kredit, akunId: $akunId)';
  }
}
