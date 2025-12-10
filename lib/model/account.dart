import 'package:equatable/equatable.dart';

class Akun extends Equatable {
  final int? id;
  final String namaAkun;
  final String jenisAkun; // Contoh: 'Kas', 'Piutang', 'Persediaan', 'Pendapatan Servis', 'Beban Pembelian', 'Modal'

  const Akun({
    this.id,
    required this.namaAkun,
    required this.jenisAkun,
  });

  // Mengonversi objek Akun menjadi Map untuk disimpan ke database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_akun': namaAkun,
      'jenis_akun': jenisAkun,
    };
  }

  // Membuat objek Akun dari Map yang diambil dari database
  factory Akun.fromMap(Map<String, dynamic> map) {
    return Akun(
      id: map['id'],
      namaAkun: map['nama_akun'],
      jenisAkun: map['jenis_akun'],
    );
  }

  // Membuat salinan objek Akun dengan properti yang diubah
  Akun copyWith({
    int? id,
    String? namaAkun,
    String? jenisAkun,
  }) {
    return Akun(
      id: id ?? this.id,
      namaAkun: namaAkun ?? this.namaAkun,
      jenisAkun: jenisAkun ?? this.jenisAkun,
    );
  }

  @override
  List<Object?> get props => [id, namaAkun, jenisAkun];

  @override
  String toString() {
    return 'Akun(id: $id, namaAkun: $namaAkun, jenisAkun: $jenisAkun)';
  }
}
